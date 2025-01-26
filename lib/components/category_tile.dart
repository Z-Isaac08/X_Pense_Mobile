import 'package:expense_tracker/models/category_model.dart';
import 'package:flutter/material.dart';

import '../pages/category_details.dart';

class CategoryTile extends StatelessWidget {
  final Category category;

  const CategoryTile({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: ListTile(
        tileColor: Theme.of(context).colorScheme.tertiary,
        title: Text(
          category.name,
          style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CategoryDetails(category: category)));
        },
      ),
    );
  }
}
