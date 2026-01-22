import 'package:flutter/material.dart';
import 'package:phishleak_guard/models/breach_result.dart';
import 'package:phishleak_guard/theme.dart';
import 'package:intl/intl.dart';

/// Card displaying breach information
class BreachCard extends StatelessWidget {
  final Breach breach;

  const BreachCard({
    super.key,
    required this.breach,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForSeverity(breach.severity);

    return Card(
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.security,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        breach.name,
                        style: context.textStyles.titleMedium?.semiBold,
                      ),
                      Text(
                        breach.domain,
                        style: context.textStyles.bodySmall?.withColor(
                          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: color, width: 1),
                  ),
                  child: Text(
                    breach.severity,
                    style: context.textStyles.labelSmall?.semiBold.withColor(color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              breach.description,
              style: context.textStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _InfoChip(
                  icon: Icons.calendar_today,
                  label: DateFormat('MMM yyyy').format(breach.breachDate),
                ),
                _InfoChip(
                  icon: Icons.people,
                  label: _formatNumber(breach.affectedAccounts),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: breach.dataTypes
                  .map((type) => _DataTypeChip(type: type))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForSeverity(String severity) {
    switch (severity) {
      case 'Critical':
        return SecurityColors.critical;
      case 'High':
        return SecurityColors.danger;
      case 'Medium':
        return SecurityColors.warning;
      case 'Low':
        return SecurityColors.info;
      default:
        return SecurityColors.info;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DataTypeChip extends StatelessWidget {
  final String type;

  const _DataTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: SecurityColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: SecurityColors.danger.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        type.replaceAll('_', ' '),
        style: context.textStyles.labelSmall?.withColor(SecurityColors.danger),
      ),
    );
  }
}
