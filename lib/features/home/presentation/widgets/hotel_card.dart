import 'package:flutter/material.dart';

import '../../data/models/hotel_model.dart';

class HotelCard extends StatelessWidget {
  const HotelCard({super.key, required this.hotel, required this.onTap});

  final HotelModel hotel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.hotel)),
        title: Text(hotel.name),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hotel.address),

            if (hotel.rating != null) Text("⭐ ${hotel.rating}"),
          ],
        ),

        trailing: const Icon(Icons.chevron_right),

        onTap: onTap,
      ),
    );
  }
}
