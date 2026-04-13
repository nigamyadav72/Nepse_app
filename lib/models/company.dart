class Company {
  final String symbol;
  final String name;
  final String? sector;
  final String? status;

  Company({
    required this.symbol,
    required this.name,
    this.sector,
    this.status,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      symbol: (json['symbol'] ?? json['Symbol'] ?? '').toString(),
      name: (json['name'] ?? json['companyName'] ?? json['Name'] ?? '').toString(),
      sector: json['sector']?.toString() ?? json['Sector']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class CompanyDetail {
  final String symbol;
  final String companyName;
  final double? ltp;
  final double? change;
  final double? percentChange;
  final double? openPrice;
  final double? highPrice;
  final double? lowPrice;
  final double? previousClose;
  final int? totalVolume;
  final double? totalTurnover;
  final double? weeks52High;
  final double? weeks52Low;
  final String? sector;
  final double? marketCap;
  final double? eps;
  final double? pe;
  final double? bookValue;
  final double? pbv;

  CompanyDetail({
    required this.symbol,
    required this.companyName,
    this.ltp,
    this.change,
    this.percentChange,
    this.openPrice,
    this.highPrice,
    this.lowPrice,
    this.previousClose,
    this.totalVolume,
    this.totalTurnover,
    this.weeks52High,
    this.weeks52Low,
    this.sector,
    this.marketCap,
    this.eps,
    this.pe,
    this.bookValue,
    this.pbv,
  });

  bool get isGain => (change ?? 0) >= 0;

  factory CompanyDetail.fromJson(Map<String, dynamic> json) {
    // Handle nested or flat structures
    final dynamic stockInfo = json['stockQuote'] ?? json['stock'] ?? json;
    final Map<String, dynamic> data = stockInfo is Map<String, dynamic> ? stockInfo : json;

    return CompanyDetail(
      symbol: (data['symbol'] ?? json['symbol'] ?? '').toString(),
      companyName: (data['companyName'] ?? data['name'] ?? json['companyName'] ?? '').toString(),
      ltp: _toDoubleN(data['ltp'] ?? data['LTP'] ?? data['lastTradedPrice']),
      change: _toDoubleN(data['pointChange'] ?? data['change'] ?? data['priceChange']),
      percentChange: _toDoubleN(data['percentageChange'] ?? data['percentChange']),
      openPrice: _toDoubleN(data['openPrice'] ?? data['open']),
      highPrice: _toDoubleN(data['highPrice'] ?? data['high']),
      lowPrice: _toDoubleN(data['lowPrice'] ?? data['low']),
      previousClose: _toDoubleN(data['previousClose'] ?? data['prevClose'] ?? data['closingPrice']),
      totalVolume: _toIntN(data['totalVolume'] ?? data['volume'] ?? data['qty']),
      totalTurnover: _toDoubleN(data['totalTurnover'] ?? data['turnover']),
      weeks52High: _toDoubleN(data['weeks52High'] ?? data['high52Week'] ?? data['fiftyTwoWeekHigh']),
      weeks52Low: _toDoubleN(data['weeks52Low'] ?? data['low52Week'] ?? data['fiftyTwoWeekLow']),
      sector: (data['sector'] ?? json['sector'])?.toString(),
      marketCap: _toDoubleN(data['marketCap'] ?? data['market_cap']),
      eps: _toDoubleN(data['eps'] ?? data['EPS']),
      pe: _toDoubleN(data['pe'] ?? data['PE'] ?? data['peRatio']),
      bookValue: _toDoubleN(data['bookValue'] ?? data['bv']),
      pbv: _toDoubleN(data['pbv'] ?? data['PBV']),
    );
  }

  static double? _toDoubleN(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _toIntN(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}
