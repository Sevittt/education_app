import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';

/// Kurslar ro'yxati yuklanayotganda ko'rinadigan shimmer skeleton.
class CourseListSkeleton extends StatelessWidget {
  final int itemCount;

  const CourseListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? AppColors.surfaceElevated : const Color(0xFFE8ECF4);
    final highlightColor = isDark ? AppColors.borderDark : const Color(0xFFF5F7FA);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: _SkeletonCard(),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.surfaceElevated : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail placeholder
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge row
                Row(
                  children: [
                    _Box(width: 72, height: 22),
                    const SizedBox(width: 8),
                    _Box(width: 56, height: 22),
                  ],
                ),
                const SizedBox(height: 12),
                // Title
                _Box(width: double.infinity, height: 16),
                const SizedBox(height: 6),
                _Box(width: 200, height: 16),
                const SizedBox(height: 12),
                // Description
                _Box(width: double.infinity, height: 12),
                const SizedBox(height: 4),
                _Box(width: 240, height: 12),
                const SizedBox(height: 16),
                // Status button
                _Box(width: 100, height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final double width;
  final double height;

  const _Box({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.borderDark : const Color(0xFFE0E4EF),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
