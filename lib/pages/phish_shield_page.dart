import 'package:flutter/material.dart';
import 'package:phishleak_guard/theme.dart';
import 'package:phishleak_guard/models/phishing_analysis_result.dart';
import 'package:phishleak_guard/services/phishing_detection_service.dart';
import 'package:phishleak_guard/services/history_service.dart';
import 'package:phishleak_guard/components/risk_meter.dart';
import 'package:phishleak_guard/components/threat_card.dart';
import 'package:go_router/go_router.dart';

/// PhishShield page for phishing detection
class PhishShieldPage extends StatefulWidget {
  const PhishShieldPage({super.key});

  @override
  State<PhishShieldPage> createState() => _PhishShieldPageState();
}

class _PhishShieldPageState extends State<PhishShieldPage> {
  final _phishingService = PhishingDetectionService();
  final _historyService = HistoryService();
  final _contentController = TextEditingController();

  String _selectedType = 'email';
  bool _isAnalyzing = false;
  PhishingAnalysisResult? _result;

  final List<Map<String, String>> _examples = [
    {
      'type': 'email',
      'content': '''Dear Customer,

Your PayPa1 account has been suspended due to unusual activity. Click here immediately to verify your account within 24 hours or it will be permanently closed.

Verify Account: http://paypa1-secure.tk/verify

Best regards,
PayPal Security Team''',
    },
    {
      'type': 'url',
      'content': 'http://amaz0n-prize.xyz/claim-reward?winner=true',
    },
    {
      'type': 'sms',
      'content': 'URGENT: Your bank account has been locked. Click http://bit.ly/3xYz to verify your identity and unlock it immediately.',
    },
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _analyzeContent() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter content to analyze')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _result = null;
    });

    try {
      final result = await _phishingService.analyzeContent(
        content: _contentController.text,
        inputType: _selectedType,
      );

      await _historyService.savePhishingAnalysis(result);

      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing content: $e')),
        );
      }
    }
  }

  void _loadExample(int index) {
    final example = _examples[index];
    setState(() {
      _selectedType = example['type']!;
      _contentController.text = example['content']!;
      _result = null;
    });
  }

  void _clear() {
    setState(() {
      _contentController.clear();
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.phishing, color: SecurityColors.danger),
            const SizedBox(width: AppSpacing.sm),
            const Text('PhishShield'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyze Suspicious Content',
                      style: context.textStyles.titleLarge?.semiBold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Type selector
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'url',
                          label: Text('URL'),
                          icon: Icon(Icons.link),
                        ),
                        ButtonSegment(
                          value: 'email',
                          label: Text('Email'),
                          icon: Icon(Icons.email),
                        ),
                        ButtonSegment(
                          value: 'sms',
                          label: Text('SMS'),
                          icon: Icon(Icons.message),
                        ),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedType = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Content input
                    TextField(
                      controller: _contentController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: 'Paste ${_selectedType} content here',
                        hintText: 'Enter the suspicious ${_selectedType} content...',
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Action buttons
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilledButton.icon(
                          onPressed: _isAnalyzing ? null : _analyzeContent,
                          icon: _isAnalyzing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.search),
                          label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze'),
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
                        for (int i = 0; i < _examples.length; i++)
                          TextButton(
                            onPressed: () => _loadExample(i),
                            child: Text('Example ${i + 1}'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Results Section
            if (_result != null) ...[
              const SizedBox(height: AppSpacing.lg),
              
              // Risk Meter
              Card(
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    children: [
                      Text(
                        'Analysis Result',
                        style: context.textStyles.titleLarge?.semiBold,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      RiskMeter(
                        riskScore: _result!.riskScore,
                        severity: _result!.severity,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: AppSpacing.paddingMd,
                        decoration: BoxDecoration(
                          color: _result!.isSafe
                              ? SecurityColors.success.withValues(alpha: 0.1)
                              : SecurityColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: _result!.isSafe
                                ? SecurityColors.success
                                : SecurityColors.danger,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _result!.isSafe ? Icons.check_circle : Icons.warning,
                              color: _result!.isSafe
                                  ? SecurityColors.success
                                  : SecurityColors.danger,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              _result!.isSafe ? 'Appears Safe' : 'Potentially Dangerous',
                              style: context.textStyles.titleMedium?.semiBold.withColor(
                                _result!.isSafe
                                    ? SecurityColors.success
                                    : SecurityColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Threats Found
              if (_result!.threats.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Detected Threats (${_result!.threats.length})',
                  style: context.textStyles.titleLarge?.semiBold,
                ),
                const SizedBox(height: AppSpacing.md),
                ...(_result!.threats.map((threat) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ThreatCard(threat: threat),
                    ))),
              ],

              // Security Tips
              const SizedBox(height: AppSpacing.lg),
              _SecurityTipsCard(isSafe: _result!.isSafe),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecurityTipsCard extends StatelessWidget {
  final bool isSafe;

  const _SecurityTipsCard({required this.isSafe});

  @override
  Widget build(BuildContext context) {
    final tips = isSafe
        ? [
            'Always verify sender addresses before responding',
            'Be cautious with unexpected emails or messages',
            'Never share passwords or sensitive data via email',
            'When in doubt, contact the organization directly',
          ]
        : [
            'Do not click any links in this message',
            'Do not provide any personal information',
            'Report this as phishing to your email provider',
            'Delete the message immediately',
            'If you clicked a link, change your passwords',
            'Enable two-factor authentication on all accounts',
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
                  Icons.lightbulb,
                  color: SecurityColors.info,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  isSafe ? 'General Security Tips' : 'Recommended Actions',
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
                        isSafe ? Icons.info : Icons.priority_high,
                        size: 16,
                        color: isSafe ? SecurityColors.info : SecurityColors.danger,
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
