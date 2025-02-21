import 'package:flutter/material.dart';
import 'dart:math' as math;

class ArrowPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;

  ArrowPainter({
    required this.start,
    required this.end,
    this.color = Colors.white,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw the main line
    canvas.drawLine(start, end, paint);

    // Calculate the arrow head
    final double arrowSize = 10.0;
    final double angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final Path arrowPath = Path();

    // Create a closed arrow head path
    arrowPath.moveTo(end.dx, end.dy); // Tip of the arrow

    // Left side of arrow head
    arrowPath.lineTo(
      end.dx - arrowSize * math.cos(angle - math.pi / 6),
      end.dy - arrowSize * math.sin(angle - math.pi / 6),
    );

    // Back of arrow head
    arrowPath.lineTo(
      end.dx - arrowSize * math.cos(angle),
      end.dy - arrowSize * math.sin(angle),
    );

    // Right side of arrow head
    arrowPath.lineTo(
      end.dx - arrowSize * math.cos(angle + math.pi / 6),
      end.dy - arrowSize * math.sin(angle + math.pi / 6),
    );

    // Close the path back to the tip
    arrowPath.close();

    // Fill the arrow head with the same color as the line
    paint.style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
