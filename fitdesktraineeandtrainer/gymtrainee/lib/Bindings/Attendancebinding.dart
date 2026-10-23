import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:gymtrainee/controller/Ateendancecontroller.dart';
import 'package:gymtrainee/controller/dashboardcontroller.dart';


class Attendancebinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>AttendanceController());
  }

}