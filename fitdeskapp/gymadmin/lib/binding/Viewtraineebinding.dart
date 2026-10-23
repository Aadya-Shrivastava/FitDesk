import 'package:get/get.dart';
import 'package:gymadmin/controller/splashscreencontroller.dart';
import 'package:gymadmin/controller/viewtraineecontroller.dart';
import 'package:gymadmin/controller/viewtrainercontroller.dart';

class Viewtraineebinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TraineeListController());
  }
}
