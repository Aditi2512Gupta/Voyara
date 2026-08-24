import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DestinationGallery extends StatelessWidget {
  const DestinationGallery({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    // Remove empty and duplicate URLs.
    final validImages = images
        .where((url) => url.trim().isNotEmpty)
        .toSet()
        .toList();

    if (validImages.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gallery", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: validImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: validImages[index],
                  width: 140,
                  height: 110,
                  fit: BoxFit.cover,

                  placeholder: (_, __) => Container(
                    width: 140,
                    height: 110,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),

                  errorWidget: (_, __, ___) => Container(
                    width: 140,
                    height: 110,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
