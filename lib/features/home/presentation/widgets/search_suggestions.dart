import 'package:flutter/material.dart';
import '../../data/models/destination_model.dart';

class SearchSuggestions extends StatelessWidget {
  const SearchSuggestions({
    super.key,
    required this.destinations,
    required this.onTap,
  });

  final List<DestinationModel> destinations;
  final void Function(DestinationModel) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: destinations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final destination = destinations[index];

        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.location_on)),
          title: Text(destination.title),
          subtitle: Text(destination.location),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => onTap(destination),
        );
      },
    );
  }
}
