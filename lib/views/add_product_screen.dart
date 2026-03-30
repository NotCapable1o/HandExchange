import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/product_controller.dart';
import '../utils/toast.dart';
import '../widgets/add_product_animations.dart';
import '../widgets/animated_assets.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ProductController controller = Get.find<ProductController>();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  double? _lat;
  double? _lng;

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isDonation = false;
  String _selectedCategory = 'Books';
  List<XFile> _selectedImages = [];

  void _openMapPicker() {
    final MapController mapController = MapController();
    final TextEditingController searchController = TextEditingController();

    const LatLng brurLocation = LatLng(25.7209, 89.2612);
    LatLng pickedLocation = _lat != null ? LatLng(_lat!, _lng!) : brurLocation;

    RxBool isSearching = false.obs;
    RxBool isSatellite = false.obs;

    const String streetUrl =
        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
    const String satelliteUrl =
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

    Get.to(
      () => SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // 1. THE MAP
              Obx(
                () => FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: pickedLocation,
                    initialZoom: 16,
                    onPositionChanged: (camera, hasGesture) =>
                        pickedLocation = camera.center,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: isSatellite.value ? satelliteUrl : streetUrl,
                      subdomains: const ['a', 'b', 'c', 'd'],
                    ),
                  ],
                ),
              ),

              // 2. SEARCH BAR (Re-Added)
              Positioned(
                top: 20,
                left: 15,
                right: 15,
                child:
                    Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: searchController,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: "Search city or area...",
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.blueAccent,
                                ),
                                suffixIcon: isSearching.value
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                          Icons.send_rounded,
                                          color: Colors.blueAccent,
                                        ),
                                        onPressed: () async {
                                          isSearching.value = true;
                                          await _searchAddress(
                                            searchController.text,
                                            mapController,
                                          );
                                          isSearching.value = false;
                                        },
                                      ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              onSubmitted: (val) async {
                                isSearching.value = true;
                                await _searchAddress(val, mapController);
                                isSearching.value = false;
                              },
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 500))
                        .slideY(begin: -0.3, end: 0),
              ),

              Positioned(
                right: 15,
                top: MediaQuery.of(Get.context!).size.height * 0.22,
                child:
                    GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            isSatellite.value = !isSatellite.value;
                          },
                          child: Obx(
                            () => Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSatellite.value
                                    ? Colors.blueAccent
                                    : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isSatellite.value
                                    ? Icons.layers_outlined
                                    : Icons.satellite_alt_outlined,
                                color: isSatellite.value
                                    ? Colors.white
                                    : Colors.blueAccent,
                                size: 26,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 700))
                        .slideX(begin: 0.5, end: 0),
              ),

              Positioned(
                right: 15,
                top: MediaQuery.of(Get.context!).size.height * 0.4,
                child:
                    Column(
                          children: [
                            _mapSideButton(Icons.add, () {
                              mapController.move(
                                mapController.camera.center,
                                mapController.camera.zoom + 1,
                              );
                            }),
                            const SizedBox(height: 10),
                            _mapSideButton(Icons.remove, () {
                              mapController.move(
                                mapController.camera.center,
                                mapController.camera.zoom - 1,
                              );
                            }),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 600))
                        .slideX(begin: 0.5, end: 0),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 45),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Text(
                              "SET PICKUP",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .shimmer(duration: const Duration(seconds: 2))
                          .moveY(begin: -5, end: 0),
                      const Icon(
                            Icons.location_on_rounded,
                            color: Colors.redAccent,
                            size: 55,
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeInOut,
                          ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child:
                          FloatingActionButton.extended(
                            heroTag: 'my_loc_btn',
                            backgroundColor: Colors.white,
                            onPressed: () => _getCurrentLocation(mapController),
                            icon: const Icon(
                              Icons.gps_fixed,
                              color: Colors.blueAccent,
                            ),
                            label: const Text(
                              "My Location",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ).animate().scale(
                            delay: const Duration(milliseconds: 300),
                          ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            _handleMapTap(pickedLocation);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.indigoAccent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "Confirm Pickup Spot",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 500))
                        .slideY(begin: 0.4, end: 0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapSideButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Icon(icon, color: Colors.blueAccent, size: 26),
      ),
    );
  }

  Future<void> _searchAddress(String query, MapController mapController) async {
    if (query.isEmpty) return;
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'hand_exchange_app'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          double lat = double.parse(data[0]['lat']);
          double lon = double.parse(data[0]['lon']);
          mapController.move(LatLng(lat, lon), 15.0);
        } else {
          showToast("Location not found", success: false);
        }
      }
    } catch (e) {
      showToast("Search error. Check internet.", success: false);
    }
  }

  Future<void> _getCurrentLocation(MapController mapController) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showToast("Location services are disabled.", success: false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showToast("Location permissions are denied", success: false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showToast(
        "Permissions are permanently denied. Please enable in settings.",
        success: false,
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    mapController.move(LatLng(position.latitude, position.longitude), 16.0);

    _handleMapTap(LatLng(position.latitude, position.longitude));
  }

  Future<void> _handleMapTap(LatLng point) async {
    setState(() {
      _lat = point.latitude;
      _lng = point.longitude;
      _locationController.text = "Fetching address...";
    });
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'hand_exchange_app'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(
          () => _locationController.text =
              data['display_name'] ?? "Pinned Location",
        );
      }
    } catch (e) {
      setState(
        () => _locationController.text =
            "Pinned Location (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})",
      );
    }
    Get.back();
    showToast("Location Selected");
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) return;
    if (_selectedImages.length + images.length > 5) {
      showToast("You can only add up to 5 photos", success: false);
    }
    setState(() {
      _selectedImages.addAll(images);
      if (_selectedImages.length > 5)
        _selectedImages = _selectedImages.sublist(0, 5);
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      showToast("Please fill all required fields", success: false);
      return;
    }
    if (_selectedImages.isEmpty) {
      showToast("Please add at least 1 photo", success: false);
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final success = await controller.addProduct({
      'title': _titleController.text.trim(),
      'price': _isDonation ? 0 : double.tryParse(_priceController.text) ?? 0,
      'pickup_location': _locationController.text.trim(),
      'lat': _lat,
      'lng': _lng,
      'category': _selectedCategory,
      'description': _descController.text.trim(),
      'is_donation': _isDonation,
    }, _selectedImages.map((x) => File(x.path)).toList());

    Get.back();
    if (success) {
      Get.back();
      showToast("Product Posted Successfully!");
    } else {
      showToast("Failed to post. Check internet or try again.", success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Add Product",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: AnimatedAssets.pageEntrance(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddProductAnimations.headerAnim(),
                  const SizedBox(height: 10),

                  const Text(
                    "Photos (Max 5)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _selectedImages.length) {
                          return GestureDetector(
                            onTap: _pickImages,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 130,
                                height: 100,

                                color: Colors.blue.withOpacity(0.0),
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child:
                                        AddProductAnimations.uploadPlaceholder(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return AnimatedAssets.animatedListItem(
                          delay: index * 50,
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: FileImage(
                                      File(_selectedImages[index].path),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 5,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedImages.removeAt(index),
                                  ),
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildField(
                    controller: _titleController,
                    label: "Product Title",
                    icon: Icons.shopping_bag_outlined,
                    validator: (v) => v!.isEmpty ? "Title is required" : null,
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: _isDonation
                          ? Colors.green.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      secondary: AddProductAnimations.donationAnim(),
                      title: const Text(
                        "Free / Donation",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: _isDonation,
                      onChanged: (v) => setState(() => _isDonation = v),
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (!_isDonation)
                    _buildField(
                      controller: _priceController,
                      label: "Price (৳)",
                      icon: Icons.payments_outlined,
                      isNumeric: true,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Price is required";
                        if (double.tryParse(value) == null)
                          return "Enter a valid number";
                        return null;
                      },
                    ),

                  TextFormField(
                    controller: _locationController,
                    readOnly: true,
                    onTap: _openMapPicker,
                    validator: (value) =>
                        value!.isEmpty ? "Location is required" : null,
                    decoration: InputDecoration(
                      labelText: "Pickup Location",
                      prefixIcon: AddProductAnimations.mapPin(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField(
                    value: _selectedCategory,
                    items:
                        ['Books', 'Electronics', 'Notes', 'Furniture', 'Other']
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val as String),
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildField(
                    controller: _descController,
                    label: "Description",
                    icon: Icons.description_outlined,
                    maxLines: 4,
                    validator: (v) =>
                        v!.isEmpty ? "Description is required" : null,
                  ),

                  const SizedBox(height: 30),

                  AnimatedAssets.tapEffect(
                    onTap: _submit,
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.cyan],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Submit Listing",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumeric = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: isNumeric
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
            : [],
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).nextFocus();
        },
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
