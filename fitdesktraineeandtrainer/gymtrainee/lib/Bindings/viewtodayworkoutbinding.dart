import 'package:get/get.dart';
import 'package:gymtrainee/controller/splashscreencontroller.dart';
import 'package:gymtrainee/controller/viewclasscontroller.dart';
import 'package:gymtrainee/controller/viewtodayworkoutcontroller.dart';
import 'package:gymtrainee/view/viewtodayworkout.dart';

class Viewtodayworkoutbinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Viewtodayworkoutcontroller());
  }
}
