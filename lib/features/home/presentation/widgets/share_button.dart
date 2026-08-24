import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/destination_model.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key, required this.destination});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share_outlined),
      onPressed: () {
        final priceText = destination.price != null
            ? "₹${destination.price!.toStringAsFixed(0)}"
            : "N/A";

        Share.share('''
🏝 ${destination.title}

📍 ${destination.location}

⭐ ${destination.rating > 0 ? destination.rating.toStringAsFixed(1) : "N/A"}

🎟 Entry / Ticket Price: $priceText

🗺 https://www.google.com/maps/search/?api=1&query=${destination.latitude},${destination.longitude}

${destination.description}
''');
      },
    );
  }
}
