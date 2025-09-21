import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../controllers/workshop_controller.dart';
import '../../controllers/service_controller.dart';
import '../../controllers/map_controller.dart';
import '../../data/models/service_model.dart';
import '../../data/models/workshop_model.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';

class WorkshopMapSearchView extends StatefulWidget {
  const WorkshopMapSearchView({super.key});

  @override
  _WorkshopMapSearchViewState createState() => _WorkshopMapSearchViewState();
}

class _WorkshopMapSearchViewState extends State<WorkshopMapSearchView> {
  final WorkshopController workshopController = Get.find<WorkshopController>();
  final ServiceController serviceController = Get.find<ServiceController>();
  final MapController mapController = Get.find<MapController>();

  MapboxMap? _mapboxMap;
  Point? _searchCenter;

  double _radiusKm = 10.0;
  ServiceType? _selectedServiceType;
  List<WorkshopModel> _nearbyWorkshops = [];
  bool _isLoading = false;
  bool _isDisposed = false;
  bool _showSearchOptions = false;


  bool shouldFocusOnWorkshop = false;
  String? targetWorkshopId;
  double? targetLatitude;
  double? targetLongitude;
  String? targetWorkshopName;
  double? targetZoom;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>?;


    shouldFocusOnWorkshop = arguments?['focusOnWorkshop'] ?? false;
    targetWorkshopId = arguments?['workshopId'];
    targetLatitude = arguments?['latitude'];
    targetLongitude = arguments?['longitude'];
    targetWorkshopName = arguments?['workshopName'];
    targetZoom = arguments?['zoom'] ?? 16.0;

    _selectedServiceType = arguments?['serviceType'] as ServiceType?;
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    if (_isDisposed) return;
    await mapController.checkLocationServices();


