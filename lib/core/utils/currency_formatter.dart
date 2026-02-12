class CurrencyFormatter {
  CurrencyFormatter._();

  static String formatMYR(int cents) {
    final ringgit = cents / 100;
    return 'RM ${ringgit.toStringAsFixed(2)}';
  }

  static String formatCents(int cents, String currency) {
    final amount = cents / 100;
    switch (currency) {
      case 'MYR':
        return 'RM ${amount.toStringAsFixed(2)}';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'SGD':
        return 'S\$${amount.toStringAsFixed(2)}';
      default:
        return '$currency ${amount.toStringAsFixed(2)}';
    }
  }
}
