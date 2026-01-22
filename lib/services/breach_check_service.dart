import 'package:phishleak_guard/models/breach_result.dart';
import 'package:uuid/uuid.dart';

/// Service for checking data breaches
class BreachCheckService {
  static const _uuid = Uuid();

  // Mock breach database
  static final List<Breach> _mockBreaches = [
    Breach(
      name: 'LinkedIn Data Breach',
      domain: 'linkedin.com',
      breachDate: DateTime(2021, 4, 1),
      affectedAccounts: 700000000,
      dataTypes: ['email', 'name', 'phone', 'location'],
      severity: 'High',
      description: 'Data scraped from public profiles including email addresses and phone numbers.',
    ),
    Breach(
      name: 'Facebook Data Leak',
      domain: 'facebook.com',
      breachDate: DateTime(2021, 4, 3),
      affectedAccounts: 533000000,
      dataTypes: ['email', 'phone', 'name', 'location', 'bio'],
      severity: 'High',
      description: 'Personal data of over 533 million users leaked online.',
    ),
    Breach(
      name: 'Adobe Breach',
      domain: 'adobe.com',
      breachDate: DateTime(2013, 10, 1),
      affectedAccounts: 153000000,
      dataTypes: ['email', 'password', 'username'],
      severity: 'Critical',
      description: 'Passwords were poorly encrypted and usernames and email addresses were also compromised.',
    ),
    Breach(
      name: 'Dropbox Breach',
      domain: 'dropbox.com',
      breachDate: DateTime(2012, 7, 1),
      affectedAccounts: 68000000,
      dataTypes: ['email', 'password'],
      severity: 'High',
      description: 'Email addresses and hashed passwords were stolen.',
    ),
    Breach(
      name: 'Yahoo! Breach',
      domain: 'yahoo.com',
      breachDate: DateTime(2013, 8, 1),
      affectedAccounts: 3000000000,
      dataTypes: ['email', 'password', 'name', 'phone', 'security_questions'],
      severity: 'Critical',
      description: 'The largest breach in history affecting all Yahoo accounts.',
    ),
    Breach(
      name: 'Twitter Breach',
      domain: 'twitter.com',
      breachDate: DateTime(2022, 12, 1),
      affectedAccounts: 235000000,
      dataTypes: ['email', 'name', 'username'],
      severity: 'Medium',
      description: 'Email addresses and usernames exposed through API vulnerability.',
    ),
    Breach(
      name: 'Canva Data Breach',
      domain: 'canva.com',
      breachDate: DateTime(2019, 5, 24),
      affectedAccounts: 137000000,
      dataTypes: ['email', 'name', 'username', 'city', 'password'],
      severity: 'High',
      description: 'User credentials and personal information compromised.',
    ),
  ];

  /// Check if email has been in any breaches
  Future<BreachCheckResult> checkEmail(String email) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate breach check based on email domain
    final emailLower = email.toLowerCase();
    final foundBreaches = <Breach>[];

    // Simple simulation: some emails will "match" breaches
    final emailHash = emailLower.hashCode.abs();
    
    // Use hash to determine which breaches to return (for demo purposes)
    if (emailHash % 3 == 0) {
      // High-risk email
      foundBreaches.addAll([
        _mockBreaches[0], // LinkedIn
        _mockBreaches[1], // Facebook
        _mockBreaches[5], // Twitter
      ]);
    } else if (emailHash % 5 == 0) {
      // Medium-risk email
      foundBreaches.addAll([
        _mockBreaches[3], // Dropbox
        _mockBreaches[6], // Canva
      ]);
    } else if (emailHash % 7 == 0) {
      // Critical-risk email
      foundBreaches.addAll([
        _mockBreaches[2], // Adobe
        _mockBreaches[4], // Yahoo
        _mockBreaches[0], // LinkedIn
      ]);
    }
    // else: No breaches found (safe)

    return BreachCheckResult(
      id: _uuid.v4(),
      email: email,
      isCompromised: foundBreaches.isNotEmpty,
      breachCount: foundBreaches.length,
      breaches: foundBreaches,
      checkedAt: DateTime.now(),
    );
  }

  /// Get all available breach data (for educational purposes)
  List<Breach> getAllBreaches() => List.unmodifiable(_mockBreaches);
}
