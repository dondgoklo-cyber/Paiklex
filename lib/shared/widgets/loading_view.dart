import 'package:flutter/material.dart';
import 'loading_skeleton.dart';

/// Widget for displaying loading states
class LoadingView extends StatelessWidget {
  final bool useSkeleton;
  final int skeletonCount;

  const LoadingView({
    super.key,
    this.useSkeleton = true,
    this.skeletonCount = 5,
  });

  const LoadingView.skeletonList({
    super.key,
    this.skeletonCount = 5,
  }) : useSkeleton = true;

  const LoadingView.circular({
    super.key,
  }) : useSkeleton = false,
       skeletonCount = 0;

  @override
  Widget build(BuildContext context) {
    if (!useSkeleton) {
      return const Center(child: CircularProgressIndicator());
    }

    return LoadingSkeletonList(itemCount: skeletonCount);
  }
}
