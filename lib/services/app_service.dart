import 'package:better_serve_lib/model/addon.dart';
import 'package:better_serve_lib/model/attribute.dart';
import 'package:better_serve_lib/model/category.dart';
import 'package:better_serve_lib/model/product.dart';
import 'package:better_serve/models/profile.dart';
import 'package:better_serve_lib/model/variation.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppService with ChangeNotifier {
  late Profile profile;

  int pageIndex = 0;
  bool loading = true;
  List<Category> categories = List.empty(growable: true);
  List<Product> products = List.empty(growable: true);
  List<Addon> addons = List.empty(growable: true);

  bool loadingImages = true;

  static const String productSql = """
*, category:category_id(*),
variation:variation_id(*,options:product_variation_options(*)),
attributes:product_attributes(*,options:product_attribute_options(*))
  """;

  AppService() {
    supabase
        .from("profiles")
        .select()
        .eq("id", supabase.auth.currentUser?.id)
        .limit(1)
        .single()
        .execute()
        .then((PostgrestResponse profileRes) async {
      if (profileRes.error != null && profileRes.status != 406) {
        return;
      }
      profile = Profile.fromJson(profileRes.data);

      await loadProducts();
      await loadAddons();
      await loadCategories();

      loading = false;
      notifyListeners();
    });
  }

  Future<void> loadProducts() async {
    PostgrestResponse res =
        await supabase.from("products").select(productSql).execute();

    if (res.error != null && res.status != 406) {
      return;
    }

    products =
        (res.data as List<dynamic>).map((e) => Product.fromJson(e)).toList();
  }

  Future<void> loadCategories() async {
    PostgrestResponse res =
        await supabase.from("categories_with_product_count").select().execute();

    if (res.error != null && res.status != 406) {
      return;
    }

    categories =
        (res.data as List<dynamic>).map((e) => Category.fromJson(e)).toList();

    categories.sort(((a, b) => a.order.compareTo(b.order)));
  }

  Future saveProduct(
      String name,
      int? basePrice,
      int categoryId,
      Variation? variation,
      List<Attribute> attributes,
      String? imageName,
      bool allowAddon) async {
    int? variationId;
    if (variation != null) {
      basePrice = getBasePrice(variation);
      variationId = await insertVariation(null, variation);
    }

    PostgrestResponse res = await supabase.from("products").insert({
      "name": name,
      "category_id": categoryId,
      "base_price": basePrice,
      "variation_id": variationId,
      "img_url": "/images/products/$imageName",
      "allow_addon": allowAddon
    }).execute();

    int productId = res.data[0]["id"];

    await insertExtras(productId, variation, attributes);
    await loadProduct(productId, false);

    notifyListeners();
  }

  updateProduct(
      int id,
      String name,
      int? basePrice,
      int categoryId,
      Variation? variation,
      List<Attribute> attributes,
      String? imageName,
      bool allowAddon) async {
    int? variationId;
    if (variation != null) {
      basePrice = getBasePrice(variation);
      variationId = await insertVariation(id, variation);
    }

    await supabase
        .from("products")
        .update({
          "name": name,
          "category_id": categoryId,
          "base_price": basePrice,
          "variation_id": variationId,
          "img_url": "/images/products/$imageName",
          "allow_addon": allowAddon
        })
        .eq("id", id)
        .execute();

    // remove all attributes
    await supabase
        .from("product_attributes")
        .delete()
        .eq("product_id", id)
        .execute();

    await insertExtras(id, variation, attributes);
    await loadProduct(id, true);

    notifyListeners();
  }

  Future<int> insertVariation(int? productId, Variation variation) async {
    if (productId != null) await deleteVariation(productId);
    PostgrestResponse res = await supabase
        .from("product_variations")
        .insert({"name": variation.name}).execute();
    for (VariationOption opt in variation.options) {
      await supabase.from("product_variation_options").insert({
        "variation_id": res.data[0]["id"],
        "value": opt.value,
        "price": opt.price,
        "is_selected": opt.selected
      }).execute();
    }
    return res.data[0]["id"];
  }

  Future insertExtras(
      int productId, Variation? variation, List<Attribute> attributes) async {
    if (variation != null) {
      var index = 0;
      await supabase
          .from("product_variation_options")
          .insert(variation.options
              .map((e) => {
                    "variation_id": variation.id,
                    "value": e.value,
                    "is_selected": e.selected,
                    "order": index++
                  })
              .toList())
          .execute();
    }
    if (attributes.isNotEmpty) {
      for (Attribute attr in attributes) {
        PostgrestResponse res3 =
            await supabase.from("product_attributes").insert({
          "product_id": productId,
          "name": attr.name,
          "is_multiple": attr.type == AttributeType.multiple
        }).execute();
        int index = 0;
        await supabase
            .from("product_attribute_options")
            .insert(attr.options
                .map((e) => {
                      "attribute_id": res3.data[0]["id"],
                      "value": e.value,
                      "is_selected": e.selected,
                      "order": index++
                    })
                .toList())
            .execute();
      }
    }
  }

  Future<String?> deleteProducts(List<Product> items) async {
    PostgrestResponse res = await supabase
        .from("products")
        .delete()
        .in_("id", items.map((e) => e.id).toList())
        .execute();
    if (res.hasError && res.status != 406) {
      return res.error!.message;
    }

    for (Product p in items) {
      products.remove(p);
    }

    notifyListeners();
    return null;
  }

  Future<void> removeVariation(Product product) async {
    await supabase
        .from("product_variation")
        .delete()
        .eq("id", product.variation!.id)
        .execute();
  }

  int? getBasePrice(Variation? variation) {
    if (variation == null) return null;
    variation.options.sort((a, b) => a.price.compareTo(b.price));
    return variation.options.first.price;
  }

  void refreshItems(VoidCallback callback) {
    loading = true;
    notifyListeners();
    loadProducts().then((value) {
      callback();
      loading = false;
      notifyListeners();
    });
  }

  Future loadProduct(int id, bool update) async {
    PostgrestResponse res = await supabase
        .from("products")
        .select(productSql)
        .eq("id", id)
        .limit(1)
        .single()
        .execute();

    Product product = Product.fromJson(res.data);

    if (update) {
      int index = products.indexWhere((p) => p.id == id);
      products[index] = product;
      return;
    }
    products.add(product);
  }

  Future<void> deleteVariation(int id) async {
    await supabase
        .from("product_variations")
        .delete()
        .eq("product_id", id)
        .execute();
  }

  Future<void> saveCategory(String categoryName, String iconName) async {
    PostgrestResponse<dynamic> res = await supabase
        .from("categories")
        .select("order")
        .order("order")
        .limit(1)
        .single()
        .execute();
    int order = 0;
    if (res.data != null) {
      order = res.data["order"];
    }
    PostgrestResponse<dynamic> res2 = await supabase.from("categories").insert({
      "name": categoryName,
      "icon": "/images/icons/$iconName",
      "order": order + 1
    }).execute();

    Category category = Category.fromJson(res2.data[0]);
    categories.add(category);
    notifyListeners();
  }

  Future<void> loadAddons() async {
    PostgrestResponse<dynamic> res =
        await supabase.from("addons").select().execute();

    if (res.error != null && res.status != 406) {
      return;
    }

    addons.clear();
    addons.addAll((res.data as List<dynamic>).map((e) => Addon.fromJson(e)));
  }

  Future<void> changeCategory(
      List<Product> items, int selectedMoveCategory) async {
    List<Future<PostgrestResponse>> updates = items
        .map((e) => supabase
            .from("products")
            .update({"category_id": selectedMoveCategory})
            .eq("id", e.id)
            .execute())
        .toList();

    await Future.wait(updates);
    await loadProducts();
    notifyListeners();
  }

  void setPage(int index) {
    pageIndex = index;
    notifyListeners();
  }

  Future<String?> deleteCategory(int id) async {
    PostgrestResponse res =
        await supabase.from("categories").delete().eq("id", id).execute();
    if (res.error != null && res.status != 406) {
      return res.error!.message;
    }
    await loadCategories();
    notifyListeners();
    return null;
  }

  Future<void> updateCategory(
      int id, String categoryName, String iconName) async {
    PostgrestResponse res = await supabase
        .from("categories")
        .update({
          "name": categoryName,
          "icon": "/images/icons/$iconName",
        })
        .eq("id", id)
        .execute();
    await loadCategories();
    notifyListeners();
  }

  Future<void> swapOrder(int oldIndex, int newIndex) async {
    Category category = categories[oldIndex];

    categories.removeAt(oldIndex);
    categories.insert(newIndex, category);

    for (int i = 0; i < categories.length; i++) {
      supabase
          .from("categories")
          .update({"order": i})
          .eq("id", categories[i].id)
          .execute();
    }

    notifyListeners();
  }

  Future<void> updateAddon(
      Addon addon, String name, int price, String imageName) async {
    await supabase
        .from("addons")
        .update({
          "name": name,
          "price": price,
          "img_path": "/images/products/$imageName"
        })
        .eq("id", addon.id)
        .execute();
    await loadAddons();
    notifyListeners();
  }

  Future<void> saveAddon(String name, int price, String imageName) async {
    await supabase.from("addons").insert({
      "name": name,
      "price": price,
      "img_path": "/images/products/$imageName"
    }).execute();
    await loadAddons();
    notifyListeners();
  }

  Future<String?> deleteAddons(List<Addon> addons) async {
    PostgrestResponse res = await supabase
        .from("addons")
        .delete()
        .in_("id", addons.map((e) => e.id).toList())
        .execute();

    if (res.hasError) {
      return res.error!.message;
    }

    await loadAddons();
    notifyListeners();
    return null;
  }
}
