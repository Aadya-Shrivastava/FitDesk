import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/Model/classmodel.dart';
import 'package:gymadmin/controller/Addtrainercontroller.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:intl/intl.dart';
import 'package:gymadmin/theme/app_palette.dart';
import 'package:gymadmin/widgets/date_calc.dart';

class TrainerAddView extends StatelessWidget {
  final TrainerController controller = Get.isRegistered<TrainerController>()
      ? Get.find<TrainerController>()
      : Get.put(TrainerController());

  TrainerAddView({super.key});

  // -------- Validators --------
  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? "This field is required" : null;

  String? _email(String? v) {
    if (v == null || v.trim().isEmpty) return "Email is required";
    final value = v.trim();
    final reg = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    if (!reg.hasMatch(value)) return "Enter a valid email";
    return null;
  }

  String? _phone(String? v) {
    if (v == null || v.trim().isEmpty) return "Phone number is required";
    final value = v.trim();
    final reg = RegExp(r'^\d{10,15}$');
    if (!reg.hasMatch(value)) return "Enter a valid phone (10-15 digits)";
    return null;
  }

  String? _password(String? v) {
    if (v == null || v.isEmpty) return "Password is required";
    if (v.length < 8) return "Password must be at least 8 characters";
    return null;
  }

  String? _pincode(String? v) {
    if (v == null || v.trim().isEmpty) return "Pincode is required";
    final value = v.trim();
    if (!RegExp(r'^\d{4,10}$').hasMatch(value)) return "Enter a valid pincode";
    return null;
  }

  String? _dob(String? v) {
    if (v == null || v.trim().isEmpty) return "DOB is required";
    try {
      DateFormat('dd-MM-yyyy').parseStrict(v.trim());
      return null;
    } catch (_) {
      return "DOB must be in DD-MM-YYYY";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          "Add Trainer",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppPalette.primary,
        centerTitle: true,
        actions: [
          Container(
            height: 40.h,
            width: 160.w,
            decoration: const BoxDecoration(shape: BoxShape.rectangle),
            child: ElevatedButton(
              onPressed: () => Get.toNamed(RouteName.viewtrainer),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: Text("View Trainers", style: TextStyle(fontSize: 15.sp, color: AppPalette.primary)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(),
              SizedBox(height: 16.h),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: controller.currentStep.value == 0
                      ? _buildBasicInfoForm()
                      : _buildAddressForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepCircle("1", "Basic Info", controller.currentStep.value == 0),
        Container(width: 40.w, height: 2.h, color: AppPalette.border),
        _stepCircle("2", "Address", controller.currentStep.value == 1),
      ],
    );
  }

  Widget _stepCircle(String step, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: isActive ? AppPalette.primary : Colors.grey,
          child: Text(
            step,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: isActive ? AppPalette.primary : AppPalette.textSecondary,
          ),
        ),
      ],
    );
  }

