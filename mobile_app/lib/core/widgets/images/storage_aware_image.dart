import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class StorageAwareImage extends StatelessWidget {
  final String? source;
  final BoxFit fit;
  final Widget fallback;
  final Widget? placeholder;
  final double? width;
  final double? height;

  const StorageAwareImage({
    super.key,
    required this.source,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedSource = source?.trim() ?? '';

    if (normalizedSource.isEmpty) {
      return fallback;
    }

    if (_isAssetPath(normalizedSource)) {
      return Image.asset(
        normalizedSource,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    if (_isHttpUrl(normalizedSource)) {
      return _CachedStorageImage(
        imageUrl: normalizedSource,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        fallback: fallback,
      );
    }

    return FutureBuilder<String?>(
      future: StorageImageUrlCache.resolve(normalizedSource),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ?? const _DefaultLoadingState();
        }

        final resolvedUrl = snapshot.data;
        if (resolvedUrl == null || resolvedUrl.isEmpty) {
          return fallback;
        }

        return _CachedStorageImage(
          imageUrl: resolvedUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: placeholder,
          fallback: fallback,
        );
      },
    );
  }

  bool _isAssetPath(String value) {
    return value.startsWith('assets/');
  }

  bool _isHttpUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }
}

class _CachedStorageImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget fallback;
  final Widget? placeholder;
  final double? width;
  final double? height;

  const _CachedStorageImage({
    required this.imageUrl,
    required this.fallback,
    required this.fit,
    this.placeholder,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? const _DefaultLoadingState(),
      errorWidget: (context, url, error) => fallback,
    );
  }
}

class StorageImageUrlCache {
  static final Map<String, Future<String?>> _pending = {};
  static final Map<String, String?> _resolved = {};

  static Future<String?> resolve(String value) {
    if (_resolved.containsKey(value)) {
      return Future.value(_resolved[value]);
    }

    final pending = _pending[value];
    if (pending != null) return pending;

    final future = _resolveInternal(value);
    _pending[value] = future;
    return future;
  }

  static Future<String?> _resolveInternal(String value) async {
    try {
      final candidates = _storagePathCandidates(value);
      debugPrint('Storage preview source: "$value"');
      debugPrint('Storage preview candidates: $candidates');

      for (final candidate in candidates) {
        try {
          final resolvedUrl = candidate.startsWith('gs://')
              ? await FirebaseStorage.instance
                    .refFromURL(candidate)
                    .getDownloadURL()
              : await FirebaseStorage.instance.ref(candidate).getDownloadURL();

          _resolved[value] = resolvedUrl;
          debugPrint('Storage preview resolved: "$candidate"');
          return resolvedUrl;
        } catch (error) {
          debugPrint('Storage preview failed for "$candidate": $error');
          continue;
        }
      }

      debugPrint('Storage preview unresolved for "$value"');
      _resolved[value] = null;
      return null;
    } finally {
      _pending.remove(value);
    }
  }

  static List<String> _storagePathCandidates(String rawValue) {
    final value = rawValue.trim().replaceAll(RegExp(r'^/+'), '');
    if (value.isEmpty || value.startsWith('gs://')) {
      return [value];
    }

    if (value.contains('/')) {
      return _withImageExtensionFallbacks(value);
    }

    final baseCandidates = [
      value,
      'Contenido/Ciudades/$value',
      'Contenido/Rutas/$value',
      'Contenido/Puntos de Interes/$value',
      'Contenido/Puntos de Inter\u00E9s/$value',
    ];

    return baseCandidates.expand(_withImageExtensionFallbacks).toSet().toList();
  }

  static List<String> _withImageExtensionFallbacks(String path) {
    final dotIndex = path.lastIndexOf('.');
    final slashIndex = path.lastIndexOf('/');
    final hasExtension = dotIndex > slashIndex;

    if (!hasExtension) {
      return [path, '$path.jpg', '$path.jpeg', '$path.png', '$path.webp'];
    }

    final basePath = path.substring(0, dotIndex);
    return [
      path,
      '$basePath.jpg',
      '$basePath.jpeg',
      '$basePath.png',
      '$basePath.webp',
    ];
  }
}

class _DefaultLoadingState extends StatelessWidget {
  const _DefaultLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blancoTarjeta,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
