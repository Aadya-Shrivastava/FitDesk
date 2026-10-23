import 'package:gymtrainee/Model/json_utils.dart';

class workout {
  bool? success;
  String? message;
  Data? data;

  workout({this.success, this.message, this.data});

  workout.fromJson(Map<String, dynamic> json) {
    success = asBool(json['success']);
    message = asStr(json['message']);
    data = json['data'] is Map ? new Data.fromJson(asMap(json['data'])!) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Workouts>? workouts;

  Data({this.workouts});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['workouts'] is List) {
      workouts = <Workouts>[];
      json['workouts'].forEach((v) {
        workouts!.add(Workouts.fromJson(asMap(v) ?? {}));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.workouts != null) {
      data['workouts'] = this.workouts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Workouts {
  int? id;
  AssignedTo? assignedTo;
  String? startDate;
  String? endDate;
  String? notes;
  List<Activities>? activities;
  String? createdAt;

  Workouts(
      {this.id,
      this.assignedTo,
      this.startDate,
      this.endDate,
      this.notes,
      this.activities,
      this.createdAt});

  Workouts.fromJson(Map<String, dynamic> json) {
    id = asInt(json['id']);
    assignedTo = json['assigned_to'] is Map
        ? new AssignedTo.fromJson(asMap(json['assigned_to'])!)
        : null;
    startDate = asStr(json['start_date']);
    endDate = asStr(json['end_date']);
    notes = asStr(json['notes']);
    if (json['activities'] is List) {
      activities = <Activities>[];
      json['activities'].forEach((v) {
        activities!.add(Activities.fromJson(asMap(v) ?? {}));
      });
    }
    createdAt = asStr(json['created_at']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.assignedTo != null) {
      data['assigned_to'] = this.assignedTo!.toJson();
    }
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['notes'] = this.notes;
    if (this.activities != null) {
      data['activities'] = this.activities!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = this.createdAt;
    return data;
  }
}

class AssignedTo {
  String? type;
  int? id;

  AssignedTo({this.type, this.id});

  AssignedTo.fromJson(Map<String, dynamic> json) {
    type = asStr(json['type']);
    id = asInt(json['id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['id'] = this.id;
    return data;
  }
}

class Activities {
  String? day;
  String? activityId;
  String? activityName;
  String? weight;
  String? sets;
  String? reps;
  String? rest;

  Activities(
      {this.day,
      this.activityId,
      this.activityName,
      this.weight,
      this.sets,
      this.reps,
      this.rest});

  Activities.fromJson(Map<String, dynamic> json) {
    day = asStr(json['day']);
    activityId = asStr(json['activity_id']);
    activityName = asStr(json['activity_name']);
    weight = asStr(json['weight']);
    sets = asStr(json['sets']);
    reps = asStr(json['reps']);
    rest = asStr(json['rest']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['activity_id'] = this.activityId;
    data['activity_name'] = this.activityName;
    data['weight'] = this.weight;
    data['sets'] = this.sets;
    data['reps'] = this.reps;
    data['rest'] = this.rest;
    return data;
  }
}
