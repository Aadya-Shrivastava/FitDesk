import 'parse_utils.dart';

class traineemodel {
  bool? success;
  String? message;
  Data? data;

  traineemodel({this.success, this.message, this.data});

  traineemodel.fromJson(Map<String, dynamic> json) {
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
  List<Trainees>? trainees;
  Pagination? pagination;

  Data({this.trainees, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['trainees'] != null) {
      trainees = <Trainees>[];
      json['trainees'].forEach((v) {
        trainees!.add(new Trainees.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.trainees != null) {
      data['trainees'] = this.trainees!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class Trainees {
  int? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? profile;
  int? isActive;
  int? traineeId;
  String? dob;
  int? age;
  String? gender;
  String? fitnessGoal;
  String? category;
  int? categoryId;
  String? trainer;
  int? trainerId;
  String? membershipPlan;
  int? membershipPlanId;
  String? membershipStartDate;
  String? membershipExpiryDate;
  String? address;
  String? city;
  String? state;
  String? country;
  String? zipCode;
  int? status;
  dynamic? document;
  String? createdAt;

  Trainees(
      {this.id,
      this.name,
      this.email,
      this.phoneNumber,
      this.profile,
      this.isActive,
      this.traineeId,
      this.dob,
      this.age,
      this.gender,
      this.fitnessGoal,
      this.category,
      this.categoryId,
      this.trainer,
      this.trainerId,
      this.membershipPlan,
      this.membershipPlanId,
      this.membershipStartDate,
      this.membershipExpiryDate,
      this.address,
      this.city,
      this.state,
      this.country,
      this.zipCode,
      this.status,
      this.document,
      this.createdAt});

  Trainees.fromJson(Map<String, dynamic> json) {
    id = asInt(json['id']);
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    profile = json['profile'];
    isActive = asInt(json['is_active']);
    traineeId = asInt(json['trainee_id']);
    dob = json['dob'];
    age = asInt(json['age']);
    gender = json['gender'];
    fitnessGoal = json['fitness_goal'];
    category = json['category'];
    categoryId = asInt(json['category_id']);
    trainer = json['trainer'];
    trainerId = asInt(json['trainer_id']);
    membershipPlan = json['membership_plan'];
    membershipPlanId = asInt(json['membership_plan_id']);
    membershipStartDate = json['membership_start_date'];
    membershipExpiryDate = json['membership_expiry_date'];
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
    data['trainee_id'] = this.traineeId;
    data['dob'] = this.dob;
    data['age'] = this.age;
    data['gender'] = this.gender;
    data['fitness_goal'] = this.fitnessGoal;
    data['category'] = this.category;
    data['category_id'] = this.categoryId;
    data['trainer'] = this.trainer;
    data['trainer_id'] = this.trainerId;
    data['membership_plan'] = this.membershipPlan;
    data['membership_plan_id'] = this.membershipPlanId;
    data['membership_start_date'] = this.membershipStartDate;
    data['membership_expiry_date'] = this.membershipExpiryDate;
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