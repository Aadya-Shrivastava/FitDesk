import 'parse_utils.dart';

class classmodel {
  bool? success;
  String? message;
  Data? data;

  classmodel({this.success, this.message, this.data});

  classmodel.fromJson(Map<String, dynamic> json) {
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
  List<Classes>? classes;
  Pagination? pagination;

  Data({this.classes, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['classes'] != null) {
      classes = <Classes>[];
      json['classes'].forEach((v) {
        classes!.add(new Classes.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.classes != null) {
      data['classes'] = this.classes!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class Classes {
  int? id;
  String? title;
  int? fees;
  String? address;
  String? notes;
  List<Schedules>? schedules;
  List<dynamic>? trainers;
  List<dynamic>? trainees;
  int? totalTrainers;
  int? totalTrainees;
  String? createdAt;

  Classes(
      {this.id,
      this.title,
      this.fees,
      this.address,
      this.notes,
      this.schedules,
      this.trainers,
      this.trainees,
      this.totalTrainers,
      this.totalTrainees,
      this.createdAt});

  Classes.fromJson(Map<String, dynamic> json) {
    id = asInt(json['id']);
    title = json['title'];
    fees = asInt(json['fees']);
    address = json['address'];
    notes = json['notes'];
    if (json['schedules'] != null) {
      schedules = <Schedules>[];
      json['schedules'].forEach((v) {
        schedules!.add(new Schedules.fromJson(v));
      });
    }
    if (json['trainers'] != null) {
      trainers = <dynamic>[];
      json['trainers'].forEach((v) {
        trainers!.add(v);
      });
    }
    if (json['trainees'] != null) {
      trainees = <dynamic>[];
      json['trainees'].forEach((v) {
        trainees!.add(v);
      });
    }
    totalTrainers = asInt(json['total_trainers']);
    totalTrainees = asInt(json['total_trainees']);
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['fees'] = this.fees;
    data['address'] = this.address;
    data['notes'] = this.notes;
    if (this.schedules != null) {
      data['schedules'] = this.schedules!.map((v) => v.toJson()).toList();
    }
    if (this.trainers != null) {
      data['trainers'] = this.trainers!.map((v) => v.toJson()).toList();
    }
    if (this.trainees != null) {
      data['trainees'] = this.trainees!.map((v) => v.toJson()).toList();
    }
    data['total_trainers'] = this.totalTrainers;
    data['total_trainees'] = this.totalTrainees;
    data['created_at'] = this.createdAt;
    return data;
  }
}

class Schedules {
  int? id;
  String? day;
  String? startTime;
  String? endTime;

  Schedules({this.id, this.day, this.startTime, this.endTime});

  Schedules.fromJson(Map<String, dynamic> json) {
    id = asInt(json['id']);
    day = json['day'];
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['day'] = this.day;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
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