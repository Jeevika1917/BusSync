import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/freshness_utils.dart';

class FreshnessBadge extends StatelessWidget {
  final FreshnessState state;

  const FreshnessBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    IconData icon;

    switch (state) {
      case FreshnessState.live:
        text = 'LIVE';
        color = AppColors.liveBadge;
        icon = Icons.sensors;
        break;
      case FreshnessState.recentlyUpdated:
        text = 'RECENT';
        color = AppColors.recentBadge;
        icon = Icons.schedule;
        break;
      case FreshnessState.stale:
        text = 'STALE';
        color = AppColors.staleBadge;
        icon = Icons.warning_amber_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
