import 'package:get/get.dart';
import 'package:gymtrainee/controller/splashscreencontroller.dart';
import 'package:gymtrainee/controller/viewattendancecontroller.dart';

class Viewattendancebinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Viewattendancecontroller());
  }
}
