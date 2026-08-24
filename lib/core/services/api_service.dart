import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  Future<dynamic> get(String url) async {
    print("REQUEST URL:");
    print(url);

    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));

    print("STATUS CODE: ${response.statusCode}");
    print(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Request failed: ${response.statusCode}');
  }
}
