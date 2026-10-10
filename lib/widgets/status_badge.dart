import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/freshness_utils.dart';

class StatusBadge extends StatelessWidget {
  final BusStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (status) {
      case BusStatus.available:
        text = 'AVAILABLE';
        color = AppColors.statusAvailable;
        break;
      case BusStatus.almostFull:
        text = 'ALMOST FULL';
        color = AppColors.statusAlmostFull;
        break;
      case BusStatus.full:
        text = 'FULL';
        color = AppColors.statusFull;
        break;
      case BusStatus.stale:
        text = 'STALE';
        color = AppColors.statusStale;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
