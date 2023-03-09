import 'package:better_serve/services/order_service.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:better_serve_lib/model/addon.dart';
import 'package:better_serve_lib/model/attribute.dart';
import 'package:better_serve/models/cart_item.dart';
import 'package:better_serve_lib/model/coupon.dart';
import 'package:better_serve_lib/model/discount.dart';
import 'package:better_serve_lib/model/variation.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve_lib/model/order.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:better_serve_lib/model/product.dart';

class CartService with ChangeNotifier {
  List<CartItem> items = List.empty(growable: true);
  Order? currentOrder;
  List<Order> onholds = List.empty(growable: true);

  int tenderAmount = 0;
  Discount? discount;
  Coupon? coupon;

  int get itemCount => items.fold(0, (value, item) => value + item.quantity);

  double get totalAmount => items.fold(0, (value, e) => value + e.total);

  bool get hasItem => items.isNotEmpty;

  CartService() {
    loadOnHoldOrders();
  }

  Future loadOnHoldOrders() async {
    PostgrestResponse res = await supabase
        .from("orders")
        .select(OrderService.orderSelect)
        .eq("status", OrderStatus.onhold.ordinal)
        .order("order_time", ascending: true)
        .execute();
    if (res.hasError) return;
    onholds.clear();
    onholds.addAll(
        (res.data as List<dynamic>).map((e) => Order.fromJson(e)).toList());
  }

  void addItem(CartItem newItem) {
    int index = getItemIndex(
        newItem.product, newItem.variation, newItem.attributes, newItem.addons);

    if (index != -1) {
      CartItem item = items[index];
      item.quantity += newItem.quantity;
    } else {
      items.add(newItem);
    }

    notifyListeners();
  }

  Future holdTransaction(Order order) async {
    if (currentOrder != null) {
      // remove order record
      deleteOrder(currentOrder!.id);
      // replace hold order at position
      int index = onholds.indexWhere((e) => e.id == currentOrder!.id);
      onholds.removeAt(index);
      onholds.insert(index, order);
    } else {
      onholds.add(order);
    }
    currentOrder = null;
    items.clear();
    tenderAmount = 0;
    notifyListeners();
  }

  void updateItem(CartItem item, CartItem update) {
    item.quantity = update.quantity;
    item.variation = update.variation;
    item.attributes = update.attributes;
    item.addons = update.addons;
    notifyListeners();
  }

  void removeItem(CartItem item) {
    items.remove(item);
    notifyListeners();
  }

  void updateQuantity(CartItem item, int value) {
    item.quantity = value;
    notifyListeners();
  }

  int getItemIndex(Product item, Variation? variation,
      List<Attribute> attributes, List<Addon> addons) {
    int? selectedVariation =
        variation?.options.getFirstOrNull((e) => e.selected)?.id;
    List<int> selectedOptions = listOptionsId(attributes);
    List<int> selectedAddons = addons.map<int>((e) => e.id).toList();
    return items.indexWhere((ci) {
      var ciVariation =
          ci.variation?.options.getFirstOrNull((e) => e.selected)?.id;
      List<int> ciOptions = listOptionsId(ci.attributes);
      List<int> ciAddons = ci.addons.map<int>((e) => e.id).toList();
      return ci.product.id == item.id &&
          selectedVariation == ciVariation &&
          listEquals(selectedOptions, ciOptions) &&
          listEquals(selectedAddons, ciAddons);
    });
  }

  void clearItems() {
    items.clear();
    notifyListeners();
  }

  List<int> listOptionsId(List<Attribute> attributes) {
    return attributes.fold([], (value, item) {
      value.addAll(
          item.options.where((e) => e.selected).map((e) => e.id!).toList());
      return value;
    });
  }

  void completeTrasaction() {
    resetAll();
    notifyListeners();
  }

  void resetAll() {
    items.clear();
    coupon = null;
    discount = null;
    tenderAmount = 0;
    if (currentOrder != null) {
      deleteOrder(currentOrder!.id);
      onholds.remove(currentOrder);
      currentOrder = null;
    }
  }

  void restoreOrder(Order order) {
    items.clear();
    for (var item in order.items) {
      Product product = item.product!;
      if (item.variationValue != null) {
        product.variation!.options = product.variation!.options.map((e) {
          e.selected = e.value == item.variationValue;
          return e;
        }).toList();
      }
      product.attributes = product.attributes.map((e) {
        OrderItemAttribute? attr =
            item.attributes.getFirstOrNull((attr) => attr.name == e.name);
        if (attr != null) {
          e.options = e.options.map((opt) {
            opt.selected = attr.values.contains(opt.value);
            return opt;
          }).toList();
        }
        return e;
      }).toList();

      List<Addon> addons = item.addons.map((e) => e.addon).toList();

      items.add(CartItem(
          product: item.product!,
          quantity: item.quantity,
          variation: product.variation,
          attributes: product.attributes,
          addons: addons));

      currentOrder = order;
    }

    notifyListeners();
  }

  void cancelTransaction() {
    resetAll();
    notifyListeners();
  }

  Future deleteOrder(id) async {
    await supabase.from("orders").delete().eq("id", id).execute();
  }

  void resetPayment() {
    tenderAmount = 0;
    notifyListeners();
  }

  void setDiscount(Discount discount) {
    this.discount = discount;
    notifyListeners();
  }

  Future<bool> setCoupon(String? code) async {
    if (code == null) {
      coupon = null;
    } else {
      PostgrestResponse res = await supabase
          .from("coupons")
          .select("*")
          .eq("code", code)
          .limit(1)
          .single()
          .execute();
      if (res.hasError) return false;

      coupon = Coupon.fromJson(res.data);
    }

    notifyListeners();
    return true;
  }

  void setTenderAmount(int value) {
    tenderAmount = value;
    notifyListeners();
  }
}
