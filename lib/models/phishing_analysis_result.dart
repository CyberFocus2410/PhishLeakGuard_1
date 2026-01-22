/// Result of phishing analysis
class PhishingAnalysisResult {
  final String id;
  final String inputType; // 'url', 'email', 'sms'
  final String content;
  final int riskScore; // 0-100
  final String severity; // 'Low', 'Medium', 'High', 'Critical'
  final bool isSafe;
  final List<ThreatFlag> threats;
  final DateTime analyzedAt;

  PhishingAnalysisResult({
    required this.id,
    required this.inputType,
    required this.content,
    required this.riskScore,
    required this.severity,
    required this.isSafe,
    required this.threats,
    required this.analyzedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'inputType': inputType,
        'content': content,
        'riskScore': riskScore,
        'severity': severity,
        'isSafe': isSafe,
        'threats': threats.map((t) => t.toJson()).toList(),
        'analyzedAt': analyzedAt.toIso8601String(),
      };

  factory PhishingAnalysisResult.fromJson(Map<String, dynamic> json) =>
      PhishingAnalysisResult(
        id: json['id'] as String,
        inputType: json['inputType'] as String,
        content: json['content'] as String,
        riskScore: json['riskScore'] as int,
        severity: json['severity'] as String,
        isSafe: json['isSafe'] as bool,
        threats: (json['threats'] as List)
            .map((t) => ThreatFlag.fromJson(t as Map<String, dynamic>))
            .toList(),
        analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      );
}

/// Individual threat detected
class ThreatFlag {
  final String type; // 'domain', 'content', 'link', 'header'
  final String title;
  final String description;
  final String severity;

  ThreatFlag({
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'description': description,
        'severity': severity,
      };

  factory ThreatFlag.fromJson(Map<String, dynamic> json) => ThreatFlag(
        type: json['type'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        severity: json['severity'] as String,
      );
}
