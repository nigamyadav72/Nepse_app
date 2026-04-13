class NepseIndex {
  final String index;
  final double currentValue;
  final double change;
  final double percentChange;

  NepseIndex({
    required this.index,
    required this.currentValue,
    required this.change,
    required this.percentChange,
  });

  bool get isGain => change >= 0;

  factory NepseIndex.fromJson(Map<String, dynamic> json) {
    return NepseIndex(
      index: (json['index'] ?? json['Index'] ?? json['name'] ?? 'N/A').toString(),
      currentValue: _toDouble(json['currentValue'] ?? json['value'] ?? json['close'] ?? 0),
      change: _toDouble(json['change'] ?? json['absoluteChange'] ?? 0),
      percentChange: _toDouble(json['percentChange'] ?? json['percentageChange'] ?? json['pctChange'] ?? 0),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
