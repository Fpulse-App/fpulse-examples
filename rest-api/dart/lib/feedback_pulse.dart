import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class FeedbackResult {
  final bool success;
  final int? feedbackId;
  final String? error;

  FeedbackResult({required this.success, this.feedbackId, this.error});

  factory FeedbackResult.fromJson(Map<String, dynamic> json) {
    return FeedbackResult(
      success: json['success'] ?? false,
      feedbackId: json['feedback_id'],
      error: json['error'],
    );
  }
}

class FeedbackPulse {
  static const String _baseUrl = 'https://api.fpulse.app/v1';

  final String apiKey;
  final String appVersion;
  final String appType;
  final String environment;

  FeedbackPulse({
    required this.apiKey,
    required this.appVersion,
    this.appType = 'ios',
    this.environment = 'production',
  });

  Map<String, String> get _deviceInfo {
    return {
      'os': Platform.operatingSystem,
      'os_version': Platform.operatingSystemVersion,
      'locale': Platform.localeName,
    };
  }

  Future<FeedbackResult> submit({
    required String sentiment,
    String? comment,
    String? screenId,
    String? userIdentifier,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final body = {
        'sentiment': sentiment,
        'app_version': appVersion,
        'app_type': appType,
        'environment': environment,
        'device_info': _deviceInfo,
        if (comment != null) 'comment': comment,
        if (screenId != null) 'screen_id': screenId,
        if (userIdentifier != null) 'user_identifier': userIdentifier,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/feedback'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return FeedbackResult.fromJson(data);
    } catch (e) {
      return FeedbackResult(success: false, error: e.toString());
    }
  }
}

// Usage Example
// final client = FeedbackPulse(
//   apiKey: 'fp_your_api_key_here',
//   appVersion: '2.1.0',
//   appType: Platform.isIOS ? 'ios' : 'android',
//   environment: kReleaseMode ? 'production' : 'development',
// );
//
// final result = await client.submit(
//   sentiment: 'positive',
//   comment: 'Flutter is amazing!',
//   screenId: 'home_screen',
// );
//
// if (result.success) {
//   print('Feedback submitted: ${result.feedbackId}');
// } else {
//   print('Error: ${result.error}');
// }
