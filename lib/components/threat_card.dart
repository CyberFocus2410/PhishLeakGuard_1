import 'package:flutter/material.dart';
import 'package:phishleak_guard/models/phishing_analysis_result.dart';
import 'package:phishleak_guard/theme.dart';

/// Card displaying a detected threat
class ThreatCard extends StatelessWidget {
  final ThreatFlag threat;

  const ThreatCard({
    super.key,
    required this.threat,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForSeverity(threat.severity);
    final icon = _getIconForType(threat.type);

    return Card(
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          threat.title,
                          style: context.textStyles.titleMedium?.semiBold,
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
                          threat.severity,
                          style: context.textStyles.labelSmall?.semiBold.withColor(color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    threat.description,
                    style: context.textStyles.bodyMedium?.withColor(
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
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

  IconData _getIconForType(String type) {
    switch (type) {
      case 'domain':
        return Icons.language;
      case 'content':
        return Icons.description;
      case 'link':
        return Icons.link;
      case 'header':
        return Icons.email;
      default:
        return Icons.warning;
    }
  }
}
