import 'parse_utils.dart';

class membershipmodel {
  bool? success;
  String? message;
  Data? data;

  membershipmodel({this.success, this.message, this.data});

  membershipmodel.fromJson(Map<String, dynamic> json) {
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
  List<Memberships>? memberships;
  Pagination? pagination;

  Data({this.memberships, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['memberships'] != null) {
      memberships = <Memberships>[];
      json['memberships'].forEach((v) {
        memberships!.add(new Memberships.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.memberships != null) {
      data['memberships'] = this.memberships!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class Memberships {
  int? id;
  String? title;
  String? package;
  String? packageLabel;
  int? amount;
  int? withTrainerFee;
  int? withoutTrainerFee;
  String? notes;
  List<Classes>? classes;
  int? totalTrainees;
  String? createdAt;

  Memberships(
      {this.id,
      this.title,
      this.package,
      this.packageLabel,
      this.amount,
      this.withTrainerFee,
      this.withoutTrainerFee,
      this.notes,
      this.classes,
      this.totalTrainees,
      this.createdAt});

  Memberships.fromJson(Map<String, dynamic> json) {
    id = asInt(json['id']);
    title = json['title'];
    package = json['package'];
    packageLabel = json['package_label'];
    amount = asInt(json['amount']);
    withTrainerFee = asInt(json['with_trainer_fee']);
    withoutTrainerFee = asInt(json['without_trainer_fee']);
    notes = json['notes'];
    if (json['classes'] != null) {
      classes = <Classes>[];
      json['classes'].forEach((v) {
        classes!.add(new Classes.fromJson(v));
      });
    }
    totalTrainees = asInt(json['total_trainees']);
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['package'] = this.package;
    data['package_label'] = this.packageLabel;
    data['amount'] = this.amount;
    data['with_trainer_fee'] = this.withTrainerFee;
    data['without_trainer_fee'] = this.withoutTrainerFee;
    data['notes'] = this.notes;
    if (this.classes != null) {
      data['classes'] = this.classes!.map((v) => v.toJson()).toList();
    }
    data['total_trainees'] = this.totalTrainees;
    data['created_at'] = this.createdAt;
    return data;
  }
}

class Classes {
  int? id;
  String? title;

  Classes({this.id, this.title});

  Classes.fromJson(Map<String, dynamic> json) {
    id = asInt(json['id']);
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
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