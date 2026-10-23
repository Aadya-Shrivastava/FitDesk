

import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:gymtrainee/Bindings/Attendancebinding.dart';
import 'package:gymtrainee/Bindings/dashboardbinding.dart';
import 'package:gymtrainee/Bindings/loginbinding.dart';
import 'package:gymtrainee/Bindings/splashbinding.dart';
import 'package:gymtrainee/Bindings/viewclassbinding.dart';
import 'package:gymtrainee/Bindings/viewtodayworkoutbinding.dart';
import 'package:gymtrainee/Bindings/viewtrainerbinding.dart';
import 'package:gymtrainee/view/Attendanceview.dart';
import 'package:gymtrainee/view/dashboard.dart';
import 'package:gymtrainee/view/login.dart';
import 'package:gymtrainee/view/splash.dart';
import 'package:gymtrainee/view/viewclass.dart';
import 'package:gymtrainee/view/viewtodayworkout.dart';
import 'package:gymtrainee/view/viewtrainer.dart';
import 'package:gymtrainee/Bindings/viewattendancebinding.dart';
import 'package:gymtrainee/view/viewattendanceview.dart';
import 'package:gymtrainee/view/fees.dart';
import 'package:gymtrainee/view/notifications.dart';
import 'package:gymtrainee/view/profile.dart';
import 'package:gymtrainee/view/events.dart';
import 'package:gymtrainee/widgets/routes/page_constants.dart';

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
      name: RouteName.addAttendance,
      page: () => AttendanceView(),
      transition: Transition.rightToLeft,
      binding: Attendancebinding(),
    ),
    GetPage(
      name: RouteName.dashboard,
      page: () => HomePage(),
      transition: Transition.rightToLeft,
      binding: Dashboardbinding(),
    ),
      
     
    GetPage(
      name: RouteName.viewclass,
      page: () => ViewClass(),
      transition: Transition.rightToLeft,
      binding: Viewclassbinding(),
    ),
 
    GetPage(
      name: RouteName.viewtrainer,
      page: () => ViewTrainer(),
      transition: Transition.rightToLeft,
      binding: Viewtrainerbinding(),

    ),
     GetPage(
      name: RouteName.viewworkout,
      page: () => ViewTodayWorkout(),
      transition: Transition.rightToLeft,
      binding: Viewtodayworkoutbinding(),

    ),
     GetPage(
      // Was pointing at the workout screen by mistake.
      name: RouteName.viewattendance,
      page: () => const Viewattendanceview(),
      transition: Transition.rightToLeft,
      binding: Viewattendancebinding(),
    ),
    GetPage(
      name: RouteName.viewfees,
      page: () => FeesView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteName.notifications,
      page: () => NotificationsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteName.profile,
      page: () => ProfileView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteName.viewevent,
      page: () => EventsView(),
      transition: Transition.rightToLeft,
    ),
    //  GetPage(
    //   name: RouteName.Addtrainer,
    //   page: () => TrainerAddView(),
    //   transition: Transition.rightToLeft,
    //   binding: Addtrainerbinding(),
    // ),
    // GetPage(
    //   name: RouteName.register,
    //   page: () => RegisterScreen(),
    //   transition: Transition.rightToLeft,
    //   binding: Registerbinding(),
    // ),
    // GetPage(
    //   name: RouteName.Addtrainee,
    //   page: () => TraineeAddView(),
    //   transition: Transition.rightToLeft,
    //   binding: Addtraineebinding(),
    // ),
    // GetPage(
    //   name: RouteName.createclass,
    //   page: () => ClassAddView(),
    //   transition: Transition.rightToLeft,
    //   binding: Createclassbinding(),
    // ),
    // GetPage(
    //   name: RouteName.createmembership,
    //   page: () => MembershipAddView(),
    //   transition: Transition.rightToLeft,
    //   binding: Createmembershipbinding(),
    // ),
    // GetPage(
    //   name: RouteName.createworkout,
    //   page: () => WorkoutAddView(),
    //   transition: Transition.rightToLeft,
    //   binding: Createworkoutbinding(),
    // ),
    // GetPage(
    //   name: RouteName.addAttendance,
    //   page: () => AttendanceView(),
    //   transition: Transition.rightToLeft,
    //   binding: Addattendencebinding(),
    // ),
    // GetPage(
    //   name: RouteName.addevent,
    //   page: () => EventAddView(),
    //   transition: Transition.rightToLeft,
    //   binding: Addeventbinding(),
    // ),
    // GetPage(
    //   name: RouteName.createactivity,
    //   page: () => ActivityAddView(),
    //   transition: Transition.rightToLeft,
    //   binding: Createactivitybinding(),
    // ),
    // GetPage(
    //   name: RouteName.createeventtype,
    //   page: () => EventTypeAddView(),
    //   transition: Transition.rightToLeft,
    //   binding: Createeventtypebinding(),
    // ),
    // GetPage(
    //   name: RouteName.CategorytypeController,
    //   page: () => CategorytypeAddView(),
    //   transition: Transition.rightToLeft,
    //   binding: Createcategorytypebinding(),
    // ),
    //  GetPage(
    //   name: RouteName.viewfees,
    //   page: () => Takefees(),
    //   transition: Transition.rightToLeft,
    //   binding: Takefeesbinding(),
    // ),
    //   GetPage(
    //   name: RouteName.payfees,
    //   page: () => Payfees(),
    //   transition: Transition.rightToLeft,
    //   binding: Payfeesbinding(),
    // ),
    //  GetPage(
    //   name: RouteName.createfees,
    //   page: () => Createfees(),
    //   transition: Transition.rightToLeft,
    //   binding: Createfeesbinding(),
    // ),
    // GetPage(
    //   name: RouteName.viewtrainer,
    //   page: () => ViewTrainersPage(),
    //   transition: Transition.rightToLeft,
    //   binding: Viewtrainerbinding(),
    // ),
    //  GetPage(
    //   name: RouteName.viewtrainee,
    //   page: () => TraineeViewPage(),
    //   transition: Transition.rightToLeft,
    //   binding: Viewtraineebinding(),
    // ),
    //  GetPage(
    //   name: RouteName.viewclass,
    //   page: () => ClassesViewPage(),
    //   transition: Transition.rightToLeft,
    //   binding: Viewclassbinding(),
    // ),
    //  GetPage(
    //   name: RouteName.viewMembership,
    //   page: () => MembershipViewPage(),
    //   transition: Transition.rightToLeft,
    //   binding: Viewmembershipbinding(),
    // ),
    //   GetPage(
    //     name: RouteName.viewworkout,
    //     page: () => WorkoutViewPage(),
    //     transition: Transition.rightToLeft,
    //     binding: Viewworkoutbinding(),
    //   ),
    //     GetPage(
    //       name: RouteName.viewattendance,
    //       page: () => AttendanceViewPage(),
    //       transition: Transition.rightToLeft,
    //       binding: Viewattendancebinding(),
    //     ),
    //       GetPage(
    //         name: RouteName.viewevent,
    //         page: () => EventViewPage(),
    //         transition: Transition.rightToLeft,
    //         binding: Vieweventbinding(),
    //       ),
    // total_proj_screen
  ];
}
//arrived_screen