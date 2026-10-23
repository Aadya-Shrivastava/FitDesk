import 'package:get/get.dart';
import 'package:gymadmin/controller/registercontroller.dart';
import 'package:gymadmin/controller/splashscreencontroller.dart';

class Registerbinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RegisterController());
  }
}
