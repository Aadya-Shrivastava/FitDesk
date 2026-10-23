class PayFeesModel {
  bool? success;
  String? message;
  PayFeesData? data;

  PayFeesModel({this.success, this.message, this.data});

  PayFeesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message']?.toString();
    data = json['data'] != null ? PayFeesData.fromJson(json['data']) : null;
  }
}

class PayFeesData {
  int? id;
  String? invoiceNumber;
  TraineeMini? trainee;
  String? durationType;
  int? monthNumber;
  String? amount;
  String? paidAmount;
  String? balanceAmount;
  String? dueDate;
  String? status;
  String? paidDate;
  String? paymentMethod;
  String? notes;
  List<Payment>? payments;
  String? createdAt;
  String? updatedAt;

  PayFeesData({
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
    this.payments,
    this.createdAt,
    this.updatedAt,
  });

  PayFeesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceNumber = json['invoice_number']?.toString();
    trainee = json['trainee'] != null ? TraineeMini.fromJson(json['trainee']) : null;
    durationType = json['duration_type']?.toString();
    monthNumber = json['month_number'];
    amount = json['amount']?.toString();
    paidAmount = json['paid_amount']?.toString();
    balanceAmount = json['balance_amount']?.toString();
    dueDate = json['due_date']?.toString();
    status = json['status']?.toString();
    paidDate = json['paid_date']?.toString();
    paymentMethod = json['payment_method']?.toString();
    notes = json['notes']?.toString();
    if (json['payments'] is List) {
      payments = (json['payments'] as List).map((e) => Payment.fromJson(e)).toList();
    }
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
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
}

/// Your backend didn’t define fields. This keeps it safe.
/// If API returns fields later, add them here.
class Payment {
  final Map<String, dynamic> raw;
  Payment(this.raw);

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(json);
}
