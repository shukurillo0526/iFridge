// I-Fridge — API Service
// ======================
// Shared HTTP client for all Flutter ↔ Railway backend communication.
// Wraps the http package with typed methods for each endpoint.

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiConfig {
  // Local Ollama-powered backend
  static const String baseUrl = 'http://localhost:8000';

  // Railway production URL (uncomment for deployment):
  // static const String baseUrl =
  //     'https://merry-motivation-production-3529.up.railway.app';
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // ── Recommendations ──────────────────────────────────────────────

  /// Fetch 5-tier recipe recommendations for a user.
  Future<Map<String, dynamic>> getRecommendations({
    required String userId,
    int maxPerTier = 10,
    bool includeTier5 = true,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/recommendations/recommend',
    ).replace(queryParameters: {
      'user_id': userId,
      'max_per_tier': '$maxPerTier',
      'include_tier5': '$includeTier5',
    });

    final response = await _client.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  // ── Vision ───────────────────────────────────────────────────────

  /// Send a grocery receipt image for OCR and AI analysis.
  /// Returns a structured JSON list of detected ingredients and expirations.
  Future<Map<String, dynamic>> parseReceipt({
    required Uint8List imageBytes,
    String filename = 'receipt.jpg',
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/receipt/scan');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({'Accept': 'application/json'}) // No auth header needed for this MVP endpoint yet
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: filename,
        contentType: MediaType('image', 'jpeg'),
      ));

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  /// Send a food image for AI recognition.
  /// Returns categorized predictions (auto_added, confirm, correct).
  Future<Map<String, dynamic>> recognizeImage({
    required String userId,
    required Uint8List imageBytes,
    String filename = 'photo.jpg',
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/vision/recognize?user_id=$userId',
    );

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_headers)
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: filename,
        contentType: MediaType('image', 'jpeg'),
      ));

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  /// Submit a user correction for a vision prediction.
  Future<Map<String, dynamic>> submitCorrection({
    required String userId,
    required String originalPrediction,
    required String correctedIngredientId,
    String? clarifaiConceptId,
    double? confidence,
    String? imageStoragePath,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/vision/correct?user_id=$userId',
    );

    final body = {
      'original_prediction': originalPrediction,
      'corrected_ingredient_id': correctedIngredientId,
      if (clarifaiConceptId != null) 'clarifai_concept_id': clarifaiConceptId,
      if (confidence != null) 'confidence': confidence,
      if (imageStoragePath != null) 'image_storage_path': imageStoragePath,
    };

    final response = await _client.post(
      uri,
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  // ── AI (Local Ollama) ───────────────────────────────────────────

  /// Detect food ingredients in a photo (loose items, not receipts).
  /// Uses the /api/v1/vision/detect-ingredients endpoint.
  Future<Map<String, dynamic>> detectIngredients({
    required Uint8List imageBytes,
    String filename = 'photo.jpg',
  }) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/api/v1/vision/detect-ingredients');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({'Accept': 'application/json'})
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: filename,
        contentType: MediaType('image', 'jpeg'),
      ));

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  /// Get a cooking tip for a recipe step from the local AI.
  Future<Map<String, dynamic>> getCookingTip({
    required String stepText,
    String? question,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/ai/cooking-tip');
    final body = {
      'step_text': stepText,
      if (question != null) 'question': question,
    };
    final response = await _client.post(
      uri,
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Generate a recipe from available ingredients using local AI.
  Future<Map<String, dynamic>> generateRecipe({
    required List<String> ingredients,
    String? cuisine,
    int? maxTimeMinutes,
    int? difficulty,
    int servings = 2,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/ai/generate-recipe');
    final body = {
      'ingredients': ingredients,
      if (cuisine != null) 'cuisine': cuisine,
      if (maxTimeMinutes != null) 'max_time_minutes': maxTimeMinutes,
      if (difficulty != null) 'difficulty': difficulty,
      'servings': servings,
    };
    final response = await _client.post(
      uri,
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Suggest substitutes for a missing ingredient.
  Future<Map<String, dynamic>> suggestSubstitute({
    required String ingredient,
    String? recipeContext,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/ai/substitute');
    final body = {
      'ingredient': ingredient,
      if (recipeContext != null) 'recipe_context': recipeContext,
    };
    final response = await _client.post(
      uri,
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Check AI pipeline health (Ollama status + loaded models).
  Future<Map<String, dynamic>> getAiStatus() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/ai/status');
    final response = await _client.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  // ── Health ───────────────────────────────────────────────────────

  /// Check backend health status.
  Future<Map<String, dynamic>> healthCheck() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/health');
    final response = await _client.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  // ── Internals ────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Accept': 'application/json',
      };

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: response.body,
    );
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
