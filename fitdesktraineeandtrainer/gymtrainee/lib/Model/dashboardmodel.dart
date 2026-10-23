import 'package:gymtrainee/Model/json_utils.dart';

class dashboard {
  bool? success;
  String? message;
  Data? data;

  dashboard({this.success, this.message, this.data});

  dashboard.fromJson(Map<String, dynamic> json) {
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
  AssignedTrainer? assignedTrainer;
  int? totalClass;
  int? totalNote;
  int? totalContact;

  Data(
      {this.assignedTrainer,
      this.totalClass,
      this.totalNote,
      this.totalContact});

  Data.fromJson(Map<String, dynamic> json) {
    assignedTrainer = json['assigned_trainer'] is Map
        ? new AssignedTrainer.fromJson(asMap(json['assigned_trainer'])!)
        : null;
    totalClass = asInt(json['total_class']);
    totalNote = asInt(json['total_note']);
    totalContact = asInt(json['total_contact']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.assignedTrainer != null) {
      data['assigned_trainer'] = this.assignedTrainer!.toJson();
    }
    data['total_class'] = this.totalClass;
    data['total_note'] = this.totalNote;
    data['total_contact'] = this.totalContact;
    return data;
  }
}

class AssignedTrainer {
  int? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? profile;

  AssignedTrainer(
      {this.id, this.name, this.email, this.phoneNumber, this.profile});

  AssignedTrainer.fromJson(Map<String, dynamic> json) {
    id = asInt(json['id']);
    name = asStr(json['name']);
    email = asStr(json['email']);
    phoneNumber = asStr(json['phone_number']);
    profile = asStr(json['profile']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['profile'] = this.profile;
    return data;
  }
}
