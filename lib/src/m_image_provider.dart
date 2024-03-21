import 'dart:async';
import 'dart:ui' as ui show Codec;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart'
    if (dart.library.io) '_m_image_loader.dart'
    if (dart.library.html) 'm_image_provider_web.dart' show ImageLoader;
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart'
    show ImageRenderMethodForWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

typedef MErrorListener = void Function(Object exception, StackTrace? stackTrace);

enum MImageRenderMethodForWeb {
  HtmlImage, // ignore: constant_identifier_names
  HttpGet, // ignore: constant_identifier_names
}

class MImageProvider extends ImageProvider<MImageProvider> {
  const MImageProvider(
    this.url, {
    this.maxHeight,
    this.maxWidth,
    this.scale = 1.0,
    this.errorListener,
    this.headers,
    this.cacheManager,
    this.cacheKey,
    this.imageRenderMethodForWeb = MImageRenderMethodForWeb.HtmlImage,
  });

  final String? cacheKey;
  final BaseCacheManager? cacheManager;
  final MErrorListener? errorListener;
  final Map<String, String>? headers;
  final MImageRenderMethodForWeb imageRenderMethodForWeb;
  final int? maxHeight;
  final int? maxWidth;
  final double scale;
  final String url;

  @override
  bool operator ==(Object other) {
    if (other is MImageProvider) {
      return ((cacheKey ?? url) == (other.cacheKey ?? other.url)) &&
          scale == other.scale &&
          maxHeight == other.maxHeight &&
          maxWidth == other.maxWidth;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(cacheKey ?? url, scale, maxHeight, maxWidth);

  @override
  ImageStreamCompleter loadImage(MImageProvider key, ImageDecoderCallback decode) {
    final chunkEvents = StreamController<ImageChunkEvent>();
    final imageStreamCompleter = MultiImageStreamCompleter(
      codec: _loadImageAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>(
          'Image provider: $this \n Image key: $key',
          this,
          style: DiagnosticsTreeStyle.errorProperty,
        );
      },
    );

    if (errorListener != null) {
      imageStreamCompleter.addListener(
        ImageStreamListener(
          (image, synchronousCall) {},
          onError: (Object error, StackTrace? trace) {
            errorListener?.call(error, trace);
          },
        ),
      );
    }
    return imageStreamCompleter;
  }

  @override
  Future<MImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture<MImageProvider>(this);
  }

  @override
  String toString() => 'CachedNetworkImageProvider("$url", scale: $scale)';

  Stream<ui.Codec> _loadImageAsync(
    MImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
  ) {
    assert(key == this);
    return ImageLoader().loadImageAsync(
      url,
      cacheKey,
      chunkEvents,
      decode,
      cacheManager ?? DefaultCacheManager(),
      maxHeight,
      maxWidth,
      headers,
      ImageRenderMethodForWeb.values[imageRenderMethodForWeb.index],
      () => PaintingBinding.instance.imageCache.evict(key),
    );
  }
}
