import 'package:get/get.dart';
import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';

class Splashscreencontroller extends GetxController {

  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    print("Splashscreencontroller initialized");

    // ⏳ Splash delay
    await Future.delayed(const Duration(seconds: 3));

    // ✅ Read login status
    final bool isLoggedIn =
        await PrefManager().readValue(key: PrefConst.login) ?? false;

    print("Login status: $isLoggedIn");

    // ✅ Navigate based on login flag
    if (isLoggedIn) {
      Get.offNamed(RouteName.dashboard);
    } else {
      Get.offNamed(RouteName.signin);
    }
  }
}
