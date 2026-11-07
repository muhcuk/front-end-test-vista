import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client})
    : _client = client ?? http.Client(),
      baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:3000',
      );

  final http.Client _client;
  final String baseUrl;

  Future<List<Company>> fetchCompanies() async {
    final response = await _client.get(Uri.parse('$baseUrl/companies'));
    _ensureSuccess(response);
    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .map((item) => Company.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createCompany({
    required String name,
    required String registrationNumber,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/companies'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'registrationNumber': registrationNumber,
      }),
    );
    _ensureSuccess(response);
  }

  Future<void> createService({
    required String companyId,
    required String name,
    required String description,
    required double price,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/services'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'companyId': companyId,
        'name': name,
        'description': description,
        'price': price,
      }),
    );
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(body['error']?.toString() ?? 'Request failed');
    } on FormatException {
      throw ApiException('Request failed (${response.statusCode})');
    }
  }
}
