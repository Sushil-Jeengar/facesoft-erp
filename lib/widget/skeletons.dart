import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Simple shimmer wrapper for any child
class _ShimmerWrap extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerWrap({
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

/// A single skeleton card with only text lines and optional trailing action circles
class SkeletonCardTextOnly extends StatelessWidget {
  final int lines; // number of grey bars in the main column
  final bool showTrailingActions; // whether to show two small circular placeholders

  const SkeletonCardTextOnly({
    this.lines = 4,
    this.showTrailingActions = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bars = List<Widget>.generate(lines, (i) {
      final widths = [180.0, double.infinity, 140.0, 160.0, 140.0, 110.0];
      final width = (i < widths.length) ? widths[i] : double.infinity;
      return Padding(
        padding: EdgeInsets.only(bottom: i == lines - 1 ? 0 : (i == 0 ? 8 : 6)),
        child: Container(
          width: width,
          height: i == 0 ? 16 : 14,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    });

    return Card(
      elevation: 1,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _ShimmerWrap(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: bars,
                ),
              ),
              if (showTrailingActions) ...[
                const SizedBox(width: 12),
                Column(
                  children: const [
                    // two action circles
                    _CirclePlaceholder(),
                    SizedBox(height: 8),
                    _CirclePlaceholder(),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

/// A skeleton card with a leading avatar/thumbnail, text lines, and trailing actions
class SkeletonCardWithAvatar extends StatelessWidget {
  final double avatarSize;

  const SkeletonCardWithAvatar({
    this.avatarSize = 50,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _ShimmerWrap(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  color: Colors.black12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _Bar(width: 160, height: 16, bottom: 8),
                    _Bar(width: double.infinity, height: 14, bottom: 6),
                    _Bar(width: 140, height: 14, bottom: 6),
                    _Bar(width: 180, height: 14, bottom: 0),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: const [
                  _CirclePlaceholder(),
                  SizedBox(height: 8),
                  _CirclePlaceholder(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double width;
  final double height;
  final double bottom;
  const _Bar({required this.width, required this.height, this.bottom = 6, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _CirclePlaceholder extends StatelessWidget {
  const _CirclePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(color: Colors.black12, shape: BoxShape.circle),
    );
  }
}

enum SkeletonVariant { textOnly, avatarAndActions }

/// A generic skeleton list to quickly drop in place of ListView.builder
class SkeletonList extends StatelessWidget {
  final int count;
  final SkeletonVariant variant;
  final EdgeInsetsGeometry padding;

  const SkeletonList({
    this.count = 6,
    this.variant = SkeletonVariant.textOnly,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 80),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: count,
      itemBuilder: (context, index) {
        switch (variant) {
          case SkeletonVariant.avatarAndActions:
            return const SkeletonCardWithAvatar();
          case SkeletonVariant.textOnly:
          default:
            return const SkeletonCardTextOnly();
        }
      },
    );
  }
}