import 'package:expense_tracker/components/tab_bar.dart';
import 'package:expense_tracker/pages/expense_page.dart';
import 'package:expense_tracker/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'category_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {

    //getting heigth and width
    final double screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              title: Text(
                "X - P E N S E S",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: screenWidth * 0.05,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600),
              ),
              leading: IconButton(
                  onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
                  icon: Provider.of<ThemeProvider>(context, listen: false).icon()
              )
          ),
          body: const Column(
            children: [
              MyTabBar(),
              Expanded(child: TabBarView(children: [ExpensePage(), CategoryPage()]))
            ],
          ),
        )
    );
  }
}