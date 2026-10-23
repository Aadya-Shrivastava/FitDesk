import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/controller/Addtraineecontroller.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:intl/intl.dart';
import 'package:gymadmin/theme/app_palette.dart';
import 'package:gymadmin/widgets/date_calc.dart';

class TraineeAddView extends StatelessWidget {
  final TraineeController controller = Get.find<TraineeController>();

  TraineeAddView({super.key});

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

  String? _age(String? v) {
    if (v == null || v.trim().isEmpty) return "Age is required";
    final value = int.tryParse(v.trim());
    if (value == null) return "Enter a valid age";
    if (value < 1 || value > 100) return "Age must be between 1 and 100";
    return null;
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
          "Add Member",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppPalette.primary,
        actions: [
          // IconButton(
          //   tooltip: "Reload dropdowns",
          //   onPressed: () => controller.fetchAllDropdowns(),
          //   icon: const Icon(Icons.refresh, color: Colors.white),
          // ),
          Container(
            height: 40.h,
            width: 150.w,
            margin: EdgeInsets.only(right: 8.w),
            child: ElevatedButton(
              onPressed: () => Get.toNamed(RouteName.viewtrainee),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: Text("View Member", style: TextStyle(fontSize: 14.sp, color: AppPalette.primary)),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final loadingDropdowns = controller.isLoadingDropdowns.value;
        final submitting = controller.isSubmitting.value;

        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (loadingDropdowns) ...[
                    const LinearProgressIndicator(),
                    SizedBox(height: 10.h),
                  ],
                  _buildStepHeader(),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: KeyedSubtree(
                        key: ValueKey(controller.currentStep.value),
                        child: controller.currentStep.value == 0
                            ? _buildBasicInfoForm()
                            : controller.currentStep.value == 1
                                ? _buildAddressForm()
                                : _buildAdditionalForm(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // submitting overlay
            if (submitting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          SizedBox(width: 12.w),
                          Text(
                            "Submitting...",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildStepHeader() {
    const steps = ["Basic Information", "Address", "Additional Detail"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        steps.length,
        (i) => Column(
          children: [
            CircleAvatar(
              backgroundColor:
                  controller.currentStep.value == i ? AppPalette.primary : Colors.grey,
              child: Text("${i + 1}", style: const TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 4.h),
            Text(
              steps[i],
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: controller.currentStep.value == i
                    ? AppPalette.primary
                    : AppPalette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- BASIC INFO ----------------
  Widget _buildBasicInfoForm() {
    return Form(
      key: controller.basicFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        children: [
          _buildTextField("Name", controller.nameController, Icons.person, validator: _required),
          _buildTextField("Email", controller.emailController, Icons.email,
              validator: _email, type: TextInputType.emailAddress),
          _buildTextField("Password", controller.passwordController, Icons.lock,
              validator: _password, obscure: true),
          _buildTextField("Phone Number", controller.phoneController, Icons.phone,
              validator: _phone, type: TextInputType.phone),
          _buildDateField("Date of Birth", controller.dobController, validator: _dob, isDob: true),
          // Age is worked out from the date of birth, so it's read-only.
          Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: TextFormField(
              controller: controller.ageController,
              readOnly: true,
              validator: _age,
              decoration: InputDecoration(
                labelText: "Age",
                helperText: "Calculated automatically from date of birth",
                prefixIcon: const Icon(Icons.cake, color: AppPalette.primary),
                suffixIcon: const Icon(Icons.auto_awesome, color: AppPalette.secondary, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                filled: true,
                fillColor: AppPalette.surface,
              ),
            ),
          ),
          _buildStringDropdown("Gender", controller.gender, const ["Male", "Female", "Other"]),
          _filePickerField(
            label: "Profile",
            helper: "jpg/jpeg/png (max 2MB)",
            file: controller.profileImage,
            onTap: controller.pickProfileImage,
          ),
          _filePickerField(
            label: "Document",
            helper: "pdf/doc/docx/jpg/jpeg/png (max 5MB)",
            file: controller.documentFile,
            onTap: controller.pickDocument,
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppPalette.primary),
                ),
                child: const Text("Back"),
              ),
              ElevatedButton(
                onPressed: controller.nextStep,
                style: ElevatedButton.styleFrom(backgroundColor: AppPalette.primary),
                child: const Text("Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- ADDRESS FORM ----------------
  Widget _buildAddressForm() {
    return Form(
      key: controller.addressFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        children: [
          _buildUseLocationButton(),
          SizedBox(height: 6.h),
          _buildTextField("Country", controller.countryController, Icons.flag, validator: _required),
          _buildTextField("State", controller.stateController, Icons.map, validator: _required),
          _buildPincodeField(),
          _buildTextField("City", controller.cityController, Icons.location_city, validator: _required),
          _buildTextField("District", controller.districtController, Icons.location_on,
              validator: _required),
          _buildTextField("Address", controller.addressController, Icons.home,
              validator: _required, maxLines: 3),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: controller.previousStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppPalette.primary),
                ),
                child: const Text("Back"),
              ),
              ElevatedButton(
                onPressed: controller.nextStep,
                style: ElevatedButton.styleFrom(backgroundColor: AppPalette.primary),
                child: const Text("Next Step"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- ADDITIONAL FORM ----------------
  Widget _buildAdditionalForm() {
    return Form(
      key: controller.additionalFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        children: [
          _buildTextField(
            "Fitness Goal",
            controller.goalController,
            Icons.flag,
            validator: (v) {
              final req = _required(v);
              if (req != null) return req;
              if (v != null && v.trim().length < 3) return "Fitness goal must be at least 3 characters";
              return null;
            },
          ),
          _buildDropItemDropdown(label: "Category", items: controller.categories, selected: controller.selectedCategory),
          _buildDropItemDropdown(label: "Membership", items: controller.memberships, selected: controller.selectedMembership),
          _buildDateField("Membership Start Date", controller.membershipStartController, validator: _required),
          // Expiry preview from start date + the plan's package.
          Obx(() => controller.membershipExpiryText.value.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.only(bottom: 14.h),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    gradient: AppPalette.headerGradient,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppPalette.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_available, color: AppPalette.secondary),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          "Membership expires on ${controller.membershipExpiryText.value}",
                          style: const TextStyle(color: AppPalette.textPrimary),
                        ),
                      ),
                    ],
                  ),
                )),
          _buildDropItemDropdown(label: "Trainer Assign", items: controller.trainers, selected: controller.selectedTrainer),

          // KEEP CLASSES DROPDOWN (UI only)
          _buildDropItemDropdown(label: "Classes (UI only)", items: controller.classes, selected: controller.selectedClass),

          SizedBox(height: 20.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: controller.previousStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppPalette.primary),
                ),
                child: const Text("Back To Previous"),
              ),
              Obx(() {
                final busy = controller.isSubmitting.value;
                final loading = controller.isLoadingDropdowns.value;
                final disabled = busy || loading;

                return ElevatedButton(
                  onPressed: disabled ? null : _onFinish, // ✅ FIXED
                  style: ElevatedButton.styleFrom(backgroundColor: AppPalette.primary),
                  child: busy
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Finish"),
                );
              }),
            ],
          ),

          SizedBox(height: 10.h),
          Text(
            "Tip: If dropdowns are empty, tap refresh icon in AppBar.",
            style: GoogleFonts.poppins(fontSize: 12.sp, color: AppPalette.textSecondary),
          ),
        ],
      ),
    );
  }

  void _onFinish() {
    // validate final step
    if (!(controller.additionalFormKey.currentState?.validate() ?? false)) return;

    // dropdown validation
    if (controller.selectedCategory.value == null) {
      _snack("Validation", "Please select Category.");
      return;
    }
    if (controller.selectedMembership.value == null) {
      _snack("Validation", "Please select Membership.");
      return;
    }
    if (controller.selectedTrainer.value == null) {
      _snack("Validation", "Please select Trainer.");
      return;
    }

    // classes is UI-only; don’t block submit if backend doesn’t care
    // but you wanted it required in UI:
    if (controller.selectedClass.value == null) {
      _snack("Validation", "Please select Class.");
      return;
    }

    // date validation
    final ms = controller.membershipStartController.text.trim();
    try {
      DateFormat("dd-MM-yyyy").parseStrict(ms);
    } catch (_) {
      _snack("Validation", "Invalid Membership Start Date.");
      return;
    }

    controller.submitForm();
  }

  // ---------------- INPUT HELPERS ----------------
  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    String? Function(String?)? validator,
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

  Widget _buildDateField(
    String label,
    TextEditingController ctrl, {
    String? Function(String?)? validator,
    bool isDob = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: TextFormField(
        controller: ctrl,
        readOnly: true,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, color: AppPalette.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          filled: true,
          fillColor: AppPalette.surface,
        ),
        onTap: () async {
          final now = DateTime.now();
          final current = DateCalc.parse(ctrl.text);
          // DOB can't be in the future; open near a typical adult age.
          final picked = await showDatePicker(
            context: Get.context!,
            initialDate: current ?? (isDob ? DateTime(now.year - 20, now.month, now.day) : now),
            firstDate: DateTime(1940),
            lastDate: isDob ? now : DateTime(2050),
          );
          if (picked != null) {
            ctrl.text = DateFormat('dd-MM-yyyy').format(picked);
          }
        },
      ),
    );
  }

  Widget _buildStringDropdown(String label, RxString value, List<String> options) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Obx(
        () => DropdownButtonFormField<String>(
          value: value.value,
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => value.value = val!,
          validator: (v) => (v == null || v.trim().isEmpty) ? "Please select $label" : null,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.list, color: AppPalette.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            filled: true,
            fillColor: AppPalette.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildDropItemDropdown({
    required String label,
    required RxList<DropItem> items,
    required Rx<DropItem?> selected,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Obx(() {
        final list = items.toList();
        final isEmpty = list.isEmpty;

        return DropdownButtonFormField<DropItem>(
          value: isEmpty ? null : selected.value,
          items: isEmpty
              ? [const DropdownMenuItem(value: null, child: Text("Loading..."))]
              : list.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(),
          onChanged: isEmpty ? null : (val) => selected.value = val,
          validator: (v) => (isEmpty || v == null) ? "Please select $label" : null,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.list, color: AppPalette.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            filled: true,
            fillColor: AppPalette.surface,
          ),
        );
      }),
    );
  }

  Widget _filePickerField({
    required String label,
    required String helper,
    required Rx<File?> file,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Obx(() {
        final name = file.value?.path.split('/').last ?? "Tap to choose";
        final hasFile = file.value != null;

        return InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              helperText: helper,
              suffixIcon: const Icon(Icons.attach_file, color: AppPalette.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              filled: true,
              fillColor: AppPalette.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: hasFile ? AppPalette.border : Colors.redAccent,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: hasFile ? AppPalette.textPrimary : Colors.redAccent,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _snack(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
