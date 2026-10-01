import '../../core/utils/currency_formatter.dart';

enum TransactionType {
  deposit,
  transfer,
  payment,
  received,
}

class BankTransaction {
  final String id;
  final String fromAccountNum;
  final String toAccountNum;
  final String fromRoutingNum;
  final String toRoutingNum;
  final int amountCents;
  final DateTime timestamp;
  final String? accountLabel;

  const BankTransaction({
    required this.id,
    required this.fromAccountNum,
    required this.toAccountNum,
    this.fromRoutingNum = '123456789',
    this.toRoutingNum = '123456789',
    required this.amountCents,
    required this.timestamp,
    this.accountLabel,
  });

  bool isInflow(String currentAccountId) => toAccountNum == currentAccountId;
  bool isOutflow(String currentAccountId) => fromAccountNum == currentAccountId;

  String formattedAmount({required String currentAccountId}) {
    final prefix = isInflow(currentAccountId) ? '+' : '-';
    return '$prefix${CurrencyFormatter.formatCents(amountCents)}';
  }

  String displayTitle(String currentAccountId) {
    if (accountLabel != null && accountLabel!.isNotEmpty) {
      return accountLabel!;
    }
    if (isInflow(currentAccountId)) {
      return fromAccountNum == '0000000000' || fromAccountNum.isEmpty
          ? 'Deposit'
          : 'Payment from $fromAccountNum';
    } else {
      return 'Payment to $toAccountNum';
    }
  }

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    DateTime parsedTime;
    final rawTime = json['timestamp'];
    if (rawTime is int) {
      // Milliseconds or seconds
      parsedTime = rawTime > 100000000000
          ? DateTime.fromMillisecondsSinceEpoch(rawTime)
          : DateTime.fromMillisecondsSinceEpoch(rawTime * 1000);
    } else if (rawTime is String) {
      parsedTime = DateTime.tryParse(rawTime) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    final amountRaw = json['amount'];
    int cents = 0;
    if (amountRaw is int) {
      cents = amountRaw;
    } else if (amountRaw is double) {
      cents = (amountRaw * 100).round();
    } else if (amountRaw is String) {
      cents = int.tryParse(amountRaw) ?? CurrencyFormatter.parseDollarsToCents(amountRaw);
    }

    return BankTransaction(
      id: json['transactionId']?.toString() ??
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      fromAccountNum: json['fromAccountNum']?.toString() ??
          json['from_account_num']?.toString() ??
          '',
      toAccountNum: json['toAccountNum']?.toString() ??
          json['to_account_num']?.toString() ??
          '',
      fromRoutingNum: json['fromRoutingNum']?.toString() ??
          json['from_routing_num']?.toString() ??
          '123456789',
      toRoutingNum: json['toRoutingNum']?.toString() ??
          json['to_routing_num']?.toString() ??
          '123456789',
      amountCents: cents,
      timestamp: parsedTime,
      accountLabel: json['accountLabel']?.toString() ?? json['label']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': id,
      'fromAccountNum': fromAccountNum,
      'toAccountNum': toAccountNum,
      'fromRoutingNum': fromRoutingNum,
      'toRoutingNum': toRoutingNum,
      'amount': amountCents,
      'timestamp': timestamp.toIso8601String(),
      'accountLabel': accountLabel,
    };
  }
}
