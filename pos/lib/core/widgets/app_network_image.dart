import 'package:flutter/material.dart';

import '../utils/media_url.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isCircle = false,
    this.backgroundColor,
    this.fallbackIcon = Icons.image_not_supported,
    this.iconSize,
    this.iconColor,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final Color? backgroundColor;
  final IconData fallbackIcon;
  final double? iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBg =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceVariant;
    final effectiveIconColor =
        iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant;

    Widget placeholder() {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: effectiveBg,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : borderRadius,
        ),
        alignment: Alignment.center,
        child: Icon(
          fallbackIcon,
          size: iconSize,
          color: effectiveIconColor,
        ),
      );
    }

    final normalizedUrl = normalizeMediaUrl(url) ?? url;
    if (normalizedUrl == null || normalizedUrl.trim().isEmpty) {
      return placeholder();
    }

    final image = Image.network(
      normalizedUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return placeholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return placeholder();
      },
    );

    Widget result = image;
    if (isCircle) {
      result = ClipOval(child: image);
    } else if (borderRadius != null) {
      result = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    if (width != null || height != null) {
      result = SizedBox(width: width, height: height, child: result);
    }

    return result;
  }
}
