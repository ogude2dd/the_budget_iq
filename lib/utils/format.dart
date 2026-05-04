String formatCurrency(double amount) {
  // Show whole number if no decimals, else show 2 decimals
  if (amount == amount.truncate()) {
    return amount.toStringAsFixed(0);
  }
  return amount.toStringAsFixed(2);
}