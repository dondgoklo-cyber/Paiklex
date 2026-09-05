import 'package:flutter/material.dart';

/// Animated wrapper for list items
/// Provides fade-in and slide-up animations when items are added
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration animationDuration;
  final bool animate;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!animate) {
      return child;
    }

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: animationDuration,
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}

/// Animation configuration for staggered animations
class AnimationConfiguration {
  final int position;
  final Duration duration;
  final Widget child;

  const AnimationConfiguration({
    required this.position,
    required this.duration,
    required this.child,
  });

  static Widget staggeredList({
    required int position,
    required Duration duration,
    required Widget child,
  }) {
    return AnimationConfiguration(
      position: position,
      duration: duration,
      child: child,
    );
  }
}

/// Slide animation widget
class SlideAnimation extends StatelessWidget {
  final Widget child;
  final double verticalOffset;
  final double horizontalOffset;
  final Duration duration;
  final Curve curve;

  const SlideAnimation({
    super.key,
    required this.child,
    this.verticalOffset = 0,
    this.horizontalOffset = 0,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(
        begin: Offset(horizontalOffset, verticalOffset),
        end: Offset.zero,
      ),
      duration: duration,
      curve: curve,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: offset,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Fade in animation widget
class FadeInAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Scale animation widget
class ScaleAnimation extends StatelessWidget {
  final Widget child;
  final double begin;
  final double end;
  final Duration duration;
  final Curve curve;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.begin = 0.8,
    this.end = 1.0,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Combined scale and fade animation for button press feedback
class PressAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const PressAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeOut,
  });

  @override
  State<PressAnimation> createState() => _PressAnimationState();
}

class _PressAnimationState extends State<PressAnimation> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: widget.duration,
        curve: widget.curve,
        scale: _pressed ? 0.95 : 1.0,
        child: widget.child,
      ),
    );
  }
}
