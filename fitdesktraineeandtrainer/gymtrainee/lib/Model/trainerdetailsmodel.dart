import 'package:gymtrainee/Model/json_utils.dart';

class trainerdetails {
  bool? success;
  String? message;
  Data? data;

  trainerdetails({this.success, this.message, this.data});

  trainerdetails.fromJson(Map<String, dynamic> json) {
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
  List<Trainers>? trainers;

  Data({this.trainers});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['trainers'] is List) {
      trainers = <Trainers>[];
      json['trainers'].forEach((v) {
        trainers!.add(Trainers.fromJson(asMap(v) ?? {}));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.trainers != null) {
      data['trainers'] = this.trainers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Trainers {
  int? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? profile;
  int? trainerId;
  String? dob;
  String? gender;
  String? qualification;
  String? address;
  String? city;
  String? state;
  String? country;
  String? zipCode;
  int? status;
  dynamic document;

  Trainers(
      {this.id,
      this.name,
      this.email,
      this.phoneNumber,
      this.profile,
      this.trainerId,
      this.dob,
      this.gender,
      this.qualification,
      this.address,
      this.city,
      this.state,
      this.country,
      this.zipCode,
      this.status,
      this.document});

  Trainers.fromJson(Map<String, dynamic> json) {
    id = asInt(json['id']);
    name = asStr(json['name']);
    email = asStr(json['email']);
    phoneNumber = asStr(json['phone_number']);
    profile = asStr(json['profile']);
    trainerId = asInt(json['trainer_id']);
    dob = asStr(json['dob']);
    gender = asStr(json['gender']);
    qualification = asStr(json['qualification']);
    address = asStr(json['address']);
    city = asStr(json['city']);
    state = asStr(json['state']);
    country = asStr(json['country']);
    zipCode = asStr(json['zip_code']);
    status = asInt(json['status']);
    document = json['document'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['profile'] = this.profile;
    data['trainer_id'] = this.trainerId;
    data['dob'] = this.dob;
    data['gender'] = this.gender;
    data['qualification'] = this.qualification;
    data['address'] = this.address;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['zip_code'] = this.zipCode;
    data['status'] = this.status;
    data['document'] = this.document;
    return data;
  }
}
