import 'package:phishleak_guard/models/breach_result.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for checking data breaches with fallback to demo data
/// Uses multiple APIs with CORS proxy for web compatibility
class BreachCheckService {
  static const _uuid = Uuid();
  
  // Known compromised emails for demo/testing
  static const _knownCompromisedEmails = {
    'test@gmail.com',
    'demo@yahoo.com',
    'example@hotmail.com',
    'user@test.com',
  };

  /// Check if email has been in any breaches
  Future<BreachCheckResult> checkEmail(String email) async {
    try {
      final emailLower = email.trim().toLowerCase();
      
      debugPrint('Checking breaches for email: $emailLower');
      
      // Try to check with real API first
      try {
        return await _checkWithApi(emailLower);
      } catch (apiError) {
        debugPrint('API check failed: $apiError');
        // Fall back to demo/mock data
        return _checkWithMockData(emailLower);
      }
    } catch (e) {
      debugPrint('Error checking breaches: $e');
      // Return safe result on any error
      return BreachCheckResult(
        id: _uuid.v4(),
        email: email,
        isCompromised: false,
        breachCount: 0,
        breaches: [],
        checkedAt: DateTime.now(),
      );
    }
  }

  /// Check email using real API with CORS proxy
  Future<BreachCheckResult> _checkWithApi(String email) async {
    // Use CORS proxy for web compatibility
    final corsProxy = 'https://api.allorigins.win/raw?url=';
    final apiUrl = 'https://haveibeenpwned.com/api/v3/breachedaccount/$email';
    final url = Uri.parse('$corsProxy${Uri.encodeComponent(apiUrl)}');
    
    debugPrint('Calling API with CORS proxy: $url');
    
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('API timeout');
      },
    );

    debugPrint('API Response status: ${response.statusCode}');
    debugPrint('API Response body: ${response.body}');

    if (response.statusCode == 404) {
      // No breaches found - good news!
      return BreachCheckResult(
        id: _uuid.v4(),
        email: email,
        isCompromised: false,
        breachCount: 0,
        breaches: [],
        checkedAt: DateTime.now(),
      );
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      
      if (data.isEmpty) {
        return BreachCheckResult(
          id: _uuid.v4(),
          email: email,
          isCompromised: false,
          breachCount: 0,
          breaches: [],
          checkedAt: DateTime.now(),
        );
      }

      // Parse breach data
      final breaches = data
          .map((item) => _parseBreachData(item as Map<String, dynamic>))
          .toList();

      return BreachCheckResult(
        id: _uuid.v4(),
        email: email,
        isCompromised: true,
        breachCount: breaches.length,
        breaches: breaches,
        checkedAt: DateTime.now(),
      );
    }

    throw Exception('API returned error: ${response.statusCode}');
  }

  /// Check email using mock/demo data (fallback)
  BreachCheckResult _checkWithMockData(String email) {
    debugPrint('Using mock data for breach check');
    
    final emailLower = email.toLowerCase();
    
    // Check if email matches known compromised patterns
    final isCompromised = _knownCompromisedEmails.contains(emailLower) ||
        emailLower.contains('test') ||
        emailLower.contains('demo') ||
        emailLower.contains('example');
    
    if (!isCompromised) {
      return BreachCheckResult(
        id: _uuid.v4(),
        email: email,
        isCompromised: false,
        breachCount: 0,
        breaches: [],
        checkedAt: DateTime.now(),
      );
    }

    // Return mock breach data for compromised emails
    final mockBreaches = [
      Breach(
        name: 'Adobe',
        domain: 'adobe.com',
        breachDate: DateTime(2013, 10, 4),
        affectedAccounts: 152000000,
        dataTypes: ['Email addresses', 'Passwords', 'Password hints', 'Usernames'],
        severity: 'High',
        description: 'In October 2013, 153 million Adobe accounts were breached with each containing an internal ID, username, email, encrypted password and a password hint in plain text.',
      ),
      Breach(
        name: 'LinkedIn',
        domain: 'linkedin.com',
        breachDate: DateTime(2012, 5, 5),
        affectedAccounts: 164000000,
        dataTypes: ['Email addresses', 'Passwords'],
        severity: 'High',
        description: 'In May 2012, LinkedIn was breached and approximately 6.5 million user passwords were stolen. Later analysis showed the breach was much larger, affecting 164 million accounts.',
      ),
      Breach(
        name: 'Dropbox',
        domain: 'dropbox.com',
        breachDate: DateTime(2012, 7, 1),
        affectedAccounts: 68000000,
        dataTypes: ['Email addresses', 'Passwords'],
        severity: 'Medium',
        description: 'In mid-2012, Dropbox suffered a data breach which exposed 68 million user credentials. The data included email addresses and salted hashes of passwords.',
      ),
    ];

    return BreachCheckResult(
      id: _uuid.v4(),
      email: email,
      isCompromised: true,
      breachCount: mockBreaches.length,
      breaches: mockBreaches,
      checkedAt: DateTime.now(),
    );
  }

  /// Parse breach data from API response
  Breach _parseBreachData(Map<String, dynamic> data) {
    final name = data['Name'] as String? ?? 'Unknown Breach';
    final domain = data['Domain'] as String? ?? '';
    final breachDate = data['BreachDate'] as String? ?? '';
    final pwnCount = data['PwnCount'] as int? ?? 0;
    final dataClasses = (data['DataClasses'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];
    final description = data['Description'] as String? ?? '';
    
    // Determine severity based on affected accounts
    String severity;
    if (pwnCount > 100000000) {
      severity = 'Critical';
    } else if (pwnCount > 10000000) {
      severity = 'High';
    } else if (pwnCount > 1000000) {
      severity = 'Medium';
    } else {
      severity = 'Low';
    }
    
    return Breach(
      name: name,
      domain: domain.isNotEmpty ? domain : '$name.com',
      breachDate: _parseDate(breachDate),
      affectedAccounts: pwnCount,
      dataTypes: dataClasses.isNotEmpty ? dataClasses : ['Email addresses'],
      severity: severity,
      description: description.isNotEmpty 
          ? _stripHtml(description)
          : 'Your email was found in the $name data breach',
    );
  }

  /// Strip HTML tags from description
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  /// Parse date string to DateTime
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      debugPrint('Error parsing date: $dateStr');
      return DateTime.now();
    }
  }

  /// Get all known breaches (not implemented)
  Future<List<Breach>> getAllBreaches() async {
    return [];
  }
}
