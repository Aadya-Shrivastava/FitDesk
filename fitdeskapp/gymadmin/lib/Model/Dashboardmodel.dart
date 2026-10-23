import 'parse_utils.dart';

class dashboardmodel {
  bool? success;
  String? message;
  Data? data;

  dashboardmodel({this.success, this.message, this.data});

  dashboardmodel.fromJson(Map<String, dynamic> json) {
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
  Stats? stats;
  int? todayIncome;
  int? todayExpense;
  AnalysisReport? analysisReport;
  Subscription? subscription;

  Data(
      {this.stats,
      this.todayIncome,
      this.todayExpense,
      this.analysisReport,
      this.subscription});

  Data.fromJson(Map<String, dynamic> json) {
    stats = json['stats'] != null ? new Stats.fromJson(json['stats']) : null;
    todayIncome = asInt(json['today_income']);
    todayExpense = asInt(json['today_expense']);
    analysisReport = json['analysis_report'] != null
        ? new AnalysisReport.fromJson(json['analysis_report'])
        : null;
    subscription = json['subscription'] != null
        ? new Subscription.fromJson(json['subscription'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.stats != null) {
      data['stats'] = this.stats!.toJson();
    }
    data['today_income'] = this.todayIncome;
    data['today_expense'] = this.todayExpense;
    if (this.analysisReport != null) {
      data['analysis_report'] = this.analysisReport!.toJson();
    }
    if (this.subscription != null) {
      data['subscription'] = this.subscription!.toJson();
    }
    return data;
  }
}

class Stats {
  int? totalTrainers;
  int? totalTrainees;
  int? totalUsers;
  int? activeUsers;
  int? inactiveUsers;

  Stats(
      {this.totalTrainers,
      this.totalTrainees,
      this.totalUsers,
      this.activeUsers,
      this.inactiveUsers});

  Stats.fromJson(Map<String, dynamic> json) {
    totalTrainers = asInt(json['total_trainers']);
    totalTrainees = asInt(json['total_trainees']);
    totalUsers = asInt(json['total_users']);
    activeUsers = asInt(json['active_users']);
    inactiveUsers = asInt(json['inactive_users']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_trainers'] = this.totalTrainers;
    data['total_trainees'] = this.totalTrainees;
    data['total_users'] = this.totalUsers;
    data['active_users'] = this.activeUsers;
    data['inactive_users'] = this.inactiveUsers;
    return data;
  }
}

class AnalysisReport {
  List<String>? label;
  List<int>? income;
  List<int>? expense;

  AnalysisReport({this.label, this.income, this.expense});

  AnalysisReport.fromJson(Map<String, dynamic> json) {
    label = (json['label'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    income = asIntList(json['income']);
    expense = asIntList(json['expense']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['income'] = this.income;
    data['expense'] = this.expense;
    return data;
  }
}

class Subscription {
  Null? name;
  String? interval;
  int? trainerLimit;
  int? traineeLimit;
  String? trainerUsage;
  String? traineeUsage;
  String? expireDate;
  int? daysLeft;
  bool? isExpired;

  Subscription(
      {this.name,
      this.interval,
      this.trainerLimit,
      this.traineeLimit,
      this.trainerUsage,
      this.traineeUsage,
      this.expireDate,
      this.daysLeft,
      this.isExpired});

  Subscription.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    interval = json['interval'];
    trainerLimit = asInt(json['trainer_limit']);
    traineeLimit = asInt(json['trainee_limit']);
    trainerUsage = json['trainer_usage'];
    traineeUsage = json['trainee_usage'];
    expireDate = json['expire_date'];
    daysLeft = asInt(json['days_left']);
    isExpired = json['is_expired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['interval'] = this.interval;
    data['trainer_limit'] = this.trainerLimit;
    data['trainee_limit'] = this.traineeLimit;
    data['trainer_usage'] = this.trainerUsage;
    data['trainee_usage'] = this.traineeUsage;
    data['expire_date'] = this.expireDate;
    data['days_left'] = this.daysLeft;
    data['is_expired'] = this.isExpired;
    return data;
  }
}