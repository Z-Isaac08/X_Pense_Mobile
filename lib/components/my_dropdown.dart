import 'package:expense_tracker/models/category_model.dart';
import 'package:flutter/material.dart';

import '../db/database_helper.dart';

class DropCategory extends StatefulWidget {
  final String valueChoose;
  final void Function(String?)? onChanged;

  const DropCategory({super.key, required this.valueChoose, required this.onChanged});

  @override
  State<DropCategory> createState() => _DropCategoryState();
}

class _DropCategoryState extends State<DropCategory> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    List<Category> categories = await _databaseHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final List<String> itemList = ['None', ..._categories.map((c) => c.name)];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Container(
        height: screenHeight * 0.07,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
              padding: EdgeInsets.all(screenWidth * 0.03),
              hint: Text(
                "Catégorie",
                style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontFamily: "Poppins"),
              ),
              elevation: 0,
              dropdownColor: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(10),
              isExpanded: true,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontFamily: "Poppins"),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              iconSize: 30,
              value: widget.valueChoose,
              onChanged: widget.onChanged,
              items: itemList.map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList()),
        ),
      ),
    );
  }
}