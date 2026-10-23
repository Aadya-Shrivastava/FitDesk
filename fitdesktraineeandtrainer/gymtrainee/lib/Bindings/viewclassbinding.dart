import 'package:get/get.dart';
import 'package:gymtrainee/controller/splashscreencontroller.dart';
import 'package:gymtrainee/controller/viewclasscontroller.dart';

class Viewclassbinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Viewclasscontroller());
  }
}
