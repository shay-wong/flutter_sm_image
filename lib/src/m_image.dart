import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:octo_image/octo_image.dart';
import 'package:sm_logger/sm_logger.dart';

import '../generated/assets.gen.dart';
import 'm_cached_netwrok_image.dart';
import 'm_image_provider.dart';

typedef MErrorWidget = Widget Function(
  BuildContext context,
  String url,
  Object error,
);

enum MImageClipMode {
  none,
  rectangle,
  circle,
  oval,
}

class MImage extends StatelessWidget {
  const MImage(
    this.source, {
    super.key,
    this.color,
    this.fit,
    double? height,
    this.placeholder,
    this.progressIndicatorBuilder,
    this.showIndicator = true,
    double? width,
    double? size,
    this.borderRadius,
    this.raduis,
    this.clipMode = MImageClipMode.rectangle,
    this.scale,
    this.package,
    this.bundle,
    this.errorWidget,
    this.httpHeaders,
    this.imageBuilder,
    this.fadeOutDuration = const Duration(milliseconds: 1000),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.fadeInCurve = Curves.easeIn,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.cacheManager,
    this.useOldImageOnUrlChange = false,
    this.filterQuality = FilterQuality.low,
    this.colorBlendMode,
    this.placeholderFadeInDuration,
    this.memCacheWidth,
    this.memCacheHeight,
    this.cacheKey,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.errorListener,
    this.onTap,
    this.imageRenderMethodForWeb = MImageRenderMethodForWeb.HtmlImage,
  })  : assert(placeholder == null || progressIndicatorBuilder == null),
        width = width ?? size,
        height = height ?? size;

  final Alignment alignment;
  final BorderRadiusGeometry? borderRadius;
  final AssetBundle? bundle;
  final String? cacheKey;
  final BaseCacheManager? cacheManager;
  final MImageClipMode clipMode;
  final Color? color;
  final BlendMode? colorBlendMode;
  final MErrorListener? errorListener;
  final MErrorWidget? errorWidget;
  final Curve fadeInCurve;
  final Duration fadeInDuration;
  final Curve fadeOutCurve;
  final Duration? fadeOutDuration;
  final FilterQuality filterQuality;
  final BoxFit? fit;
  final double? height;
  final Map<String, String>? httpHeaders;
  final ImageWidgetBuilder? imageBuilder;
  final MImageRenderMethodForWeb imageRenderMethodForWeb;
  final bool matchTextDirection;
  final int? maxHeightDiskCache;
  final int? maxWidthDiskCache;
  final int? memCacheHeight;
  final int? memCacheWidth;
  final String? package;
  final PlaceholderWidgetBuilder? placeholder;
  final Duration? placeholderFadeInDuration;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final double? raduis;
  final ImageRepeat repeat;
  final double? scale;
  final bool showIndicator;
  final String? source;
  final bool useOldImageOnUrlChange;
  final double? width;
  final VoidCallback? onTap;

  @protected
  Widget get _errorImage {
    return Image(
      image: _errorImageProvider,
      width: width,
      height: height,
      fit: fit,
      color: color,
    );
  }

  @protected
  static ImageProvider get _errorImageProvider => Assets.imgFail.provider();

  @protected
  Widget get _placeholderImage {
    return Icon(
      Icons.image,
      size: width ?? height,
      color: color,
    );
  }

  @protected
  Widget get _placeholderIndicator {
    return LoadingAnimationWidget.beat(
      color: Colors.white,
      size: 20,
    );
  }

  ImageProvider get image {
    return provider(
      source,
      httpHeaders: httpHeaders,
      errorListener: errorListener,
      package: package,
      bundle: bundle,
      scale: scale,
      cacheManager: cacheManager,
      cacheKey: cacheKey,
      imageRenderMethodForWeb: imageRenderMethodForWeb,
    );
  }

