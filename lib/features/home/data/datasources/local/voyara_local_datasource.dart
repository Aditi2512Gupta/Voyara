import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/destination_model.dart';

class VoyaraLocalDataSource {
  const VoyaraLocalDataSource();

  Future<List<DestinationModel>> getDestinations() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/voyara_local.json',
    );

    final List<dynamic> data = jsonDecode(jsonString);

    return data
        .map(
          (json) =>
              DestinationModel.fromVoyara(Map<String, dynamic>.from(json)),
        )
        .toList();
  }
}
