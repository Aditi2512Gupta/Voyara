import 'package:flutter/material.dart';

class LoadingDestinations extends StatelessWidget {
  const LoadingDestinations({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 280,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}