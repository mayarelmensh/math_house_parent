class PaymentInvoiceModel {
  PaymentInvoiceModel({
      this.invoice,});

  PaymentInvoiceModel.fromJson(dynamic json) {
    invoice = json['invoice'] != null ? Invoice.fromJson(json['invoice']) : null;
  }
  Invoice? invoice;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (invoice != null) {
      map['invoice'] = invoice?.toJson();
    }
    return map;
  }

}

class Invoice {
  Invoice({
      this.receipt,
      this.service,
      this.paymentMethod,
      this.total,
      this.package,
      this.category,
      this.course,
      this.chapters,});

  Invoice.fromJson(dynamic json) {
    receipt = json['receipt'];
    service = json['service'];
    paymentMethod = json['payment_method'];
    total = json['total'];
    package = json['package'];
    category = json['category'];
    course = json['course'];
    chapters = json['chapters'];
  }
  String? receipt;
  String? service;
  String? paymentMethod;
  int? total;
  String? package;
  String? category;
  String? course;
  dynamic chapters;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['receipt'] = receipt;
    map['service'] = service;
    map['payment_method'] = paymentMethod;
    map['total'] = total;
    map['package'] = package;
    map['category'] = category;
    map['course'] = course;
    map['chapters'] = chapters;
    return map;
  }

}