import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;
  String? _token;

  ApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      print('GET Request to: $baseUrl$endpoint');
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      print('GET Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    dynamic data, {
    bool isMultipart = false,
  }) async {
    try {
      final url = '$baseUrl$endpoint';
      print('POST Request to: $url');
      print('POST Data: $data');
      print('Is Multipart: $isMultipart');

      late http.Response response;

      if (isMultipart &&
          data is Map<String, dynamic> &&
          data['image'] is File) {
        final request = http.MultipartRequest('POST', Uri.parse(url));

        // Add headers including Authorization token
        final headers = await _getHeaders();
        headers.remove('Content-Type'); // Remove Content-Type for multipart
        if (_token != null) {
          request.headers['Authorization'] =
              'Bearer $_token'; // Explicitly set Authorization header
        }
        request.headers.addAll(headers);

        final file = data['image'] as File;
        print('File path: ${file.path}');
        print('File exists: ${file.existsSync()}');
        print('File size: ${await file.length()} bytes');
        print(
            'Authorization header present: ${request.headers.containsKey('Authorization')}');
        print('Authorization header: ${request.headers['Authorization']}');
        print('Headers: ${request.headers}');

        // Get file extension from path
        final fileExtension = file.path.split('.').last.toLowerCase();
        final mimeType = fileExtension == 'png' ? 'image/png' : 'image/jpeg';

        final multipartFile = http.MultipartFile(
          'image',
          file.openRead(),
          await file.length(),
          filename: file.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        );

        request.files.add(multipartFile);
        print('Request files: ${request.files}');
        print('Request fields: ${request.fields}');

        final streamedResponse = await request.send();
        print('Upload response status: ${streamedResponse.statusCode}');
        response = await http.Response.fromStream(streamedResponse);
      } else {
        final headers = await _getHeaders();
        print('Request headers: $headers');
        response = await _client.post(
          Uri.parse(url),
          headers: headers,
          body: json.encode(data),
        );
      }

      print('POST Response status: ${response.statusCode}');
      print('POST Response headers: ${response.headers}');
      print('POST Response body: ${response.body}');
      return _handleResponse(response);
    } catch (e, stackTrace) {
      print('POST Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = '$baseUrl$endpoint';
      print('PUT Request to: $url');
      print('PUT Data: $data');
      final headers = await _getHeaders();
      print('Request headers: $headers');
      print(
          'Authorization header present: ${headers.containsKey('Authorization')}');
      print('Authorization header: ${headers['Authorization']}');
      final response = await _client.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      );
      print('PUT Response status: ${response.statusCode}');
      print('PUT Response headers: ${response.headers}');
      print('PUT Response body: ${response.body}');
      return _handleResponse(response);
    } catch (e, stackTrace) {
      print('PUT Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      print('DELETE Request to: $baseUrl$endpoint');
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      print('DELETE Error: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    print('Response Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return json.decode(response.body);
    }

    throw Exception('Server error: ${response.statusCode}');
  }
}
