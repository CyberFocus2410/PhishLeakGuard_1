/// Result of data breach check
class BreachCheckResult {
  final String id;
  final String email;
  final bool isCompromised;
  final int breachCount;
  final List<Breach> breaches;
  final DateTime checkedAt;

  BreachCheckResult({
    required this.id,
    required this.email,
    required this.isCompromised,
    required this.breachCount,
    required this.breaches,
    required this.checkedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'isCompromised': isCompromised,
        'breachCount': breachCount,
        'breaches': breaches.map((b) => b.toJson()).toList(),
        'checkedAt': checkedAt.toIso8601String(),
      };

  factory BreachCheckResult.fromJson(Map<String, dynamic> json) =>
      BreachCheckResult(
        id: json['id'] as String,
        email: json['email'] as String,
        isCompromised: json['isCompromised'] as bool,
        breachCount: json['breachCount'] as int,
        breaches: (json['breaches'] as List)
            .map((b) => Breach.fromJson(b as Map<String, dynamic>))
            .toList(),
        checkedAt: DateTime.parse(json['checkedAt'] as String),
      );
}

/// Individual breach information
class Breach {
  final String name;
  final String domain;
  final DateTime breachDate;
  final int affectedAccounts;
  final List<String> dataTypes; // password, email, credit_card, etc.
  final String severity; // 'Low', 'Medium', 'High', 'Critical'
  final String description;

  Breach({
    required this.name,
    required this.domain,
    required this.breachDate,
    required this.affectedAccounts,
    required this.dataTypes,
    required this.severity,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'domain': domain,
        'breachDate': breachDate.toIso8601String(),
        'affectedAccounts': affectedAccounts,
        'dataTypes': dataTypes,
        'severity': severity,
        'description': description,
      };

  factory Breach.fromJson(Map<String, dynamic> json) => Breach(
        name: json['name'] as String,
        domain: json['domain'] as String,
        breachDate: DateTime.parse(json['breachDate'] as String),
        affectedAccounts: json['affectedAccounts'] as int,
        dataTypes: (json['dataTypes'] as List).cast<String>(),
        severity: json['severity'] as String,
        description: json['description'] as String,
      );
}
