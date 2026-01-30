/// Result of phone number spam lookup
class PhoneLookupResult {
  final String phoneNumber;
  final String status; // 'Safe', 'Reported', 'High Risk', 'Unknown'
  final String explanation;
  final int reportCount;
  final List<String> reportCategories; // 'Telemarketing', 'Scam', 'Robocall', etc.
  final DateTime checkedAt;

  PhoneLookupResult({
    required this.phoneNumber,
    required this.status,
    required this.explanation,
    required this.reportCount,
    required this.reportCategories,
    required this.checkedAt,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'status': status,
        'explanation': explanation,
        'reportCount': reportCount,
        'reportCategories': reportCategories,
        'checkedAt': checkedAt.toIso8601String(),
      };

  factory PhoneLookupResult.fromJson(Map<String, dynamic> json) =>
      PhoneLookupResult(
        phoneNumber: json['phoneNumber'] as String,
        status: json['status'] as String,
        explanation: json['explanation'] as String,
        reportCount: json['reportCount'] as int,
        reportCategories: (json['reportCategories'] as List)
            .map((e) => e as String)
            .toList(),
        checkedAt: DateTime.parse(json['checkedAt'] as String),
      );
}
