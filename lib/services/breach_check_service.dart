import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:phishleak_guard/models/breach_result.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

/// Service for checking data breaches using HaveIBeenPwned API
class BreachCheckService {
  static const _uuid = Uuid();
  static const _apiBaseUrl = 'https://haveibeenpwned.com/api/v3';
  
  // User agent is required by HaveIBeenPwned API
  static const _userAgent = 'PhishLeakGuard-Flutter-App';

  /// Check if email has been in any breaches using HaveIBeenPwned API
  Future<BreachCheckResult> checkEmail(String email) async {
    try {
      final emailLower = email.trim().toLowerCase();
      
      // Use the paste API endpoint which doesn't require an API key
      // and the range search for password checking
      final breaches = await _fetchBreachesForEmail(emailLower);

      return BreachCheckResult(
        id: _uuid.v4(),
        email: email,
        isCompromised: breaches.isNotEmpty,
        breachCount: breaches.length,
        breaches: breaches,
        checkedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error checking breaches: $e');
      
      // Fallback to informative message
      throw Exception('Unable to check breaches at this time. Please try again later.');
    }
  }

  /// Fetch breaches for an email from HaveIBeenPwned
  Future<List<Breach>> _fetchBreachesForEmail(String email) async {
    try {
      // URL encode the email
      final encodedEmail = Uri.encodeComponent(email);
      final url = Uri.parse('$_apiBaseUrl/breachedaccount/$encodedEmail?truncateResponse=false');
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': _userAgent,
        },
      );

      // 404 means no breaches found (this is expected and good!)
      if (response.statusCode == 404) {
        return [];
      }

      // 200 means breaches were found
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((breach) => _parseBreachData(breach)).toList();
      }

      // 429 means rate limited
      if (response.statusCode == 429) {
        throw Exception('Rate limited. Please wait a moment and try again.');
      }

      // Other error codes
      throw Exception('API returned status ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching breaches from API: $e');
      rethrow;
    }
  }

  /// Parse breach data from HaveIBeenPwned API response
  Breach _parseBreachData(Map<String, dynamic> data) {
    return Breach(
      name: data['Title'] as String? ?? 'Unknown Breach',
      domain: data['Domain'] as String? ?? 'unknown',
      breachDate: _parseDate(data['BreachDate'] as String?),
      affectedAccounts: data['PwnCount'] as int? ?? 0,
      dataTypes: _parseDataClasses(data['DataClasses']),
      severity: _calculateSeverity(data),
      description: data['Description'] as String? ?? 'No description available',
    );
  }

  /// Parse date from string
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Parse data classes (types of data compromised)
  List<String> _parseDataClasses(dynamic dataClasses) {
    if (dataClasses is List) {
      return dataClasses.map((e) => e.toString().toLowerCase()).toList();
    }
    return [];
  }

  /// Calculate severity based on breach data
  String _calculateSeverity(Map<String, dynamic> data) {
    final dataClasses = _parseDataClasses(data['DataClasses']);
    final isSensitive = data['IsSensitive'] as bool? ?? false;
    
    // Check for critical data types
    final hasCriticalData = dataClasses.any((type) => 
      type.contains('password') || 
      type.contains('credit card') ||
      type.contains('social security') ||
      type.contains('bank')
    );

    if (hasCriticalData || isSensitive) return 'Critical';
    
    final hasImportantData = dataClasses.any((type) =>
      type.contains('email') ||
      type.contains('phone') ||
      type.contains('address')
    );

    if (hasImportantData) return 'High';
    
    return 'Medium';
  }

  /// Get all available breach data (for educational purposes)
  /// This returns the most recent breaches from HIBP
  Future<List<Breach>> getAllBreaches() async {
    try {
      final url = Uri.parse('$_apiBaseUrl/breaches');
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': _userAgent,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Return only the 10 most recent breaches
        return data
            .take(10)
            .map((breach) => _parseBreachData(breach))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching all breaches: $e');
      return [];
    }
  }
}
