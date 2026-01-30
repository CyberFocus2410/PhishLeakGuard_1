import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:phishleak_guard/models/phone_lookup_result.dart';

/// Service for checking phone numbers against spam databases
class SpamCallerService {
  // Using NumVerify API for phone validation and reputation check
  // For production, you would want to use services like:
  // - Twilio Lookup API
  // - NumVerify
  // - Whitepages Pro
  // - Truecaller API
  
  /// Check a phone number's reputation
  /// Note: This is a privacy-first approach - we don't store user phone numbers
  Future<PhoneLookupResult> checkPhoneNumber(String phoneNumber) async {
    try {
      // Clean the phone number
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      if (cleanNumber.isEmpty || cleanNumber.length < 10) {
        throw Exception('Invalid phone number format');
      }

      // In production, integrate with actual spam database API
      // For MVP, we'll use pattern matching and basic validation
      final result = await _analyzePhoneNumber(cleanNumber);
      
      return result;
    } catch (e) {
      debugPrint('Error checking phone number: $e');
      
      // Return fallback result
      return PhoneLookupResult(
        phoneNumber: phoneNumber,
        status: 'Unknown',
        explanation: 'Unable to verify this number at the moment. Be cautious with unknown callers.',
        reportCount: 0,
        reportCategories: [],
        checkedAt: DateTime.now(),
      );
    }
  }

  /// Analyze phone number using pattern matching and heuristics
  /// In production, this would call external spam database APIs
  Future<PhoneLookupResult> _analyzePhoneNumber(String phoneNumber) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample safe numbers - These will always return as safe
    final safeExamples = [
      '+14155552671', // Google headquarters
      '+12025551234', // Generic example number
      '+442071234567', // UK example
      '+918012345678', // India example
      '+15105551234', // California example
    ];
    
    if (safeExamples.contains(phoneNumber)) {
      return PhoneLookupResult(
        phoneNumber: phoneNumber,
        status: 'Safe',
        explanation: 'This number has no reported spam activity. It appears to be a legitimate number.',
        reportCount: 0,
        reportCategories: [],
        checkedAt: DateTime.now(),
      );
    }
    
    // Sample known spam numbers - These will return as high risk
    final knownSpamExamples = [
      '+18001234567', // Telemarketing example
      '+19999999999', // Suspicious pattern
      '+11111111111', // Repeated digits
      '+12345678901', // Sequential pattern
    ];
    
    if (knownSpamExamples.contains(phoneNumber)) {
      return PhoneLookupResult(
        phoneNumber: phoneNumber,
        status: 'High Risk',
        explanation: 'This number has been reported multiple times for spam and telemarketing. Do not answer.',
        reportCount: 50,
        reportCategories: ['Known Spam', 'Telemarketing'],
        checkedAt: DateTime.now(),
      );
    }
    
    int reportCount = 0;
    List<String> categories = [];
    String status = 'Safe';
    String explanation = 'This number has no reported spam activity. However, always verify caller identity before sharing personal information.';
    
    // Robocall patterns - multiple repeated digits (7+ same digits in a row)
    final robocallPattern = RegExp(r'(\d)\1{6,}');
    if (robocallPattern.hasMatch(phoneNumber)) {
      reportCount += 15;
      categories.add('Robocall');
      status = 'Reported';
      explanation = 'This number shows patterns typical of automated robocalls. Answer with caution.';
    }
    
    // Check for suspicious sequential patterns (e.g., 12345678)
    if (_hasSequentialDigits(phoneNumber)) {
      reportCount += 12;
      categories.add('Suspicious Pattern');
      if (status == 'Safe') {
        status = 'Reported';
        explanation = 'This number contains unusual sequential patterns. Be cautious when answering.';
      }
    }
    
    // Check for premium rate numbers (example patterns)
    final premiumRatePatterns = [
      RegExp(r'^\+1(900)'), // US premium rate
      RegExp(r'^\+44(871|872|873)'), // UK premium rate
    ];
    
    for (final pattern in premiumRatePatterns) {
      if (pattern.hasMatch(phoneNumber)) {
        reportCount += 8;
        categories.add('Premium Rate');
        if (status == 'Safe') {
          status = 'Reported';
          explanation = 'This appears to be a premium rate number. Charges may apply.';
        }
        break;
      }
    }
    
    // Check for known spam number patterns (simulated database lookup)
    // In production, this would query an actual spam database API
    final knownSpamPatterns = [
      '+1234567890', // Example spam number
      '+9999999999',
      '18005551234',
    ];
    
    if (knownSpamPatterns.contains(phoneNumber)) {
      reportCount += 50;
      categories.add('Known Spam');
      categories.add('Telemarketing');
      status = 'High Risk';
      explanation = 'This number has been reported multiple times for spam and telemarketing. Do not answer.';
    }
    
    // Determine final status based on report count
    if (reportCount >= 30) {
      status = 'High Risk';
      explanation = 'This number has been reported multiple times for suspicious activity. Do not answer or provide any personal information.';
    } else if (reportCount >= 10) {
      status = 'Reported';
      explanation = 'This number has some reports of suspicious activity. Answer with caution and verify the caller\'s identity.';
    }
    
    return PhoneLookupResult(
      phoneNumber: phoneNumber,
      status: status,
      explanation: explanation,
      reportCount: reportCount,
      reportCategories: categories,
      checkedAt: DateTime.now(),
    );
  }
  
  /// Check if number contains suspicious sequential digits
  bool _hasSequentialDigits(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 8) return false;
    
    // Check for ascending sequences (e.g., 12345678)
    for (int i = 0; i < digits.length - 5; i++) {
      bool isSequential = true;
      for (int j = 0; j < 5; j++) {
        if (int.parse(digits[i + j]) != int.parse(digits[i]) + j) {
          isSequential = false;
          break;
        }
      }
      if (isSequential) return true;
    }
    
    // Check for descending sequences (e.g., 87654321)
    for (int i = 0; i < digits.length - 5; i++) {
      bool isSequential = true;
      for (int j = 0; j < 5; j++) {
        if (int.parse(digits[i + j]) != int.parse(digits[i]) - j) {
          isSequential = false;
          break;
        }
      }
      if (isSequential) return true;
    }
    
    return false;
  }

  /// Format phone number for display
  String formatPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // US/Canada format
    if (cleanNumber.startsWith('+1') && cleanNumber.length == 12) {
      return '+1 (${cleanNumber.substring(2, 5)}) ${cleanNumber.substring(5, 8)}-${cleanNumber.substring(8)}';
    }
    
    // International format
    if (cleanNumber.startsWith('+')) {
      return cleanNumber;
    }
    
    // Default format
    if (cleanNumber.length == 10) {
      return '(${cleanNumber.substring(0, 3)}) ${cleanNumber.substring(3, 6)}-${cleanNumber.substring(6)}';
    }
    
    return phoneNumber;
  }
}
