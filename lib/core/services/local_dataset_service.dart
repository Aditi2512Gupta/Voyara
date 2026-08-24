import 'dart:convert';
import 'package:flutter/services.dart';

class LocalDatasetService {

  Future<List<dynamic>> loadDestinations() async {

    final jsonString = await rootBundle.loadString(
      'assets/data/voyara_local.json',
    );

    return jsonDecode(jsonString);
  }

}