class MarketSummary {
  final double totalTurnover;
  final int totalTradedShares;
  final int totalTransactions;
  final int totalScripsTraded;

  MarketSummary({
    required this.totalTurnover,
    required this.totalTradedShares,
    required this.totalTransactions,
    required this.totalScripsTraded,
  });

  factory MarketSummary.fromJson(Map<String, dynamic> json) {
    return MarketSummary(
      totalTurnover: _toDouble(json['Total Turnover Rs:'] ?? json['totalTurnover'] ?? 0),
      totalTradedShares: _toInt(json['Total Traded Shares'] ?? json['totalTradedShares'] ?? 0),
      totalTransactions: _toInt(json['Total Transactions'] ?? json['totalTransactions'] ?? 0),
      totalScripsTraded: _toInt(json['Total Scrips Traded'] ?? json['totalScripsTraded'] ?? 0),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
