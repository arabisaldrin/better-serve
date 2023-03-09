class Sale {
  final int orderCount;
  final int itemCount;
  final int totalAmount;
  final String transactionDate;

  Sale({
    required this.orderCount,
    required this.itemCount,
    required this.totalAmount,
    required this.transactionDate,
  });

  Sale.fromJson(dynamic json)
      : this(
          orderCount: json["order_count"],
          itemCount: json["item_count"],
          totalAmount: json["order_amount"],
          transactionDate: json["transaction_date"],
        );
}
