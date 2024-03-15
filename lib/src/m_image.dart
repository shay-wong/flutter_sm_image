import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_sm_logger/sm_logger.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'm_cached_netwrok_image.dart';
import 'm_image_provider.dart';

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
    this.scale,
    this.package,
    this.bundle,
  })  : assert(placeholder == null || progressIndicatorBuilder == null),
        width = width ?? size,
        height = height ?? size;

  final AssetBundle? bundle;
  final Color? color;
  final BoxFit? fit;
  final double? height;
  final String? package;
  final PlaceholderWidgetBuilder? placeholder;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final double? scale;
  final bool showIndicator;
  final String? source;
  final double? width;

  @protected
  static const ImageProvider _errorImageProvider = AssetImage(
    'assets/images/icons/img_fail.png',
    package: 'flutter_sm_image',
  );

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

  static ImageProvider provider(
    String? source, {
    String? placeholder,
    ImageProvider? placeholderImage,
    int? maxWidth,
    int? maxHeight,
    Map<String, String>? headers,
    void Function(Object)? errorListener,
    String? package,
    AssetBundle? bundle,
    double scale = 1.0,
    BaseCacheManager? cacheManager,
    String? cacheKey,
    ImageRenderMethodForWeb imageRenderMethodForWeb = ImageRenderMethodForWeb.HtmlImage,
  }) {
    if (source != null && source.isNotEmpty) {
      final uri = Uri.tryParse(source);
      if (uri != null && uri.hasScheme) {
        return MImageProvider(
          source,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          headers: headers ?? {'Cache-Control': 'max-age=2592000'},
          errorListener: errorListener,
          scale: scale,
          cacheKey: cacheKey,
          imageRenderMethodForWeb: imageRenderMethodForWeb,
          cacheManager: cacheManager,
        );
      }
      return AssetImage(
        source,
        package: package,
        bundle: bundle,
      );
    }
    if (placeholderImage != null) return placeholderImage;
    if (placeholder != null && placeholder.isNotEmpty) {
      return AssetImage(
        placeholder,
        package: package,
        bundle: bundle,
      );
    }
    return _errorImageProvider;
  }

  @override
  Widget build(BuildContext context) {
    if (source != null && source!.isNotEmpty == true) {
      final uri = Uri.tryParse(source!);
      if (uri != null && uri.hasScheme) {
        return MCachedNetworkImage(
          imageUrl: source!,
          width: width,
          height: height,
          fit: fit,
          color: color,
          progressIndicatorBuilder: progressIndicatorBuilder ??
              ((placeholder == null && showIndicator) ? (ctx, url, progress) => _placeholderIndicator : null),
          placeholder: placeholder ??
              ((progressIndicatorBuilder == null && !showIndicator) ? (ctx, url) => _placeholderImage : null),
          errorWidget: (ctx, url, e) {
            logger.e(e);
            return _errorImage;
          },
        );
      }
      // OPTIMIZE: loadingBuilder 和 frameBuilder
      return Image(
        image: scale != null
            ? ExactAssetImage(source!, bundle: bundle, scale: scale!, package: package)
            : AssetImage(source!, bundle: bundle, package: package),
        width: width,
        height: height,
        fit: fit,
        color: color,
        errorBuilder: (ctx, obj, trace) => _errorImage,
      );
    }
    return placeholder != null ? placeholder!(context, '') : _placeholderImage;
  }
}
