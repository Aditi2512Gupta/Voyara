import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<dynamic> get(String url) async {
    debugPrint('REQUEST URL:');
    debugPrint(url);

    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));

    debugPrint('STATUS CODE: ');
    debugPrint(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Request failed: ');
  }
}
