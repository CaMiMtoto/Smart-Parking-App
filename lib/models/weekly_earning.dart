class WeeklyEarning {
  final String date;
  final String day;
  final int amount;

  WeeklyEarning({required this.date, required this.day, required this.amount});

  factory WeeklyEarning.fromJson(Map<String, dynamic> json) {
    return WeeklyEarning(
      date: json['date'],
      day: json['day'],
      amount: json['amount'],
    );
  }
}
