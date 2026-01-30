import 'package:flutter/material.dart';
import 'package:phishleak_guard/theme.dart';

/// Badge component for displaying scam type classifications
class ScamTypeBadge extends StatelessWidget {
  final String scamType;

  const ScamTypeBadge({
    super.key,
    required this.scamType,
  });

  IconData _getIcon(String type) {
    switch (type) {
      case 'Bank Fraud':
        return Icons.account_balance;
      case 'Job Scam':
        return Icons.work_off;
      case 'Delivery Scam':
        return Icons.local_shipping;
      case 'Romance Scam':
        return Icons.favorite_border;
      case 'Investment Scam':
        return Icons.trending_up;
      default:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: SecurityColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: SecurityColors.danger, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(scamType),
            color: SecurityColors.danger,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            scamType,
            style: context.textStyles.titleMedium?.semiBold.withColor(
              SecurityColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
