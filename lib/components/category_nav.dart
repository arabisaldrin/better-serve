import 'package:better_serve/pages/manager/categories/widgets/category_form_dialog.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve_lib/model/category.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryNav extends StatefulWidget {
  final List<Category> categories;
  final bool Function(Category?) onSelect;
  final bool showAdd;
  final int selectedIndex;
  const CategoryNav(this.categories,
      {Key? key,
      required this.onSelect,
      this.showAdd = false,
      this.selectedIndex = 0})
      : super(key: key);

  get widgtes => null;

  @override
  State<StatefulWidget> createState() => _CategoryNavState();
}

class _CategoryNavState extends State<CategoryNav> {
  int selectedIndex = 0;
  late SettingsService _settings;
  @override
  void initState() {
    selectedIndex = widget.selectedIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(builder: (context, settings, _) {
      _settings = settings;
      return Material(
        elevation: 10,
        child: SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildItem(
                    0, "All", const Icon(Icons.dashboard_customize_outlined),
                    () {
                  widget.onSelect(null);
                  return true;
                }),
                for (int i = 1; i < widget.categories.length + 1; i++)
                  categoryWidget(i),
                if (widget.showAdd)
                  Hero(
                      tag: "add_category",
                      child: buildItem(widget.categories.length + 2, "Add",
                          const Icon(Icons.add), () {
                        pushHeroDialog(const CategoryFormDialog());
                        return false;
                      }))
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget categoryWidget(int index) {
    Category category = widget.categories[index - 1];
    return buildItem(
        index,
        category.name,
        CachedNetworkImage(
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          placeholderFadeInDuration: Duration.zero,
          placeholder: (context, url) {
            return const SizedBox(
              width: 30,
              height: 30,
            );
          },
          imageUrl: publicPath(category.icon),
          errorWidget: (context, url, error) {
            return const Center(
              child: Icon(Icons.error),
            );
          },
          width: 30,
        ), () {
      widget.onSelect(category);
      return true;
    });
  }

  Widget buildItem(index, text, icon, bool Function() onSelect) {
    bool isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Material(
        elevation: isSelected ? 5 : 0,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() {
              if (onSelect()) selectedIndex = index;
            });
          },
          child: Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    width: 2,
                    color: isSelected
                        ? _settings.primaryColor
                        : Colors.transparent)),
            child: Column(children: [
              icon,
              const SizedBox(
                height: 10,
              ),
              Text(
                text,
                style: isSelected
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : null,
              )
            ]),
          ),
        ),
      ),
    );
  }
}
