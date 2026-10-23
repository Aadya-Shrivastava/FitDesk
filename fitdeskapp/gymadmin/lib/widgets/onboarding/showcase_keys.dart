import 'package:flutter/material.dart';

/// GlobalKeys used to walk first-time users through the drawer's main
/// features. [walkthroughOrder] is the order they're highlighted in — it
/// does not need to match the order the items appear in the drawer list.
class ShowcaseKeys {
  ShowcaseKeys._();

  static final classes = GlobalKey();
  static final membership = GlobalKey();
  static final category = GlobalKey();
  static final workoutActivity = GlobalKey();
  static final trainer = GlobalKey();
  static final trainee = GlobalKey();
  static final workouts = GlobalKey();
  static final fees = GlobalKey();
  static final attendance = GlobalKey();

  static List<GlobalKey> get walkthroughOrder => [
        classes,
        membership,
        category,
        workoutActivity,
        trainer,
        trainee,
        workouts,
        fees,
        attendance,
      ];
}
