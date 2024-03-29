
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:octo_image/octo_image.dart';

import 'm_image_provider.dart';

typedef ImageWidgetBuilder = Widget Function(
  BuildContext context,
  ImageProvider imageProvider,
);

typedef PlaceholderWidgetBuilder = Widget Function(
  BuildContext context,
  String url,
);

typedef ProgressIndicatorBuilder = Widget Function(
  BuildContext context,
  String url,
  DownloadProgress progress,
);

typedef LoadingErrorWidgetBuilder = Widget Function(
  BuildContext context,
  String url,
  Object error,
);

class MCachedNetworkImage extends StatelessWidget {
  MCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.httpHeaders,
    this.imageBuilder,
    this.placeholder,
    this.progressIndicatorBuilder,
    this.errorWidget,
    this.fadeOutDuration = const Duration(milliseconds: 1000),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.fadeInCurve = Curves.easeIn,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.cacheManager,
    this.useOldImageOnUrlChange = false,
    this.color,
    this.filterQuality = FilterQuality.low,
    this.colorBlendMode,
    this.placeholderFadeInDuration,
    this.memCacheWidth,
    this.memCacheHeight,
    this.cacheKey,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.errorListener,
    MImageRenderMethodForWeb imageRenderMethodForWeb = MImageRenderMethodForWeb.HtmlImage,
  }) : _image = MImageProvider(
          imageUrl,
          headers: httpHeaders,
          cacheManager: cacheManager,
          cacheKey: cacheKey,
          imageRenderMethodForWeb: imageRenderMethodForWeb,
          maxWidth: maxWidthDiskCache,
          maxHeight: maxHeightDiskCache,
          errorListener: errorListener,
        );

  final Alignment alignment;
  final String? cacheKey;
  final BaseCacheManager? cacheManager;
  final Color? color;
  final BlendMode? colorBlendMode;
  final MErrorListener? errorListener;
  final LoadingErrorWidgetBuilder? errorWidget;
  final Curve fadeInCurve;
  final Duration fadeInDuration;
  final Curve fadeOutCurve;
  final Duration? fadeOutDuration;
  final FilterQuality filterQuality;
  final BoxFit? fit;
  final double? height;
  final Map<String, String>? httpHeaders;
  final ImageWidgetBuilder? imageBuilder;
  final String imageUrl;
  final bool matchTextDirection;
  final int? maxHeightDiskCache;
  final int? maxWidthDiskCache;
  final int? memCacheHeight;
  final int? memCacheWidth;
  final PlaceholderWidgetBuilder? placeholder;
  final Duration? placeholderFadeInDuration;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final ImageRepeat repeat;
  final bool useOldImageOnUrlChange;
  final double? width;

  final MImageProvider _image;

  MImageProvider get image => _image;
  static CacheManagerLogLevel get logLevel => CacheManager.logLevel;

  static Future<bool> evictFromCache(
    String url, {
    String? cacheKey,
    BaseCacheManager? cacheManager,
    double scale = 1,
  }) async {
    final effectiveCacheManager = cacheManager ?? DefaultCacheManager();
    await effectiveCacheManager.removeFile(cacheKey ?? url);
    return MImageProvider(url, scale: scale).evict();
  }

  static set logLevel(CacheManagerLogLevel level) => CacheManager.logLevel = level;

  Widget _octoErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return errorWidget!(context, imageUrl, error);
  }

  Widget _octoImageBuilder(BuildContext context, Widget child) {
    return imageBuilder!(context, _image);
  }

  Widget _octoPlaceholderBuilder(BuildContext context) {
    return placeholder!(context, imageUrl);
  }

  Widget _octoProgressIndicatorBuilder(
    BuildContext context,
    ImageChunkEvent? progress,
  ) {
    int? totalSize;
    var downloaded = 0;
    if (progress != null) {
      totalSize = progress.expectedTotalBytes;
      downloaded = progress.cumulativeBytesLoaded;
    }
    return progressIndicatorBuilder!(
      context,
      imageUrl,
      DownloadProgress(imageUrl, totalSize, downloaded),
    );
  }

  @override
  Widget build(BuildContext context) {
    var octoPlaceholderBuilder = placeholder != null ? _octoPlaceholderBuilder : null;
    final octoProgressIndicatorBuilder = progressIndicatorBuilder != null ? _octoProgressIndicatorBuilder : null;

    if (octoPlaceholderBuilder == null && octoProgressIndicatorBuilder == null) {
      octoPlaceholderBuilder = (context) => Container();
    }

    return OctoImage(
      image: _image,
      imageBuilder: imageBuilder != null ? _octoImageBuilder : null,
      placeholderBuilder: octoPlaceholderBuilder,
      progressIndicatorBuilder: octoProgressIndicatorBuilder,
      errorBuilder: errorWidget != null ? _octoErrorBuilder : null,
      fadeOutDuration: fadeOutDuration,
      fadeOutCurve: fadeOutCurve,
      fadeInDuration: fadeInDuration,
      fadeInCurve: fadeInCurve,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      color: color,
      filterQuality: filterQuality,
      colorBlendMode: colorBlendMode,
      placeholderFadeInDuration: placeholderFadeInDuration,
      gaplessPlayback: useOldImageOnUrlChange,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
    );
  }
}
