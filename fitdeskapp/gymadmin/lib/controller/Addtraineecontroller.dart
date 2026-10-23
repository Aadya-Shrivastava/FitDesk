import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:gymadmin/controller/dashboardcontroller.dart';
import 'package:gymadmin/widgets/location/location_helper.dart';
import 'package:gymadmin/widgets/date_calc.dart';

// Pickers
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

// Local storage
import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';

// Existing controllers
import 'package:gymadmin/controller/viewtrainercontroller.dart';
import 'package:gymadmin/controller/viewmembershipcontroller.dart';
import 'package:gymadmin/controller/viewclasscontroller.dart';
import 'package:gymadmin/controller/createcategorytype.dart';

// Existing model types
import 'package:gymadmin/Model/viewtrainermodel.dart';
import 'package:gymadmin/Model/membershipmodel.dart';
import 'package:gymadmin/Model/classmodel.dart' as cls_model;
import 'package:gymadmin/Model/categoriesmodel.dart';

class DropItem {
  final int id;
  final String label;

  const DropItem({required this.id, required this.label});

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class TraineeController extends GetxController {
  final String createTraineeEndpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/trainees";

  // steps
  final currentStep = 0.obs;
  final isLoadingDropdowns = false.obs;
  final isSubmitting = false.obs;

  // form keys
  final basicFormKey = GlobalKey<FormState>();
  final addressFormKey = GlobalKey<FormState>();
  final additionalFormKey = GlobalKey<FormState>();

  // basic
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController(); // UI dd-MM-yyyy
  final ageController = TextEditingController();
  final gender = "Male".obs;

  // files
  final profileImage = Rx<File?>(null);
  final documentFile = Rx<File?>(null);

  // address
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController(text: "India");
  final zipController = TextEditingController(); // pincode

  // location lookup state
  final isLocating = false.obs;
  final isLookingUpPincode = false.obs;
  Timer? _pincodeDebounce;

  // additional
  final goalController = TextEditingController();
  final membershipStartController = TextEditingController(); // UI dd-MM-yyyy

  // dropdown lists (KEEP ALL)
  final categories = <DropItem>[].obs;
  final memberships = <DropItem>[].obs;
  final trainers = <DropItem>[].obs;
  final classes = <DropItem>[].obs; // UI only

  // selected dropdowns
  final selectedCategory = Rx<DropItem?>(null);
  final selectedMembership = Rx<DropItem?>(null);
  final selectedTrainer = Rx<DropItem?>(null);
  final selectedClass = Rx<DropItem?>(null); // UI only

  // external controllers
  late final ViewTrainerController trainerCtrl;
  late final ViewMembershipController membershipCtrl;
  late final ViewClassesController classesCtrl;
  late final CategorytypeController categoryCtrl;

  Worker? _wTrainer;
  Worker? _wMember;
  Worker? _wClass;
  Worker? _wCategory;

  Future<String?> getToken() async {
    return await PrefManager().readValue(key: PrefConst.token);
  }

  @override
  void onInit() {
    super.onInit();

    trainerCtrl = Get.isRegistered<ViewTrainerController>()
        ? Get.find<ViewTrainerController>()
        : Get.put(ViewTrainerController(), permanent: true);

    membershipCtrl = Get.isRegistered<ViewMembershipController>()
        ? Get.find<ViewMembershipController>()
        : Get.put(ViewMembershipController(), permanent: true);

    classesCtrl = Get.isRegistered<ViewClassesController>()
        ? Get.find<ViewClassesController>()
        : Get.put(ViewClassesController(), permanent: true);

    categoryCtrl = Get.isRegistered<CategorytypeController>()
        ? Get.find<CategorytypeController>()
        : Get.put(CategorytypeController(), permanent: true);

    // reactive mapping (prevents empty dropdown issue)
    _wTrainer = ever<List<Trainers>>(trainerCtrl.trainers, (_) {
      _mapTrainers(trainerCtrl.trainers);
      selectedTrainer.value = _ensureSelected(selectedTrainer.value, trainers);
    });

    _wMember = ever<List<Memberships>>(membershipCtrl.memberships, (_) {
      _mapMemberships(membershipCtrl.memberships);
      selectedMembership.value = _ensureSelected(selectedMembership.value, memberships);
    });

    _wClass = ever<List<cls_model.Classes>>(classesCtrl.classes, (_) {
      _mapClasses(classesCtrl.classes);
      selectedClass.value = _ensureSelected(selectedClass.value, classes);
    });

    _wCategory = ever<List<Categories>>(categoryCtrl.categories, (_) {
      _mapCategories(categoryCtrl.categories);
      selectedCategory.value = _ensureSelected(selectedCategory.value, categories);
    });

    // Auto-calculated fields: age from DOB, expiry from start date + package.
    dobController.addListener(_syncAge);
    membershipStartController.addListener(_syncExpiry);
    ever(selectedMembership, (_) => _syncExpiry());

    fetchAllDropdowns();
  }

  // ------------------ AUTO-CALCULATED FIELDS ------------------

  /// Shown read-only under the membership dropdown (the API sets the real
  /// expiry date; this is the same rule so the admin sees it before saving).
  final membershipExpiryText = ''.obs;

  void _syncAge() {
    final age = DateCalc.ageFromString(dobController.text);
    final text = age?.toString() ?? '';
    if (ageController.text != text) ageController.text = text;
  }

  void _syncExpiry() {
    final id = selectedMembership.value?.id;
    final plan = membershipCtrl.memberships.firstWhereOrNull((m) => m.id == id);
    final start = DateCalc.parse(membershipStartController.text);
    final end = DateCalc.expiryFor(start, plan?.package);
    membershipExpiryText.value = end == null
        ? ''
        : '${DateFormat('dd-MM-yyyy').format(end)}  (${plan?.packageLabel ?? plan?.package})';
  }

  @override
  void onClose() {
    dobController.removeListener(_syncAge);
    membershipStartController.removeListener(_syncExpiry);
    _wTrainer?.dispose();
    _wMember?.dispose();
    _wClass?.dispose();
    _wCategory?.dispose();

    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    dobController.dispose();
    ageController.dispose();

    addressController.dispose();
    cityController.dispose();
    districtController.dispose();
    stateController.dispose();
    countryController.dispose();
    zipController.dispose();

    goalController.dispose();
    membershipStartController.dispose();
    _pincodeDebounce?.cancel();
    super.onClose();
  }

  // ------------------ LOCATION / PINCODE ------------------

  /// Fills the address form from the device's current GPS location.
  Future<void> useCurrentLocation() async {
    isLocating.value = true;
    try {
      final pos = await LocationHelper.getCurrentPosition(onError: _warnToast);
      if (pos == null) return;

      final addr = await LocationHelper.reverseGeocode(pos.latitude, pos.longitude);
      if (addr == null) {
        _warnToast("Could not resolve an address for your location.");
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
  /// once a valid 6-digit Indian pincode has been typed (debounced so we
  /// don't call the API on every single digit).
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

  Future<void> fetchAllDropdowns() async {
    isLoadingDropdowns.value = true;
    try {
      await Future.wait([
        trainerCtrl.fetchTrainers(page: 1),
        membershipCtrl.fetchMemberships(reset: true),
        classesCtrl.fetchClasses(reset: true),
        categoryCtrl.fetchCategories(reset: true),
      ]);

      selectedCategory.value = _ensureSelected(selectedCategory.value, categories);
      selectedMembership.value = _ensureSelected(selectedMembership.value, memberships);
      selectedTrainer.value = _ensureSelected(selectedTrainer.value, trainers);
      selectedClass.value = _ensureSelected(selectedClass.value, classes);
    } catch (e) {
      _errorToast("Failed to load dropdowns: $e");
    } finally {
      isLoadingDropdowns.value = false;
    }
  }

  DropItem? _ensureSelected(DropItem? current, List<DropItem> list) {
    if (list.isEmpty) return null;
    if (current == null) return list.first;
    for (final item in list) {
      if (item.id == current.id) return item;
    }
    return list.first;
  }

  void _mapCategories(List<Categories> list) {
    categories.assignAll(
      list
          .where((x) => (x.id ?? 0) > 0)
          .map((x) => DropItem(
                id: x.id!,
                label: (x.title ?? "Category #${x.id}").trim(),
              ))
          .toList(),
    );
  }

  void _mapMemberships(List<Memberships> list) {
    memberships.assignAll(
      list
          .where((x) => (x.id ?? 0) > 0)
          .map((x) => DropItem(
                id: x.id!,
                label: (x.title ?? "Membership #${x.id}").trim(),
              ))
          .toList(),
    );
  }

  void _mapTrainers(List<Trainers> list) {
    trainers.assignAll(
      list
          .where((x) => (x.id ?? 0) > 0)
          .map((x) => DropItem(
                id: x.id!,
                label: ((x.name ?? "").trim().isNotEmpty)
                    ? x.name!.trim()
                    : (x.email ?? "Trainer #${x.id}").trim(),
              ))
          .toList(),
    );
  }

  void _mapClasses(List<cls_model.Classes> list) {
    classes.assignAll(
      list
          .where((x) => (x.id ?? 0) > 0)
          .map((x) => DropItem(
                id: x.id!,
                label: (x.title ?? "Class #${x.id}").trim(),
              ))
          .toList(),
    );
  }

  // ------------------ STEP NAV (FIXED) ------------------
  void nextStep() {
    if (currentStep.value == 0) {
      if (!(basicFormKey.currentState?.validate() ?? false)) return;

      if (profileImage.value == null) {
        _warnToast("Profile image is required");
        return;
      }
      if (!_validateProfileFile(profileImage.value!)) return;

      if (documentFile.value == null) {
        _warnToast("Document is required");
        return;
      }
      if (!_validateDocumentFile(documentFile.value!)) return;
    }

    if (currentStep.value == 1) {
      if (!(addressFormKey.currentState?.validate() ?? false)) return;
    }

    if (currentStep.value < 2) currentStep.value++;
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // ------------------ PICKERS ------------------
  Future<void> pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (x != null) {
        final f = File(x.path);
        if (!_validateProfileFile(f)) return;
        profileImage.value = f;
      }
    } catch (e) {
      _warnToast("Failed to pick image: $e");
    }
  }

  Future<void> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      );
      if (result != null && result.files.single.path != null) {
        final f = File(result.files.single.path!);
        if (!_validateDocumentFile(f)) return;
        documentFile.value = f;
      }
    } catch (e) {
      _warnToast("Failed to pick document: $e");
    }
  }

