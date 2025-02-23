import 'package:flutter/material.dart';
import 'dart:math' as math;

class ArrowPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;
  final double weight;
  final bool? showWeight;

  ArrowPainter(
      {required this.start,
      required this.end,
      this.color = Colors.white,
      this.strokeWidth = 2.0,
      required this.weight,
      this.showWeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);

    if (showWeight ?? false) {
      final textSpan = TextSpan(
        text: weight.toStringAsFixed(2),
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);

      final random = math.Random();
      final ratio = random.nextBool()
          ? 0.2 + random.nextDouble() * 0.1
          : 0.4 + random.nextDouble() * 0.1;

      // Calculate position along the line
      final posX = start.dx + (end.dx - start.dx) * ratio;
      final posY = start.dy + (end.dy - start.dy) * ratio;

      final perpOffset = 15.0;
      final textOffset = Offset(
          posX - textPainter.width / 2 - perpOffset * math.sin(angle),
          posY - textPainter.height / 2 + perpOffset * math.cos(angle));

      canvas.save();
      canvas.translate(textOffset.dx, textOffset.dy);
      if (angle.abs() < math.pi / 4) {
        canvas.rotate(angle);
      }
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // Calculate the arrow head
    final double arrowSize = 10.0;
    final double angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final Path arrowPath = Path();

    arrowPath.moveTo(end.dx, end.dy);

    arrowPath.lineTo(
      end.dx - arrowSize * math.cos(angle - math.pi / 6),
      end.dy - arrowSize * math.sin(angle - math.pi / 6),
    );

    arrowPath.lineTo(
      end.dx - arrowSize * math.cos(angle),
      end.dy - arrowSize * math.sin(angle),
    );

    arrowPath.lineTo(
      end.dx - arrowSize * math.cos(angle + math.pi / 6),
      end.dy - arrowSize * math.sin(angle + math.pi / 6),
    );

    arrowPath.close();

    paint.style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