  static ImageProvider provider(
    String? source, {
    String? placeholder,
    ImageProvider? placeholderImage,
    int? maxWidth,
    int? maxHeight,
    Map<String, String>? httpHeaders,
    MErrorListener? errorListener,
    String? package,
    AssetBundle? bundle,
    double? scale,
    BaseCacheManager? cacheManager,
    String? cacheKey,
    MImageRenderMethodForWeb imageRenderMethodForWeb = MImageRenderMethodForWeb.HtmlImage,
  }) {
    if (source != null && source.isNotEmpty) {
      final uri = Uri.tryParse(source);
      if (uri != null && uri.hasScheme) {
        return MImageProvider(
          source,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          headers: httpHeaders ?? {'Cache-Control': 'max-age=2592000'},
          errorListener: errorListener,
          scale: scale ?? 1.0,
          cacheKey: cacheKey,
          imageRenderMethodForWeb: imageRenderMethodForWeb,
          cacheManager: cacheManager,
        );
      }
      return _assetImage(source, scale, bundle, package);
    }
    if (placeholderImage != null) return placeholderImage;
    if (placeholder != null && placeholder.isNotEmpty) {
      return _assetImage(placeholder, scale, bundle, package);
    }
    return _errorImageProvider;
  }

  @protected
  static ImageProvider _assetImage(
    String source,
    double? scale,
    AssetBundle? bundle,
    String? package,
  ) {
    return scale != null
        ? ExactAssetImage(source, bundle: bundle, scale: scale, package: package)
        : AssetImage(source, bundle: bundle, package: package);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (source != null && source!.isNotEmpty == true) {
      final uri = Uri.tryParse(source!);
      if (uri != null && uri.hasScheme) {
        child = MCachedNetworkImage(
          imageUrl: source!,
          width: width,
          height: height,
          fit: fit,
          color: color,
          progressIndicatorBuilder: progressIndicatorBuilder ??
              ((placeholder == null && showIndicator) ? (ctx, url, progress) => _placeholderIndicator : null),
          placeholder: placeholder ??
              ((progressIndicatorBuilder == null && !showIndicator) ? (ctx, url) => _placeholderImage : null),
          errorWidget: errorWidget ??
              (ctx, url, e) {
                logger.e(e);
                return _errorImage;
              },
          httpHeaders: httpHeaders,
          imageBuilder: imageBuilder,
          fadeOutDuration: fadeOutDuration,
          fadeOutCurve: fadeOutCurve,
          fadeInDuration: fadeInDuration,
          fadeInCurve: fadeInCurve,
          alignment: alignment,
          repeat: repeat,
          matchTextDirection: matchTextDirection,
          cacheManager: cacheManager,
          useOldImageOnUrlChange: useOldImageOnUrlChange,
          filterQuality: filterQuality,
          colorBlendMode: colorBlendMode,
          placeholderFadeInDuration: placeholderFadeInDuration,
          memCacheWidth: memCacheWidth,
          memCacheHeight: memCacheHeight,
          cacheKey: cacheKey,
          maxWidthDiskCache: maxWidthDiskCache,
          maxHeightDiskCache: maxHeightDiskCache,
          errorListener: errorListener,
          imageRenderMethodForWeb: imageRenderMethodForWeb,
        );
      } else {
        child = OctoImage(
          image: _assetImage(source!, scale, bundle, package),
          width: width,
          height: height,
          fit: fit,
          color: color,
          progressIndicatorBuilder: progressIndicatorBuilder != null || (placeholder == null && showIndicator)
              ? (context, progress) {
                  int? totalSize;
                  var downloaded = 0;
                  if (progress != null) {
                    totalSize = progress.expectedTotalBytes;
                    downloaded = progress.cumulativeBytesLoaded;
                  }
                  return progressIndicatorBuilder?.call(
                        context,
                        source!,
                        DownloadProgress(
                          source!,
                          totalSize,
                          downloaded,
                        ),
                      ) ??
                      _placeholderIndicator;
                }
              : null,
          placeholderBuilder: placeholder != null || (progressIndicatorBuilder == null && !showIndicator)
              ? (ctx) => _placeholderImage
              : null,
          errorBuilder: (ctx, obj, trace) => errorWidget?.call(ctx, source!, obj) ?? _errorImage,
        );
      }
    } else {
      child = placeholder != null ? placeholder!(context, '') : _placeholderImage;
    }

    if (clipMode == MImageClipMode.circle || clipMode == MImageClipMode.oval) {
      child = ClipOval(
        child: child,
      );
    } else if (clipMode == MImageClipMode.rectangle && raduis != null) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(raduis!),
        child: child,
      );
    }

    if (onTap != null) {
      child = GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return child;
  }
}
