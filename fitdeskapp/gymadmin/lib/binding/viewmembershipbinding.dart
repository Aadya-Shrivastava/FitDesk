import 'package:get/get.dart';
import 'package:gymadmin/controller/splashscreencontroller.dart';
import 'package:gymadmin/controller/viewclasscontroller.dart';
import 'package:gymadmin/controller/viewmembershipcontroller.dart';
import 'package:gymadmin/controller/viewtraineecontroller.dart';
import 'package:gymadmin/controller/viewtrainercontroller.dart';

class Viewmembershipbinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ViewMembershipController ());
  }
}
