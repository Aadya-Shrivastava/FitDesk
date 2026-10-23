import 'package:get/get.dart';
import 'package:gymadmin/controller/splashscreencontroller.dart';
import 'package:gymadmin/controller/viewtrainercontroller.dart';
import 'package:gymadmin/controller/viewworkoutcontroller.dart';

class Viewworkoutbinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Viewworkoutcontroller());
  }
}
