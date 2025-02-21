import 'package:flutter/material.dart';
import 'package:perceptron/core/configs/constants/app_constants.dart';
import 'package:perceptron/core/configs/theme/app_colors.dart';
import 'package:perceptron/presentation/home/screen/home_screen.dart';

class Unit extends StatelessWidget {
  final double value;
  final List<Connection> connections;
  final Function(dynamic)? onHover;
  const Unit(
      {super.key,
      required this.value,
      required this.connections,
      this.onHover});

  @override
  Widget build(BuildContext context) {
    // Create tooltip message from connections
    String tooltipMessage = connections.isEmpty
        ? 'No connections'
        : connections
            .map((conn) =>
                'Source: ${conn.sourceId} -> Target: ${conn.targetId} (Weight: ${conn.weight})')
            .join('\n');

    return MouseRegion(
      onEnter: (_) => onHover?.call(true),
      onExit: (_) => onHover?.call(false),
      child: Tooltip(
        message: tooltipMessage,
        waitDuration: const Duration(milliseconds: 500),
        showDuration: const Duration(seconds: 2),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          alignment: Alignment.center,
          width: AppConstants.unitSize,
          height: AppConstants.unitSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.primary, width: 6),
          ),
          child: Text(
            value.toString(),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.background,
                ),
          ),
        ),
      ),
    );
  }
}
