import 'parse_utils.dart';

class viewtrainer {
  bool? success;
  String? message;
  Data? data;

  viewtrainer({this.success, this.message, this.data});

  viewtrainer.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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
  Pagination? pagination;

  Data({this.trainers, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['trainers'] != null) {
      trainers = <Trainers>[];
      json['trainers'].forEach((v) {
        trainers!.add(new Trainers.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.trainers != null) {
      data['trainers'] = this.trainers!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
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
  int? isActive;
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
  String? document;
  String? createdAt;

  Trainers(
      {this.id,
      this.name,
      this.email,
      this.phoneNumber,
      this.profile,
      this.isActive,
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
      this.document,
      this.createdAt});

  Trainers.fromJson(Map<String, dynamic> json) {
    id = asInt(json['id']);
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    profile = json['profile'];
    isActive = asInt(json['is_active']);
    trainerId = asInt(json['trainer_id']);
    dob = json['dob'];
    gender = json['gender'];
    qualification = json['qualification'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    zipCode = json['zip_code'];
    status = asInt(json['status']);
    document = json['document'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['profile'] = this.profile;
    data['is_active'] = this.isActive;
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
    data['created_at'] = this.createdAt;
    return data;
  }
}

class Pagination {
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  int? from;
  int? to;

  Pagination(
      {this.total,
      this.perPage,
      this.currentPage,
      this.lastPage,
      this.from,
      this.to});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = asInt(json['total']);
    perPage = asInt(json['per_page']);
    currentPage = asInt(json['current_page']);
    lastPage = asInt(json['last_page']);
    from = asInt(json['from']);
    to = asInt(json['to']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['per_page'] = this.perPage;
    data['current_page'] = this.currentPage;
    data['last_page'] = this.lastPage;
    data['from'] = this.from;
    data['to'] = this.to;
    return data;
  }
}