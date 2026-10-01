import '../../core/utils/currency_formatter.dart';

class AccountBalance {
  final int balanceCents;
  final String accountId;
  final String routingNumber;
  final DateTime lastUpdated;

  const AccountBalance({
    required this.balanceCents,
    required this.accountId,
    this.routingNumber = '123456789',
    required this.lastUpdated,
  });

  double get dollars => balanceCents / 100.0;
  String get formatted => CurrencyFormatter.formatCents(balanceCents);

  factory AccountBalance.fromRaw(dynamic raw, String accountId) {
    int cents = 0;
    if (raw is int) {
      cents = raw;
    } else if (raw is double) {
      cents = (raw * 100).round();
    } else if (raw is String) {
      cents = int.tryParse(raw) ?? CurrencyFormatter.parseDollarsToCents(raw);
    } else if (raw is Map<String, dynamic>) {
      final val = raw['balance'] ?? raw['amount'] ?? 0;
      if (val is int) cents = val;
      if (val is double) cents = (val * 100).round();
      if (val is String) cents = int.tryParse(val) ?? CurrencyFormatter.parseDollarsToCents(val);
    }
    return AccountBalance(
      balanceCents: cents,
      accountId: accountId,
      lastUpdated: DateTime.now(),
    );
  }

  AccountBalance copyWith({
    int? balanceCents,
    String? accountId,
    String? routingNumber,
    DateTime? lastUpdated,
  }) {
    return AccountBalance(
      balanceCents: balanceCents ?? this.balanceCents,
      accountId: accountId ?? this.accountId,
      routingNumber: routingNumber ?? this.routingNumber,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
