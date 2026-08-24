import 'package:flutter/material.dart';

import '../../data/models/hotel_model.dart';
import 'hotel_card.dart';

class NearbyHotelsSection extends StatelessWidget {
  const NearbyHotelsSection({
    super.key,
    required this.hotels,
    required this.onHotelTap,
  });

  final List<HotelModel> hotels;
  final void Function(HotelModel) onHotelTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nearby Hotels",
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 16),

        ...hotels.take(5).map(
          (hotel) => HotelCard(
            hotel: hotel,
            onTap: () => onHotelTap(hotel),
          ),
        ),
      ],
    );
  }
}