import 'package:flutter/material.dart';
import 'package:phishleak_guard/theme.dart';
import 'package:go_router/go_router.dart';

/// Landing page with hero section and dual CTAs
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar.large(
            floating: true,
            title: Row(
              children: [
                Icon(
                  Icons.shield,
                  color: SecurityColors.cyan,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'PhishLeak Guard',
                  style: context.textStyles.headlineSmall?.bold,
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => context.push('/dashboard'),
                icon: const Icon(Icons.history),
                label: const Text('History'),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              padding: AppSpacing.paddingXl,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Icon(
                    Icons.security,
                    size: 80,
                    color: SecurityColors.cyan,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Your Digital Shield',
                    style: context.textStyles.displaySmall?.bold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Comprehensive cybersecurity protection combining phishing detection and data breach monitoring in one powerful platform.',
                    style: context.textStyles.bodyLarge?.withColor(
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Main CTAs
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: _CTACard(
                                title: 'PhishShield',
                                description: 'Detect phishing attempts in URLs, emails, and SMS',
                                icon: Icons.phishing,
                                color: SecurityColors.danger,
                                onTap: () => context.push('/phish-shield'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Flexible(
                              child: _CTACard(
                                title: 'LeakWatch',
                                description: 'Check if your email has been compromised',
                                icon: Icons.security,
                                color: SecurityColors.cyan,
                                onTap: () => context.push('/leak-watch'),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _CTACard(
                              title: 'PhishShield',
                              description: 'Detect phishing attempts in URLs, emails, and SMS',
                              icon: Icons.phishing,
                              color: SecurityColors.danger,
                              onTap: () => context.push('/phish-shield'),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _CTACard(
                              title: 'LeakWatch',
                              description: 'Check if your email has been compromised',
                              icon: Icons.security,
                              color: SecurityColors.cyan,
                              onTap: () => context.push('/leak-watch'),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Statistics Section
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingXl,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Why It Matters',
                    style: context.textStyles.headlineMedium?.bold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    alignment: WrapAlignment.center,
                    children: const [
                      _StatCard(
                        value: '3.4B',
                        label: 'Phishing emails sent daily',
                        icon: Icons.email,
                      ),
                      _StatCard(
                        value: '15B',
                        label: 'Credentials exposed in breaches',
                        icon: Icons.vpn_key,
                      ),
                      _StatCard(
                        value: '90%',
                        label: 'Of data breaches start with phishing',
                        icon: Icons.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Educational Section
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingXl,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Common Threats',
                    style: context.textStyles.headlineMedium?.bold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _ThreatInfoCard(
                    title: 'Phishing Attacks',
                    description: 'Fraudulent messages designed to steal your credentials or install malware.',
                    icon: Icons.phishing,
                    tips: [
                      'Check sender email addresses carefully',
                      'Hover over links before clicking',
                      'Be wary of urgent requests',
                      'Never share passwords via email',
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _ThreatInfoCard(
                    title: 'Data Breaches',
                    description: 'Unauthorized access to databases exposing personal information.',
                    icon: Icons.leak_add,
                    tips: [
                      'Use unique passwords for each account',
                      'Enable two-factor authentication',
                      'Monitor your accounts regularly',
                      'Change passwords after breaches',
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CTACard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CTACard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          padding: AppSpacing.paddingLg,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: context.textStyles.headlineSmall?.bold.withColor(color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: context.textStyles.bodyMedium?.withColor(
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Get Started'),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: SecurityColors.cyan,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: context.textStyles.headlineLarge?.bold.withColor(
                  SecurityColors.cyan,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: context.textStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreatInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<String> tips;

  const _ThreatInfoCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: SecurityColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    icon,
                    color: SecurityColors.warning,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: context.textStyles.titleLarge?.semiBold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              description,
              style: context.textStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Protection Tips:',
              style: context.textStyles.titleSmall?.semiBold,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: SecurityColors.success,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          tip,
                          style: context.textStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
