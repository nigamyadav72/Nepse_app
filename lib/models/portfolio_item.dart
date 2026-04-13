import 'dart:convert';

class PortfolioItem {
  final String id;
  final String symbol;
  final int quantity;
  final double purchasePrice;
  final DateTime purchaseDate;

  PortfolioItem({
    required this.id,
    required this.symbol,
    required this.quantity,
    required this.purchasePrice,
    required this.purchaseDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate.toIso8601String(),
    };
  }

  factory PortfolioItem.fromMap(Map<String, dynamic> map) {
    return PortfolioItem(
      id: map['id'],
      symbol: map['symbol'],
      quantity: map['quantity'],
      purchasePrice: map['purchasePrice']?.toDouble() ?? 0.0,
      purchaseDate: DateTime.parse(map['purchaseDate']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PortfolioItem.fromJson(String source) => PortfolioItem.fromMap(json.decode(source));
}