  // ------------------ SUBMIT (FIXED) ------------------
  Future<void> submitForm() async {
    if (isSubmitting.value) return; // prevent double taps

   

   

   


    // date checks
    final dobText = dobController.text.trim();
    final startText = membershipStartController.text.trim();

    if (!_isValidDdMmYyyy(dobText)) {
      _warnToast("DOB invalid (DD-MM-YYYY)");
      currentStep.value = 0;
      return;
    }
    if (!_isValidDdMmYyyy(startText)) {
      _warnToast("Membership start date invalid (DD-MM-YYYY)");
      currentStep.value = 2;
      return;
    }

    isSubmitting.value = true;

    try {
      final token = await getToken();
      if (token == null || token.trim().isEmpty) {
        _errorToast("Token missing. Login again.");
        return;
      }

      final req = http.MultipartRequest("POST", Uri.parse(createTraineeEndpoint));
      req.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer ${token.trim()}",
      });

      // ✅ EXACT BODY KEYS YOU SHARED
      req.fields["name"] = nameController.text.trim();
      req.fields["email"] = emailController.text.trim();
      req.fields["password"] = passwordController.text.trim();
      req.fields["phone_number"] = phoneController.text.trim();
      req.fields["dob"] = _ddMMyyyyToYyyyMMdd(dobText);
      req.fields["age"] = ageController.text.trim();
      req.fields["gender"] = gender.value;

