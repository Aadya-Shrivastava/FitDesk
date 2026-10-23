import 'package:gymtrainee/Model/json_utils.dart';

// IMPORTANT: Rename classes properly. Dart style uses PascalCase.
class ViewAttendanceResponse {
  bool? success;
  String? message;
  AttendanceData? data;

  ViewAttendanceResponse({this.success, this.message, this.data});

  ViewAttendanceResponse.fromJson(Map<String, dynamic> json) {
    success = asBool(json['success']);
    message = asStr(json['message']);
    data = json['data'] is Map ? AttendanceData.fromJson(asMap(json['data'])!) : null;
  }
}

class AttendanceData {
  List<Attendance>? attendance;

  AttendanceData({this.attendance});

  AttendanceData.fromJson(Map<String, dynamic> json) {
    if (json['attendance'] is List) {
      attendance = <Attendance>[];
      json['attendance'].forEach((v) {
        attendance!.add(Attendance.fromJson(asMap(v) ?? {}));
      });
    }
  }
}

class Attendance {
  int? id;
  String? date;
  String? status;
  String? checkedInTime;
  String? checkedOutTime;
  String? checkinAddress;
  String? checkoutAddress;
  String? duration;
  String? notes;

  Attendance({
    this.id,
    this.date,
    this.status,
    this.checkedInTime,
    this.checkedOutTime,
    this.checkinAddress,
    this.checkoutAddress,
    this.duration,
    this.notes,
  });

  Attendance.fromJson(Map<String, dynamic> json) {
    id = asInt(json['id']);
    date = asStr(json['date']);
    status = asStr(json['status']);
    checkedInTime = asStr(json['checked_in_time']);
    checkedOutTime = asStr(json['checked_out_time']);
    checkinAddress = asStr(json['checkin_address']);
    checkoutAddress = asStr(json['checkout_address']);
    duration = asStr(json['duration']);
    notes = asStr(json['notes']);
  }
}
