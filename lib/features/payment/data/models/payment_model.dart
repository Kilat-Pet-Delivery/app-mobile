class PaymentModel {
  final String id;
  final String bookingId;
  final String ownerId;
  final String? runnerId;
  final String escrowStatus;
  final int amountCents;
  final int platformFeeCents;
  final int runnerPayoutCents;
  final String currency;
  final String? paymentMethod;
  final String? stripePaymentId;
  final DateTime? escrowHeldAt;
  final DateTime? escrowReleasedAt;
  final DateTime? refundedAt;
  final String? refundReason;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.ownerId,
    this.runnerId,
    required this.escrowStatus,
    required this.amountCents,
    required this.platformFeeCents,
    required this.runnerPayoutCents,
    required this.currency,
    this.paymentMethod,
    this.stripePaymentId,
    this.escrowHeldAt,
    this.escrowReleasedAt,
    this.refundedAt,
    this.refundReason,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      ownerId: json['owner_id'] as String,
      runnerId: json['runner_id'] as String?,
      escrowStatus: json['escrow_status'] as String,
      amountCents: json['amount_cents'] as int? ?? 0,
      platformFeeCents: json['platform_fee_cents'] as int? ?? 0,
      runnerPayoutCents: json['runner_payout_cents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'MYR',
      paymentMethod: json['payment_method'] as String?,
      stripePaymentId: json['stripe_payment_id'] as String?,
      escrowHeldAt: json['escrow_held_at'] != null
          ? DateTime.parse(json['escrow_held_at'] as String)
          : null,
      escrowReleasedAt: json['escrow_released_at'] != null
          ? DateTime.parse(json['escrow_released_at'] as String)
          : null,
      refundedAt: json['refunded_at'] != null
          ? DateTime.parse(json['refunded_at'] as String)
          : null,
      refundReason: json['refund_reason'] as String?,
      version: json['version'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String get statusDisplay {
    switch (escrowStatus) {
      case 'held': return 'Payment Held';
      case 'released': return 'Payment Released';
      case 'refunded': return 'Refunded';
      case 'created': return 'Processing';
      case 'failed': return 'Failed';
      default: return escrowStatus;
    }
  }
}
