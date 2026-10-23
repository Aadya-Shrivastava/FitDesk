import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymadmin/Model/classmodel.dart';
import 'package:gymadmin/controller/dashboardcontroller.dart';
import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import 'package:gymadmin/widgets/location/location_helper.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

// Import your model file (where classmodel / Classes exist)
// Example:
// import 'package:gymadmin/models/classmodel.dart';

class TrainerController extends GetxController {
  // Step tracking
  RxInt currentStep = 0.obs;

  // Loading
  final RxBool isSubmitting = false.obs;

  // Form Keys
  final basicInfoFormKey = GlobalKey<FormState>();
  final addressFormKey = GlobalKey<FormState>();

  // Controllers for Basic Info
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final qualificationController = TextEditingController();
  final dobController = TextEditingController();

  // Address
  final countryController = TextEditingController(text: "India");
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final zipController = TextEditingController(); // pincode
  final addressController = TextEditingController();

  // location lookup state
  final RxBool isLocating = false.obs;
  final RxBool isLookingUpPincode = false.obs;
  Timer? _pincodeDebounce;

  // Dropdown Values
  RxString gender = 'Male'.obs;

  // Files
  final Rx<File?> profileImage = Rx<File?>(null);
  final Rx<File?> documentFile = Rx<File?>(null);
var  token = "".obs;
  // API endpoints
  final String endpoint =
      'https://fitdesk.theapexinnovation.com/api/v1/gym-owner/trainers';
  final String classesEndpoint =
      'https://fitdesk.theapexinnovation.com/api/v1/gym-owner/classes';

  // -------- Classes dropdown state --------
  final RxBool isLoadingClasses = false.obs;
  final RxList<Classes> classesList = <Classes>[].obs;
  final Rx<Classes?> selectedClass = Rx<Classes?>(null);

  // TODO: implement based on your auth storage
  Future<String?> getToken() async {
    // Example:
    token.value = await PrefManager().readValue(key: PrefConst.token);
    // final box = GetStorage();
    // return box.read('token');
    return token.value;
  }

  @override
  void onInit() {
    super.onInit();
    
    fetchClasses();
  }

