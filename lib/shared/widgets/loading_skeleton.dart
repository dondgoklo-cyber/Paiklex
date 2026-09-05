import 'package:flutter/material.dart';

/// A skeleton loader widget that mimics the appearance of content
/// Used as a placeholder during loading states
class LoadingSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const LoadingSkeleton({
    super.key,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius,
  });

  const LoadingSkeleton.listTile({
    super.key,
    this.margin,
  }) : width = double.infinity,
       height = 72,
       padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
       borderRadius = BorderRadius.circular(12);

  const LoadingSkeleton.card({
    super.key,
    this.margin,
  }) : width = double.infinity,
       height = 120,
       padding = const EdgeInsets.all(16),
       borderRadius = BorderRadius.circular(12);

  const LoadingSkeleton.text({
    super.key,
    this.width,
    this.margin,
  }) : height = 16,
       padding = EdgeInsets.zero,
       borderRadius = BorderRadius.circular(4);

  const LoadingSkeleton.circular({
    super.key,
    double size = 48,
  }) : width = size,
       height = size,
       margin = EdgeInsets.zero,
       padding = EdgeInsets.zero,
       borderRadius = BorderRadius.circular(size / 2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceVariant;
    final highlightColor = theme.colorScheme.onSurface.withOpacity(0.1);

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: borderRadius,
      ),
      child: _Shimmer(
        baseColor: baseColor,
        highlightColor: highlightColor,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Shimmer effect for loading skeletons
class _Shimmer extends StatefulWidget {
  final Color baseColor;
  final Color highlightColor;
  final BorderRadius? borderRadius;

  const _Shimmer({
    required this.baseColor,
    required this.highlightColor,
    this.borderRadius,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: const Offset(2, 0),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: SlideTransition(
        position: _animation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.25, 0.5, 0.75],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
    );
  }
}

/// List of loading skeletons for lists
class LoadingSkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index) itemBuilder;

  const LoadingSkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemBuilder = _defaultListItemBuilder,
  });

  static Widget _defaultListItemBuilder(int index) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: LoadingSkeleton.listTile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(index),
    );
  }
}

/// Grid of loading skeletons
class LoadingSkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final Widget Function(int index) itemBuilder;

  const LoadingSkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.itemBuilder = _defaultGridItemBuilder,
  });

  static Widget _defaultGridItemBuilder(int index) {
    return const LoadingSkeleton.card();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(index),
    );
  }
}
