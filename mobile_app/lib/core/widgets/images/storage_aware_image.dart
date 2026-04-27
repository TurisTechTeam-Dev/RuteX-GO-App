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
      return Image.network(
        normalizedSource,
        width: width,
        height: height,
        fit: fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? const _DefaultLoadingState();
        },
        errorBuilder: (context, error, stackTrace) => fallback,
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

        return Image.network(
          resolvedUrl,
          width: width,
          height: height,
          fit: fit,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ?? const _DefaultLoadingState();
          },
          errorBuilder: (context, error, stackTrace) => fallback,
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

class StorageImageUrlCache {
  static final Map<String, Future<String?>> _pending = {};
  static final Map<String, String?> _resolved = {};

  static Future<String?> resolve(String value) {
    if (_resolved[value] != null) {
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
          final resolved = _withCacheBuster(resolvedUrl);
          _resolved[value] = resolved;
          debugPrint('Storage preview resolved: "$candidate"');
          return resolved;
        } catch (error) {
          debugPrint('Storage preview failed for "$candidate": $error');
          continue;
        }
      }

      debugPrint('Storage preview unresolved for "$value"');
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
      'Contenido/Puntos de Interés/$value',
    ];

    return baseCandidates.expand(_withImageExtensionFallbacks).toSet().toList();
  }

  static List<String> _withImageExtensionFallbacks(String path) {
    final dotIndex = path.lastIndexOf('.');
    final slashIndex = path.lastIndexOf('/');
    final hasExtension = dotIndex > slashIndex;

    if (!hasExtension) {
      return [
        path,
        '$path.jpg',
        '$path.jpeg',
        '$path.png',
        '$path.webp',
      ];
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

  static String _withCacheBuster(String url) {
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}preview=${DateTime.now().millisecondsSinceEpoch}';
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
