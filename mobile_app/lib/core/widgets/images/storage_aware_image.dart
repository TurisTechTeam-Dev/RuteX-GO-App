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
      return CachedNetworkImage(
        imageUrl: normalizedSource,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ?? const _DefaultLoadingState(),
        errorWidget: (context, url, error) => fallback,
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

        return CachedNetworkImage(
          imageUrl: resolvedUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) =>
              placeholder ?? const _DefaultLoadingState(),
          errorWidget: (context, url, error) => fallback,
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
      final resolved = value.startsWith('gs://')
          ? await FirebaseStorage.instance.refFromURL(value).getDownloadURL()
          : await FirebaseStorage.instance.ref(value).getDownloadURL();
      _resolved[value] = resolved;
      return resolved;
    } catch (_) {
      _resolved[value] = null;
      return null;
    } finally {
      _pending.remove(value);
    }
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
