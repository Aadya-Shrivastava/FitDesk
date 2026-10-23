import 'package:gymtrainee/Model/json_utils.dart';

class classes {
  bool? success;
  String? message;
  Data? data;

  classes({this.success, this.message, this.data});

  classes.fromJson(Map<String, dynamic> json) {
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
  List<Classes>? classes;

  Data({this.classes});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['classes'] is List) {
      classes = <Classes>[];
      json['classes'].forEach((v) {
        classes!.add(Classes.fromJson(asMap(v) ?? {}));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.classes != null) {
      data['classes'] = this.classes!.map((v) => v.toJson()).toList();
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
  List<Trainers>? trainers;
  bool? isEnrolled;

  Classes(
      {this.id,
      this.title,
      this.fees,
      this.address,
      this.notes,
      this.schedules,
      this.trainers,
      this.isEnrolled});

  Classes.fromJson(Map<String, dynamic> json) {
    id = asInt(json['id']);
    title = asStr(json['title']);
    fees = asInt(json['fees']);
    address = asStr(json['address']);
    notes = asStr(json['notes']);
    if (json['schedules'] is List) {
      schedules = <Schedules>[];
      json['schedules'].forEach((v) {
        schedules!.add(Schedules.fromJson(asMap(v) ?? {}));
      });
    }
    if (json['trainers'] is List) {
      trainers = <Trainers>[];
      json['trainers'].forEach((v) {
        trainers!.add(Trainers.fromJson(asMap(v) ?? {}));
      });
    }
    isEnrolled = asBool(json['is_enrolled']);
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
    data['is_enrolled'] = this.isEnrolled;
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
    day = asStr(json['day']);
    startTime = asStr(json['start_time']);
    endTime = asStr(json['end_time']);
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

class Trainers {
  int? id;
  String? name;
  String? email;

  Trainers({this.id, this.name, this.email});

  Trainers.fromJson(Map<String, dynamic> json) {
    id = asInt(json['id']);
    name = asStr(json['name']);
    email = asStr(json['email']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    return data;
  }
}
