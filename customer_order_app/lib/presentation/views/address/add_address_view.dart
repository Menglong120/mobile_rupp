import 'package:customer_order_app/core/themes/themes.dart';
import 'package:customer_order_app/presentation/controllers/address_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class AddAddressView extends StatefulWidget {
  const AddAddressView({super.key});

  @override
  State<AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<AddAddressView> {
  final AddressController controller = Get.find<AddressController>();
  final TextEditingController addressLineController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  
  LatLng? selectedLocation;
  final MapController mapController = MapController();
  bool isDefault = false;
  bool isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      selectedLocation = LatLng(position.latitude, position.longitude);
    });
    mapController.move(selectedLocation!, 15);
    _getAddressFromLatLng(selectedLocation!);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      isGeocoding = true;
      addressLineController.text = 'Fetching address...';
    });
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Construct a readable address
        List<String> addressParts = [];
        if (place.name != null && place.name!.isNotEmpty && place.name != place.street) addressParts.add(place.name!);
        if (place.street != null && place.street!.isNotEmpty) addressParts.add(place.street!);
        if (place.subLocality != null && place.subLocality!.isNotEmpty) addressParts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) addressParts.add(place.administrativeArea!);

        setState(() {
          addressLineController.text = addressParts.join(', ');
        });
      } else {
        setState(() {
          addressLineController.text = 'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        addressLineController.text = 'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
    } finally {
      setState(() {
        isGeocoding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Delivery Address'),
        backgroundColor: ThemesApp.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: selectedLocation ?? const LatLng(11.5564, 104.9282), // Phnom Penh
                    initialZoom: 13,
                    onTap: (tapPosition, point) {
                      setState(() {
                        selectedLocation = point;
                      });
                      _getAddressFromLatLng(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    if (selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedLocation!,
                            width: 80,
                            height: 80,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                PositionReference(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _getCurrentLocation,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: ThemesApp.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Address Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressLineController,
                    decoration: InputDecoration(
                      hintText: 'Street, House No, Building...',
                      prefixIcon: const Icon(Icons.home),
                      suffixIcon: isGeocoding 
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: labelController,
                    decoration: InputDecoration(
                      hintText: 'Label (e.g., Home, Work, Office)',
                      prefixIcon: const Icon(Icons.label),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: isDefault,
                        onChanged: (val) => setState(() => isDefault = val ?? false),
                        activeColor: ThemesApp.primaryColor,
                      ),
                      const Text('Set as default address'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemesApp.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _saveAddress() async {
    if (selectedLocation == null) {
      Get.snackbar('Error', 'Please select a location on the map');
      return;
    }
    if (addressLineController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter address details');
      return;
    }

    final success = await controller.addAddress(
      addressLineController.text,
      selectedLocation!.latitude,
      selectedLocation!.longitude,
      labelController.text.isNotEmpty ? labelController.text : null,
      isDefault,
    );

    if (success) {
      Get.back();
      Get.snackbar('Success', 'Address saved successfully');
    }
  }
}

class PositionReference extends StatelessWidget {
  final Widget child;
  final double? bottom;
  final double? right;
  const PositionReference({super.key, required this.child, this.bottom, this.right});

  @override
  Widget build(BuildContext context) {
    return Positioned(bottom: bottom, right: right, child: child);
  }
}
