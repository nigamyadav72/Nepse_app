class StockItem {
  final String symbol;
  final String? companyName;
  final double ltp;
  final double pointChange;
  final double percentageChange;
  final double? openPrice;
  final double? highPrice;
  final double? lowPrice;
  final double? previousClose;
  final int? totalVolume;
  final double? totalTurnover;

  StockItem({
    required this.symbol,
    this.companyName,
    required this.ltp,
    required this.pointChange,
    required this.percentageChange,
    this.openPrice,
    this.highPrice,
    this.lowPrice,
    this.previousClose,
    this.totalVolume,
    this.totalTurnover,
  });

  bool get isGain => pointChange >= 0;

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      symbol: (json['symbol'] ?? json['Symbol'] ?? '').toString(),
      companyName: json['companyName']?.toString() ?? json['name']?.toString(),
      ltp: _toDouble(json['ltp'] ?? json['LTP'] ?? json['lastTradedPrice'] ?? 0),
      pointChange: _toDouble(json['pointChange'] ?? json['change'] ?? json['priceChange'] ?? 0),
      percentageChange: _toDouble(json['percentageChange'] ?? json['percentChange'] ?? json['pctChange'] ?? 0),
      openPrice: _toDoubleNullable(json['openPrice'] ?? json['open']),
      highPrice: _toDoubleNullable(json['highPrice'] ?? json['high']),
      lowPrice: _toDoubleNullable(json['lowPrice'] ?? json['low']),
      previousClose: _toDoubleNullable(json['previousClose'] ?? json['prevClose'] ?? json['closingPrice']),
      totalVolume: _toIntNullable(json['totalVolume'] ?? json['volume'] ?? json['qty']),
      totalTurnover: _toDoubleNullable(json['totalTurnover'] ?? json['turnover']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _toIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'companyName': companyName,
        'ltp': ltp,
        'pointChange': pointChange,
        'percentageChange': percentageChange,
        'openPrice': openPrice,
        'highPrice': highPrice,
        'lowPrice': lowPrice,
        'previousClose': previousClose,
        'totalVolume': totalVolume,
        'totalTurnover': totalTurnover,
      };
}
