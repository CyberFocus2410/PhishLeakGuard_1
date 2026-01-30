import 'package:flutter/material.dart';
import 'package:phishleak_guard/theme.dart';
import 'package:phishleak_guard/models/phone_lookup_result.dart';
import 'package:phishleak_guard/services/spam_caller_service.dart';
import 'package:phishleak_guard/services/history_service.dart';

/// Spam Caller Lookup page
class SpamCallerPage extends StatefulWidget {
  const SpamCallerPage({super.key});

  @override
  State<SpamCallerPage> createState() => _SpamCallerPageState();
}

class _SpamCallerPageState extends State<SpamCallerPage> {
  final _spamService = SpamCallerService();
  final _phoneController = TextEditingController();
  
  bool _isChecking = false;
  PhoneLookupResult? _result;

  // Example phone numbers for testing
  final List<Map<String, String>> _examples = [
    // SAFE EXAMPLES
    {'number': '+14155552671', 'label': 'Google HQ'},
    {'number': '+442071234567', 'label': 'UK Business'},
    {'number': '+918012345678', 'label': 'India Mobile'},
    {'number': '+15105551234', 'label': 'CA Number'},
    // SPAM EXAMPLES
    {'number': '+19999999999', 'label': 'Spam Pattern'},
    {'number': '+11111111111', 'label': 'Repeated Digits'},
    {'number': '+12345678901', 'label': 'Sequential'},
    {'number': '+18001234567', 'label': 'Telemarketing'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _loadExample(String number) {
    setState(() {
      _phoneController.text = number;
      _result = null;
    });
  }

  Future<void> _checkNumber() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    setState(() {
      _isChecking = true;
      _result = null;
    });

    try {
      final result = await _spamService.checkPhoneNumber(_phoneController.text);
      
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
          SnackBar(content: Text('Error checking number: $e')),
        );
      }
    }
  }

  void _clear() {
    setState(() {
      _phoneController.clear();
      _result = null;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Safe':
        return SecurityColors.success;
      case 'Reported':
        return SecurityColors.warning;
      case 'High Risk':
        return SecurityColors.danger;
      default:
        return SecurityColors.info;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Safe':
        return Icons.check_circle;
      case 'Reported':
        return Icons.warning;
      case 'High Risk':
        return Icons.dangerous;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    SecurityColors.warning.withValues(alpha: 0.2),
                    SecurityColors.warning.withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(color: SecurityColors.warning, width: 2),
              ),
              child: Icon(Icons.phone, color: SecurityColors.warning, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('Spam Caller Lookup'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              SecurityColors.warning.withValues(alpha: 0.05),
              Theme.of(context).colorScheme.surface,
              SecurityColors.warning.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Privacy Notice with gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                gradient: LinearGradient(
                  colors: [
                    SecurityColors.cyan.withValues(alpha: 0.15),
                    SecurityColors.cyan.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(color: SecurityColors.cyan.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: SecurityColors.cyan.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                child: Padding(
                  padding: AppSpacing.paddingMd,
                  child: Row(
                    children: [
                      Icon(Icons.privacy_tip, color: SecurityColors.cyan, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '🔒 Privacy-first: Phone numbers are not stored',
                          style: context.textStyles.bodySmall?.semiBold.withColor(
                            SecurityColors.cyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Input Section with gradient border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                gradient: LinearGradient(
                  colors: [
                    SecurityColors.warning.withValues(alpha: 0.15),
                    SecurityColors.warning.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(color: SecurityColors.warning.withValues(alpha: 0.3)),
              ),
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.search, color: SecurityColors.warning),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Check Unknown Number',
                            style: context.textStyles.titleLarge?.semiBold,
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.md),
                    
                    Text(
                      'Enter a phone number to check its reputation',
                      style: context.textStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '+1 (555) 123-4567',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                        helperText: 'Include country code for best results',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilledButton.icon(
                          onPressed: _isChecking ? null : _checkNumber,
                          icon: _isChecking
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.search),
                          label: Text(_isChecking ? 'Checking...' : 'Check Number'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _clear,
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                    
                    // Example buttons
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Try an example:',
                      style: context.textStyles.bodySmall?.semiBold,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (var example in _examples)
                          OutlinedButton.icon(
                            onPressed: () => _loadExample(example['number']!),
                            icon: const Icon(Icons.phone, size: 16),
                            label: Text(example['label']!, style: const TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                      ],
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
                        _getStatusIcon(_result!.status),
                        size: 64,
                        color: _getStatusColor(_result!.status),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _result!.status,
                        style: context.textStyles.headlineSmall?.semiBold.withColor(
                          _getStatusColor(_result!.status),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _spamService.formatPhoneNumber(_result!.phoneNumber),
                        style: context.textStyles.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Report count
                      Container(
                        padding: AppSpacing.paddingMd,
                        decoration: BoxDecoration(
                          color: _getStatusColor(_result!.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_result!.reportCount}',
                              style: context.textStyles.displayMedium?.bold.withColor(
                                _getStatusColor(_result!.status),
                              ),
                            ),
                            Text(
                              'Reports',
                              style: context.textStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Explanation Card
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: SecurityColors.info),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'What This Means',
                            style: context.textStyles.titleMedium?.semiBold,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _result!.explanation,
                        style: context.textStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              // Categories
              if (_result!.reportCategories.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: AppSpacing.paddingLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Categories',
                          style: context.textStyles.titleMedium?.semiBold,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: _result!.reportCategories.map((category) {
                            return Chip(
                              label: Text(category),
                              backgroundColor: SecurityColors.danger.withValues(alpha: 0.1),
                              side: BorderSide(color: SecurityColors.danger),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Safety Tips
              const SizedBox(height: AppSpacing.md),
              _SafetyTipsCard(status: _result!.status),
            ],
          ],
        ),
      )),
    );
  }
}

class _SafetyTipsCard extends StatelessWidget {
  final String status;

  const _SafetyTipsCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final tips = status == 'Safe'
        ? [
            'Even safe numbers can be spoofed - verify caller identity',
            'Never share personal information over the phone',
            'Be cautious with unsolicited calls',
          ]
        : [
            'Do not answer calls from this number',
            'Block the number on your phone',
            'Never provide personal or financial information',
            'Report the number to your carrier',
            'Be wary of similar numbers calling you',
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
                  Icons.shield,
                  color: status == 'Safe' ? SecurityColors.success : SecurityColors.danger,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Safety Tips',
                  style: context.textStyles.titleMedium?.semiBold,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        status == 'Safe' ? Icons.check : Icons.warning,
                        size: 16,
                        color: status == 'Safe' 
                            ? SecurityColors.success 
                            : SecurityColors.danger,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          tip,
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
