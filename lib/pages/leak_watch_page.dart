import 'package:flutter/material.dart';
import 'package:phishleak_guard/theme.dart';
import 'package:phishleak_guard/models/breach_result.dart';
import 'package:phishleak_guard/services/breach_check_service.dart';
import 'package:phishleak_guard/services/history_service.dart';
import 'package:phishleak_guard/components/breach_card.dart';
import 'package:go_router/go_router.dart';

/// LeakWatch page for data breach monitoring
class LeakWatchPage extends StatefulWidget {
  const LeakWatchPage({super.key});

  @override
  State<LeakWatchPage> createState() => _LeakWatchPageState();
}

class _LeakWatchPageState extends State<LeakWatchPage> {
  final _breachService = BreachCheckService();
  final _historyService = HistoryService();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isChecking = false;
  BreachCheckResult? _result;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isChecking = true;
      _result = null;
    });

    try {
      final result = await _breachService.checkEmail(_emailController.text.trim());
      await _historyService.saveBreachCheck(result);

      setState(() {
        _result = result;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _isChecking = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking email: $e')),
        );
      }
    }
  }

  void _clear() {
    setState(() {
      _emailController.clear();
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.security, color: SecurityColors.cyan),
            const SizedBox(width: AppSpacing.sm),
            const Text('LeakWatch'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/dashboard'),
            icon: const Icon(Icons.history),
            tooltip: 'View History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Section
            Card(
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check for Data Breaches',
                        style: context.textStyles.titleLarge?.semiBold,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Enter your email address to check if it has been compromised in any known data breaches.',
                        style: context.textStyles.bodyMedium?.withColor(
                          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Email input
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'your.email@example.com',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      
                      // Action buttons
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          FilledButton.icon(
                            onPressed: _isChecking ? null : _checkEmail,
                            icon: _isChecking
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.search),
                            label: Text(_isChecking ? 'Checking...' : 'Check Breaches'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _clear,
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: AppSpacing.paddingSm,
                        decoration: BoxDecoration(
                          color: SecurityColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: SecurityColors.info.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.privacy_tip,
                              size: 16,
                              color: SecurityColors.info,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Your email is not stored. All checks are anonymous.',
                                style: context.textStyles.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Results Section
            if (_result != null) ...[
              const SizedBox(height: AppSpacing.lg),
              
              // Status Card
              Card(
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    children: [
                      Icon(
                        _result!.isCompromised ? Icons.warning : Icons.check_circle,
                        size: 64,
                        color: _result!.isCompromised
                            ? SecurityColors.danger
                            : SecurityColors.success,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _result!.isCompromised
                            ? 'Email Compromised'
                            : 'No Breaches Found',
                        style: context.textStyles.headlineSmall?.bold.withColor(
                          _result!.isCompromised
                              ? SecurityColors.danger
                              : SecurityColors.success,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _result!.isCompromised
                            ? 'Found in ${_result!.breachCount} known data ${_result!.breachCount == 1 ? "breach" : "breaches"}'
                            : 'This email has not been found in any known breaches',
                        style: context.textStyles.bodyMedium?.withColor(
                          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Breaches List
              if (_result!.breaches.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Breach Details',
                  style: context.textStyles.titleLarge?.semiBold,
                ),
                const SizedBox(height: AppSpacing.md),
                ...(_result!.breaches.map((breach) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: BreachCard(breach: breach),
                    ))),
              ],

              // Recommendations
              const SizedBox(height: AppSpacing.lg),
              _RecommendationsCard(isCompromised: _result!.isCompromised),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  final bool isCompromised;

  const _RecommendationsCard({required this.isCompromised});

  @override
  Widget build(BuildContext context) {
    final recommendations = isCompromised
        ? [
            'Change your password immediately on all affected accounts',
            'Enable two-factor authentication (2FA) wherever possible',
            'Use a unique, strong password for each account',
            'Consider using a password manager',
            'Monitor your accounts for suspicious activity',
            'Review your financial statements regularly',
            'Be alert for phishing attempts using your exposed data',
          ]
        : [
            'Continue using strong, unique passwords for each account',
            'Enable two-factor authentication on all important accounts',
            'Regularly check for breaches using this tool',
            'Be cautious of phishing attempts',
            'Keep your software and apps updated',
            'Use a reputable password manager',
          ];

    return Card(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCompromised ? Icons.priority_high : Icons.verified_user,
                  color: isCompromised ? SecurityColors.danger : SecurityColors.success,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  isCompromised ? 'Immediate Actions Required' : 'Stay Protected',
                  style: context.textStyles.titleMedium?.semiBold,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isCompromised ? Icons.arrow_right : Icons.check,
                        size: 20,
                        color: isCompromised
                            ? SecurityColors.danger
                            : SecurityColors.success,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          rec,
                          style: context.textStyles.bodyMedium,
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
