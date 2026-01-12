class Wallet {
  final double total;
  final double remaining;

  Wallet({required this.total, required this.remaining});

  Map<String, dynamic> toMap() => {
    'total': total,
    'remaining': remaining,
  };

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      total: map['total'],
      remaining: map['remaining'],
    );
  }
}