      req.fields["category"] = "${selectedCategory.value!.id}";
      req.fields["fitness_goal"] = goalController.text.trim();
      req.fields["membership_plan"] = "${selectedMembership.value!.id}";
      req.fields["membership_start_date"] = _ddMMyyyyToYyyyMMdd(startText);
      req.fields["trainer_assign"] = "${selectedTrainer.value!.id}";

      req.fields["address"] = addressController.text.trim();
      req.fields["city"] = cityController.text.trim();
      req.fields["district"] = districtController.text.trim();
      req.fields["state"] = stateController.text.trim();
      req.fields["country"] = countryController.text.trim();
      req.fields["zip_code"] = zipController.text.trim(); // pincode

      // ✅ KEEP Classes dropdown in UI ONLY (do not send to API)
      // If backend later supports it, then add key here.

      req.files.add(await http.MultipartFile.fromPath("profile", profileImage.value!.path));
      req.files.add(await http.MultipartFile.fromPath("document", documentFile.value!.path));

      // Debug prints
      debugPrint("====== TRAINEE CREATE REQUEST ======");
      debugPrint("URL: $createTraineeEndpoint");
      req.fields.forEach((k, v) => debugPrint("FIELD $k: $v"));
      for (final f in req.files) {
        debugPrint("FILE ${f.field}: ${f.filename}");
      }

