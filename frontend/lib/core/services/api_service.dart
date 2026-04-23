// I-Fridge — API Service
// ======================
// Shared HTTP client for all Flutter ↔ backend communication.
// Auto-detects environment: localhost → local backend, GitHub Pages → Railway.

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiConfig {
  static const String _localUrl = 'http://localhost:8000';
  static const String _productionUrl =
      'https://merry-motivation-production-3529.up.railway.app';

  /// Automatically picks the right backend URL based on where the app is running.
  /// - `flutter run -d Chrome` → localhost:8000 (local Ollama AI)
  /// - GitHub Pages (*.github.io) → Railway production backend
  static String get baseUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      // Running on GitHub Pages or any non-localhost domain → production
      if (host != 'localhost' && host != '127.0.0.1') {
        return _productionUrl;
      }
    }
    // Local development (flutter run, desktop, emulator)
    return _localUrl;
  }

  /// True when connecting to the local backend (Ollama AI available).
  static bool get isLocal => baseUrl == _localUrl;
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
    bool shelfOnly = false,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/ai/generate-recipe');
    final body = {
      'ingredients': ingredients,
      if (cuisine != null) 'cuisine': cuisine,
      if (maxTimeMinutes != null) 'max_time_minutes': maxTimeMinutes,
      if (difficulty != null) 'difficulty': difficulty,
      'servings': servings,
      'shelf_only': shelfOnly,
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

  /// Parse unstructured raw text into a structured recipe object.
  Future<Map<String, dynamic>> parseRawRecipe({
    required String rawText,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/ai/parse-raw');
    final body = {
      'raw_text': rawText,
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

  // ── Inventory ─────────────────────────────────────────────────

  /// Add an item to inventory via the backend (bypasses RLS).
  Future<Map<String, dynamic>> addInventoryItem({
    required String userId,
    required String ingredientName,
    String category = 'Pantry',
    double quantity = 1.0,
    String unit = 'pcs',
    String location = 'Fridge',
    String? expiryDate,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/inventory/add-item');
    final body = {
      'user_id': userId,
      'ingredient_name': ingredientName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'location': location,
      if (expiryDate != null) 'expiry_date': expiryDate,
    };
    final response = await _client.post(
      uri,
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  // ── Ingredient Search ───────────────────────────────────────────

  /// Search ingredients by name (EN, KO, canonical) with full metadata.
  Future<List<Map<String, dynamic>>> searchIngredients(String query, {int limit = 8}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/ingredients/search?q=${Uri.encodeComponent(query)}&limit=$limit');
    final response = await _client.get(uri, headers: _headers);
    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data['ingredients'] ?? []);
  }

  // ── Calorie Analysis ───────────────────────────────────────────

  /// Analyze food items for calorie content.
  Future<Map<String, dynamic>> analyzeCalories(List<String> foodItems) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/calories/analyze');
    final response = await _client.post(
      uri,
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'food_items': foodItems}),
    );
    return _handleResponse(response);
  }

  /// Log a meal's nutrition.
  Future<Map<String, dynamic>> logNutrition({
    required String userId,
    required String mealType,
    required List<Map<String, dynamic>> foodItems,
    String? notes,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/calories/log');
    final response = await _client.post(
      uri,
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'meal_type': mealType,
        'food_items': foodItems,
        if (notes != null) 'notes': notes,
      }),
    );
    return _handleResponse(response);
  }

  /// Get daily nutrition summary.
  Future<Map<String, dynamic>> getDailyNutrition(String userId, {String? date}) async {
    final params = date != null ? '?date=$date' : '';
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/calories/daily/$userId$params');
    final response = await _client.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  /// Analyze a food photo for calorie content via vision AI.
  Future<Map<String, dynamic>> analyzeCaloriesImage(List<int> imageBytes, String filename) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/calories/analyze-image');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: filename));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
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

  // ── Barcode Lookup ───────────────────────────────────────────────

  Future<Map<String, dynamic>?> lookupBarcode(String code) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/barcode/lookup?code=$code'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Inventory CRUD ──────────────────────────────────────────────

  /// Update an inventory item's properties.
  Future<Map<String, dynamic>> updateInventoryItem({
    required String itemId,
    double? quantity,
    String? unit,
    String? itemState,
    String? location,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (quantity != null) body['quantity'] = quantity;
    if (unit != null) body['unit'] = unit;
    if (itemState != null) body['item_state'] = itemState;
    if (location != null) body['location'] = location;
    if (notes != null) body['notes'] = notes;

    final response = await _client.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/inventory/$itemId'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Delete an inventory item.
  Future<Map<String, dynamic>> deleteInventoryItem(String itemId) async {
    final response = await _client.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/inventory/$itemId'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// Consume (decrement) an inventory item.
  Future<Map<String, dynamic>> consumeInventoryItem({
    required String inventoryId,
    required double quantityToConsume,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/inventory/consume'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'inventory_id': inventoryId,
        'quantity_to_consume': quantityToConsume,
      }),
    );
    return _handleResponse(response);
  }

  // ── User Data ───────────────────────────────────────────────────

  /// Initialize a user's profile rows (idempotent).
  Future<Map<String, dynamic>> initUser({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/user/init'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'email': email,
        if (displayName != null) 'display_name': displayName,
      }),
    );
    return _handleResponse(response);
  }

  /// Fetch the complete user dashboard in a single call.
  Future<Map<String, dynamic>> getUserDashboard({
    required String userId,
  }) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/user/$userId/dashboard'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// Update user profile fields.
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? displayName,
    List<String>? dietaryTags,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{'user_id': userId};
    if (displayName != null) body['display_name'] = displayName;
    if (dietaryTags != null) body['dietary_tags'] = dietaryTags;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;

    final response = await _client.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/user/profile'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  // ── Shopping List ───────────────────────────────────────────────

  /// Add an item to the shopping list.
  Future<Map<String, dynamic>> addShoppingItem({
    required String userId,
    required String ingredientName,
    double quantity = 1.0,
    String unit = 'pcs',
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/user/shopping-list'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'ingredient_name': ingredientName,
        'quantity': quantity,
        'unit': unit,
      }),
    );
    return _handleResponse(response);
  }

  /// Toggle a shopping list item's purchased status.
  Future<Map<String, dynamic>> toggleShoppingItem({
    required String itemId,
    required bool isPurchased,
  }) async {
    final response = await _client.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/user/shopping-list/$itemId'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'is_purchased': isPurchased}),
    );
    return _handleResponse(response);
  }

  /// Delete a shopping list item.
  Future<Map<String, dynamic>> deleteShoppingItem(String itemId) async {
    final response = await _client.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/user/shopping-list/$itemId'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ── Meal Plan ───────────────────────────────────────────────────

  /// Plan a recipe for a specific date.
  Future<Map<String, dynamic>> addMealPlan({
    required String userId,
    required String recipeId,
    required String plannedDate,
    String mealType = 'dinner',
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/user/meal-plan'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'recipe_id': recipeId,
        'planned_date': plannedDate,
        'meal_type': mealType,
      }),
    );
    return _handleResponse(response);
  }

  /// Delete a planned meal.
  Future<Map<String, dynamic>> deleteMealPlan(String mealId) async {
    final response = await _client.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/user/meal-plan/$mealId'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// Get AI-powered ingredient substitutions
  Future<Map<String, dynamic>> getSubstitution({
    required String ingredient,
    String? recipeContext,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/ai/substitute'),
      headers: _headers,
      body: jsonEncode({
        'ingredient': ingredient,
        'recipe_context': recipeContext,
      }),
    );
    return _handleResponse(response);
  }

  /// Get server-side computed recipe recommendations (6-signal scoring)
  Future<Map<String, dynamic>> getRecommendations({
    required String userId,
    int maxPerTier = 10,
    bool includeTier5 = true,
    String? cuisineFilter,
  }) async {
    final params = <String, String>{
      'max_per_tier': maxPerTier.toString(),
      'include_tier5': includeTier5.toString(),
    };
    if (cuisineFilter != null) params['cuisine_filter'] = cuisineFilter;

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/v1/recommendations/$userId',
    ).replace(queryParameters: params);

    final response = await _client.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  /// Record that the user cooked a recipe (triggers flavor profile learning)
  Future<Map<String, dynamic>> recordCook({
    required String userId,
    required String recipeId,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/user/cook'),
      headers: _headers,
      body: jsonEncode({'user_id': userId, 'recipe_id': recipeId}),
    );
    return _handleResponse(response);
  }

  /// Track video engagement (like, save, view)
  Future<Map<String, dynamic>> trackEngagement({
    required String userId,
    required String videoId,
    required String action,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/user/engagement'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'video_id': videoId,
        'action': action,
      }),
    );
    return _handleResponse(response);
  }

  /// Extract recipe from YouTube video metadata
  Future<Map<String, dynamic>> extractYouTubeRecipe({
    required String videoTitle,
    String videoDescription = '',
    String channelName = '',
    String? youtubeId,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/ai/youtube-recipe'),
      headers: _headers,
      body: jsonEncode({
        'video_title': videoTitle,
        'video_description': videoDescription,
        'channel_name': channelName,
        'youtube_id': youtubeId,
      }),
    );
    return _handleResponse(response);
  }

  /// Generate smart shopping list from missing ingredients
  Future<Map<String, dynamic>> generateShoppingList({
    required String userId,
    required List<String> recipeIds,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/ai/shopping-list'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'recipe_ids': recipeIds,
      }),
    );
    return _handleResponse(response);
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
