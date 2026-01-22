import 'package:phishleak_guard/models/phishing_analysis_result.dart';
import 'package:uuid/uuid.dart';

/// Service for detecting phishing attempts
class PhishingDetectionService {
  static const _uuid = Uuid();

  // Suspicious domain patterns
  static final List<String> _suspiciousDomains = [
    'paypa1', 'amaz0n', 'micros0ft', 'app1e', 'g00gle', 'faceb00k',
    'netf1ix', 'bankofamer1ca', 'wel1sfargo', 'ch4se',
  ];

  // Suspicious TLDs
  static final List<String> _suspiciousTlds = [
    '.tk', '.ml', '.ga', '.cf', '.gq', '.xyz', '.top', '.click',
  ];

  // Phishing keywords
  static final List<String> _phishingKeywords = [
    'verify account', 'urgent action', 'suspended account', 'confirm identity',
    'click here immediately', 'prize winner', 'claim reward', 'reset password',
    'unusual activity', 'security alert', 'limited time', 'act now',
    'verify your information', 'update payment', 'confirm your account',
  ];

  // Generic greetings (suspicious)
  static final List<String> _genericGreetings = [
    'dear customer', 'dear user', 'dear member', 'valued customer',
    'dear sir/madam', 'hello user',
  ];

  /// Analyze content for phishing indicators
  Future<PhishingAnalysisResult> analyzeContent({
    required String content,
    required String inputType,
  }) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    final threats = <ThreatFlag>[];
    final contentLower = content.toLowerCase();

    // Check for suspicious domains
    _checkDomains(content, threats);

    // Check for phishing keywords
    _checkKeywords(contentLower, threats);

    // Check for generic greetings
    _checkGreetings(contentLower, threats);

    // Check for URLs
    _checkUrls(content, threats);

    // Check for urgency
    _checkUrgency(contentLower, threats);

    // Check for requests for credentials
    _checkCredentialRequests(contentLower, threats);

    // Calculate risk score based on threats
    final riskScore = _calculateRiskScore(threats);
    final severity = _calculateSeverity(riskScore);
    final isSafe = riskScore < 30;

    return PhishingAnalysisResult(
      id: _uuid.v4(),
      inputType: inputType,
      content: content,
      riskScore: riskScore,
      severity: severity,
      isSafe: isSafe,
      threats: threats,
      analyzedAt: DateTime.now(),
    );
  }

  void _checkDomains(String content, List<ThreatFlag> threats) {
    for (final suspicious in _suspiciousDomains) {
      if (content.toLowerCase().contains(suspicious)) {
        threats.add(ThreatFlag(
          type: 'domain',
          title: 'Suspicious Domain Detected',
          description: 'Domain contains common typosquatting pattern: $suspicious',
          severity: 'High',
        ));
      }
    }

    for (final tld in _suspiciousTlds) {
      if (content.toLowerCase().contains(tld)) {
        threats.add(ThreatFlag(
          type: 'domain',
          title: 'Suspicious TLD',
          description: 'Uses uncommon or suspicious top-level domain: $tld',
          severity: 'Medium',
        ));
      }
    }

    // Check for IP address in URL
    final ipPattern = RegExp(r'https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
    if (ipPattern.hasMatch(content)) {
      threats.add(ThreatFlag(
        type: 'domain',
        title: 'IP Address in URL',
        description: 'URL uses IP address instead of domain name',
        severity: 'High',
      ));
    }
  }

  void _checkKeywords(String content, List<ThreatFlag> threats) {
    for (final keyword in _phishingKeywords) {
      if (content.contains(keyword)) {
        threats.add(ThreatFlag(
          type: 'content',
          title: 'Phishing Keyword Detected',
          description: 'Contains common phishing phrase: "$keyword"',
          severity: 'Medium',
        ));
        break; // Only add one keyword threat
      }
    }
  }

  void _checkGreetings(String content, List<ThreatFlag> threats) {
    for (final greeting in _genericGreetings) {
      if (content.contains(greeting)) {
        threats.add(ThreatFlag(
          type: 'content',
          title: 'Generic Greeting',
          description: 'Uses generic greeting instead of your name',
          severity: 'Low',
        ));
        break;
      }
    }
  }

  void _checkUrls(String content, List<ThreatFlag> threats) {
    // Check for shortened URLs
    final shortenedUrlPattern = RegExp(
      r'(bit\.ly|tinyurl\.com|goo\.gl|t\.co|ow\.ly|is\.gd)',
      caseSensitive: false,
    );
    if (shortenedUrlPattern.hasMatch(content)) {
      threats.add(ThreatFlag(
        type: 'link',
        title: 'Shortened URL',
        description: 'Contains shortened URL that hides the real destination',
        severity: 'Medium',
      ));
    }

    // Check for multiple URLs (suspicious)
    final urlPattern = RegExp(r'https?://[^\s]+');
    final urlMatches = urlPattern.allMatches(content);
    if (urlMatches.length > 3) {
      threats.add(ThreatFlag(
        type: 'link',
        title: 'Multiple URLs',
        description: 'Contains unusually many links (${urlMatches.length})',
        severity: 'Medium',
      ));
    }
  }

  void _checkUrgency(String content, List<ThreatFlag> threats) {
    final urgencyPatterns = [
      'within 24 hours', 'immediately', 'right now', 'expires today',
      'last chance', 'final notice', 'act fast',
    ];

    for (final pattern in urgencyPatterns) {
      if (content.contains(pattern)) {
        threats.add(ThreatFlag(
          type: 'content',
          title: 'Urgent Language',
          description: 'Uses pressure tactics to force quick action',
          severity: 'Medium',
        ));
        break;
      }
    }
  }

  void _checkCredentialRequests(String content, List<ThreatFlag> threats) {
    final credentialPatterns = [
      'enter your password', 'provide your ssn', 'social security number',
      'credit card number', 'account number', 'pin code', 'login credentials',
    ];

    for (final pattern in credentialPatterns) {
      if (content.contains(pattern)) {
        threats.add(ThreatFlag(
          type: 'content',
          title: 'Credential Request',
          description: 'Requests sensitive personal information',
          severity: 'Critical',
        ));
        break;
      }
    }
  }

  int _calculateRiskScore(List<ThreatFlag> threats) {
    int score = 0;

    for (final threat in threats) {
      switch (threat.severity) {
        case 'Critical':
          score += 30;
          break;
        case 'High':
          score += 20;
          break;
        case 'Medium':
          score += 12;
          break;
        case 'Low':
          score += 5;
          break;
      }
    }

    return score > 100 ? 100 : score;
  }

  String _calculateSeverity(int riskScore) {
    if (riskScore >= 70) return 'Critical';
    if (riskScore >= 50) return 'High';
    if (riskScore >= 30) return 'Medium';
    return 'Low';
  }
}
