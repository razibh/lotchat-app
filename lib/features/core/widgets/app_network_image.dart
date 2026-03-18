import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart'; // DiagnosticPropertiesBuilder এর জন্য

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const AppNetworkImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        width: width,
        height: height,
        color: backgroundColor ?? Colors.grey.shade200,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (BuildContext context, String url) => placeholder ??
              Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
          errorWidget: (BuildContext context, String url, Object error) => errorWidget ??
              Container(
                color: Colors.grey.shade300,
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey.shade600,
                    size: 30,
                  ),
                ),
              ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('imageUrl', imageUrl));
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
    properties.add(EnumProperty<BoxFit>('fit', fit));
    properties.add(DiagnosticsProperty<BorderRadius?>('borderRadius', borderRadius));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
  }
}

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final bool isOnline;

  const AppAvatar({
    this.imageUrl,
    this.name,
    this.radius = 20,
    this.isOnline = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: imageUrl != null
              ? CachedNetworkImageProvider(imageUrl!)
              : null,
          backgroundColor: Colors.grey.shade300,
          child: imageUrl == null && name != null
              ? Text(
            name![0].toUpperCase(),
            style: TextStyle(
              fontSize: radius * 0.6,
              fontWeight: FontWeight.bold,
            ),
          )
              : null,
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('imageUrl', imageUrl));
    properties.add(StringProperty('name', name));
    properties.add(DoubleProperty('radius', radius));
    properties.add(DiagnosticsProperty<bool>('isOnline', isOnline));
  }
}

class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Duration fadeInDuration;
  final bool memCacheHeight;
  final bool memCacheWidth;

  const AppCachedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.memCacheHeight = false,
    this.memCacheWidth = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      memCacheHeight: memCacheHeight ? height?.toInt() : null,
      memCacheWidth: memCacheWidth ? width?.toInt() : null,
      placeholder: (BuildContext context, String url) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (BuildContext context, String url, Object error) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.error, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('imageUrl', imageUrl));
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
    properties.add(EnumProperty<BoxFit>('fit', fit));
    properties.add(DiagnosticsProperty<Duration>('fadeInDuration', fadeInDuration));
    properties.add(DiagnosticsProperty<bool>('memCacheHeight', memCacheHeight));
    properties.add(DiagnosticsProperty<bool>('memCacheWidth', memCacheWidth));
  }
}