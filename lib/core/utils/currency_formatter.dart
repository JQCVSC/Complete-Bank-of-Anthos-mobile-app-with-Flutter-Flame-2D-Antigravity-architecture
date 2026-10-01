import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Converts cents (standard Bank of Anthos internal ledger format) to formatted string
  /// e.g. 150000 cents -> "$1,500.00"
  static String formatCents(int? cents) {
    if (cents == null) return '\$0.00';
    final double dollars = cents / 100.0;
    return _currencyFormat.format(dollars);
  }

  /// Formats dollars double to string
  static String formatDollars(double? dollars) {
    if (dollars == null) return '\$0.00';
    return _currencyFormat.format(dollars);
  }

  /// Parses dollars string input (e.g. "150.50") into integer cents (15050)
  static int parseDollarsToCents(String input) {
    final cleaned = input.replaceAll('\$', '').replaceAll(',', '').trim();
    final double? parsed = double.tryParse(cleaned);
    if (parsed == null) return 0;
    return (parsed * 100).round();
  }
}