      final streamed = await req.send().timeout(const Duration(seconds: 20));
      final resp = await http.Response.fromStream(streamed);

      debugPrint("STATUS: ${resp.statusCode}");
      debugPrint("BODY: ${resp.body}");

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        Get.snackbar(
          "Success",
          "Trainee created successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        clearAll();

        // Keep the dashboard's "Members" stat card in sync with the trainee
        // we just added, without waiting for the user to pull-to-refresh.
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchDashboard();
        }
        return;
      }

      final pretty = _prettyApiError(resp.body);
      Get.defaultDialog(
        title: "Create Failed (${resp.statusCode})",
        content: SingleChildScrollView(child: Text(pretty, style: const TextStyle(fontSize: 12))),
        confirm: ElevatedButton(onPressed: Get.back, child: const Text("OK")),
      );
    } catch (e) {
      _errorToast("Create failed: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

  String _prettyApiError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded["message"]?.toString();
        final errors = decoded["errors"];
        if (errors is Map) {
          final b = StringBuffer();
          if (message != null) b.writeln(message);
          errors.forEach((k, v) => b.writeln("$k: $v"));
          return b.toString();
        }
        if (message != null) return message;
        return decoded.toString();
      }
      return body;
    } catch (_) {
      return body;
    }
  }

  void clearAll() {
    currentStep.value = 0;

    nameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    dobController.clear();
    ageController.clear();
    gender.value = "Male";

    profileImage.value = null;
    documentFile.value = null;

    addressController.clear();
    cityController.clear();
    districtController.clear();
    stateController.clear();
    countryController.text = "India";
    zipController.clear();

    goalController.clear();
    membershipStartController.clear();

    selectedCategory.value = categories.isNotEmpty ? categories.first : null;
    selectedMembership.value = memberships.isNotEmpty ? memberships.first : null;
    selectedTrainer.value = trainers.isNotEmpty ? trainers.first : null;
    selectedClass.value = classes.isNotEmpty ? classes.first : null; // keep UI dropdown
  }

  // ------------------ FILE VALIDATION ------------------
  bool _validateProfileFile(File f) {
    final ext = f.path.toLowerCase();
    final okType = ext.endsWith(".jpg") || ext.endsWith(".jpeg") || ext.endsWith(".png");
    if (!okType) {
      _warnToast("Profile must be jpg/jpeg/png");
      return false;
    }
    final bytes = f.lengthSync();
    if (bytes > 2 * 1024 * 1024) {
      _warnToast("Profile max size is 2MB");
      return false;
    }
    return true;
  }

  bool _validateDocumentFile(File f) {
    final ext = f.path.toLowerCase();
    final okType = ext.endsWith(".pdf") ||
        ext.endsWith(".doc") ||
        ext.endsWith(".docx") ||
        ext.endsWith(".jpg") ||
        ext.endsWith(".jpeg") ||
        ext.endsWith(".png");
    if (!okType) {
      _warnToast("Document must be pdf/doc/docx/jpg/jpeg/png");
      return false;
    }
    final bytes = f.lengthSync();
    if (bytes > 5 * 1024 * 1024) {
      _warnToast("Document max size is 5MB");
      return false;
    }
    return true;
  }

  // ------------------ DATE HELPERS ------------------
  bool _isValidDdMmYyyy(String input) {
    try {
      DateFormat("dd-MM-yyyy").parseStrict(input.trim());
      return true;
    } catch (_) {
      return false;
    }
  }

  String _ddMMyyyyToYyyyMMdd(String input) {
    final d = DateFormat("dd-MM-yyyy").parseStrict(input.trim());
    return DateFormat("yyyy-MM-dd").format(d);
  }

  void _warnToast(String msg) {
    Get.snackbar(
      "Alert",
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void _errorToast(String msg) {
    Get.snackbar(
      "Error",
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 6),
    );
  }
}
