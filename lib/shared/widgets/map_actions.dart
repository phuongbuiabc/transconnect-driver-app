import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLinks {
  static bool valid(double? lat, double? lon) =>
      lat != null &&
      lon != null &&
      lat.isFinite &&
      lon.isFinite &&
      lat.abs() <= 90 &&
      lon.abs() <= 180;
  static Uri view(double lat, double lon) => Uri.https(
    'www.google.com',
    '/maps/search/',
    {'api': '1', 'query': '$lat,$lon'},
  );
  static Uri directions(double lat, double lon) => Uri.https(
    'www.google.com',
    '/maps/dir/',
    {'api': '1', 'destination': '$lat,$lon'},
  );
  static Uri other(double lat, double lon) =>
      Uri.parse('geo:$lat,$lon?q=$lat,$lon');
}

class MapActions extends StatefulWidget {
  final double? latitude, longitude;
  const MapActions({
    super.key,
    required this.latitude,
    required this.longitude,
  });
  @override
  State<MapActions> createState() => _MapActionsState();
}

class _MapActionsState extends State<MapActions> {
  bool opening = false;
  Future<void> open(Uri uri, {Uri? fallback}) async {
    if (opening) return;
    setState(() => opening = true);
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      /* Try the HTTPS fallback below. */
    }
    if (!launched && fallback != null) {
      try {
        launched = await launchUrl(
          fallback,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        /* Report failure without discarding the location. */
      }
    }
    if (!mounted) return;
    setState(() => opening = false);
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không mở được ứng dụng bản đồ. Vui lòng thử lại.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final valid = MapLinks.valid(widget.latitude, widget.longitude);
    final lat = widget.latitude ?? 0, lon = widget.longitude ?? 0;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: !valid || opening
              ? null
              : () => open(MapLinks.view(lat, lon)),
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('Google Maps'),
        ),
        FilledButton.tonalIcon(
          onPressed: !valid || opening
              ? null
              : () => open(MapLinks.directions(lat, lon)),
          icon: const Icon(Icons.directions_outlined, size: 18),
          label: const Text('Chỉ đường'),
        ),
        TextButton(
          onPressed: !valid || opening
              ? null
              : () => open(
                  MapLinks.other(lat, lon),
                  fallback: MapLinks.view(lat, lon),
                ),
          child: const Text('Ứng dụng khác'),
        ),
      ],
    );
  }
}
