import 'package:gymtrainee/Model/json_utils.dart';

class loginmodel {
  bool? success;
  String? message;
  Data? data;

  loginmodel({this.success, this.message, this.data});

  loginmodel.fromJson(Map<String, dynamic> json) {
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
  User? user;
  Trainee? trainee;
  String? token;

  Data({this.user, this.token});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] is Map ? new User.fromJson(asMap(json['user'])!) : null;
    token = asStr(json['token']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['token'] = this.token;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? type;
  String? profile;
  Trainee? trainee;

  User(
      {this.id,
      this.name,
      this.email,
      this.phoneNumber,
      this.type,
      this.profile,
      this.trainee});

  User.fromJson(Map<String, dynamic> json) {
    id = asInt(json['id']);
    name = asStr(json['name']);
    email = asStr(json['email']);
    phoneNumber = asStr(json['phone_number']);
    type = asStr(json['type']);
    profile = asStr(json['profile']);
    trainee =
        json['trainee'] is Map ? new Trainee.fromJson(asMap(json['trainee'])!) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['type'] = this.type;
    data['profile'] = this.profile;
    if (this.trainee != null) {
      data['trainee'] = this.trainee!.toJson();
    }
    return data;
  }
}

class Trainee {
  int? traineeId;
  String? dob;
  String? gender;
  int? age;
  String? fitnessGoal;
  int? membershipPlan;
  String? membershipStartDate;
  String? membershipExpiryDate;
  int? trainerAssign;

  Trainee(
      {this.traineeId,
      this.dob,
      this.gender,
      this.age,
      this.fitnessGoal,
      this.membershipPlan,
      this.membershipStartDate,
      this.membershipExpiryDate,
      this.trainerAssign});

  Trainee.fromJson(Map<String, dynamic> json) {
    traineeId = asInt(json['trainee_id']);
    dob = asStr(json['dob']);
    gender = asStr(json['gender']);
    age = asInt(json['age']);
    fitnessGoal = asStr(json['fitness_goal']);
    membershipPlan = asInt(json['membership_plan']);
    membershipStartDate = asStr(json['membership_start_date']);
    membershipExpiryDate = asStr(json['membership_expiry_date']);
    trainerAssign = asInt(json['trainer_assign']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trainee_id'] = this.traineeId;
    data['dob'] = this.dob;
    data['gender'] = this.gender;
    data['age'] = this.age;
    data['fitness_goal'] = this.fitnessGoal;
    data['membership_plan'] = this.membershipPlan;
    data['membership_start_date'] = this.membershipStartDate;
    data['membership_expiry_date'] = this.membershipExpiryDate;
    data['trainer_assign'] = this.trainerAssign;
    return data;
  }
}
