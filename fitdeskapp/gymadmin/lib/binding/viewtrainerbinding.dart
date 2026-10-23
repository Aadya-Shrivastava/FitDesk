import 'package:get/get.dart';
import 'package:gymadmin/controller/viewtrainercontroller.dart';

class Viewtrainerbinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ViewTrainerController());
  }
}
