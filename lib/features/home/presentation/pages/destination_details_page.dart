import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/utils/map_launcher.dart';
import '../../providers/home_provider.dart';
import '../../providers/destination_details_provider.dart';
import '../../data/models/destination_model.dart';
import '../../providers/similar_provider.dart';
import '../widgets/destination_card.dart';
import '../widgets/nearby_hotels_section.dart';
import '../widgets/nearby_places_section.dart';
import '../widgets/destination_gallery.dart';
import '../widgets/book_now_button.dart';
import '../widgets/destination_map.dart';
import '../widgets/info_chip.dart';
import '../widgets/favorite_button.dart';
import '../widgets/share_button.dart';
import '../widgets/reviews_section.dart';
import '../../providers/recently_viewed_provider.dart';
import '../widgets/add_review_dialog.dart';
import '../../providers/review_provider.dart';

class DestinationDetailsPage extends ConsumerStatefulWidget {
  const DestinationDetailsPage({super.key, required this.destination});

  final DestinationModel destination;

  @override
  ConsumerState<DestinationDetailsPage> createState() =>
      _DestinationDetailsPageState();
}

class _DestinationDetailsPageState
    extends ConsumerState<DestinationDetailsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(recentlyViewedProvider.notifier).add(widget.destination);
    });
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;

    // IMAGE SOURCE
    final hasDatasetImage = destination.imageUrl.trim().isNotEmpty;

    final imagesAsync = ref.watch(
      destinationImagesProvider(
        '${destination.title}, ${destination.location}',
      ),
    );

    final nearbyPlacesAsync = ref.watch(
      nearbyPlacesProvider((
        lat: destination.latitude,
        lon: destination.longitude,
      )),
    );

    final nearbyHotelsAsync = ref.watch(
      nearbyHotelsProvider((
        lat: destination.latitude,
        lon: destination.longitude,
      )),
    );

    final descriptionAsync = ref.watch(
      destinationDescriptionAsyncProvider(destination),
    );

    final weatherAsync = ref.watch(
      destinationWeatherAsyncProvider(destination),
    );

    final reviewsAsync = ref.watch(reviewsProvider(destination.id));

    final similarAsync = ref.watch(similarDestinationsProvider(destination));

    // ------------------------------------------------------------
    // IMAGE PLACEHOLDER
    // ------------------------------------------------------------

    Widget imageUnavailable({double iconSize = 60}) {
      return Container(
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          size: iconSize,
          color: Colors.grey.shade600,
        ),
      );
    }

    // ------------------------------------------------------------
    // NETWORK IMAGE
    // ------------------------------------------------------------

    Widget networkImage(String url, {bool showProgress = true}) {
      if (url.trim().isEmpty) {
        return imageUnavailable();
      }

      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, __) {
          return Container(
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: showProgress
                ? const CircularProgressIndicator()
                : const SizedBox(),
          );
        },
        errorWidget: (_, __, ___) {
          return imageUnavailable();
        },
      );
    }

    // ------------------------------------------------------------
    // HEADER IMAGE
    // ------------------------------------------------------------

    Widget buildHeaderImage() {
      return imagesAsync.when(
        loading: () {
          // Show dataset image immediately if available
          if (hasDatasetImage) {
            return networkImage(destination.imageUrl, showProgress: false);
          }

          return Container(
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },

        error: (_, __) {
          // Dataset image as fallback
          if (hasDatasetImage) {
            return networkImage(destination.imageUrl);
          }

          return imageUnavailable();
        },

        data: (images) {
          // ------------------------------------------------
          // 1. Try Unsplash/Wikipedia result first
          // ------------------------------------------------
          for (final image in images) {
            final url = image.imageUrl.trim();

            if (url.isNotEmpty) {
              return networkImage(url);
            }
          }

          // ------------------------------------------------
          // 2. Dataset image fallback
          // ------------------------------------------------
          if (hasDatasetImage) {
            return networkImage(destination.imageUrl);
          }

          return imageUnavailable();
        },
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ========================================================
          // HEADER
          // ========================================================
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(destination.title),
              background: Hero(
                tag: 'destination-${destination.id}',
                child: buildHeaderImage(),
              ),
            ),
            actions: [
              ShareButton(destination: destination),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FavoriteButton(destination: destination),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // LOCATION
                  // ==================================================
                  Text(
                    destination.location,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // WEATHER
                  // ==================================================
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: weatherAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text("Weather unavailable"),
                        data: (weather) {
                          if (!weather.isAvailable) {
                            return const Center(
                              child: Text(
                                "Weather unavailable",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (weather.icon != null)
                                    Image.network(
                                      'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                                      width: 55,
                                    ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${weather.temperature?.toStringAsFixed(1) ?? 'N/A'}°C",
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (weather.condition != null)
                                        Text(weather.condition!),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  InfoChip(
                                    icon: Icons.thermostat,
                                    text:
                                        "${weather.temperature?.toStringAsFixed(1) ?? 'N/A'}°C",
                                  ),
                                  if (weather.condition != null)
                                    InfoChip(
                                      icon: Icons.cloud,
                                      text: weather.condition!,
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // ENTRY / TICKET PRICE
                  // ==================================================
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.confirmation_number),
                      title: const Text("Entry / Ticket Price"),
                      subtitle: const Text("If available"),
                      trailing: Text(
                        destination.price != null
                            ? "₹${destination.price!.toStringAsFixed(0)}"
                            : "N/A",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      InfoChip(
                        icon: Icons.star,
                        text: destination.rating > 0
                            ? destination.rating.toStringAsFixed(1)
                            : "N/A",
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // QUICK FACTS
                  // ==================================================
                  Text(
                    "Quick Facts",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (destination.categories.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: destination.categories
                                    .map(
                                      (category) => Chip(label: Text(category)),
                                    )
                                    .toList(),
                              ),
                            ),
                          ListTile(
                            leading: const Icon(Icons.star),
                            title: const Text("Rating"),
                            trailing: Text(
                              destination.rating > 0
                                  ? destination.rating.toStringAsFixed(1)
                                  : "N/A",
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.confirmation_number),
                            title: const Text("Entry / Ticket Price"),
                            trailing: Text(
                              destination.price != null
                                  ? "₹${destination.price!.toStringAsFixed(0)}"
                                  : "N/A",
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.location_on),
                            title: const Text("Location"),
                            trailing: Text(destination.location),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // ABOUT
                  // ==================================================
                  Text(
                    "About",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  const SizedBox(height: 12),

                  descriptionAsync.when(
                    loading: () => const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => Text(
                      destination.description,
                      style: const TextStyle(height: 1.5),
                    ),
                    data: (description) => Text(
                      description.isEmpty
                          ? destination.description
                          : description,
                      style: const TextStyle(height: 1.5),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // GALLERY
                  // ==================================================
                  imagesAsync == null
                      ? DestinationGallery(
                          images: [
                            if (destination.imageUrl.trim().isNotEmpty)
                              destination.imageUrl,
                          ],
                        )
                      : imagesAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, __) {
                            if (destination.imageUrl.trim().isEmpty) {
                              return const SizedBox();
                            }

                            return DestinationGallery(
                              images: [destination.imageUrl],
                            );
                          },
                          data: (images) {
                            final gallery = <String>[];

                            // 1. Dataset image first
                            if (destination.imageUrl.trim().isNotEmpty) {
                              gallery.add(destination.imageUrl);
                            }

                            // 2. Add ALL Unsplash/Wikipedia images
                            for (final image in images) {
                              final url = image.imageUrl.trim();

                              if (url.isNotEmpty && !gallery.contains(url)) {
                                gallery.add(url);
                              }
                            }

                            if (gallery.isEmpty) {
                              return const SizedBox();
                            }

                            return DestinationGallery(images: gallery);
                          },
                        ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // WHAT'S INCLUDED
                  // ==================================================
                  if (destination.includes.isNotEmpty) ...[
                    Text(
                      "What's Included",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...destination.includes.map(
                      (item) => Card(
                        elevation: 0,
                        color: Colors.green.shade50,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(item),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // ==================================================
                  // REVIEWS
                  // ==================================================
                  const SizedBox(height: 30),

                  reviewsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text(error.toString()),
                    data: (reviews) {
                      if (reviews.isEmpty) {
                        return const SizedBox();
                      }

                      return Column(
                        children: [
                          ReviewsSection(reviews: reviews),
                          const SizedBox(height: 30),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  FilledButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            AddReviewDialog(destinationId: destination.id),
                      );
                    },
                    icon: const Icon(Icons.rate_review),
                    label: const Text("Write a Review"),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // NEARBY PLACES
                  // ==================================================
                  nearbyPlacesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(e.toString()),
                    data: (result) {
                      if (result.destinations.isEmpty) {
                        return const Center(
                          child: Text("No nearby attractions found."),
                        );
                      }

                      return NearbyPlacesSection(places: result.destinations);
                    },
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // NEARBY HOTELS
                  // ==================================================
                  nearbyHotelsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(e.toString()),
                    data: (hotels) {
                      if (hotels.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("No nearby hotels found."),
                          ),
                        );
                      }

                      return NearbyHotelsSection(
                        hotels: hotels,
                        onHotelTap: (hotel) {
                          MapLauncher.openGoogleMaps(
                            latitude: hotel.latitude,
                            longitude: hotel.longitude,
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // SIMILAR DESTINATIONS
                  // ==================================================
                  similarAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(e.toString()),
                    data: (places) {
                      if (places.isEmpty) {
                        return const SizedBox();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Similar Destinations",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 280,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: places.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 16),
                              itemBuilder: (_, index) =>
                                  DestinationCard(destination: places[index]),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // LOCATION
                  // ==================================================
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 12),

                  DestinationMap(
                    latitude: destination.latitude,
                    longitude: destination.longitude,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Coordinates",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 4),

                  SelectableText(
                    "${destination.latitude.toStringAsFixed(5)}, "
                    "${destination.longitude.toStringAsFixed(5)}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 12),

                  FilledButton.icon(
                    onPressed: () {
                      MapLauncher.openGoogleMaps(
                        latitude: destination.latitude,
                        longitude: destination.longitude,
                      );
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('Open in Google Maps'),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // SAVE TRIP
                  // ==================================================
                  SizedBox(
                    width: double.infinity,
                    child: BookNowButton(
                      onPressed: () {
                        context.push('/booking', extra: destination);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
