import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/features/runner/providers/runner_provider.dart';

/// Compact live stats (proxies + data) shown above the runner controls.
class LiveStatsPanel extends ConsumerWidget {
  final String runnerId;

  const LiveStatsPanel({super.key, required this.runnerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runnerInstance = ref.watch(runnerInstanceProvider(runnerId));

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: GeistSpacing.sm,
        vertical: GeistSpacing.xs,
      ),
      padding: EdgeInsets.all(GeistSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Proxies',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: GeistColors.gray700,
                ),
              ),
              SizedBox(height: GeistSpacing.xs),
              ProxyStatsRow(stats: runnerInstance?.proxyStats ?? {}),
            ],
          ),
          SizedBox(height: GeistSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: GeistColors.gray700,
                ),
              ),
              SizedBox(height: GeistSpacing.xs),
              DataStatsRow(stats: runnerInstance?.dataStats ?? {}),
            ],
          ),
        ],
      ),
    );
  }
}

class ProxyStatsRow extends StatelessWidget {
  final Map<String, int> stats;
  const ProxyStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StatusPill(
            color: GeistColors.gray400,
            count: stats['untested'] ?? 0,
            label: 'Untested',
          ),
          StatusPill(
            color: GeistColors.successColor,
            count: stats['good'] ?? 0,
            label: 'Good',
          ),
          StatusPill(
            color: GeistColors.errorColor,
            count: stats['bad'] ?? 0,
            label: 'Bad',
          ),
          StatusPill(
            color: GeistColors.warningColor,
            count: stats['banned'] ?? 0,
            label: 'Banned',
          ),
        ],
      ),
    );
  }
}

class DataStatsRow extends StatelessWidget {
  final Map<String, int> stats;
  const DataStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          StatusPill(
            color: GeistColors.gray400,
            count: stats['pending'] ?? 0,
            label: 'Pending',
          ),
          StatusPill(
            color: GeistColors.successColor,
            count: stats['success'] ?? 0,
            label: 'Success',
          ),
          StatusPill(
            color: GeistColors.warningColor,
            count: stats['custom'] ?? 0,
            label: 'Custom',
          ),
          StatusPill(
            color: GeistColors.errorColor,
            count: stats['failed'] ?? 0,
            label: 'Failed',
          ),
          StatusPill(
            color: GeistColors.infoColor,
            count: stats['tocheck'] ?? 0,
            label: 'ToCheck',
          ),
          StatusPill(
            color: GeistColors.blue,
            count: stats['retry'] ?? 0,
            label: 'Retry',
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final Color color;
  final int count;
  final String label;
  const StatusPill({
    super.key,
    required this.color,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: GeistSpacing.xs),
      padding: EdgeInsets.symmetric(horizontal: GeistSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(width: 2),
          const SizedBox.shrink(),
          Text(label, style: const TextStyle(color: GeistColors.gray700)),
        ],
      ),
    );
  }
}
