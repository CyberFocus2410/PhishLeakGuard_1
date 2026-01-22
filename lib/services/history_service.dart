import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phishleak_guard/models/phishing_analysis_result.dart';
import 'package:phishleak_guard/models/breach_result.dart';

/// Service for managing analysis history
class HistoryService {
  static const String _phishingHistoryKey = 'phishing_history';
  static const String _breachHistoryKey = 'breach_history';
  static const int _maxHistoryItems = 20;

  /// Save phishing analysis to history
  Future<void> savePhishingAnalysis(PhishingAnalysisResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getPhishingHistory();
    
    history.insert(0, result);
    
    // Keep only last N items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    final jsonList = history.map((r) => r.toJson()).toList();
    await prefs.setString(_phishingHistoryKey, jsonEncode(jsonList));
  }

  /// Get phishing analysis history
  Future<List<PhishingAnalysisResult>> getPhishingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_phishingHistoryKey);
      
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => PhishingAnalysisResult.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's an error parsing history, return empty list and clear corrupted data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_phishingHistoryKey);
      return [];
    }
  }

  /// Save breach check to history
  Future<void> saveBreachCheck(BreachCheckResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getBreachHistory();
    
    history.insert(0, result);
    
    // Keep only last N items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    final jsonList = history.map((r) => r.toJson()).toList();
    await prefs.setString(_breachHistoryKey, jsonEncode(jsonList));
  }

  /// Get breach check history
  Future<List<BreachCheckResult>> getBreachHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_breachHistoryKey);
      
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => BreachCheckResult.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's an error parsing history, return empty list and clear corrupted data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_breachHistoryKey);
      return [];
    }
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phishingHistoryKey);
    await prefs.remove(_breachHistoryKey);
  }

  /// Clear phishing history
  Future<void> clearPhishingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phishingHistoryKey);
  }

  /// Clear breach history
  Future<void> clearBreachHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_breachHistoryKey);
  }
}