  void nextStep() {
    if (currentStep.value == 0) {
      if (basicInfoFormKey.currentState!.validate()) {
        currentStep.value = 1;
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // ------------------ LOCATION / PINCODE ------------------

  /// Fills the address form from the device's current GPS location.
  Future<void> useCurrentLocation() async {
    isLocating.value = true;
    try {
      final pos = await LocationHelper.getCurrentPosition(onError: _showError);
      if (pos == null) return;

      final addr = await LocationHelper.reverseGeocode(pos.latitude, pos.longitude);
      if (addr == null) {
        _showError("Could not resolve an address for your location.");
        return;
      }

      countryController.text = addr.country.isNotEmpty ? addr.country : "India";
      if (addr.state.isNotEmpty) stateController.text = addr.state;
      if (addr.district.isNotEmpty) districtController.text = addr.district;
      if (addr.city.isNotEmpty) cityController.text = addr.city;
      if (addr.pincode.isNotEmpty) zipController.text = addr.pincode;
      if (addressController.text.trim().isEmpty && addr.fullAddress.isNotEmpty) {
        addressController.text = addr.fullAddress;
      }
    } finally {
      isLocating.value = false;
    }
  }

  /// Called on every keystroke in the pincode field; auto-fills city/district
  /// once a valid 6-digit Indian pincode has been typed (debounced).
  void onPincodeChanged(String value) {
    _pincodeDebounce?.cancel();
    final pincode = value.trim();
    if (pincode.length != 6) return;

    _pincodeDebounce = Timer(const Duration(milliseconds: 400), () => _lookupPincode(pincode));
  }

  Future<void> _lookupPincode(String pincode) async {
    isLookingUpPincode.value = true;
    try {
      final addr = await LocationHelper.lookupIndianPincode(pincode);
      if (addr == null) return;

      if (countryController.text.trim().isEmpty) countryController.text = "India";
      if (addr.state.isNotEmpty) stateController.text = addr.state;
      if (addr.district.isNotEmpty) districtController.text = addr.district;
      if (addr.city.isNotEmpty) cityController.text = addr.city;
    } finally {
      isLookingUpPincode.value = false;
    }
  }

  // -------- Load classes --------
  Future<void> fetchClasses() async {
    isLoadingClasses.value = true;
    try {
      final token = await getToken();

      final resp = await http.get(
        Uri.parse(classesEndpoint),
        headers: {
          "Accept": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final model = classmodel.fromJson(decoded);

        final list = model.data?.classes ?? <Classes>[];
        classesList.assignAll(list);

        if (classesList.isNotEmpty && selectedClass.value == null) {
          selectedClass.value = classesList.first;
        }
      } else {
        _showError("Failed to load classes (${resp.statusCode}).");
      }
    } catch (e) {
      _showError("Failed to load classes: $e");
    } finally {
      isLoadingClasses.value = false;
    }
  }

  // -------- File pickers --------
  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;

    final file = File(xfile.path);

    // 2MB limit
    final bytes = await file.length();
    if (bytes > 2 * 1024 * 1024) {
      _showError("Profile image must be <= 2MB.");
      return;
    }

    profileImage.value = file;
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);

    // 5MB limit
    final bytes = await file.length();
    if (bytes > 5 * 1024 * 1024) {
      _showError("Document must be <= 5MB.");
      return;
    }

    documentFile.value = file;
  }

  // -------- DOB conversion (UI dd-MM-yyyy -> API yyyy-MM-dd) --------
  String _dobForApi() {
    final raw = dobController.text.trim();
    if (raw.isEmpty) return "";

    final isoRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (isoRegex.hasMatch(raw)) return raw;

    try {
      final dt = DateFormat('dd-MM-yyyy').parseStrict(raw);
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (_) {
      return raw; // will fail validation below
    }
  }

  // -------- Submit --------
  Future<void> submitForm() async {
    if (!addressFormKey.currentState!.validate()) return;

    // Required class selection
    if (selectedClass.value == null) {
      _showError("Please select a class.");
      return;
    }

    // Required files
    if (profileImage.value == null) {
      _showError("Please select a profile image.");
      return;
    }
    if (documentFile.value == null) {
      _showError("Please select a document.");
      return;
    }

    final dobApi = _dobForApi();
    if (dobApi.isEmpty || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dobApi)) {
      _showError("DOB must be valid and in YYYY-MM-DD format.");
      return;
    }

    isSubmitting.value = true;

    try {
      final token = await getToken();
      final request = http.MultipartRequest("POST", Uri.parse(endpoint));

      request.headers["Accept"] = "application/json";
      if (token != null && token.isNotEmpty) {
        request.headers["Authorization"] = "Bearer $token";
      }

      request.fields.addAll({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text,
        "phone_number": phoneController.text.trim(),
        "dob": dobApi,
        "gender": gender.value,
        "qualification": qualificationController.text.trim(),
        "address": addressController.text.trim(),
        "city": cityController.text.trim(),
        "district": districtController.text.trim(),
        "state": stateController.text.trim(),
        "country": countryController.text.trim(),
        "zip_code": zipController.text.trim(), // pincode

        // ⚠️ If backend uses a different key, change it here.
        "class_id": selectedClass.value!.id.toString(),
      });

      request.files.add(await http.MultipartFile.fromPath(
        "profile",
        profileImage.value!.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        "document",
        documentFile.value!.path,
      ));

      final streamed = await request.send().timeout(const Duration(seconds: 20));
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        Get.snackbar(
          "Success",
          "Trainer added successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        clearAll();

        // Keep the dashboard's "Trainers" stat card in sync with the
        // trainer we just added, without waiting for a pull-to-refresh.
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchDashboard();
        }
      } else {
        _showError(_extractError(resp));
      }
    } catch (e) {
      _showError("Request failed: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

  String _extractError(http.Response resp) {
    try {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map) {
        if (decoded["message"] != null) return decoded["message"].toString();
        if (decoded["error"] != null) return decoded["error"].toString();
        if (decoded["errors"] != null) return decoded["errors"].toString();
      }
      return "Failed (${resp.statusCode}): ${resp.body}";
    } catch (_) {
      return "Failed (${resp.statusCode}): ${resp.body}";
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      "Error",
      msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void clearAll() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    qualificationController.clear();
    dobController.clear();

    countryController.text = "India";
    stateController.clear();
    cityController.clear();
    districtController.clear();
    zipController.clear();
    addressController.clear();

    gender.value = 'Male';
    profileImage.value = null;
    documentFile.value = null;
    selectedClass.value = null;

    currentStep.value = 0;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    qualificationController.dispose();
    dobController.dispose();

    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    districtController.dispose();
    zipController.dispose();
    addressController.dispose();

    _pincodeDebounce?.cancel();
    super.onClose();
  }
}
