import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();

  void createCategory() {
    if (formKey.currentState!.validate()) {
      Get.snackbar(
        "Success",
        "Category created successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      titleController.clear();
    }
  }
}
