import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_task_manager_app/controllers/task_controller.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart'; // Import the Geolocator package

/// The [MapSelectionPage] is a stateless widget that displays a map
/// and allows the user to select a location. It fetches the user's
/// current location and moves the map to that location. It also
/// provides a floating action button to confirm the selected location.
class MapSelectionPage extends StatelessWidget {
  final TaskController controller = Get.find<TaskController>(); // Get the TaskController instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'), // App bar title
      ),
      body: FutureBuilder<GeoPoint>(
        future: _getUserLocation(), // Fetch user location
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show a loading indicator
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching location')); // Show an error message
          } else {
            GeoPoint userLocation = snapshot.data!; // Get the user's location
            return OSMFlutter(
              controller: controller.mapController, // Map controller
              osmOption: const OSMOption(
                zoomOption: ZoomOption(
                  initZoom: 18, // Initial zoom level
                  minZoomLevel: 3, // Minimum zoom level
                  maxZoomLevel: 19, // Maximum zoom level
                  stepZoom: 1.0, // Zoom step
                ),
                showZoomController: true, // Show zoom controller
              ),
              onMapIsReady: (isReady) async {
                if (isReady) {
                  // Move map to user's current location after it's ready
                  await controller.mapController.moveTo(userLocation);
                  await controller.mapController.addMarker(
                    userLocation,
                    markerIcon: const MarkerIcon(
                      icon: Icon(Icons.pin_drop, // Set marker icon
                          color: Colors.red, size: 48),
                    ),
                  );
                }
              },
              onGeoPointClicked: (geoPoint) async {
                // Move to the selected GeoPoint
                await controller.mapController.moveTo(geoPoint);
                await controller.mapController.removeMarker(userLocation);
                await controller.mapController.addMarker(
                  geoPoint,
                  markerIcon: const MarkerIcon(
                    icon: Icon(Icons.pin_drop, // Set a different icon if needed
                        color: Colors.blue, size: 48),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic to get the selected location and pop the page
          GeoPoint? selectedLocation =
              controller.mapController.listenerMapSingleTapping.value;
          if (selectedLocation != null) {
            Navigator.of(context)
                .pop(selectedLocation); // Return the selected location
          }
        },
        child: const Icon(Icons.check), // Confirmation icon
      ),
    );
  }

  /// Fetches the user's current location using Geolocator.
  Future<GeoPoint> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied"); // Handle permission denial
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high); // Get the current position
      return GeoPoint(
          latitude: position.latitude, longitude: position.longitude); // Create a GeoPoint
    } catch (e) {
      rethrow; // Rethrow to handle in FutureBuilder
    }
  }
}