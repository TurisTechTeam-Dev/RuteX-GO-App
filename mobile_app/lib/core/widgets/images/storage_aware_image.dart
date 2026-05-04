/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import 'storage_network_image.dart';

class StorageAwareImage extends StatelessWidget {
  final String? source;
  final List<String> alternateSources;
  final BoxFit fit;
  final Widget fallback;
  final Widget? placeholder;
  final double? width;
  final double? height;

  const StorageAwareImage({
    super.key,
    required this.source,
    this.alternateSources = const [],
    required this.fallback,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedSource = source?.trim() ?? '';
    final normalizedAlternates = alternateSources
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    final assetFallbackSource = _firstAssetPath([
      normalizedSource,
      ...normalizedAlternates,
    ]);

    if (normalizedSource.isEmpty && normalizedAlternates.isEmpty) {
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
      future: StorageImageUrlCache.resolveAny([
        normalizedSource,
        ...normalizedAlternates,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ?? const _DefaultLoadingState();
        }

        final resolvedUrl = snapshot.data;
        if (resolvedUrl == null || resolvedUrl.isEmpty) {
          return assetFallbackSource == null
              ? fallback
              : Image.asset(
                  assetFallbackSource,
                  width: width,
                  height: height,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) => fallback,
                );
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

  String? _firstAssetPath(List<String> values) {
    for (final value in values) {
      if (_isAssetPath(value)) return value;
    }

    return null;
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
    return buildResolvedStorageNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ?? const _DefaultLoadingState(),
      fallback: fallback,
    );
  }
}

class StorageImageUrlCache {
  static final Map<String, Future<String?>> _pending = {};
  static final Map<String, String?> _resolved = {};

  static Future<String?> resolveAny(List<String> values) async {
    for (final value in values) {
      final normalizedValue = value.trim();
      if (normalizedValue.isEmpty) continue;

      final resolvedUrl = await resolve(normalizedValue);
      if (resolvedUrl != null && resolvedUrl.isNotEmpty) return resolvedUrl;
    }

    return null;
  }

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

      for (final candidate in candidates) {
        try {
          final resolvedUrl = await _downloadUrlForCandidate(candidate);

          _resolved[value] = resolvedUrl;
          return resolvedUrl;
        } catch (error) {
          continue;
        }
      }

      _resolved[value] = null;
      return null;
    } finally {
      _pending.remove(value);
    }
  }

  static List<String> _storagePathCandidates(String rawValue) {
    final normalizedValues = _decodedStorageValues(rawValue);
    final candidates = <String>[];
    final bucket = Firebase.app().options.storageBucket;

    for (final rawCandidate in normalizedValues) {
      final value = rawCandidate.trim().replaceAll(RegExp(r'^/+'), '');
      if (value.isEmpty || value.startsWith('gs://')) {
        candidates.add(value);
        continue;
      }

      if (value.contains('/')) {
        candidates.addAll(_withImageExtensionFallbacks(value));
        candidates.addAll(_withImageExtensionFallbacks(_swapInterestAccent(value)));
        candidates.addAll(_withImageExtensionFallbacks(_titleCaseFileName(value)));
        continue;
      }

      final baseCandidates = [
        value,
        _titleCaseFileName(value),
        'Contenido/Ciudades/$value',
        'Contenido/Ciudades/${_titleCaseFileName(value)}',
        'Contenido/Rutas/$value',
        'Contenido/Rutas/${_titleCaseFileName(value)}',
        'Contenido/Puntos de Interes/$value',
        'Contenido/Puntos de Interes/${_titleCaseFileName(value)}',
        'Contenido/Puntos de Inter\u00E9s/$value',
        'Contenido/Puntos de Inter\u00E9s/${_titleCaseFileName(value)}',
      ];

      candidates.addAll(baseCandidates.expand(_withImageExtensionFallbacks));
    }

    final expandedCandidates = <String>[];
    for (final candidate in candidates) {
      if (candidate.isEmpty) continue;
      expandedCandidates.add(candidate);
      if (bucket != null &&
          bucket.isNotEmpty &&
          !candidate.startsWith('gs://') &&
          !_isAssetCandidate(candidate)) {
        expandedCandidates.add('gs://$bucket/$candidate');
      }
    }

    return expandedCandidates.toSet().toList();
  }

  static Future<String> _downloadUrlForCandidate(String candidate) {
    if (candidate.startsWith('gs://')) {
      return FirebaseStorage.instance.refFromURL(candidate).getDownloadURL();
    }

    return FirebaseStorage.instance.ref(candidate).getDownloadURL();
  }

  static bool _isAssetCandidate(String value) {
    return value.startsWith('assets/');
  }

  static List<String> _decodedStorageValues(String rawValue) {
    final values = <String>{rawValue.trim()};

    for (final decoder in [Uri.decodeFull, Uri.decodeComponent]) {
      try {
        values.add(decoder(rawValue.trim()));
      } catch (_) {
        // Keep the original value when it is not valid URI-encoded text.
      }
    }

    return values.toList();
  }

  static String _swapInterestAccent(String value) {
    if (value.contains('Puntos de Inter\u00E9s')) {
      return value.replaceAll('Puntos de Inter\u00E9s', 'Puntos de Interes');
    }

    return value.replaceAll('Puntos de Interes', 'Puntos de Inter\u00E9s');
  }

  static String _titleCaseFileName(String value) {
    final slashIndex = value.lastIndexOf('/');
    final prefix = slashIndex == -1 ? '' : '${value.substring(0, slashIndex)}/';
    final fileName = slashIndex == -1 ? value : value.substring(slashIndex + 1);
    if (fileName.isEmpty) return value;

    final dotIndex = fileName.lastIndexOf('.');
    final stem = dotIndex == -1 ? fileName : fileName.substring(0, dotIndex);
    final extension = dotIndex == -1 ? '' : fileName.substring(dotIndex);

    final titledStem = stem
        .split(RegExp(r'([ _-])'))
        .map((part) {
          if (part.isEmpty || RegExp(r'^[ _-]$').hasMatch(part)) return part;
          return part[0].toUpperCase() + part.substring(1);
        })
        .join();

    return '$prefix$titledStem$extension';
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
