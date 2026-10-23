import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:gymadmin/controller/logincontroller.dart';
import 'package:gymadmin/controller/payfeescontroller.dart';

class Payfeesbinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>Payfeescontroller());
  }

}