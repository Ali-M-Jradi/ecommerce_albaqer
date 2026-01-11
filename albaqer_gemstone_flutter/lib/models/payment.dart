class Payment {
  final int? id;
  final int orderId;
  final String paymentMethod;
  final String? transactionId;
  final double amount;
  final String currency;
  final String status;
  final String? paymentGateway;
  final String? cardLastFour;
  final DateTime? createdAt;

  Payment({
    this.id,
    required this.orderId,
    required this.paymentMethod,
    this.transactionId,
    required this.amount,
    this.currency = 'USD',
    this.status = 'pending',
    this.paymentGateway,
    this.cardLastFour,
    this.createdAt,
  });

  // Convert Payment object to Map for database insertion
  Map<String, dynamic> get paymentMap {
    return {
      'id': id,
      'order_id': orderId,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_gateway': paymentGateway,
      'card_last_four': cardLastFour,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create Payment from Map (database result)
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      orderId: map['order_id'] as int,
      paymentMethod: map['payment_method'] as String,
      transactionId: map['transaction_id'] as String?,
      amount: map['amount'] as double,
      currency: map['currency'] as String? ?? 'USD',
      status: map['status'] as String? ?? 'pending',
      paymentGateway: map['payment_gateway'] as String?,
      cardLastFour: map['card_last_four'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  // Create Payment from JSON (API response)
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int?,
      orderId: json['order_id'] as int,
      paymentMethod: json['payment_method'] as String,
      transactionId: json['transaction_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'pending',
      paymentGateway: json['payment_gateway'] as String?,
      cardLastFour: json['card_last_four'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // Convert Payment to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_gateway': paymentGateway,
      'card_last_four': cardLastFour,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Payment{id: $id, orderId: $orderId, method: $paymentMethod, amount: $amount $currency, status: $status}';
  }
}
