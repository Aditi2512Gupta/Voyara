import 'package:flutter/material.dart';

import '../../data/models/destination_model.dart';

class SearchDestinationCard extends StatelessWidget {
  const SearchDestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  final DestinationModel destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.travel_explore),
        ),
        title: Text(
          destination.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          destination.location.isEmpty
              ? "Unknown location"
              : destination.location,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
