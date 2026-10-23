

import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:gymadmin/binding/Addattendencebinding.dart';
import 'package:gymadmin/binding/Addeventbinding.dart';
import 'package:gymadmin/binding/Addtraineebinding.dart';
import 'package:gymadmin/binding/Addtrainerbinding.dart';
import 'package:gymadmin/binding/CreateClassbinding.dart';
import 'package:gymadmin/binding/CreateMembershipbinding.dart';
import 'package:gymadmin/binding/Registerbinding.dart';
import 'package:gymadmin/binding/Viewtraineebinding.dart';
import 'package:gymadmin/binding/createactivitybinding.dart';
import 'package:gymadmin/binding/createcategorytypebinding.dart';
import 'package:gymadmin/binding/createeventtypebinding.dart';
import 'package:gymadmin/binding/createfeesbinding.dart';
import 'package:gymadmin/binding/createworkoutbinding.dart';
import 'package:gymadmin/binding/dashboardbinding.dart';
import 'package:gymadmin/binding/loginbinding.dart';
import 'package:gymadmin/binding/payfeesbinding.dart';
import 'package:gymadmin/binding/splashbinding.dart';
import 'package:gymadmin/binding/takefeesbinding.dart';
import 'package:gymadmin/binding/viewattendancebinding.dart';
import 'package:gymadmin/binding/viewclassbinding.dart';
import 'package:gymadmin/binding/vieweventbinding.dart';
import 'package:gymadmin/binding/viewmembershipbinding.dart';
import 'package:gymadmin/binding/viewtrainerbinding.dart';
import 'package:gymadmin/binding/viewworkoutbinding.dart';
import 'package:gymadmin/view/AddAttendance.dart';
import 'package:gymadmin/view/AddEvent.dart';
import 'package:gymadmin/view/Addtrainee.dart';
import 'package:gymadmin/view/Addtrainer.dart';
import 'package:gymadmin/view/CreateClass.dart';
import 'package:gymadmin/view/CreateMembership.dart';
import 'package:gymadmin/view/CreateWorkout.dart';
import 'package:gymadmin/view/Registerview.dart';
import 'package:gymadmin/view/createactivity.dart';
import 'package:gymadmin/view/createcategorytype.dart';
import 'package:gymadmin/view/createeventtype.dart';
import 'package:gymadmin/view/createfees.dart';
import 'package:gymadmin/view/dashboard.dart';
import 'package:gymadmin/view/login.dart';
import 'package:gymadmin/view/notifications.dart';
import 'package:gymadmin/view/payfees.dart';
import 'package:gymadmin/view/profile.dart';
import 'package:gymadmin/view/splash.dart';
import 'package:gymadmin/view/takefees.dart';
import 'package:gymadmin/view/viewTrainee.dart';
import 'package:gymadmin/view/viewattendance.dart';
import 'package:gymadmin/view/viewclass.dart';
import 'package:gymadmin/view/viewevent.dart';
import 'package:gymadmin/view/viewmembership.dart';
import 'package:gymadmin/view/viewtrainer.dart';
import 'package:gymadmin/view/viewworkout.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';

class AppRoutes {
  static appRoutes() => [
    GetPage(
      name: RouteName.splash_screen,
      page: () => SplashScreen(),
      transition: Transition.rightToLeft,
      binding: Splashscreenbinding(),
    ),
      GetPage(
      name: RouteName.signin,
      page: () => Login(),
      transition: Transition.rightToLeft,
      binding: Signinbinding(),
    ),
    GetPage(
      name: RouteName.dashboard,
      page: () => HomePage(),
      transition: Transition.rightToLeft,
      binding: Dashboardbinding(),
    ),
     GetPage(
      name: RouteName.Addtrainer,
      page: () => TrainerAddView(),
      transition: Transition.rightToLeft,
      binding: Addtrainerbinding(),
    ),
    GetPage(
      name: RouteName.register,
      page: () => RegisterScreen(),
      transition: Transition.rightToLeft,
      binding: Registerbinding(),
    ),
    GetPage(
      name: RouteName.Addtrainee,
      page: () => TraineeAddView(),
      transition: Transition.rightToLeft,
      binding: Addtraineebinding(),
    ),
    GetPage(
      name: RouteName.createclass,
      page: () => ClassAddView(),
      transition: Transition.rightToLeft,
      binding: Createclassbinding(),
    ),
    GetPage(
      name: RouteName.createmembership,
      page: () => MembershipAddView(),
      transition: Transition.rightToLeft,
      binding: Createmembershipbinding(),
    ),
    GetPage(
      name: RouteName.createworkout,
      page: () => WorkoutAddView(),
      transition: Transition.rightToLeft,
      binding: Createworkoutbinding(),
    ),
    GetPage(
      name: RouteName.addAttendance,
      page: () => AttendanceView(),
      transition: Transition.rightToLeft,
      binding: Addattendencebinding(),
    ),
    GetPage(
      name: RouteName.addevent,
      page: () => EventAddView(),
      transition: Transition.rightToLeft,
      binding: Addeventbinding(),
    ),
    GetPage(
      name: RouteName.createactivity,
      page: () => ActivityAddView(),
      transition: Transition.rightToLeft,
      binding: Createactivitybinding(),
    ),
    GetPage(
      name: RouteName.createeventtype,
      page: () => EventTypeAddView(),
      transition: Transition.rightToLeft,
      binding: Createeventtypebinding(),
    ),
    GetPage(
      name: RouteName.CategorytypeController,
      page: () => CategorytypeAddView(),
      transition: Transition.rightToLeft,
      binding: Createcategorytypebinding(),
    ),
     GetPage(
      name: RouteName.viewfees,
      page: () => Takefees(),
      transition: Transition.rightToLeft,
      binding: Takefeesbinding(),
    ),
      GetPage(
      name: RouteName.payfees,
      page: () => Payfees(),
      transition: Transition.rightToLeft,
      binding: Payfeesbinding(),
    ),
     GetPage(
      name: RouteName.createfees,
      page: () => Createfees(),
      transition: Transition.rightToLeft,
      binding: Createfeesbinding(),
    ),
    GetPage(
      name: RouteName.viewtrainer,
      page: () => ViewTrainersPage(),
      transition: Transition.rightToLeft,
      binding: Viewtrainerbinding(),
    ),
     GetPage(
      name: RouteName.viewtrainee,
      page: () => TraineeViewPage(),
      transition: Transition.rightToLeft,
      binding: Viewtraineebinding(),
    ),
     GetPage(
      name: RouteName.viewclass,
      page: () => ClassesViewPage(),
      transition: Transition.rightToLeft,
      binding: Viewclassbinding(),
    ),
     GetPage(
      name: RouteName.viewMembership,
      page: () => MembershipViewPage(),
      transition: Transition.rightToLeft,
      binding: Viewmembershipbinding(),
    ),
      GetPage(
        name: RouteName.viewworkout,
        page: () => WorkoutViewPage(),
        transition: Transition.rightToLeft,
        binding: Viewworkoutbinding(),
      ),
        GetPage(
          name: RouteName.viewattendance,
          page: () => AttendanceViewPage(),
          transition: Transition.rightToLeft,
          binding: Viewattendancebinding(),
        ),
          GetPage(
            name: RouteName.viewevent,
            page: () => EventViewPage(),
            transition: Transition.rightToLeft,
            binding: Vieweventbinding(),
          ),
    GetPage(
      name: RouteName.profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteName.notifications,
      page: () => const NotificationsScreen(),
      transition: Transition.rightToLeft,
    ),
    // total_proj_screen
  ];
}
//arrived_screen