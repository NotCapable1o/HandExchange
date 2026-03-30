import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductLocationMap extends StatefulWidget {
  final double lat;
  final double lng;
  const ProductLocationMap({super.key, required this.lat, required this.lng});

  @override
  State<ProductLocationMap> createState() => _ProductLocationMapState();
}

class _ProductLocationMapState extends State<ProductLocationMap> {
  bool isSatellite = false;
  String distanceText = "Calculating distance...";

  @override
  void initState() {
    super.initState();
    _getDistance();
  }

  Future<void> _getDistance() async {
    try {
      Position pos = await Geolocator.getCurrentPosition();
      double dist = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        widget.lat,
        widget.lng,
      );
      if (mounted) {
        setState(() {
          distanceText = dist > 1000
              ? "${(dist / 1000).toStringAsFixed(1)} km from you"
              : "${dist.toStringAsFixed(0)} meters from you";
        });
      }
    } catch (e) {
      if (mounted) setState(() => distanceText = "Pickup Point: Rangpur");
    }
  }

  Future<void> _openGoogleMaps() async {
    final String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=${widget.lat},${widget.lng}';
    final Uri uri = Uri.parse(googleUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $googleUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(widget.lat, widget.lng),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: isSatellite
                      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                      : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(widget.lat, widget.lng),
                      width: 80,
                      height: 80,
                      child: _RadarPin(),
                    ),
                  ],
                ),
              ],
            ),

            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: _GlassContainer(
                isDark: isDark,
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_walk,
                      color: isDark ? Colors.blue[300] : Colors.blueAccent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        distanceText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _openGoogleMaps,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.map_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 15,
              right: 15,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() => isSatellite = !isSatellite);
                },
                child: _GlassContainer(
                  isDark: isDark,
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isSatellite ? Icons.map : Icons.satellite_alt,
                    color: isDark ? Colors.blue[300] : Colors.blueAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

class _RadarPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.2),
              ),
            )
            .animate(onPlay: (c) => c.repeat())
            .scale(
              duration: 2.seconds,
              begin: const Offset(1, 1),
              end: const Offset(3, 3),
            )
            .fadeOut(),
        const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
      ],
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool isDark;
  const _GlassContainer({
    required this.child,
    this.padding,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.white.withOpacity(0.75),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.white.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: child,
        ),
      ),
    );
  }
}
