class loginmodel {
  bool? success;
  String? message;
  Data? data;

  loginmodel({this.success, this.message, this.data});

  loginmodel.fromJson(Map<String, dynamic> json) {
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
  User? user;
  Subscription? subscription;
  BusinessStats? businessStats;
  String? token;

  Data({this.user, this.subscription, this.businessStats, this.token});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    subscription = json['subscription'] != null
        ? new Subscription.fromJson(json['subscription'])
        : null;
    businessStats = json['business_stats'] != null
        ? new BusinessStats.fromJson(json['business_stats'])
        : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.subscription != null) {
      data['subscription'] = this.subscription!.toJson();
    }
    if (this.businessStats != null) {
      data['business_stats'] = this.businessStats!.toJson();
    }
    data['token'] = this.token;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? type;
  String? phoneNumber;
  String? profile;
  int? isActive;

  User(
      {this.id,
      this.name,
      this.email,
      this.type,
      this.phoneNumber,
      this.profile,
      this.isActive});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    type = json['type'];
    phoneNumber = json['phone_number'];
    profile = json['profile'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['type'] = this.type;
    data['phone_number'] = this.phoneNumber;
    data['profile'] = this.profile;
    data['is_active'] = this.isActive;
    return data;
  }
}

class Subscription {
  int? id;
  String? name;
  String? interval;
  double? price;
  int? trainerLimit;
  int? traineeLimit;
  int? classLimit;

  Subscription(
      {this.id,
      this.name,
      this.interval,
      this.price,
      this.trainerLimit,
      this.traineeLimit,
      this.classLimit});

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['title'];
    interval = json['interval'];
    price = (json['price'] as num?)?.toDouble();
    trainerLimit = json['trainer_limit'];
    traineeLimit = json['trainee_limit'];
    classLimit = json['user_limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['interval'] = this.interval;
    data['price'] = this.price;
    data['trainer_limit'] = this.trainerLimit;
    data['trainee_limit'] = this.traineeLimit;
    data['class_limit'] = this.classLimit;
    return data;
  }
}

class BusinessStats {
  int? totalTrainers;
  int? totalTrainees;
  int? totalUsers;

  BusinessStats({this.totalTrainers, this.totalTrainees, this.totalUsers});

  BusinessStats.fromJson(Map<String, dynamic> json) {
    totalTrainers = json['total_trainers'];
    totalTrainees = json['total_trainees'];
    totalUsers = json['total_users'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_trainers'] = this.totalTrainers;
    data['total_trainees'] = this.totalTrainees;
    data['total_users'] = this.totalUsers;
    return data;
  }
}