  // ---------- BASIC INFO FORM ----------
  Widget _buildBasicInfoForm() {
    return Form(
      key: controller.basicInfoFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        children: [
          _buildTextField("Name", controller.nameController, Icons.person,
              validator: _required),
          _buildTextField("Email", controller.emailController, Icons.email,
              validator: _email, type: TextInputType.emailAddress),
          _buildTextField("Phone Number", controller.phoneController, Icons.phone,
              validator: _phone, type: TextInputType.phone),
          _buildTextField("Password", controller.passwordController, Icons.lock,
              validator: _password, obscure: true),
          _buildTextField("Qualification", controller.qualificationController,
              Icons.school,
              validator: _required),

          // ✅ Classes dropdown from API
          _buildClassesDropdown(),

          _buildDateField("Date of Birth", controller.dobController),
          _buildGenderDropdown("Gender", controller.gender),

          SizedBox(height: 6.h),
          _buildFilePickers(),

          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppPalette.primary),
                ),
                child: Text(
                  "Back",
                  style: GoogleFonts.poppins(
                    color: AppPalette.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () {
                          if (!controller.basicInfoFormKey.currentState!.validate()) {
                            return;
                          }

                          // require dropdown + files before next step
                          if (controller.selectedClass.value == null) {
                            Get.snackbar(
                              "Error",
                              "Please select a class.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          if (controller.profileImage.value == null) {
                            Get.snackbar(
                              "Error",
                              "Please select a profile image.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          if (controller.documentFile.value == null) {
                            Get.snackbar(
                              "Error",
                              "Please select a document.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          controller.nextStep();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary,
                    padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                  ),
                  child: Text(
                    "Next",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassesDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Obx(() {
        if (controller.isLoadingClasses.value) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: "Class",
              prefixIcon: const Icon(Icons.class_, color: AppPalette.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              filled: true,
              fillColor: AppPalette.surface,
            ),
            child: Row(
              children: [
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12.w),
                Text("Loading classes...", style: GoogleFonts.poppins()),
              ],
            ),
          );
        }

        return DropdownButtonFormField<Classes>(
          value: controller.selectedClass.value,
          items: controller.classesList
              .map(
                (c) => DropdownMenuItem<Classes>(
                  value: c,
                  child: Text(c.title ?? "Untitled"),
                ),
              )
              .toList(),
          onChanged: (val) => controller.selectedClass.value = val,
          validator: (_) => controller.selectedClass.value == null
              ? "Class is required"
              : null,
          decoration: InputDecoration(
            labelText: "Class",
            prefixIcon: const Icon(Icons.class_, color: AppPalette.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            filled: true,
            fillColor: AppPalette.surface,
          ),
        );
      }),
    );
  }

  Widget _buildFilePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Uploads",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 10.h),

        // Profile image
        Obx(() {
          final File? img = controller.profileImage.value;
          return Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.pickProfileImage,
                  icon: const Icon(Icons.image),
                  label: Text(img == null
                      ? "Pick Profile Image"
                      : "Change Profile Image"),
                ),
              ),
              SizedBox(width: 10.w),
              if (img != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.file(
                    img,
                    width: 52.w,
                    height: 52.w,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          );
        }),
        SizedBox(height: 10.h),

        // Document
        Obx(() {
          final File? doc = controller.documentFile.value;
          return Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.pickDocument,
                  icon: const Icon(Icons.attach_file),
                  label: Text(doc == null ? "Pick Document" : "Change Document"),
                ),
              ),
              SizedBox(width: 10.w),
              if (doc != null)
                Expanded(
                  child: Text(
                    doc.path.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12.sp),
                  ),
                ),
            ],
          );
        }),
        SizedBox(height: 4.h),
        Text(
          "Profile: jpg/jpeg/png (max 2MB) • Document: pdf/doc/docx/jpg/png (max 5MB)",
          style: GoogleFonts.poppins(fontSize: 11.sp, color: AppPalette.textSecondary),
        ),
      ],
    );
  }

  // ---------- ADDRESS FORM ----------
  Widget _buildAddressForm() {
    return Form(
      key: controller.addressFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        children: [
          _buildUseLocationButton(),
          SizedBox(height: 6.h),
          _buildTextField("Country", controller.countryController, Icons.public,
              validator: _required),
          _buildTextField("State", controller.stateController, Icons.map,
              validator: _required),
          _buildPincodeField(),
          _buildTextField("City", controller.cityController, Icons.location_city,
              validator: _required),
          _buildTextField("District", controller.districtController, Icons.location_on,
              validator: _required),
          _buildTextField("Address", controller.addressController, Icons.home,
              validator: _required, maxLines: 3),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.previousStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppPalette.primary),
                ),
                child: Text(
                  "Back",
                  style: GoogleFonts.poppins(
                    color: AppPalette.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : controller.submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                  ),
                  child: controller.isSubmitting.value
                      ? SizedBox(
                          height: 18.h,
                          width: 18.h,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          "Finish",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ---------- COMMON BUILDERS ----------
  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    required String? Function(String?) validator,
    bool obscure = false,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: type,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppPalette.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          filled: true,
          fillColor: AppPalette.surface,
        ),
      ),
    );
  }

  // Fills country/state/district/city/pincode from the device's GPS location.
  Widget _buildUseLocationButton() {
    return Obx(() {
      final locating = controller.isLocating.value;
      return Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: locating ? null : controller.useCurrentLocation,
            icon: locating
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location, color: AppPalette.primary),
            label: Text(locating ? "Detecting location..." : "Use Current Location"),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppPalette.primary),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
      );
    });
  }

  // Pincode field: typing a valid 6-digit code auto-fills state/district/city.
  Widget _buildPincodeField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Obx(
        () => TextFormField(
          controller: controller.zipController,
          keyboardType: TextInputType.number,
          validator: _pincode,
          onChanged: controller.onPincodeChanged,
          decoration: InputDecoration(
            labelText: "Pincode",
            prefixIcon: const Icon(Icons.pin_drop, color: AppPalette.primary),
            suffixIcon: controller.isLookingUpPincode.value
                ? Padding(
                    padding: EdgeInsets.all(14.w),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            filled: true,
            fillColor: AppPalette.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController ctrl) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      // Rebuilds as the date changes so the age shows under the field.
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: ctrl,
        builder: (context, value, _) {
          final age = DateCalc.ageFromString(value.text);
          return TextFormField(
            controller: ctrl,
            readOnly: true,
            validator: _dob,
            decoration: InputDecoration(
              labelText: label,
              helperText: age == null ? null : "Age: $age years (calculated automatically)",
              helperStyle: const TextStyle(color: AppPalette.secondary),
              prefixIcon: const Icon(Icons.calendar_today, color: AppPalette.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              filled: true,
              fillColor: AppPalette.surface,
            ),
            onTap: () async {
              final now = DateTime.now();
              final DateTime? pickedDate = await showDatePicker(
                context: Get.context!,
                initialDate: DateCalc.parse(ctrl.text) ??
                    DateTime(now.year - 25, now.month, now.day),
                firstDate: DateTime(1940),
                lastDate: now,
              );
              if (pickedDate != null) {
                ctrl.text = DateFormat('dd-MM-yyyy').format(pickedDate);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildGenderDropdown(String label, RxString value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Obx(
        () => DropdownButtonFormField<String>(
          value: value.value,
          items: ["Male", "Female", "Other"]
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => value.value = val ?? "Male",
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.person, color: AppPalette.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            filled: true,
            fillColor: AppPalette.surface,
          ),
        ),
      ),
    );
  }
}
