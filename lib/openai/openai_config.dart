import 'dart:convert';
import 'package:http/http.dart' as http;

/// OpenAI API configuration and helper methods
class OpenAIConfig {
  static const apiKey = String.fromEnvironment('OPENAI_PROXY_API_KEY');
  static const endpoint = String.fromEnvironment('OPENAI_PROXY_ENDPOINT');

  /// Analyze content for phishing using GPT-4o
  static Future<Map<String, dynamic>> analyzePhishing(String content, String inputType) async {
    if (apiKey.isEmpty || endpoint.isEmpty) {
      throw Exception('OpenAI configuration missing');
    }

    final prompt = '''Analyze the following ${inputType} content for phishing indicators.

Content to analyze:
"""
$content
"""

Analyze this content and provide a detailed security assessment. Look for:
1. Suspicious URLs or domains (typosquatting, IP addresses, unusual TLDs)
2. Phishing keywords and urgent language
3. Requests for sensitive information (passwords, credit cards, SSN)
4. Generic greetings instead of personalized names
5. Shortened URLs that hide destinations
6. Poor grammar or spelling errors
7. Mismatched sender information
8. Threatening or pressure tactics

Provide your analysis as a JSON object with:
- "isSafe": boolean (true if safe, false if phishing/suspicious)
- "riskScore": number 0-100 (0=safe, 100=critical danger)
- "severity": string ("Low", "Medium", "High", or "Critical")
- "threats": array of objects with "type", "title", "description", and "severity"
- "summary": brief explanation of your assessment

Be strict in your analysis - even subtle red flags should be noted.''';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a cybersecurity expert specializing in phishing detection. Output your analysis as a JSON object.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'response_format': {'type': 'json_object'},
        'temperature': 0.3,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final content_text = data['choices'][0]['message']['content'];
    return jsonDecode(content_text);
  }
}
