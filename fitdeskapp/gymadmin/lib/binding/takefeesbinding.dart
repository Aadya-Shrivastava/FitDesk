import 'package:get/get.dart';
import 'package:gymadmin/controller/splashscreencontroller.dart';
import 'package:gymadmin/controller/viewattendancecontroller.dart';
import 'package:gymadmin/controller/viewclasscontroller.dart';
import 'package:gymadmin/controller/viewtraineecontroller.dart';
import 'package:gymadmin/controller/viewtrainercontroller.dart';
import 'package:gymadmin/controller/takefeescontroller.dart';

class Takefeesbinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Takefeescontroller());
  }
}
