import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchControllerProvider =
    Provider.autoDispose<SearchController>((ref) {
  final controller = SearchController();

  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});