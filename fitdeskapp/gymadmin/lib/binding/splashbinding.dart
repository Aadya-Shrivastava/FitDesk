import 'package:get/get.dart';
import 'package:gymadmin/controller/splashscreencontroller.dart';

class Splashscreenbinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Splashscreencontroller());
  }
}
