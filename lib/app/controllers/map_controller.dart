import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' show pow, cos, sin, pi;
import '../utils/constants.dart';
import '../utils/location_service.dart';

class MapController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  var isLoading = false.obs;

  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  CircleAnnotationManager? circleAnnotationManager;
  PolylineAnnotationManager? polylineAnnotationManager;
  PolygonAnnotationManager? polygonAnnotationManager;

  // Use LocationService's reactive variables
  Rx<geo.Position?> get currentPosition => _locationService.currentPosition;

  RxBool get hasLocationPermission => _locationService.hasLocationPermission;

  RxBool get isLocationServiceEnabled =>
      _locationService.isLocationServiceEnabled;
  PointAnnotation? currentLocationMarker;
  CircleAnnotation? currentLocationCircle;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(Duration.zero, () {
      checkLocationServices();
    });
  }

  Future<void> checkLocationServices() async {
    await _locationService.checkLocationServices();
  }

  Future<geo.Position?> getCurrentLocation() async {
    return await _locationService.getCurrentLocation();
  }

  Future<void> requestLocationPermission() async {
    await _locationService.requestLocationPermission();
  }

  void setMapboxMap(MapboxMap map) {
    mapboxMap = map;
  }

  Future<void> setupAnnotationManagers() async {
    if (mapboxMap == null) return;

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await Future.delayed(Duration(milliseconds: 1000 * attempt));

        if (pointAnnotationManager == null) {
          try {
            pointAnnotationManager =
                await mapboxMap!.annotations.createPointAnnotationManager();
          } catch (e) {
            if (attempt == 3) pointAnnotationManager = null;
          }
        }

        if (circleAnnotationManager == null) {
          try {
            circleAnnotationManager =
                await mapboxMap!.annotations.createCircleAnnotationManager();
          } catch (e) {
            if (attempt == 3) circleAnnotationManager = null;
          }
        }

        if (polylineAnnotationManager == null) {
          try {
            polylineAnnotationManager =
                await mapboxMap!.annotations.createPolylineAnnotationManager();
          } catch (e) {
            if (attempt == 3) polylineAnnotationManager = null;
          }
        }

        if (polygonAnnotationManager == null) {
          try {
            polygonAnnotationManager =
                await mapboxMap!.annotations.createPolygonAnnotationManager();
          } catch (e) {
            if (attempt == 3) polygonAnnotationManager = null;
          }
        }

        if (pointAnnotationManager != null || circleAnnotationManager != null) {
          break;
        }
      } catch (e) {
        if (attempt == 3) {}
      }
    }
  }

  Future<void> addWorkshopLocationMarker(double latitude, double longitude,
      {String? workshopName}) async {
    if (!areValidCoordinates(latitude, longitude)) {
      return;
    }

    if (circleAnnotationManager == null || pointAnnotationManager == null) {
      await setupAnnotationManagers();
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    if (circleAnnotationManager == null) {
      Get.snackbar(
        'Map Notice',
        'Location selected but marker display may be limited',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      final point = Point(coordinates: Position(longitude, latitude));

      final outerCircle = CircleAnnotationOptions(
        geometry: point,
        circleRadius: 25.0,
        circleColor: 0x33FF0000,
        circleStrokeWidth: 0.0,
      );
      await circleAnnotationManager!.create(outerCircle);

      final whiteBorder = CircleAnnotationOptions(
        geometry: point,
        circleRadius: 8.0,
        circleColor: 0xFFFFFFFF,
        circleStrokeColor: 0xFFFF0000,
        circleStrokeWidth: 2.0,
      );
      await circleAnnotationManager!.create(whiteBorder);

      final redCenter = CircleAnnotationOptions(
        geometry: point,
        circleRadius: 5.0,
        circleColor: 0xFFFF0000,
      );
      await circleAnnotationManager!.create(redCenter);

      if (pointAnnotationManager != null &&
          workshopName != null &&
          workshopName.isNotEmpty) {
        final textPoint = Point(
          coordinates: Position(longitude, latitude - 0.0003),
        );

        final textOptions = PointAnnotationOptions(
          geometry: textPoint,
          textField: workshopName,
          textSize: 13.0,
          textColor: 0xFFD32F2F,
          textHaloColor: 0xFFFFFFFF,
          textHaloWidth: 2.5,
          textAnchor: TextAnchor.CENTER,
          textOpacity: 1.0,
        );

        await pointAnnotationManager!.create(textOptions);
      }
    } catch (e) {
      if (circleAnnotationManager != null) {
        final point = Point(coordinates: Position(longitude, latitude));

        final simpleCircle = CircleAnnotationOptions(
          geometry: point,
          circleRadius: 10.0,
          circleColor: 0xFFFF0000,
          circleStrokeColor: 0xFFFFFFFF,
          circleStrokeWidth: 2.0,
        );
        await circleAnnotationManager!.create(simpleCircle);
      }
    }
  }

  Future<void> addCurrentLocationMarker(
      double latitude, double longitude) async {
    if (!areValidCoordinates(latitude, longitude)) {
      return;
    }

    await removeCurrentLocationMarker();

    if (circleAnnotationManager == null || pointAnnotationManager == null) {
      await setupAnnotationManagers();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    try {
      final point = Point(coordinates: Position(longitude, latitude));

      if (circleAnnotationManager != null) {
        final outerCircle = CircleAnnotationOptions(
          geometry: point,
          circleRadius: 25.0,
          circleColor: 0x330066FF,
          circleStrokeWidth: 0.0,
        );
        currentLocationCircle =
            await circleAnnotationManager!.create(outerCircle);
      }

      if (pointAnnotationManager != null) {
        final locationDot = PointAnnotationOptions(
          geometry: point,
          iconImage: "circle-15",
          iconSize: 1.2,
          iconColor: 0xFF0066FF,
        );
        currentLocationMarker =
            await pointAnnotationManager!.create(locationDot);

        final whiteBorder = CircleAnnotationOptions(
          geometry: point,
          circleRadius: 8.0,
          circleColor: 0xFFFFFFFF,
          circleStrokeColor: 0xFF0066FF,
          circleStrokeWidth: 2.0,
        );
        await circleAnnotationManager!.create(whiteBorder);

        final blueCenter = CircleAnnotationOptions(
          geometry: point,
          circleRadius: 5.0,
          circleColor: 0xFF0066FF,
        );
        await circleAnnotationManager!.create(blueCenter);
      }
    } catch (e) {
      if (circleAnnotationManager != null) {
        final point = Point(coordinates: Position(longitude, latitude));
        final simpleCircle = CircleAnnotationOptions(
          geometry: point,
          circleRadius: 10.0,
          circleColor: 0xFF0066FF,
          circleStrokeColor: 0xFFFFFFFF,
          circleStrokeWidth: 2.0,
        );
        await circleAnnotationManager!.create(simpleCircle);
      }
    }
  }

  Future<void> removeCurrentLocationMarker() async {
    if (currentLocationMarker != null && pointAnnotationManager != null) {
      try {
        await pointAnnotationManager!.delete(currentLocationMarker!);
        currentLocationMarker = null;
      } catch (e) {
        currentLocationMarker = null;
      }
    }

    if (currentLocationCircle != null && circleAnnotationManager != null) {
      try {
        await circleAnnotationManager!.delete(currentLocationCircle!);
        currentLocationCircle = null;
      } catch (e) {
        currentLocationCircle = null;
      }
    }
  }

  Future<bool> _tryMultipleCirclesPin(double latitude, double longitude) async {
    if (circleAnnotationManager == null) return false;

    try {
      final point = Point(coordinates: Position(longitude, latitude));

      final outerCircle = CircleAnnotationOptions(
        geometry: point,
        circleRadius: 18.0,
        circleColor: 0xFFFF0000,
        circleStrokeColor: 0xFFFFFFFF,
        circleStrokeWidth: 2.0,
      );

      await circleAnnotationManager!.create(outerCircle);

      final innerCircle = CircleAnnotationOptions(
        geometry: point,
        circleRadius: 8.0,
        circleColor: 0xFFFFFFFF,
      );

      await circleAnnotationManager!.create(innerCircle);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _trySingleCirclePin(double latitude, double longitude) async {
    if (circleAnnotationManager == null) return false;

    try {
      final point = Point(coordinates: Position(longitude, latitude));

      final circle = CircleAnnotationOptions(
        geometry: point,
        circleRadius: 15.0,
        circleColor: 0xFFFF0000,
        circleStrokeColor: 0xFFFFFFFF,
        circleStrokeWidth: 3.0,
      );

      await circleAnnotationManager!.create(circle);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _tryTextOnlyMarker(double latitude, double longitude) async {
    if (pointAnnotationManager == null) return false;

    try {
      final point = Point(coordinates: Position(longitude, latitude));

      final textOptions = PointAnnotationOptions(
        geometry: point,
        textField: "WORKSHOP HERE",
        textSize: 14.0,
        textColor: 0xFFFF0000,
        textHaloColor: 0xFFFFFFFF,
        textHaloWidth: 2.0,
        textAnchor: TextAnchor.CENTER,
      );

      await pointAnnotationManager!.create(textOptions);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _tryAddWorkshopText(double latitude, double longitude) async {
    if (pointAnnotationManager == null) {
      return;
    }

    try {
      final textPoint =
          Point(coordinates: Position(longitude, latitude - 0.0002));

      final textOptions = PointAnnotationOptions(
        geometry: textPoint,
        textField: "Workshop",
        textSize: 12.0,
        textColor: 0xFFFF0000,
        textHaloColor: 0xFFFFFFFF,
        textHaloWidth: 2.0,
        textAnchor: TextAnchor.CENTER,
      );

      await pointAnnotationManager!.create(textOptions);
    } catch (e) {}
  }

  Future<void> debugAnnotationManagers() async {
    if (mapboxMap != null) {
      try {
        final cameraState = await mapboxMap!.getCameraState();
      } catch (e) {}
    }
  }

  Future<void> addMarker(
    double latitude,
    double longitude, {
    String? title,
    String? snippet,
    Map<String, dynamic>? userData,
  }) async {
    if (pointAnnotationManager == null) {
      return;
    }

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final point = Point(coordinates: Position(longitude, latitude));

        final options = PointAnnotationOptions(
          geometry: point,
          textField: title ?? "Marker",
          textOffset: [0.0, -2.0],
          textColor: 0xFF000000,
          textSize: 12.0,
        );

        await pointAnnotationManager!.create(options);
        return;
      } catch (e) {
        if (attempt == 1) {
          await _recreatePointAnnotationManager();
        }
      }
    }
  }

  Future<void> addDestinationMarker(double lat, double lng,
      {required String title}) async {
    if (pointAnnotationManager == null) {
      return;
    }

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final point = Point(coordinates: Position(lng, lat));

        final options = PointAnnotationOptions(
          geometry: point,
          iconImage: "marker-15",
          iconSize: 1.5,
          iconAnchor: IconAnchor.BOTTOM,
          iconColor: 0xFFFF0000,
          textField: title,
          textSize: 13.0,
          textColor: 0xFFFF0000,
          textHaloColor: 0xFFFFFFFF,
          textHaloWidth: 2.0,
          textAnchor: TextAnchor.TOP,
          textOffset: [0.0, 0.5],
        );

        await pointAnnotationManager!.create(options);
        return;
      } catch (e) {
        if (attempt == 1) {
          await _recreatePointAnnotationManager();
        }
      }
    }
  }

  Future<void> addWorkshopPinMarker(double latitude, double longitude,
      {String? workshopName}) async {
    if (!areValidCoordinates(latitude, longitude)) {
      return;
    }

    if (circleAnnotationManager == null || pointAnnotationManager == null) {
      await setupAnnotationManagers();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    try {
      final point = Point(coordinates: Position(longitude, latitude));

      if (circleAnnotationManager != null) {
        final outerCircle = CircleAnnotationOptions(
          geometry: point,
          circleRadius: 25.0,
          circleColor: 0x33FF0000,
          circleStrokeWidth: 0.0,
        );
        await circleAnnotationManager!.create(outerCircle);

        final whiteBorder = CircleAnnotationOptions(
          geometry: point,
          circleRadius: 8.0,
          circleColor: 0xFFFFFFFF,
          circleStrokeColor: 0xFFFF0000,
          circleStrokeWidth: 2.0,
        );
        await circleAnnotationManager!.create(whiteBorder);

        final redCenter = CircleAnnotationOptions(
          geometry: point,
          circleRadius: 5.0,
          circleColor: 0xFFFF0000,
        );
        await circleAnnotationManager!.create(redCenter);
      }

      if (pointAnnotationManager != null && workshopName != null) {
        final textPoint = Point(
          coordinates: Position(longitude, latitude - 0.0003),
        );

        final textOptions = PointAnnotationOptions(
          geometry: textPoint,
          textField: workshopName,
          textSize: 13.0,
          textColor: 0xFFD32F2F,
          textHaloColor: 0xFFFFFFFF,
          textHaloWidth: 2.5,
          textAnchor: TextAnchor.CENTER,
          textOpacity: 1.0,
        );

        await pointAnnotationManager!.create(textOptions);
      }
    } catch (e) {
      if (circleAnnotationManager != null) {
        final point = Point(coordinates: Position(longitude, latitude));

        final simpleCircle = CircleAnnotationOptions(
          geometry: point,
          circleRadius: 10.0,
          circleColor: 0xFFFF0000,
          circleStrokeColor: 0xFFFFFFFF,
          circleStrokeWidth: 2.0,
        );
        await circleAnnotationManager!.create(simpleCircle);
      }
    }
  }

  Future<void> addRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    bool addEndMarker = false,
  }) async {
    try {
      if (mapboxMap == null) {
        _showRouteError('Map not ready. Please try again.');
        return;
      }

      isLoading.value = true;
      await clearRoute();

      if (polylineAnnotationManager == null) {
        await _recreatePolylineAnnotationManager();
        if (polylineAnnotationManager == null) {
          await _showStraightLineFallback(startLat, startLng, endLat, endLng);
          return;
        }
      }

      final routeCoordinates = await _getDirectionsRoute(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
      );

      if (routeCoordinates.isNotEmpty) {
        bool routeDrawn = false;
        for (int attempt = 1; attempt <= 2; attempt++) {
          try {
            final lineString = LineString(coordinates: routeCoordinates);

            final options = PolylineAnnotationOptions(
              geometry: lineString,
              lineColor: 0xFF0066FF,
              lineWidth: 5.0,
              lineOpacity: 0.8,
            );

            await polylineAnnotationManager!.create(options);
            routeDrawn = true;
            break;
          } catch (e) {
            if (attempt == 1) {
              await _recreatePolylineAnnotationManager();
            }
          }
        }

        if (!routeDrawn) {
          await _showStraightLineFallback(startLat, startLng, endLat, endLng);
        }
      } else {
        await _showStraightLineFallback(startLat, startLng, endLat, endLng);
      }
    } catch (e) {
      await _showStraightLineFallback(startLat, startLng, endLat, endLng);
    } finally {
      isLoading.value = false;
    }
  }

  void _showRouteError(String message) {
    Get.snackbar(
      'Route Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _showStraightLineFallback(
      double startLat, double startLng, double endLat, double endLng) async {
    try {
      await addMarker(endLat, endLng, title: "Destination");

      Get.snackbar(
        'Route Info',
        'Showing destination marker. Route line unavailable.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {}
  }

  Future<List<Position>> _getDirectionsRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/$startLng,$startLat;$endLng,$endLat'
        '?access_token=${AppConstants.mapboxAccessToken}&geometries=geojson&overview=full';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates =
              data['routes'][0]['geometry']['coordinates'] as List;

          return coordinates
              .map(
                  (coord) => Position(coord[0].toDouble(), coord[1].toDouble()))
              .toList();
        }
      } else {}
    } catch (e) {}

    return _getStraightLineCoordinates(startLat, startLng, endLat, endLng);
  }

  Future<List<Position>> getDirectionsRouteWithProfile({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String profile = 'driving',
  }) async {
    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/$profile/$startLng,$startLat;$endLng,$endLat'
        '?access_token=${AppConstants.mapboxAccessToken}&geometries=geojson&overview=full&steps=true';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates =
              data['routes'][0]['geometry']['coordinates'] as List;

          return coordinates
              .map(
                  (coord) => Position(coord[0].toDouble(), coord[1].toDouble()))
              .toList();
        }
      }
    } catch (e) {}

    return _getStraightLineCoordinates(startLat, startLng, endLat, endLng);
  }

  Future<Map<String, dynamic>?> getRouteInfo({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String profile = 'driving',
  }) async {
    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/$profile/$startLng,$startLat;$endLng,$endLat'
        '?access_token=${AppConstants.mapboxAccessToken}&overview=simplified';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          return {
            'distance': route['distance'],
            'duration': route['duration'],
            'steps': route['legs'][0]['steps'] ?? [],
          };
        }
      }
    } catch (e) {}

    return null;
  }

  Future<void> _addStraightLineRoute(
      double startLat, double startLng, double endLat, double endLng) async {
    try {
      if (polylineAnnotationManager != null) {
        final coordinates =
            _getStraightLineCoordinates(startLat, startLng, endLat, endLng);
        final lineString = LineString(coordinates: coordinates);

        final options = PolylineAnnotationOptions(
          geometry: lineString,
          lineColor: 0xFFFF6B6B,
          lineWidth: 5.0,
          lineOpacity: 0.8,
        );

        await polylineAnnotationManager!.create(options);
      }
    } catch (e) {}
  }

  List<Position> _getStraightLineCoordinates(
      double startLat, double startLng, double endLat, double endLng) {
    return [
      Position(startLng, startLat),
      Position(endLng, endLat),
    ];
  }

  Future<void> addRouteWithWaypoints(List<Position> waypoints) async {
    if (polylineAnnotationManager != null && waypoints.length >= 2) {
      try {
        await clearRoute();

        final lineString = LineString(coordinates: waypoints);

        final options = PolylineAnnotationOptions(
          geometry: lineString,
          lineColor: 0xFF0066FF,
          lineWidth: 5.0,
          lineOpacity: 0.8,
        );

        await polylineAnnotationManager!.create(options);
      } catch (e) {}
    }
  }

  Future<void> fitRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    if (mapboxMap == null) {
      return;
    }

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final double minLat = startLat < endLat ? startLat : endLat;
        final double maxLat = startLat > endLat ? startLat : endLat;
        final double minLng = startLng < endLng ? startLng : endLng;
        final double maxLng = startLng > endLng ? startLng : endLng;

        const double padding = 0.01;

        final double centerLat = (minLat + maxLat) / 2;
        final double centerLng = (minLng + maxLng) / 2;

        final double latDiff = maxLat - minLat + padding;
        final double lngDiff = maxLng - minLng + padding;
        final double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

        double zoom = 10.0;
        if (maxDiff < 0.01)
          zoom = 14.0;
        else if (maxDiff < 0.05)
          zoom = 12.0;
        else if (maxDiff < 0.1)
          zoom = 11.0;
        else if (maxDiff < 0.5)
          zoom = 9.0;
        else
          zoom = 8.0;

        final center = Point(coordinates: Position(centerLng, centerLat));

        await mapboxMap!.flyTo(
          CameraOptions(
            center: center,
            zoom: zoom,
          ),
          MapAnimationOptions(duration: 2000, startDelay: 0),
        );
        return;
      } catch (e) {
        if (attempt == 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    try {
      final double centerLat = (startLat + endLat) / 2;
      final double centerLng = (startLng + endLng) / 2;
      await flyToLocation(centerLat, centerLng, zoom: 12.0);
    } catch (e) {}
  }

  Future<void> clearRoute() async {
    if (polylineAnnotationManager == null) {
      return;
    }

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        await polylineAnnotationManager!.deleteAll();
        return;
      } catch (e) {
        if (attempt == 1) {
          await _recreatePolylineAnnotationManager();
        } else {
          polylineAnnotationManager = null;
        }
      }
    }
  }

  Future<void> _recreatePointAnnotationManager() async {
    if (mapboxMap == null) return;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      pointAnnotationManager =
          await mapboxMap!.annotations.createPointAnnotationManager();
    } catch (e) {
      pointAnnotationManager = null;
    }
  }

  Future<void> _recreatePolylineAnnotationManager() async {
    if (mapboxMap == null) return;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      polylineAnnotationManager =
          await mapboxMap!.annotations.createPolylineAnnotationManager();
    } catch (e) {
      polylineAnnotationManager = null;
    }
  }

  Future<void> addMarkers(List<Map<String, dynamic>> markers) async {
    if (pointAnnotationManager != null) {
      try {
        await pointAnnotationManager!.deleteAll();

        for (final markerData in markers) {
          await addMarker(
            markerData['latitude'],
            markerData['longitude'],
            title: markerData['title'],
            snippet: markerData['snippet'],
          );
        }
      } catch (e) {}
    }
  }

  Future<void> addCircle(
    double latitude,
    double longitude,
    double radiusMeters, {
    int fillColor = 0x330066FF,
    int strokeColor = 0xFF0066FF,
    double strokeWidth = 2.0,
  }) async {
    if (polylineAnnotationManager == null && polygonAnnotationManager == null) {
      return;
    }

    try {
      const int numPoints = 64;
      List<Position> circlePoints = [];

      const double metersPerDegreeLat = 111320.0;
      final double metersPerDegreeLng = 111320.0 * cos(latitude * pi / 180.0);

      for (int i = 0; i <= numPoints; i++) {
        final double angle = (i * 360.0 / numPoints) * (pi / 180.0);

        final double deltaLat =
            (radiusMeters * cos(angle)) / metersPerDegreeLat;
        final double deltaLng =
            (radiusMeters * sin(angle)) / metersPerDegreeLng;

        final double pointLat = latitude + deltaLat;
        final double pointLng = longitude + deltaLng;

        circlePoints.add(Position(pointLng, pointLat));
      }

      if (polygonAnnotationManager != null && fillColor != 0x00000000) {
        try {
          final polygonCoordinates = [circlePoints];

          final polygonOptions = PolygonAnnotationOptions(
            geometry: Polygon(coordinates: polygonCoordinates),
            fillColor: fillColor,
            fillOpacity: 0.3,
          );

          await polygonAnnotationManager!.create(polygonOptions);
        } catch (e) {}
      }

      if (polylineAnnotationManager != null) {
        try {
          final lineString = LineString(coordinates: circlePoints);

          final lineOptions = PolylineAnnotationOptions(
            geometry: lineString,
            lineColor: strokeColor,
            lineWidth: strokeWidth,
            lineOpacity: 0.9,
          );

          await polylineAnnotationManager!.create(lineOptions);
        } catch (e) {}
      }
    } catch (e) {}
  }

  Future<void> addSearchCircle(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    final radiusMeters = radiusKm * 1000.0;

    await addCircle(
      latitude,
      longitude,
      radiusMeters,
      fillColor: 0x33FF6B35,
      strokeColor: 0xFFFF6B35,
      strokeWidth: 2.0,
    );
  }

  Future<void> clearSearchCircles() async {
    if (polylineAnnotationManager != null) {
      try {
        await polylineAnnotationManager!.deleteAll();
      } catch (e) {}
    }

    if (polygonAnnotationManager != null) {
      try {
        await polygonAnnotationManager!.deleteAll();
      } catch (e) {}
    }

    if (circleAnnotationManager != null) {
      try {
        await circleAnnotationManager!.deleteAll();
      } catch (e) {}
    }

    final currentPos = currentPosition.value;
    if (currentPos != null) {
      await Future.delayed(const Duration(milliseconds: 200));
      await addCurrentLocationMarker(
        currentPos.latitude,
        currentPos.longitude,
      );
    }
  }

  Future<void> clearAnnotations() async {
    final currentLat = currentPosition.value?.latitude;
    final currentLng = currentPosition.value?.longitude;

    if (pointAnnotationManager != null) {
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          await pointAnnotationManager!.deleteAll();
          break;
        } catch (e) {
          if (attempt == 1) {
            await _recreatePointAnnotationManager();
          } else {
            pointAnnotationManager = null;
          }
        }
      }
    }

    if (circleAnnotationManager != null) {
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          await circleAnnotationManager!.deleteAll();
          break;
        } catch (e) {
          if (attempt == 2) {
            circleAnnotationManager = null;
          }
        }
      }
    }

    await clearRoute();

    if (currentLat != null && currentLng != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      await addCurrentLocationMarker(currentLat, currentLng);
    }
  }

  Future<void> clearMarkers() async {
    if (pointAnnotationManager != null) {
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          await pointAnnotationManager!.deleteAll();
          return;
        } catch (e) {
          if (attempt == 1) {
            await _recreatePointAnnotationManager();
          } else {
            pointAnnotationManager = null;
          }
        }
      }
    }
  }

  Future<void> clearCircles() async {
    if (circleAnnotationManager != null) {
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          await circleAnnotationManager!.deleteAll();
          return;
        } catch (e) {
          if (attempt == 2) {
            circleAnnotationManager = null;
          }
        }
      }
    }
  }

  Future<void> flyToLocation(
    double latitude,
    double longitude, {
    double zoom = 15.0,
    int duration = 2000,
  }) async {
    if (mapboxMap == null) {
      return;
    }

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final center = Point(coordinates: Position(longitude, latitude));

        await mapboxMap!.flyTo(
          CameraOptions(
            center: center,
            zoom: zoom,
          ),
          MapAnimationOptions(duration: duration, startDelay: 0),
        );
        return;
      } catch (e) {
        if (attempt == 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    Get.snackbar(
      'Navigation Warning',
      'Unable to move camera to location. Map may not be fully loaded.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return _locationService.calculateDistance(
        startLat, startLng, endLat, endLng);
  }

  double metersToKilometers(double meters) {
    return _locationService.metersToKilometers(meters);
  }

  double kilometersToMeters(double kilometers) {
    return _locationService.kilometersToMeters(kilometers);
  }

  bool isWithinRadius(
    double centerLat,
    double centerLng,
    double pointLat,
    double pointLng,
    double radiusMeters,
  ) {
    return _locationService.isWithinRadius(
        centerLat, centerLng, pointLat, pointLng, radiusMeters);
  }

  String formatDistance(double meters) {
    return _locationService.formatDistance(meters);
  }

  bool areValidCoordinates(double latitude, double longitude) {
    return _locationService.areValidCoordinates(latitude, longitude);
  }

  geo.Position getDefaultLocation() {
    return _locationService.getDefaultLocation();
  }

  Future<LocationServiceStatus> getLocationServiceStatus() async {
    return await _locationService.getLocationServiceStatus();
  }

  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  Future<void> resetAllManagers() async {
    pointAnnotationManager = null;
    circleAnnotationManager = null;
    polylineAnnotationManager = null;
    polygonAnnotationManager = null;

    if (mapboxMap != null) {
      await Future.delayed(const Duration(milliseconds: 3000));
      await setupAnnotationManagers();
    }
  }

  void enableEmergencyMode() {
    pointAnnotationManager = null;
    circleAnnotationManager = null;
    polylineAnnotationManager = null;
    polygonAnnotationManager = null;

    Get.snackbar(
      'Map Notice',
      'Map is running in limited mode. Some features may not be available.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
    );
  }

  bool hasWorkingAnnotationManager() {
    return pointAnnotationManager != null ||
        circleAnnotationManager != null ||
        polylineAnnotationManager != null ||
        polygonAnnotationManager != null;
  }

  Future<void> setupAnnotationManagersWithHealthCheck() async {
    if (mapboxMap == null) return;

    bool isHealthy = await _isPlatformConnectionHealthy();
    if (!isHealthy) {
      await Future.delayed(const Duration(milliseconds: 2000));
      isHealthy = await _isPlatformConnectionHealthy();
      if (!isHealthy) {
        return;
      }
    }

    await setupAnnotationManagers();
  }

  Future<bool> _isPlatformConnectionHealthy() async {
    if (mapboxMap == null) return false;

    try {
      final cameraState = await mapboxMap!.getCameraState();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void onClose() {
    try {
      pointAnnotationManager = null;
      circleAnnotationManager = null;
      polylineAnnotationManager = null;
      polygonAnnotationManager = null;
      mapboxMap = null;
    } catch (e) {}
    super.onClose();
  }
}
