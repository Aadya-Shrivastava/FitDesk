import 'package:get/get.dart';
import 'package:gymtrainee/controller/splashscreencontroller.dart';

class Splashscreenbinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Splashscreencontroller());
  }
}
