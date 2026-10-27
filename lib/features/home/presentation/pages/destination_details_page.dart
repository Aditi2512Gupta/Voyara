import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../core/providers/location_provider.dart';
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

    final forecastAsync = ref.watch(
      destinationForecastAsyncProvider(destination),
    );

    final reviewsAsync = ref.watch(reviewsProvider(destination.id));

    final currentUser =
        Firebase.apps.isNotEmpty ? FirebaseAuth.instance.currentUser : null;
    final reviewsList = reviewsAsync.valueOrNull;
    final hasReviews = reviewsList != null && reviewsList.isNotEmpty;
    final double liveRating = hasReviews
        ? double.parse((reviewsList.fold<double>(0.0, (s, r) => s + r.rating) / reviewsList.length).toStringAsFixed(1))
        : destination.rating;
    final int liveReviewCount = hasReviews ? reviewsList.length : destination.reviewCount;
    final userReview = currentUser == null || reviewsList == null
        ? null
        : reviewsList.where((r) => r.userId == currentUser.uid).firstOrNull;

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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFree = destination.price == null || destination.price == 0;
    final categoryText = destination.categories.isNotEmpty ? destination.categories.first : "Adventure";

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ========================================================
          // HERO BANNER
          // ========================================================
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'destination-${destination.id}',
                child: buildHeaderImage(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ShareButton(destination: destination),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FavoriteButton(destination: destination, size: 40),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    destination.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),

                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: isDark ? AppColors.secondary : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Rating & Price row matching mockup
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.star, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        liveRating > 0 ? liveRating.toStringAsFixed(1) : "4.6",
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "(${liveReviewCount > 0 ? liveReviewCount : '1.2k'} reviews)",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFree ? AppColors.mintLight : AppColors.orangeLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isFree ? "Free" : "₹${destination.price!.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isFree ? AppColors.primary : AppColors.tertiary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick chips matching mockup: Best Time, Duration, Category
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const InfoChip(
                          icon: Icons.calendar_month,
                          text: "Oct - Mar",
                          label: "Best Time",
                        ),
                        const SizedBox(width: 8),
                        const InfoChip(
                          icon: Icons.timer_outlined,
                          text: "2-4 hours",
                          label: "Duration",
                        ),
                        const SizedBox(width: 8),
                        InfoChip(
                          icon: Icons.category_outlined,
                          text: categoryText,
                          label: "Category",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // WEATHER
                  // ==================================================
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: weatherAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, _) => const Text("Weather unavailable"),
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
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.wb_sunny_outlined,
                                        size: 40,
                                      ),
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

                  const SizedBox(height: 12),

                  // ==================================================
                  // 5-DAY FORECAST
                  // ==================================================
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    size: 18,
                                    color: isDark
                                        ? AppColors.secondary
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "5-Day Forecast",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 18),
                                tooltip: "Refresh forecast",
                                onPressed: () {
                                  ref.invalidate(
                                    destinationForecastAsyncProvider(destination),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          forecastAsync.when(
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (_, _) => Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Forecast unavailable",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: () {
                                        ref.invalidate(
                                          destinationForecastAsyncProvider(
                                            destination,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.refresh, size: 16),
                                      label: const Text("Retry"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            data: (forecastList) {
                              if (forecastList.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      "Forecast unavailable",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                );
                              }

                              return SizedBox(
                                height: 140,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: forecastList.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (context, index) {
                                    final day = forecastList[index];
                                    final now = DateTime.now();
                                    final isToday = day.date.year == now.year &&
                                        day.date.month == now.month &&
                                        day.date.day == now.day;
                                    const weekdayNames = [
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat',
                                      'Sun'
                                    ];
                                    final weekday = isToday
                                        ? 'Today'
                                        : weekdayNames[day.date.weekday - 1];
                                    final dateText =
                                        "${day.date.day}/${day.date.month}";

                                    return Container(
                                      width: 90,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.cardDark
                                                .withValues(alpha: 0.8)
                                            : AppColors.backgroundLight,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isToday
                                              ? (isDark
                                                  ? AppColors.secondary
                                                  : AppColors.primary)
                                              : (isDark
                                                  ? AppColors.borderDark
                                                  : AppColors.borderLight),
                                          width: isToday ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            weekday,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isToday
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              color: isToday
                                                  ? (isDark
                                                      ? AppColors.secondary
                                                      : AppColors.primary)
                                                  : null,
                                            ),
                                          ),
                                          Text(
                                            dateText,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          if (day.icon.isNotEmpty)
                                            Image.network(
                                              'https://openweathermap.org/img/wn/${day.icon}@2x.png',
                                              width: 38,
                                              height: 38,
                                              errorBuilder: (_, _, _) =>
                                                  const Icon(
                                                Icons.wb_sunny_outlined,
                                                size: 28,
                                              ),
                                            ),
                                          Text(
                                            "${day.maxTemp.toStringAsFixed(0)}° / ${day.minTemp.toStringAsFixed(0)}°",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            day.condition,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
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
                        text: liveRating > 0
                            ? (liveReviewCount > 0
                                ? "${liveRating.toStringAsFixed(1)} ($liveReviewCount)"
                                : liveRating.toStringAsFixed(1))
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
                              liveRating > 0
                                  ? (liveReviewCount > 0
                                      ? "${liveRating.toStringAsFixed(1)} ($liveReviewCount ${liveReviewCount == 1 ? 'review' : 'reviews'})"
                                      : liveRating.toStringAsFixed(1))
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
                      return Column(
                        children: [
                          ReviewsSection(
                            destinationId: destination.id,
                            reviews: reviews,
                            currentUserId: currentUser?.uid,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),

                  FilledButton.icon(
                    onPressed: () {
                      if (currentUser == null) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text("Please log in to write a review"),
                            action: SnackBarAction(
                              label: "Log In",
                              onPressed: () => context.push('/login'),
                            ),
                          ),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        builder: (_) => AddReviewDialog(
                          destinationId: destination.id,
                          existingReview: userReview,
                        ),
                      );
                    },
                    icon: Icon(userReview != null ? Icons.edit : Icons.rate_review),
                    label: Text(
                      userReview != null ? "Edit Your Review" : "Write a Review",
                    ),
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
                          final currentPos =
                              ref.read(currentLocationProvider).valueOrNull;
                          MapLauncher.openDirections(
                            destinationLatitude: hotel.latitude,
                            destinationLongitude: hotel.longitude,
                            originLatitude: currentPos?.latitude,
                            originLongitude: currentPos?.longitude,
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

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final currentPos =
                            ref.read(currentLocationProvider).valueOrNull;
                        MapLauncher.openDirections(
                          destinationLatitude: destination.latitude,
                          destinationLongitude: destination.longitude,
                          originLatitude: currentPos?.latitude,
                          originLongitude: currentPos?.longitude,
                        );
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Get Directions in Google Maps',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Turn-by-turn navigation • Live traffic',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
