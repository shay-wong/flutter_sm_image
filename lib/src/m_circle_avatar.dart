import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../sm_image.dart';
import 'generated/assets.gen.dart';

typedef MImageErrorProviderBuilder = ImageProvider Function(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
);

class MCircleAvatar extends StatefulWidget {
  const MCircleAvatar({
    super.key,
    this.source,
    this.foregroundSource,
    this.child,
    this.backgroundColor,
    this.backgroundImage,
    this.foregroundImage,
    this.onBackgroundImageErrorBuilder,
    this.onForegroundImageErrorBuilder,
    this.foregroundColor,
    double? radius,
    this.minRadius,
    this.maxRadius,
    this.placeholder,
    this.foregroundPlaceholder,
    this.onTap,
    this.package,
    this.bundle,
    double? diameter,
    this.fit,
    this.errorFit,
  })  : assert(radius == null || diameter == null || (minRadius == null && maxRadius == null)),
        assert(source != null || backgroundImage != null || onBackgroundImageErrorBuilder == null),
        assert(foregroundImage != null || onForegroundImageErrorBuilder == null),
        diameter = diameter ?? (radius != null ? radius * 2.0 : null);

  final Color? backgroundColor;
  final ImageProvider? backgroundImage;
  final AssetBundle? bundle;
  final Widget? child;
  final double? diameter;
  final BoxFit? fit;
  final BoxFit? errorFit;
  final Color? foregroundColor;
  final ImageProvider? foregroundImage;
  final double? maxRadius;
  final double? minRadius;
  final MImageErrorProviderBuilder? onBackgroundImageErrorBuilder;
  final MImageErrorProviderBuilder? onForegroundImageErrorBuilder;
  final VoidCallback? onTap;
  final String? package;
  final String? placeholder;
  final String? foregroundPlaceholder;
  final String? source;
  final String? foregroundSource;

  // The default max if only the min is specified.
  static const double _defaultMaxRadius = double.infinity;

  // The default min if only the max is specified.
  static const double _defaultMinRadius = 0.0;

  // The default radius if nothing is specified.
  static const double _defaultRadius = 20.0;

  @override
  State<MCircleAvatar> createState() => _MCircleAvatarState();
}

class _MCircleAvatarState extends State<MCircleAvatar> {
  Object? _lastException;
  StackTrace? _lastStack;

  DecorationImage? _effectiveDecorationImage({
    required BuildContext context,
    ImageProvider? image,
    String? source,
    String? placeholder,
    ImageProvider? defaultProvider,
  }) {
    ImageProvider? effectiveImage;
    BoxFit? fit = widget.fit ?? BoxFit.cover;
    if (_lastException != null) {
      effectiveImage =
          widget.onBackgroundImageErrorBuilder?.call(context, _lastException!, _lastStack) ?? Assets.imgFail.provider();
      fit = widget.errorFit;
    } else {
      effectiveImage = image ??
          (source != null || placeholder != null
              ? MImage.provider(
                  source ?? placeholder,
                  package: widget.package,
                  bundle: widget.bundle,
                )
              : defaultProvider);
      if (source != null && source.isEmpty == true) {
        fit = widget.errorFit;
      }
    }

    return effectiveImage != null
        ? DecorationImage(
            image: effectiveImage,
            onError: _handleError(widget.onBackgroundImageErrorBuilder),
            fit: fit,
          )
        : null;
  }

  double get _maxDiameter {
    if (widget.diameter == null && widget.minRadius == null && widget.maxRadius == null) {
      return MCircleAvatar._defaultRadius * 2.0;
    }
    return widget.diameter ?? 2.0 * (widget.maxRadius ?? MCircleAvatar._defaultMaxRadius);
  }

  double get _minDiameter {
    if (widget.diameter == null && widget.minRadius == null && widget.maxRadius == null) {
      return MCircleAvatar._defaultRadius * 2.0;
    }
    return widget.diameter ?? 2.0 * (widget.minRadius ?? MCircleAvatar._defaultMinRadius);
  }

  ImageErrorListener? _handleError(MImageErrorProviderBuilder? builder) {
    _lastException = null;
    _lastStack = null;
    return builder != null || kDebugMode
        ? (Object error, StackTrace? stackTrace) {
            setState(() {
              _lastException = error;
              _lastStack = stackTrace;
            });
            assert(() {
              if (builder == null) {
                // ignore: only_throw_errors, since we're just proxying the error.
                throw error; // Ensures the error message is printed to the console.
              }
              return true;
            }());
          }
        : null;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final ThemeData theme = Theme.of(context);
    final Color? effectiveForegroundColor =
        widget.foregroundColor ?? (theme.useMaterial3 ? theme.colorScheme.onPrimaryContainer : null);
    final TextStyle effectiveTextStyle =
        theme.useMaterial3 ? theme.textTheme.titleMedium! : theme.primaryTextTheme.titleMedium!;
    TextStyle textStyle = effectiveTextStyle.copyWith(color: effectiveForegroundColor);
    Color? effectiveBackgroundColor =
        widget.backgroundColor ?? (theme.useMaterial3 ? theme.colorScheme.primaryContainer : null);
    if (effectiveBackgroundColor == null) {
      switch (ThemeData.estimateBrightnessForColor(textStyle.color!)) {
        case Brightness.dark:
          effectiveBackgroundColor = theme.primaryColorLight;
        case Brightness.light:
          effectiveBackgroundColor = theme.primaryColorDark;
      }
    } else if (effectiveForegroundColor == null) {
      switch (ThemeData.estimateBrightnessForColor(widget.backgroundColor!)) {
        case Brightness.dark:
          textStyle = textStyle.copyWith(color: theme.primaryColorLight);
        case Brightness.light:
          textStyle = textStyle.copyWith(color: theme.primaryColorDark);
      }
    }
    final double minDiameter = _minDiameter;
    final double maxDiameter = _maxDiameter;
    Widget effectiveChild = AnimatedContainer(
      constraints: BoxConstraints(
        minHeight: minDiameter,
        minWidth: minDiameter,
        maxWidth: maxDiameter,
        maxHeight: maxDiameter,
      ),
      duration: kThemeChangeDuration,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        image: _effectiveDecorationImage(
          context: context,
          image: widget.backgroundImage,
          source: widget.source,
          placeholder: widget.placeholder,
          defaultProvider: Assets.avatar.provider(bundle: widget.bundle),
        ),
        shape: BoxShape.circle,
      ),
      foregroundDecoration:
          widget.foregroundImage != null || widget.foregroundSource != null || widget.foregroundPlaceholder != null
              ? BoxDecoration(
                  image: _effectiveDecorationImage(
                    context: context,
                    image: widget.foregroundImage,
                    source: widget.foregroundSource,
                    placeholder: widget.foregroundPlaceholder,
                  ),
                  shape: BoxShape.circle,
                )
              : null,
      child: widget.child == null
          ? null
          : Center(
              // Need to disable text scaling here so that the text doesn't
              // escape the avatar when the textScaleFactor is large.
              child: MediaQuery.withNoTextScaling(
                child: IconTheme(
                  data: theme.iconTheme.copyWith(color: textStyle.color),
                  child: DefaultTextStyle(
                    style: textStyle,
                    child: widget.child!,
                  ),
                ),
              ),
            ),
    );

    if (widget.onTap != null) {
      effectiveChild = InkWell(
        onTap: widget.onTap,
        child: effectiveChild,
      );
    }
    return effectiveChild;
  }
}