    if (shouldFocusOnWorkshop && targetLatitude != null && targetLongitude != null) {

      setState(() {
        _searchCenter = Point(
          coordinates: Position(targetLongitude!, targetLatitude!),
        );
      });


      await Future.delayed(const Duration(milliseconds: 1000));


      await mapController.flyToLocation(
        targetLatitude!,
        targetLongitude!,
        zoom: targetZoom ?? 16.0,
      );


      await _updateSearchCircle();


      if (targetWorkshopId != null) {
        final workshop = workshopController.findWorkshopById(targetWorkshopId!);
        if (workshop != null) {

          await Future.delayed(const Duration(milliseconds: 500));
          _showWorkshopBottomSheet(workshop);
        }
      }
    } else {
      _setInitialSearchCenter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isTablet = screenWidth > 600;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Map
          Positioned.fill(
            child: Obx(() {
              final currentPos = mapController.currentPosition.value;
              return MapWidget(
                key: const ValueKey("workshopSearchMap"),
                cameraOptions: CameraOptions(
                  center: Point(
                    coordinates: Position(
                      shouldFocusOnWorkshop && targetLongitude != null
                          ? targetLongitude!
                          : currentPos?.longitude ?? 36.2765,
                      shouldFocusOnWorkshop && targetLatitude != null
                          ? targetLatitude!
                          : currentPos?.latitude ?? 33.5138,
                    ),
                  ),
                  zoom: shouldFocusOnWorkshop ? (targetZoom ?? 16.0) : 12.0,
                ),
                onMapCreated: _onMapCreated,
                onTapListener: (MapContentGestureContext context) {
                  _onMapTap(context);
                },
              );
            }),
          ),

          // Top Search Bar
          Positioned(
            top: topPadding + 10,
            left: isTablet ? 24 : 16,
            right: isTablet ? 24 : 16,
            child: _buildTopSearchBar(isTablet),
          ),


          if (!shouldFocusOnWorkshop)
            Positioned(
              left: isTablet ? 24 : 16,
              top: topPadding + (isTablet ? 100 : 120),
              child: _buildRadiusSlider(isTablet),
            ),


          Positioned(
            right: isTablet ? 24 : 16,
            top: topPadding + (isTablet ? 100 : 120),
            child: Column(
              children: [
                _buildLocationButton(isTablet),
                if (!shouldFocusOnWorkshop) ...[
                  SizedBox(height: isTablet ? 6 : 8),
                  Container(
                    width: isTablet ? 45 : 50,
                    height: isTablet ? 45 : 50,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.radio_button_unchecked,
                        color: Colors.white,
                        size: isTablet ? 20 : 24,
                      ),
                      onPressed: () {
                        if (_searchCenter != null) {
                          _updateSearchCircle();
                        } else {
                          setState(() {
                            _searchCenter = Point(
                              coordinates: Position(36.2765, 33.5138),
                            );
                          });
                          _updateSearchCircle();
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),


          if (_showSearchOptions && !shouldFocusOnWorkshop)
            Positioned(
              top: topPadding + (isTablet ? 70 : 80),
              left: isTablet ? 24 : 16,
              right: isTablet ? 24 : 16,
              child: _buildSearchOptionsPanel(isTablet),
            ),


          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomResultsPanel(isTablet),
          ),


          if (!shouldFocusOnWorkshop)
            Positioned(
              bottom: _nearbyWorkshops.isEmpty ? (isTablet ? 100 : 120) : (isTablet ? 160 : 200),
              right: isTablet ? 24 : 16,
              child: _buildSearchFAB(isTablet),
            ),
        ],
      ),
    );
  }

  Widget _buildTopSearchBar(bool isTablet) {
    return Container(
      height: isTablet ? 45 : 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 22.5 : 25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey,
              size: isTablet ? 20 : 24,
            ),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: GestureDetector(
              onTap: shouldFocusOnWorkshop ? null : () {
                setState(() {
                  _showSearchOptions = !_showSearchOptions;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 12),
                child: Text(
                  shouldFocusOnWorkshop && targetWorkshopName != null
                      ? targetWorkshopName!
                      : _selectedServiceType?.displayName ?? 'select_service_type'.tr,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 16,
                    color: (_selectedServiceType != null || shouldFocusOnWorkshop)
                        ? Colors.black87
                        : Colors.grey[600],
                    fontWeight: shouldFocusOnWorkshop ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (!shouldFocusOnWorkshop)
            IconButton(
              icon: Icon(
                _showSearchOptions ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey,
                size: isTablet ? 20 : 24,
              ),
              onPressed: () {
                setState(() {
                  _showSearchOptions = !_showSearchOptions;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSearchOptionsPanel(bool isTablet) {
    return Container(
      margin: EdgeInsets.only(top: isTablet ? 8 : 10),
      padding: EdgeInsets.all(isTablet ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 10 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'select_service_type'.tr,
            style: TextStyle(
              fontSize: isTablet ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? 10 : 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : 2,
              childAspectRatio: isTablet ? 3.2 : 3.5,
              crossAxisSpacing: isTablet ? 6 : 8,
              mainAxisSpacing: isTablet ? 6 : 8,
            ),
            itemCount: ServiceType.values.length,
            itemBuilder: (context, index) {
              final serviceType = ServiceType.values[index];
              final isSelected = _selectedServiceType == serviceType;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedServiceType = serviceType;
                    _showSearchOptions = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(isTablet ? 6 : 8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      serviceType.displayName,
                      style: TextStyle(
                        color:
                        isSelected ? AppColors.primary : Colors.grey[700],
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: isTablet ? 10 : 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusSlider(bool isTablet) {
    return Container(
      height: isTablet ? 220 : 250,
      width: isTablet ? 65 : 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(isTablet ? 25 : 30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Radius Text with Range Indicator
          Padding(
            padding: EdgeInsets.all(isTablet ? 6 : 8),
            child: Column(
              children: [
                Text(
                  '${_radiusKm.toInt()}',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'km',
                  style: TextStyle(
                    fontSize: isTablet ? 10 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isTablet ? 2 : 4),
              ],
            ),
          ),


          Expanded(
            child: RotatedBox(
              quarterTurns: -1,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: isTablet ? 3 : 4,
                  thumbShape:
                  RoundSliderThumbShape(enabledThumbRadius: isTablet ? 6 : 8),
                  overlayShape:
                  RoundSliderOverlayShape(overlayRadius: isTablet ? 12 : 16),
                ),
                child: Slider(
                  value: _radiusKm,
                  min: 1.0,
                  max: 500.0,
                  divisions: 499,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    if (mounted && !_isDisposed) {
                      setState(() {
                        _radiusKm = value;
                      });
                      _updateSearchRadius();
                    }
                  },
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(isTablet ? 6 : 8),
            child: Icon(
              Icons.radio_button_unchecked,
              size: isTablet ? 14 : 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton(bool isTablet) {
    return Container(
      width: isTablet ? 45 : 50,
      height: isTablet ? 45 : 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.my_location,
          color: AppColors.primary,
          size: isTablet ? 20 : 24,
        ),
        onPressed: _goToCurrentLocation,
      ),
    );
  }

  Widget _buildBottomResultsPanel(bool isTablet) {
    final panelHeight = MediaQuery.of(context).size.height * (isTablet ? 0.35 : 0.4);

    if (_nearbyWorkshops.isEmpty && !shouldFocusOnWorkshop) {
      return Container(
        height: isTablet ? 80 : 100,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: isTablet ? 28 : 32,
                color: Colors.grey[400],
              ),
              SizedBox(height: isTablet ? 6 : 8),
              Text(
                _selectedServiceType != null
                    ? 'tap_search_to_find_workshops'.tr
                    : 'select_service_type_first'.tr,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isTablet ? 12 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (shouldFocusOnWorkshop && _nearbyWorkshops.isEmpty) {
      return Container(
        height: isTablet ? 80 : 100,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      size: isTablet ? 18 : 20,
                    ),
                    label: Text(
                      'back_to_services'.tr,
                      style: TextStyle(fontSize: isTablet ? 13 : 15),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Results panel
    return Container(
      height: panelHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.symmetric(vertical: isTablet ? 6 : 8),
            width: isTablet ? 35 : 40,
            height: isTablet ? 3 : 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 16,
              vertical: isTablet ? 6 : 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    shouldFocusOnWorkshop && targetWorkshopName != null
                        ? targetWorkshopName!
                        : '${'nearby_workshops'.tr} (${_nearbyWorkshops.length})',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!shouldFocusOnWorkshop)
                  TextButton(
                    onPressed: _showAllResults,
                    child: Text(
                      'view_all'.tr,
                      style: TextStyle(fontSize: isTablet ? 12 : 14),
                    ),
                  ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
              itemCount: _nearbyWorkshops.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final workshop = _nearbyWorkshops[index];
                return _buildWorkshopListItem(workshop, isTablet);
              },
            ),
          ),


          if (shouldFocusOnWorkshop)
            Padding(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    size: isTablet ? 18 : 20,
                  ),
                  label: Text(
                    'back_to_services'.tr,
                    style: TextStyle(fontSize: isTablet ? 13 : 15),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchFAB(bool isTablet) {
    return Container(
      height: isTablet ? 48 : 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 24 : 28),
          onTap: _searchNearbyWorkshops,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  SizedBox(
                    width: isTablet ? 16 : 20,
                    height: isTablet ? 16 : 20,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(
                    Icons.search,
                    color: Colors.white,
                    size: isTablet ? 18 : 20,
                  ),
                SizedBox(width: isTablet ? 6 : 8),
                Text(
                  'search'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkshopListItem(WorkshopModel workshop, bool isTablet) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        vertical: isTablet ? 6 : 8,
        horizontal: 0,
      ),
      leading: CircleAvatar(
        radius: isTablet ? 22 : 25,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          workshop.name.isNotEmpty ? workshop.name[0].toUpperCase() : 'W',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 16 : 18,
          ),
        ),
      ),
      title: Text(
        workshop.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isTablet ? 14 : 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isTablet ? 2 : 4),
          Text(
            workshop.workingHours,
            style: TextStyle(
              color: Colors.grey,
              fontSize: isTablet ? 12 : 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isTablet ? 2 : 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: isTablet ? 14 : 16,
                color: Colors.grey,
              ),
              SizedBox(width: isTablet ? 2 : 4),
              Expanded(
                child: Text(
                  workshop.distanceFromUser != null
                      ? mapController
                      .formatDistance(workshop.distanceFromUser! * 1000)
                      : mapController
                      .formatDistance(_calculateDistance(workshop) * 1000),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: isTablet ? 10 : 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: isTablet ? 14 : 16,
        color: Colors.grey,
      ),
      onTap: () {
        _focusOnWorkshop(workshop);
      },
    );
  }

  // Map Event Handlers
  void _onMapCreated(MapboxMap mapboxMap) {
    if (_isDisposed) return;
    _mapboxMap = mapboxMap;
    mapController.setMapboxMap(mapboxMap);
    _setupAnnotationManagers();
  }

  Future<void> _setupAnnotationManagers() async {
    if (_isDisposed || _mapboxMap == null) return;
    await mapController.setupAnnotationManagers();
  }

  void _onMapTap(MapContentGestureContext context) {
    if (_isDisposed || shouldFocusOnWorkshop) return;
    setState(() {
      _searchCenter = context.point;
      _showSearchOptions = false;
    });
    _updateSearchCircle();
  }

  Future<void> _setInitialSearchCenter() async {
    if (_isDisposed) return;
    await mapController.getCurrentLocation();
    final currentPos = mapController.currentPosition.value;

    if (currentPos != null && !_isDisposed) {
      if (mounted) {
        setState(() {
          _searchCenter = Point(
            coordinates: Position(currentPos.longitude, currentPos.latitude),
          );
        });
      }

      if (_mapboxMap != null) {
        await mapController.flyToLocation(
          currentPos.latitude,
          currentPos.longitude,
          zoom: 12.0,
        );
      }

      _updateSearchCircle();
    }
  }

  void _goToCurrentLocation() {
    if (_isDisposed) return;
    final currentPos = mapController.currentPosition.value;
    if (currentPos != null && _mapboxMap != null) {
      final currentPoint = Point(
        coordinates: Position(currentPos.longitude, currentPos.latitude),
      );

      if (mounted) {
        setState(() {
          _searchCenter = currentPoint;
        });
      }

      mapController.flyToLocation(
        currentPos.latitude,
        currentPos.longitude,
        zoom: 15.0,
      );

      _updateSearchCircle();
    } else {
      mapController.getCurrentLocation();
    }
  }

  Future<void> _updateSearchCircle() async {
    if (_searchCenter == null || _isDisposed) return;

    await mapController.clearCircles();
    await mapController.addCircle(
      _searchCenter!.coordinates.lat.toDouble(),
      _searchCenter!.coordinates.lng.toDouble(),
      mapController.kilometersToMeters(_radiusKm),
      fillColor: AppColors.primary.withOpacity(0.2).value,
      strokeColor: AppColors.primary.value,
      strokeWidth: 2.0,
    );
  }

  void _updateSearchRadius() {
    if (_isDisposed) return;
    _updateSearchCircle();
  }

  Future<void> _searchNearbyWorkshops() async {
    if (_searchCenter == null || _selectedServiceType == null || _isDisposed) {
      Get.snackbar(
        'error'.tr,
        'select_location_and_service'.tr,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final results = await workshopController.searchNearbyWorkshopsLocally(
        serviceType: _selectedServiceType!.name,
        longitude: _searchCenter!.coordinates.lng.toDouble(),
        latitude: _searchCenter!.coordinates.lat.toDouble(),
        radiusKm: _radiusKm,
      );

      if (mounted && !_isDisposed) {
        setState(() {
          _nearbyWorkshops = results;
        });
      }

      if (_nearbyWorkshops.isNotEmpty) {
        await _addWorkshopMarkers();

        Get.snackbar(
          'search_complete'.tr,
          'found_workshops'
              .tr
              .replaceAll('{count}', _nearbyWorkshops.length.toString()),
          backgroundColor: AppColors.success.withOpacity(0.1),
          colorText: AppColors.success,
        );
      } else {
        Get.snackbar(
          'search_complete'.tr,
          'no_workshops_found_in_area'.tr,
          backgroundColor: AppColors.warning.withOpacity(0.1),
          colorText: AppColors.warning,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'search_failed'.tr}: ${e.toString()}',
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addWorkshopMarkers() async {
    if (_isDisposed) return;
    await mapController.clearMarkers();

    for (final workshop in _nearbyWorkshops) {
      await mapController.addMarker(
        workshop.latitude,
        workshop.longitude,
        title: workshop.name,
      );
    }
  }

  void _focusOnWorkshop(WorkshopModel workshop) {
    if (_mapboxMap != null && !_isDisposed) {
      mapController.flyToLocation(
        workshop.latitude,
        workshop.longitude,
        zoom: 16.0,
      );
      _showWorkshopBottomSheet(workshop);
    }
  }

  void _showWorkshopBottomSheet(WorkshopModel workshop) {
    if (_isDisposed) return;
    final isTablet = MediaQuery.of(context).size.width > 600;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: isTablet ? 0.35 : 0.4,
        minChildSize: isTablet ? 0.25 : 0.3,
        maxChildSize: isTablet ? 0.7 : 0.8,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(isTablet ? 16 : 20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: isTablet ? 35 : 40,
                    height: isTablet ? 3 : 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: isTablet ? 25 : 30,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        workshop.name.isNotEmpty
                            ? workshop.name[0].toUpperCase()
                            : 'W',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 20,
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workshop.name,
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isTablet ? 2 : 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: isTablet ? 14 : 16,
                                color: Colors.grey,
                              ),
                              SizedBox(width: isTablet ? 2 : 4),
                              Expanded(
                                child: Text(
                                  workshop.workingHours,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: isTablet ? 12 : 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isTablet ? 2 : 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: isTablet ? 14 : 16,
                                color: Colors.grey,
                              ),
                              SizedBox(width: isTablet ? 2 : 4),
                              Text(
                                workshop.distanceFromUser != null
                                    ? mapController.formatDistance(
                                    workshop.distanceFromUser! * 1000)
                                    : mapController.formatDistance(
                                    _calculateDistance(workshop) * 1000),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: isTablet ? 12 : 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 12 : 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: isTablet ? 50 : 60),
                  child: SingleChildScrollView(
                    child: Text(
                      workshop.description,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.toNamed(
                            AppRoutes.workshopDetails,
                            arguments: workshop,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 12),
                        ),
                        child: Text(
                          'view_details'.tr,
                          style: TextStyle(fontSize: isTablet ? 13 : 15),
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 8 : 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          _getDirections(workshop);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 12),
                        ),
                        child: Text(
                          'directions'.tr,
                          style: TextStyle(fontSize: isTablet ? 13 : 15),
                        ),
                      ),
                    ),
                  ],
                ),


                if (shouldFocusOnWorkshop) ...[
                  SizedBox(height: isTablet ? 12 : 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        Get.back();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        size: isTablet ? 16 : 18,
                      ),
                      label: Text(
                        'back_to_services'.tr,
                        style: TextStyle(fontSize: isTablet ? 13 : 15),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 12),
                      ),
                    ),
                  ),
                ],


                SizedBox(height: isTablet ? 16 : 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAllResults() {
    if (_isDisposed) return;
    Get.toNamed(
      AppRoutes.filteredServices,
      arguments: {
        'serviceType': _selectedServiceType,
        'title': _selectedServiceType?.displayName ?? 'Services',
        'workshops': _nearbyWorkshops,
        'isLocationBased': true,
      },
    );
  }

  void _getDirections(WorkshopModel workshop) {
    Get.snackbar(
      'directions'.tr,
      '${'opening_directions_to'.tr} ${workshop.name}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  double _calculateDistance(WorkshopModel workshop) {
    if (_searchCenter == null) return 0.0;

    return mapController.calculateDistance(
      _searchCenter!.coordinates.lat.toDouble(),
      _searchCenter!.coordinates.lng.toDouble(),
      workshop.latitude,
      workshop.longitude,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}