import 'package:better_serve_lib/model/addon.dart';
import 'package:better_serve_lib/model/attribute.dart';
import 'package:better_serve_lib/model/product.dart';
import 'package:better_serve_lib/model/variation.dart';
import 'package:better_serve/utils/app_helper.dart';

class CartItem {
  Product product;
  int quantity;
  Variation? variation;
  List<Attribute> attributes;
  List<Addon> addons;

  CartItem(
      {required this.product,
      required this.quantity,
      required this.variation,
      required this.attributes,
      required this.addons});

  int get price =>
      variation?.options.getFirstOrNull((e) => e.selected)?.price ??
      product.basePrice;

  int get total {
    int addonsTotal = addons.fold(0, (value, e) => value + e.price);
    return (price * quantity) + addonsTotal;
  }

  dynamic toJson() {
    return {
      "product": product.toJson(),
      "quantity": quantity,
      "variation": variation?.toJson(),
      "attributes": attributes.map((e) => e.toJson()).toList(),
      "addons": addons.map((e) => e.toJson()).toList()
    };
  }

  CartItem.fromJson(dynamic json)
      : this(
            product: Product.fromJson(json["product"]),
            quantity: json["quantity"],
            variation: Variation.fromJson(json["variation"]),
            attributes: (json["attributes"] as List<dynamic>)
                .map((e) => Attribute.fromJson(e))
                .toList(),
            addons: (json["addons"] as List<dynamic>)
                .map((e) => Addon.fromJson(e))
                .toList());
}
