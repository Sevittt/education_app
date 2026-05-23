import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A reliable network image widget backed by [CachedNetworkImage].
///
/// - Automatically caches images on disk to avoid redundant network calls.
/// - Gracefully handles [SocketException] / timeout errors with a fallback UI.
/// - Wraps in [ClipRRect] for optional rounded corners.
class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Empty URL → render fallback immediately (no network call)
    if (imageUrl.isEmpty) {
      return _buildFallback(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        // Show a shimmer-style loading indicator
        placeholder: (context, url) =>
            placeholder ?? _buildLoadingShimmer(context),
        // On any network failure (timeout, 404, etc.) show fallback icon
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildFallback(context),
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary.withAlpha(128),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(128),
        size: (height ?? 48) * 0.4,
      ),
    );
  }
}
