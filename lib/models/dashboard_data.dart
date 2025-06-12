class DashboardData {
  final int activeCars;
  final int todayRevenue;
  final int totalRevenue;
  final List<Earning> earnings;

  DashboardData({
    required this.activeCars,
    required this.todayRevenue,
    required this.totalRevenue,
    required this.earnings,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      activeCars: json['active_cars'],
      todayRevenue: json['today_revenue'],
      totalRevenue: json['total_revenue'],
      earnings: (json['earnings'] as List)
          .map((e) => Earning.fromJson(e))
          .toList(),
    );
  }
}

class Earning {
  final String day;
  final int amount;

  Earning({required this.day, required this.amount});

  factory Earning.fromJson(Map<String, dynamic> json) {
    return Earning(
      day: json['day'],
      amount: json['amount'],
    );
  }
}
