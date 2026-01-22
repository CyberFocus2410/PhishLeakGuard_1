import 'package:flutter/material.dart';
import 'package:phishleak_guard/theme.dart';
import 'package:phishleak_guard/models/phishing_analysis_result.dart';
import 'package:phishleak_guard/models/breach_result.dart';
import 'package:phishleak_guard/services/history_service.dart';
import 'package:intl/intl.dart';

/// Dashboard page showing analysis history
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _historyService = HistoryService();
  
  List<PhishingAnalysisResult> _phishingHistory = [];
  List<BreachCheckResult> _breachHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final phishing = await _historyService.getPhishingHistory();
      final breach = await _historyService.getBreachHistory();
      
      setState(() {
        _phishingHistory = phishing;
        _breachHistory = breach;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: SecurityColors.danger,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearAllHistory();
      await _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalScans = _phishingHistory.length + _breachHistory.length;
    final threatsDetected = _phishingHistory.where((r) => !r.isSafe).length;
    final breachesFound = _breachHistory.where((r) => r.isCompromised).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Dashboard'),
        actions: [
          if (totalScans > 0)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : totalScans == 0
              ? _EmptyState()
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: SingleChildScrollView(
                    padding: AppSpacing.paddingMd,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Statistics
                        _StatisticsSection(
                          totalScans: totalScans,
                          threatsDetected: threatsDetected,
                          breachesFound: breachesFound,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Phishing History
                        if (_phishingHistory.isNotEmpty) ...[
                          Text(
                            'Phishing Analysis History',
                            style: context.textStyles.titleLarge?.semiBold,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ...(_phishingHistory.map((result) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: _PhishingHistoryCard(result: result),
                              ))),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        // Breach History
                        if (_breachHistory.isNotEmpty) ...[
                          Text(
                            'Breach Check History',
                            style: context.textStyles.titleLarge?.semiBold,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ...(_breachHistory.map((result) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: _BreachHistoryCard(result: result),
                              ))),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No History Yet',
              style: context.textStyles.headlineSmall?.semiBold,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start analyzing content or checking for breaches to see your history here.',
              style: context.textStyles.bodyMedium?.withColor(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticsSection extends StatelessWidget {
  final int totalScans;
  final int threatsDetected;
  final int breachesFound;

  const _StatisticsSection({
    required this.totalScans,
    required this.threatsDetected,
    required this.breachesFound,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          children: [
            Text(
              'Overview',
              style: context.textStyles.titleLarge?.semiBold,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Total Scans',
                    value: totalScans.toString(),
                    icon: Icons.analytics,
                    color: SecurityColors.info,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Threats',
                    value: threatsDetected.toString(),
                    icon: Icons.warning,
                    color: SecurityColors.danger,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Breaches',
                    value: breachesFound.toString(),
                    icon: Icons.security,
                    color: SecurityColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: context.textStyles.headlineMedium?.bold.withColor(color),
        ),
        Text(
          label,
          style: context.textStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PhishingHistoryCard extends StatelessWidget {
  final PhishingAnalysisResult result;

  const _PhishingHistoryCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.isSafe ? SecurityColors.success : SecurityColors.danger;
    
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.isSafe ? Icons.check_circle : Icons.warning,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    result.inputType.toUpperCase(),
                    style: context.textStyles.titleSmall?.semiBold,
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
                    'Score: ${result.riskScore}',
                    style: context.textStyles.labelSmall?.semiBold.withColor(color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              result.content.length > 100
                  ? '${result.content.substring(0, 100)}...'
                  : result.content,
              style: context.textStyles.bodySmall?.withColor(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              DateFormat('MMM dd, yyyy • HH:mm').format(result.analyzedAt),
              style: context.textStyles.bodySmall?.withColor(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreachHistoryCard extends StatelessWidget {
  final BreachCheckResult result;

  const _BreachHistoryCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.isCompromised ? SecurityColors.danger : SecurityColors.success;
    
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.isCompromised ? Icons.warning : Icons.check_circle,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    result.email,
                    style: context.textStyles.titleSmall?.semiBold,
                    overflow: TextOverflow.ellipsis,
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
                    result.isCompromised
                        ? '${result.breachCount} ${result.breachCount == 1 ? "breach" : "breaches"}'
                        : 'Safe',
                    style: context.textStyles.labelSmall?.semiBold.withColor(color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              DateFormat('MMM dd, yyyy • HH:mm').format(result.checkedAt),
              style: context.textStyles.bodySmall?.withColor(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
