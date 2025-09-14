import 'package:flutter/material.dart';

/// Background foto air + overlay gradasi biru → transparan.
class AquaBackground extends StatelessWidget {
  final Widget child;
  const AquaBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Foto air
        Image.asset(
          'assets/images/bg_pool.jpg',
          fit: BoxFit.cover,
        ),
        // Overlay gradasi agar teks kontras
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xCC3BA7FF), // biru dengan opacity
                Color(0x663BA7FF),
                Colors.transparent,
              ],
              stops: [0.0, 0.35, 1.0],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
