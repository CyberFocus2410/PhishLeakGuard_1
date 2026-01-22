import 'package:phishleak_guard/models/breach_result.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Service for checking data breaches using Firebase Cloud Functions
/// This avoids CORS issues by proxying the API call through the backend
class BreachCheckService {
  static const _uuid = Uuid();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Check if email has been in any breaches using Firebase Cloud Function
  Future<BreachCheckResult> checkEmail(String email) async {
    try {
      final emailLower = email.trim().toLowerCase();
      
      debugPrint('Checking breaches for email: $emailLower');
      
      // Call Firebase Cloud Function
      final callable = _functions.httpsCallable('checkEmailBreach');
      final result = await callable.call<Map<String, dynamic>>({
        'email': emailLower,
      });

      final data = result.data;
      debugPrint('Breach check result: $data');

      if (data == null) {
        throw Exception('No data returned from breach check');
      }

      final isCompromised = data['isCompromised'] as bool? ?? false;
      final breachCount = data['breachCount'] as int? ?? 0;
      final breachesData = data['breaches'] as List<dynamic>? ?? [];

      final breaches = breachesData
          .map((b) => _parseBreachData(b as Map<String, dynamic>))
          .toList();

      return BreachCheckResult(
        id: _uuid.v4(),
        email: email,
        isCompromised: isCompromised,
        breachCount: breachCount,
        breaches: breaches,
        checkedAt: DateTime.now(),
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Firebase Functions error: ${e.code} - ${e.message}');
      
      // Handle specific error codes
      if (e.code == 'failed-precondition') {
        throw Exception(
          'Breach checking service is not configured properly. '
          'Please contact support.'
        );
      } else if (e.code == 'resource-exhausted') {
        throw Exception('Rate limit exceeded. Please try again in a few moments.');
      } else if (e.code == 'invalid-argument') {
        throw Exception('Invalid email format. Please check and try again.');
      }
      
      throw Exception('Unable to check breaches: ${e.message}');
    } catch (e) {
      debugPrint('Error checking breaches: $e');
      throw Exception('Unable to check breaches at this time. Please try again later.');
    }
  }

  /// Parse breach data from Firebase Function response
  Breach _parseBreachData(Map<String, dynamic> data) {
    return Breach(
      name: data['name'] as String? ?? 'Unknown',
      domain: data['domain'] as String? ?? '',
      breachDate: _parseDate(data['breachDate'] as String?),
      affectedAccounts: data['affectedAccounts'] as int? ?? 0,
      dataTypes: (data['dataTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      severity: data['severity'] as String? ?? 'Medium',
      description: data['description'] as String? ?? '',
    );
  }

  /// Parse date string to DateTime
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      debugPrint('Error parsing date: $dateStr');
      return DateTime.now();
    }
  }

  /// Get all known breaches (not implemented as we focus on email-specific checks)
  Future<List<Breach>> getAllBreaches() async {
    // This endpoint is not needed for email-specific breach checking
    return [];
  }
}
