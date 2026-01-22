import 'package:flutter/material.dart';
import 'package:phishleak_guard/theme.dart';
import 'dart:math' as math;

/// Circular risk meter visualization
class RiskMeter extends StatelessWidget {
  final int riskScore; // 0-100
  final String severity;

  const RiskMeter({
    super.key,
    required this.riskScore,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForSeverity(severity);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: _RiskMeterPainter(
              riskScore: riskScore,
              color: color,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$riskScore',
                    style: context.textStyles.displayMedium?.bold.withColor(color),
                  ),
                  Text(
                    'Risk Score',
                    style: context.textStyles.bodyMedium?.withColor(
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            severity.toUpperCase(),
            style: context.textStyles.titleLarge?.bold.withColor(color),
          ),
        ),
      ],
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
        return SecurityColors.success;
      default:
        return SecurityColors.info;
    }
  }
}

class _RiskMeterPainter extends CustomPainter {
  final int riskScore;
  final Color color;

  _RiskMeterPainter({
    required this.riskScore,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Background arc
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      backgroundPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (riskScore / 100) * math.pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RiskMeterPainter oldDelegate) =>
      oldDelegate.riskScore != riskScore || oldDelegate.color != color;
}
