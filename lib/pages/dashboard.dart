import 'package:flutter/material.dart';
import 'package:food_delivery_app/models/food.dart';
import 'package:food_delivery_app/models/restaurant.dart';
import 'package:food_delivery_app/pages/food_page.dart';
import 'package:food_delivery_app/user/user_provider.dart';
import 'package:food_delivery_app/utils/my_current_location.dart';
import 'package:food_delivery_app/utils/my_description_box.dart';
import 'package:food_delivery_app/utils/my_food_tile.dart';
import 'package:food_delivery_app/utils/my_silver_app_bar.dart';
import 'package:food_delivery_app/utils/my_tab_bar.dart';
import 'package:food_delivery_app/utils/mydrawer.dart';
import 'package:provider/provider.dart';

class HomeDash extends StatefulWidget {
  const HomeDash({super.key});

  @override
  State<HomeDash> createState() => _HomeDashState();
}

class _HomeDashState extends State<HomeDash>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? userName;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: FoodCategory.values.length, vsync: this);

    // Fetch user data from UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchUserData(); // Call to fetch user data
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Food> _filterMenuByCategory(FoodCategory category, List<Food> fullMenu) {
    return fullMenu.where((food) => food.category == category).toList();
  }

  List<Widget> getFoodInThisCategory(List<Food> fullMenu) {
    return FoodCategory.values.map((category) {
      List<Food> categoryMenu = _filterMenuByCategory(category, fullMenu);
      return ListView.builder(
          itemCount: categoryMenu.length,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final food = categoryMenu[index];
            return MyFoodTile(
              food: food,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodPage(
                      food: food,
                    ),
                  ),
                );
              },
            );
          });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const Mydrawer(),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            Consumer<UserProvider>(builder: (context, UserProvider, child) {
              return MySilverAppBar(
                title: MyTabBar(tabController: _tabController),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Divider(
                      indent: 25,
                      endIndent: 25,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child:
                          MyCurrentLocation(), // This should show the current location
                    ),
                    const MyDescriptionBox(),
                  ],
                ),
              );
            })
          ],
          body: Consumer<Restaurant>(
            builder: (context, restaurant, child) => TabBarView(
              controller: _tabController,
              children: [...getFoodInThisCategory(restaurant.menu)],
            ),
          ),
        ));
  }
}
