import 'dart:math';
import 'package:flutter/material.dart';

/// Bouncing cube loader — CSS animloader ekvivalenti.
/// Kvadrat o'z o'lchamida soat strelkasi bo'ylab aylanib yuradi,
/// har burilishda Y va X o'qlari bo'ylab 180° flip qiladi.
class SelectionLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const SelectionLoader({super.key, this.size = 24, this.color});

  @override
  State<SelectionLoader> createState() => _SelectionLoaderState();
}

class _SelectionLoaderState extends State<SelectionLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final s = widget.size;

    return SizedBox(
      width: s * 2,
      height: s * 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final t = _controller.value;

          // Translation: square path (0,0)→(s,0)→(s,s)→(0,s)→(0,0)
          final double tx, ty;
          if (t < 0.25) {
            tx = (t / 0.25) * s;
            ty = 0;
          } else if (t < 0.5) {
            tx = s;
            ty = ((t - 0.25) / 0.25) * s;
          } else if (t < 0.75) {
            tx = s * (1 - (t - 0.5) / 0.25);
            ty = s;
          } else {
            tx = 0;
            ty = s * (1 - (t - 0.75) / 0.25);
          }

          // rotateY: 0→180 (0–25%), stays (25–50%), 180→360 (50–75%), stays (75–100%)
          final double rotY;
          if (t < 0.25) {
            rotY = (t / 0.25) * pi;
          } else if (t < 0.5) {
            rotY = pi;
          } else if (t < 0.75) {
            rotY = pi + ((t - 0.5) / 0.25) * pi;
          } else {
            rotY = 2 * pi;
          }

          // rotateX: stays 0 (0–25%), 0→-180 (25–50%), stays -180 (50–75%), -180→0 (75–100%)
          final double rotX;
          if (t < 0.25) {
            rotX = 0;
          } else if (t < 0.5) {
            rotX = -((t - 0.25) / 0.25) * pi;
          } else if (t < 0.75) {
            rotX = -pi;
          } else {
            rotX = -pi + ((t - 0.75) / 0.25) * pi;
          }

          final matrix = Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..translateByDouble(tx, ty, 0, 1)
            ..rotateX(rotX)
            ..rotateY(rotY);

          return Transform(
            transform: matrix,
            child: SizedBox(
              width: s,
              height: s,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            ),
          );
        },
      ),
    );
  }
}
