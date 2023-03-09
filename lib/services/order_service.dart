import 'package:better_serve/models/cart_item.dart';
import 'package:better_serve_lib/model/coupon.dart';
import 'package:better_serve_lib/model/discount.dart';
import 'package:better_serve_lib/model/order.dart';
import 'package:better_serve/models/sale.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_service.dart';

class OrderService with ChangeNotifier {
  List<Order> orders = List.empty(growable: true);
  List<Order> get onGoingOrders => orders
      .where(
        (order) => [OrderStatus.pending.ordinal, OrderStatus.processing.ordinal]
            .contains(order.status),
      )
      .toList();
  List<Order> get completedOrders => orders
      .where(
        (order) => order.status > 2,
      )
      .toList();

  List<Order> todaysOrders = List.empty(growable: true);

  int get todaysSalesAmount =>
      todaysOrders.fold(0, (v, e) => v + e.orderAmount);
  int get todaysSalesItems => todaysOrders.fold(0, (v, e) => v + e.itemCount);

  static const String orderSelect =
      """*,order_items(*,product:product_id(${AppService.productSql}),
      order_item_attributes(*),
      order_item_addons(*,addon:addon_id(*))),
      coupon:coupon_id(*)
""";

  OrderService() {
    loadOrders().then((_) => notifyListeners());
    subscribeToStatusChange();
  }

  Future<void> subscribeToStatusChange() async {
    supabase.from("orders").on(SupabaseEventTypes.update, (x) {
      if (x.newRecord != null) {
        int index = orders.indexWhere((e) => e.id == x.newRecord!["id"]);
        orders[index].status = x.newRecord!["status"];
        notifyListeners();
      }
    }).subscribe();
  }

  Future<void> loadOrders() async {
    PostgrestResponse res =
        await supabase.from("orders").select(orderSelect).in_("status", [
      OrderStatus.pending.ordinal,
      OrderStatus.processing.ordinal,
    ]).execute();
    orders.clear();
    orders.addAll((res.data as List<dynamic>).map((e) => Order.fromJson(e)));
  }

  Future<Order?> createOrder(List<CartItem> items, double orderAmount,
      double grandTotal, Discount? discount, int paymentAmount, Coupon? coupon,
      [bool isHold = false]) async {
    PostgrestResponse res = await supabase.from("orders").insert({
      "item_count": items.length,
      "order_amount": orderAmount,
      "grand_total": grandTotal,
      "payment_amount": paymentAmount.toInt(),
      if (discount != null) ...{
        "discount_type": discount.type.name,
        "discount_rate":
            discount.type == DiscountType.rate ? discount.value : null,
        "discount_amount": discount.type == DiscountType.fixed
            ? discount.value
            : orderAmount * (discount.value / 100),
      },
      "coupon_id": coupon?.id
    }).execute();
    if (res.error != null && res.status != 406) {
      return null;
    }

    int orderId = res.data[0]["id"];

    for (CartItem item in items) {
      var orderItemRes = await supabase.from("order_items").insert({
        "order_id": orderId,
        "quantity": item.quantity,
        "unit_price": item.price,
        "sub_total": item.total,
        "product_id": item.product.id,
        "product_name": item.product.name,
        "product_img": item.product.imgPath,
        "variation_name": item.variation?.name,
        "variation_value":
            item.variation?.options.getFirstOrNull((v) => v.selected)?.value
      }).execute();

      int orderItemId = orderItemRes.data[0]["id"];

      if (item.attributes.isNotEmpty) {
        await supabase
            .from("order_item_attributes")
            .insert(item.attributes
                .map((e) => {
                      "order_item_id": orderItemId,
                      "name": e.name,
                      "values": e.options
                          .where((opt) => opt.selected)
                          .map<String>((opt) => opt.value)
                          .toList()
                    })
                .toList())
            .execute();
      }

      if (item.addons.isNotEmpty) {
        await supabase
            .from("order_item_addons")
            .insert(item.addons
                .map((e) => {
                      "order_item_id": orderItemId,
                      "name": e.name,
                      "price": e.price,
                      "img_path": e.imgPath,
                      "addon_id": e.id
                    })
                .toList())
            .execute();
      }
    }

    // get newly created order
    var qOrderRes = await supabase
        .from("orders")
        .select(orderSelect)
        .eq("id", res.data[0]["id"])
        .limit(1)
        .single()
        .execute();

    Order newOrder = Order.fromJson(qOrderRes.data);
    orders.add(newOrder);

    if (!isHold) {
      // trigger update so kitchen can pickup new order
      supabase
          .from("orders")
          .update({"status": 1})
          .eq("id", newOrder.id)
          .execute();
    }

    notifyListeners();

    return newOrder;
  }

  Future<void> completeOrder(Order order) async {
    await supabase
        .from("orders")
        .update({"status": 3})
        .eq("id", order.id)
        .execute();

    orders.remove(order);

    loadOrders().then((_) => notifyListeners());
  }

  Future<Sale?> getSale([String? tdate]) async {
    tdate = tdate ?? DateFormat("yyyy-MM-dd").format(DateTime.now());
    PostgrestResponse res = await supabase
        .from("sales")
        .select()
        .eq("transaction_date", tdate)
        .limit(1)
        .single()
        .execute();
    if (res.error != null && res.status != 406) {
      return null;
    }

    if (res.data == null) {
      return Sale(
          orderCount: 0, itemCount: 0, totalAmount: 0, transactionDate: tdate);
    }

    return Sale.fromJson(res.data);
  }
}
