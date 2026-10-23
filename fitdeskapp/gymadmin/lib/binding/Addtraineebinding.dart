import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:gymadmin/controller/Addtraineecontroller.dart';
import 'package:gymadmin/controller/Addtrainercontroller.dart';
import 'package:gymadmin/controller/dashboardcontroller.dart';
import 'package:gymadmin/controller/logincontroller.dart';

class Addtraineebinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>TraineeController());
  }

}