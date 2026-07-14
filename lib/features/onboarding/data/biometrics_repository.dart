import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class LivenessSessionResponse {
  final String sessionId;
  final String? authToken;

  const LivenessSessionResponse({
    required this.sessionId,
    this.authToken,
  });
}

class VerifyBiometricsResponse {
  final bool isMatch;
  final String livenessDecision;
  final String? errorMessage;

  const VerifyBiometricsResponse({
    required this.isMatch,
    required this.livenessDecision,
    this.errorMessage,
  });
}

class BiometricsRepository {
  final SupabaseClient _client;

  BiometricsRepository(this._client);

  Future<LivenessSessionResponse> createLivenessSession() async {
    final response = await _client.functions.invoke(
      'verify-biometrics',
      headers: {'x-action': 'create-session'},
      body: {},
    );

    if (response.status != 200) {
      throw Exception('Failed to create liveness session: ${response.data}');
    }

    final data = jsonDecode(response.data as String) as Map<String, dynamic>;
    return LivenessSessionResponse(
      sessionId: data['sessionId'] as String,
      authToken: data['authToken'] as String?,
    );
  }

  Future<VerifyBiometricsResponse> verifyBiometrics({
    required String imagePath,
    required Map<String, dynamic> humanTargetFaceCoordinates,
    required String verifySessionId,
  }) async {
    final fields = <String, String>{
      'humanTargetFaceCoordinates': jsonEncode(humanTargetFaceCoordinates),
      'verifySessionId': verifySessionId,
    };

    final file = await http.MultipartFile.fromPath('photo', imagePath);

    final response = await _client.functions.invoke(
      'verify-biometrics',
      headers: {'x-action': 'verify'},
      body: fields,
      files: [file],
    );

    if (response.status != 200) {
      throw Exception('Biometric verification failed: ${response.data}');
    }

    final data = jsonDecode(response.data as String) as Map<String, dynamic>;
    return VerifyBiometricsResponse(
      isMatch: data['isMatch'] as bool,
      livenessDecision: data['livenessDecision'] as String,
      errorMessage: data['errorMessage'] as String?,
    );
  }
}
