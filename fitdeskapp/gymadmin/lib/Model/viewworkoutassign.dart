  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  class viewworkoutassign {
    bool? success;
    String? message;
    Data? data;

    viewworkoutassign({this.success, this.message, this.data});

    viewworkoutassign.fromJson(Map<String, dynamic> json) {
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
    List<Workouts>? workouts;
    Pagination? pagination;

    Data({this.workouts, this.pagination});

    Data.fromJson(Map<String, dynamic> json) {
      if (json['workouts'] != null) {
        workouts = <Workouts>[];
        json['workouts'].forEach((v) {
          workouts!.add(new Workouts.fromJson(v));
        });
      }
      pagination = json['pagination'] != null
          ? new Pagination.fromJson(json['pagination'])
          : null;
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      if (this.workouts != null) {
        data['workouts'] = this.workouts!.map((v) => v.toJson()).toList();
      }
      if (this.pagination != null) {
        data['pagination'] = this.pagination!.toJson();
      }
      return data;
    }
  }

  class Workouts {
    int? id;
    AssignedTo? assignedTo;
    String? startDate;
    String? endDate;
    String? notes;
    List<Activities>? activities;
    int? totalActivities;
    String? createdAt;

    Workouts(
        {this.id,
        this.assignedTo,
        this.startDate,
        this.endDate,
        this.notes,
        this.activities,
        this.totalActivities,
        this.createdAt});

    Workouts.fromJson(Map<String, dynamic> json) {
      id = _toInt(json['id']);
      assignedTo = json['assigned_to'] != null
          ? new AssignedTo.fromJson(json['assigned_to'])
          : null;
      startDate = json['start_date'];
      endDate = json['end_date'];
      notes = json['notes'];
      if (json['activities'] != null) {
        activities = <Activities>[];
        json['activities'].forEach((v) {
          activities!.add(new Activities.fromJson(v));
        });
      }
      totalActivities = _toInt(json['total_activities']);
      createdAt = json['created_at'];
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['id'] = this.id;
      if (this.assignedTo != null) {
        data['assigned_to'] = this.assignedTo!.toJson();
      }
      data['start_date'] = this.startDate;
      data['end_date'] = this.endDate;
      data['notes'] = this.notes;
      if (this.activities != null) {
        data['activities'] = this.activities!.map((v) => v.toJson()).toList();
      }
      data['total_activities'] = this.totalActivities;
      data['created_at'] = this.createdAt;
      return data;
    }
  }

  class AssignedTo {
    String? type;
    int? id;
    String? title;

    AssignedTo({this.type, this.id, this.title});

    AssignedTo.fromJson(Map<String, dynamic> json) {
      type = json['type'];
      id = _toInt(json['id']);
      title = json['title'];
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['type'] = this.type;
      data['id'] = this.id;
      data['title'] = this.title;
      return data;
    }
  }

  class Activities {
    String? day;
    int? activityId;
    String? activityName;
    int? weight;
    int? sets;
    int? reps;
    int? rest;

    Activities(
        {this.day,
        this.activityId,
        this.activityName,
        this.weight,
        this.sets,
        this.reps,
        this.rest});

    Activities.fromJson(Map<String, dynamic> json) {
      day = json['day'];
      activityId = _toInt(json['activity_id']);
      activityName = json['activity_name'];
      weight = _toInt(json['weight']);
      sets = _toInt(json['sets']);
      reps = _toInt(json['reps']);
      rest = _toInt(json['rest']);
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['day'] = this.day;
      data['activity_id'] = this.activityId;
      data['activity_name'] = this.activityName;
      data['weight'] = this.weight;
      data['sets'] = this.sets;
      data['reps'] = this.reps;
      data['rest'] = this.rest;
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
      total = _toInt(json['total']);
      perPage = _toInt(json['per_page']);
      currentPage = _toInt(json['current_page']);
      lastPage = _toInt(json['last_page']);
      from = _toInt(json['from']);
      to = _toInt(json['to']);
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