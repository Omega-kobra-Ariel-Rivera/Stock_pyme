class DailyTotal {
  const DailyTotal({required this.day, required this.total});

  final DateTime day;
  final int total;
}

class TopProduct {
  TopProduct({required this.name, this.quantity = 0, this.total = 0});

  final String name;
  double quantity;
  int total;
}
