// lib/Model/fees_model.dart
class FeesModel {
  bool? success;
  String? message;
  FeesData? data;

  FeesModel({this.success, this.message, this.data});

  FeesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? FeesData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = {};
    out['success'] = success;
    out['message'] = message;
    if (data != null) out['data'] = data!.toJson();
    return out;
  }
}

class FeesData {
  List<FeeItem>? fees;
  Pagination? pagination;

  FeesData({this.fees, this.pagination});

  FeesData.fromJson(Map<String, dynamic> json) {
    if (json['fees'] != null) {
      fees = <FeeItem>[];
      for (final v in (json['fees'] as List)) {
        fees!.add(FeeItem.fromJson(v));
      }
    }
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = {};
    if (fees != null) out['fees'] = fees!.map((v) => v.toJson()).toList();
    if (pagination != null) out['pagination'] = pagination!.toJson();
    return out;
  }
}

class FeeItem {
  int? id;
  String? invoiceNumber;
  TraineeMini? trainee;
  String? durationType; // "Monthly", "Quarterly", etc (depends on backend)
  int? monthNumber; // 1..12 maybe
  String? amount;
  String? paidAmount;
  String? balanceAmount;
  String? dueDate; // usually "YYYY-MM-DD" or ISO
  String? status; // "Paid", "Pending", etc
  String? paidDate;
  String? paymentMethod;
  String? notes;
  String? createdAt;

  FeeItem({
    this.id,
    this.invoiceNumber,
    this.trainee,
    this.durationType,
    this.monthNumber,
    this.amount,
    this.paidAmount,
    this.balanceAmount,
    this.dueDate,
    this.status,
    this.paidDate,
    this.paymentMethod,
    this.notes,
    this.createdAt,
  });

  FeeItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceNumber = json['invoice_number'];
    trainee = json['trainee'] != null ? TraineeMini.fromJson(json['trainee']) : null;
    durationType = json['duration_type'];
    monthNumber = json['month_number'];
    amount = json['amount']?.toString();
    paidAmount = json['paid_amount']?.toString();
    balanceAmount = json['balance_amount']?.toString();
    dueDate = json['due_date']?.toString();
    status = json['status']?.toString();
    paidDate = json['paid_date']?.toString();
    paymentMethod = json['payment_method']?.toString();
    notes = json['notes']?.toString();
    createdAt = json['created_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = {};
    out['id'] = id;
    out['invoice_number'] = invoiceNumber;
    if (trainee != null) out['trainee'] = trainee!.toJson();
    out['duration_type'] = durationType;
    out['month_number'] = monthNumber;
    out['amount'] = amount;
    out['paid_amount'] = paidAmount;
    out['balance_amount'] = balanceAmount;
    out['due_date'] = dueDate;
    out['status'] = status;
    out['paid_date'] = paidDate;
    out['payment_method'] = paymentMethod;
    out['notes'] = notes;
    out['created_at'] = createdAt;
    return out;
  }
}

class TraineeMini {
  int? id;
  String? name;

  TraineeMini({this.id, this.name});

  TraineeMini.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = {};
    out['id'] = id;
    out['name'] = name;
    return out;
  }
}

class Pagination {
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  int? from;
  int? to;

  Pagination({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.from,
    this.to,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    perPage = json['per_page'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    from = json['from'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = {};
    out['total'] = total;
    out['per_page'] = perPage;
    out['current_page'] = currentPage;
    out['last_page'] = lastPage;
    out['from'] = from;
    out['to'] = to;
    return out;
  }
}
