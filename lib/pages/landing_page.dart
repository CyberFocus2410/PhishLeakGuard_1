import 'package:flutter/material.dart';
import 'package:phishleak_guard/theme.dart';
import 'package:go_router/go_router.dart';

/// Landing page with animated cyber security theme
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar with glow effect
            SliverAppBar.large(
              floating: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      SecurityColors.cyan.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              title: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: SecurityColors.cyan.withValues(alpha: 0.3 * _pulseController.value),
                              blurRadius: 20 * _pulseController.value,
                              spreadRadius: 5 * _pulseController.value,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shield,
                          color: SecurityColors.cyan,
                          size: 32,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'PhishShield Guard',
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

            // Hero Section with scan animation
            SliverToBoxAdapter(
              child: Container(
                padding: AppSpacing.paddingXl,
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Animated Shield Icon
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer pulse ring
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 120 + (40 * _pulseController.value),
                              height: 120 + (40 * _pulseController.value),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: SecurityColors.cyan.withValues(alpha: 0.3 - (0.3 * _pulseController.value)),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        ),
                        // Scan line effect
                        AnimatedBuilder(
                          animation: _scanController,
                          builder: (context, child) {
                            return ClipOval(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: [
                                      _scanController.value - 0.1,
                                      _scanController.value,
                                      _scanController.value + 0.1,
                                    ].map((s) => s.clamp(0.0, 1.0)).toList(),
                                    colors: [
                                      Colors.transparent,
                                      SecurityColors.cyan.withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Shield icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: SecurityColors.cyan.withValues(alpha: 0.1),
                            border: Border.all(
                              color: SecurityColors.cyan,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.security,
                            size: 60,
                            color: SecurityColors.cyan,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            SecurityColors.cyan.withValues(alpha: 0.2),
                            SecurityColors.cyan.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: SecurityColors.cyan),
                        boxShadow: [
                          BoxShadow(
                            color: SecurityColors.cyan.withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        '⚡ AI-POWERED THREAT DETECTION',
                        style: context.textStyles.labelMedium?.semiBold.withColor(
                          SecurityColors.cyan,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Main heading with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          SecurityColors.cyan,
                          SecurityColors.info,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'Your Complete\nCybersecurity Shield',
                        style: context.textStyles.displaySmall?.bold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Detect phishing, scan suspicious links, check spam callers,\nand monitor data breaches—all in one powerful platform.',
                      style: context.textStyles.bodyLarge?.withColor(
                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Main CTAs with glow effects
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 900) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: _CTACard(
                                  title: 'PhishShield',
                                  description: 'AI-powered phishing detection',
                                  icon: Icons.phishing,
                                  color: SecurityColors.danger,
                                  onTap: () => context.push('/phish-shield'),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Flexible(
                                child: _CTACard(
                                  title: 'Spam Lookup',
                                  description: 'Real-time caller verification',
                                  icon: Icons.phone,
                                  color: SecurityColors.warning,
                                  onTap: () => context.push('/spam-caller'),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Flexible(
                                child: _CTACard(
                                  title: 'LeakWatch',
                                  description: 'Breach monitoring & alerts',
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
                                description: 'AI-powered phishing detection',
                                icon: Icons.phishing,
                                color: SecurityColors.danger,
                                onTap: () => context.push('/phish-shield'),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _CTACard(
                                title: 'Spam Lookup',
                                description: 'Real-time caller verification',
                                icon: Icons.phone,
                                color: SecurityColors.warning,
                                onTap: () => context.push('/spam-caller'),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _CTACard(
                                title: 'LeakWatch',
                                description: 'Breach monitoring & alerts',
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

            // Statistics Section with gradient cards
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.paddingXl,
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      '🔥 The Threat Landscape',
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
                          color: SecurityColors.danger,
                        ),
                        _StatCard(
                          value: '15B',
                          label: 'Credentials exposed in breaches',
                          icon: Icons.vpn_key,
                          color: SecurityColors.warning,
                        ),
                        _StatCard(
                          value: '90%',
                          label: 'Of breaches start with phishing',
                          icon: Icons.warning,
                          color: SecurityColors.critical,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Features Section
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.paddingXl,
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      '⚡ Powerful Features',
                      style: context.textStyles.headlineMedium?.bold,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _FeatureCard(
                      title: 'Advanced AI Detection',
                      description: 'Powered by OpenAI GPT-4 to analyze phishing patterns, suspicious URLs, and scam content with industry-leading accuracy.',
                      icon: Icons.psychology,
                      gradient: [SecurityColors.cyan, SecurityColors.info],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _FeatureCard(
                      title: 'Real-Time Threat Intelligence',
                      description: 'Instant analysis of emails, SMS, and URLs against global threat databases to keep you protected 24/7.',
                      icon: Icons.flash_on,
                      gradient: [SecurityColors.warning, SecurityColors.danger],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _FeatureCard(
                      title: 'Privacy First',
                      description: 'Zero data storage. Your phone numbers and sensitive content are never saved, ensuring complete privacy.',
                      icon: Icons.privacy_tip,
                      gradient: [SecurityColors.success, SecurityColors.cyan],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CTACard extends StatefulWidget {
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
  State<_CTACard> createState() => _CTACardState();
}

class _CTACardState extends State<_CTACard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _isHovered ? 0.3 : 0.1),
                blurRadius: _isHovered ? 20 : 8,
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color.withValues(alpha: 0.1),
                      widget.color.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                padding: AppSpacing.paddingLg,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.color.withValues(alpha: 0.2),
                            widget.color.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: widget.color, width: 2),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 48,
                        color: widget.color,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.title,
                      style: context.textStyles.headlineSmall?.bold.withColor(widget.color),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.description,
                      style: context.textStyles.bodyMedium?.withColor(
                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: widget.onTap,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Launch Scanner'),
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.color,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  value,
                  style: context.textStyles.headlineLarge?.bold.withColor(color),
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
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient.first.withValues(alpha: 0.1),
            gradient.last.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: gradient.first.withValues(alpha: 0.3),
        ),
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient.map((c) => c.withValues(alpha: 0.2)).toList()),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: gradient.first),
                ),
                child: Icon(
                  icon,
                  color: gradient.first,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textStyles.titleLarge?.semiBold,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: context.textStyles.bodySmall?.withColor(
                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
