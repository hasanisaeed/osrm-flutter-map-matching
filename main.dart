import 'dart:convert';
import 'package:firestation_manager_app/pages/utils/tile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MapMatchingPage());
  }
}

class MapMatchingPage extends StatefulWidget {
  @override
  State<MapMatchingPage> createState() => _MapMatchingPageState();
}

class _MapMatchingPageState extends State<MapMatchingPage> {
  static const MARKERS_MAX = 4;
  static const startPosition = LatLng(54.9580, 36.4138);
  List<Marker> markers = [];
  List<Polyline> polylines = [];
  String statusMessage = '';

  MapController mapController = MapController();

  void _onTap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      int markersCount = markers.length;
      if (markersCount < MARKERS_MAX) {
        markers.add(
          Marker(
            point: latlng,
            child: const Icon(Icons.location_on, color: Colors.red),
          ),
        );
        polylines.clear();
        return;
      }

      int linesCount = polylines.length;
      if (linesCount >= 1) {
        clearMap();
        return;
      }

      List<String> lngLats = markers.map((marker) {
        return marker.point.longitude.toStringAsFixed(6) +
            ',' +
            marker.point.latitude.toStringAsFixed(6);
      }).toList();

      sendOsrmRequest(lngLats);
    });
  }

  void clearMap([String str = '']) {
    setState(() {
      statusMessage = str;
      markers.clear();
      polylines.clear();
    });
  }

  void sendOsrmRequest(List<String> lngLats) async {
    List<String> radiuses = List.filled(lngLats.length, '49');

    String url =
        'https://router.project-osrm.org/match/v1/driving/${lngLats.join(';')}?overview=simplified&radiuses=${radiuses.join(';')}&generate_hints=false&skip_waypoints=true&gaps=ignore&annotations=nodes&geometries=geojson';

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode >= 200 && response.statusCode < 400) {
        var data = jsonDecode(response.body);
        processOsrmReply(data);
      } else {
        clearMap('Error status: ${response.statusCode}');
      }
    } catch (e) {
      clearMap('Error: $e');
    }
  }

  void processOsrmReply(dynamic data) {
    if (data['code'] != 'Ok') {
      clearMap('Error code: ' + data['code']);
      return;
    }

    MapMatching mapMatching = MapMatching.fromJson(data);

    setState(() {
      polylines.clear();
      mapMatching.matchings.forEach((matching) {
        List<LatLng> points = matching.geometry.coordinates.map((coord) {
          return LatLng(coord[1], coord[0]);
        }).toList();

        polylines.add(
          Polyline(
            points: points,
            strokeWidth: 4.0,
            color: Colors.blue,
          ),
        );
      });

      List<LatLng> allPoints = [];
      polylines.forEach((polyline) {
        allPoints.addAll(polyline.points);
      });

      if (allPoints.isNotEmpty) {
        LatLngBounds bounds = LatLngBounds.fromPoints(allPoints);
        mapController.fitBounds(
          bounds,
          options: const FitBoundsOptions(
            padding: EdgeInsets.all(20),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Flutter Map Matching'),
          backgroundColor: Colors.blue),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: startPosition,
              zoom: 14.0,
              onTap: _onTap,
            ),
            children: [
              openStreetMapTileLayer,
              PolylineLayer(
                polylines: polylines,
              ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          ),
          if (statusMessage.isNotEmpty)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                color: Colors.white70,
                child: Text(
                  statusMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
