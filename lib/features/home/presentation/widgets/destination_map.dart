import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/location_provider.dart';
import '../../data/models/route_model.dart';
import '../../providers/home_provider.dart';

class DestinationMap extends ConsumerStatefulWidget {
  const DestinationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.userLatitude,
    this.userLongitude,
    this.showUserLocation = true,
    this.showRoute = true,
    this.showCaption = true,
    this.height = 250,
    this.destinationTitle,
  });

  final double latitude;
  final double longitude;
  final double? userLatitude;
  final double? userLongitude;
  final bool showUserLocation;
  final bool showRoute;
  final bool showCaption;
  final double height;
  final String? destinationTitle;

  @override
  ConsumerState<DestinationMap> createState() => _DestinationMapState();
}

class _DestinationMapState extends ConsumerState<DestinationMap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitPoints(List<LatLng> points) {
    if (points.isEmpty) return;
    try {
      if (points.length == 1) {
        _mapController.move(points.first, 14);
      } else {
        final bounds = LatLngBounds.fromPoints(points);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
            maxZoom: 15,
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destPoint = LatLng(widget.latitude, widget.longitude);

    // Resolve user location if requested.
    LatLng? userPoint;
    if (widget.showUserLocation) {
      if (widget.userLatitude != null && widget.userLongitude != null) {
        userPoint = LatLng(widget.userLatitude!, widget.userLongitude!);
      } else {
        final locationAsync = ref.watch(currentLocationProvider);
        final pos = locationAsync.valueOrNull;
        if (pos != null && (pos.latitude != 0 || pos.longitude != 0)) {
          userPoint = LatLng(pos.latitude, pos.longitude);
        }
      }
    }

    // Determine route query if user location is valid and showRoute is enabled.
    final canRoute = widget.showRoute &&
        userPoint != null &&
        (userPoint.latitude != widget.latitude ||
            userPoint.longitude != widget.longitude);

    final routeQuery = canRoute
        ? (
            startLat: userPoint.latitude,
            startLon: userPoint.longitude,
            endLat: widget.latitude,
            endLon: widget.longitude,
          )
        : null;

    final routeAsync = routeQuery != null
        ? ref.watch(routeFutureProvider(routeQuery))
        : null;

    final route = routeAsync?.valueOrNull;

    // Listen to route completion to auto-fit camera bounds once loaded.
    if (routeQuery != null) {
      ref.listen<AsyncValue<RouteModel?>>(routeFutureProvider(routeQuery),
          (previous, next) {
        if (next.hasValue &&
            next.value != null &&
            next.value!.points.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _fitPoints(next.value!.points);
          });
        }
      });
    }

    // Prepare markers
    final markers = <Marker>[
      Marker(
        point: destPoint,
        width: 48,
        height: 48,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      ),
    ];

    if (userPoint != null) {
      markers.add(
        Marker(
          point: userPoint,
          width: 44,
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      );
    }

    // Camera initial configuration
    final initialCameraFit = (userPoint != null && route == null)
        ? CameraFit.bounds(
            bounds: LatLngBounds.fromPoints([destPoint, userPoint]),
            padding: const EdgeInsets.all(40),
            maxZoom: 14,
          )
        : null;

    final mapWidget = SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: destPoint,
                initialZoom: 13,
                initialCameraFit: initialCameraFit,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.aditigupta.voyara',
                ),

                if (route != null && route.points.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: route.points,
                        strokeWidth: 4.5,
                        color: AppColors.secondary,
                        borderColor: AppColors.primaryDark,
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),

                MarkerLayer(markers: markers),
              ],
            ),

            // Route status overlay banner/chip (top-left)
            if (canRoute && routeAsync != null && routeQuery != null)
              Positioned(
                top: 10,
                left: 10,
                child: _buildRouteStatusChip(
                  context,
                  routeAsync: routeAsync,
                  route: route,
                  routeQuery: routeQuery,
                  isDark: isDark,
                ),
              ),

            // Map action buttons (bottom-right: re-center controls)
            Positioned(
              bottom: 10,
              right: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (userPoint != null) ...[
                    _buildMapIconButton(
                      icon: Icons.my_location,
                      tooltip: 'Center on my location',
                      isDark: isDark,
                      onPressed: () => _mapController.move(userPoint!, 14),
                    ),
                    const SizedBox(height: 6),
                  ],
                  _buildMapIconButton(
                    icon: Icons.location_on,
                    tooltip: 'Center on destination',
                    isDark: isDark,
                    onPressed: () => _mapController.move(destPoint, 14),
                  ),
                  if (route != null && route.points.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildMapIconButton(
                      icon: Icons.route,
                      tooltip: 'Fit entire route',
                      isDark: isDark,
                      onPressed: () => _fitPoints(route.points),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.showCaption) {
      return mapWidget;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        mapWidget,
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Map preview uses OpenStreetMap/Geoapify estimates without live traffic. Google Maps provides live navigation and traffic information.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapIconButton({
    required IconData icon,
    required String tooltip,
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteStatusChip(
    BuildContext context, {
    required AsyncValue<RouteModel?> routeAsync,
    required RouteModel? route,
    required RouteQuery routeQuery,
    required bool isDark,
  }) {
    if (routeAsync.isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : Colors.white).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(width: 8),
            Text(
              "Finding driving route...",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (route != null && route.points.isNotEmpty) {
      return Tooltip(
        message:
            'Preview driving estimate without live traffic.\nTap "Get Directions in Google Maps" for live navigation.',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.cardDark : Colors.white)
                .withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.directions_car,
                size: 15,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                "Est. ${route.formattedDistance} • ${route.formattedDuration} · No live traffic",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Error or route unavailable state with retry
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : Colors.white).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 6),
          const Text(
            "Route unavailable",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () {
              ref.invalidate(routeFutureProvider(routeQuery));
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 13, color: AppColors.secondary),
                  SizedBox(width: 2),
                  Text(
                    "Retry",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
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