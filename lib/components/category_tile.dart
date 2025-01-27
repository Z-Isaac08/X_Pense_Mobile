import 'package:expense_tracker/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../pages/category_details.dart';

class CategoryTile extends StatelessWidget {
  final Category category;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDelPressed;

  const CategoryTile({
    super.key,
    required this.category,
    required this.onDelPressed,
    required this.onEditPressed
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: onEditPressed,
              backgroundColor: Colors.grey.shade700,
              icon: Icons.mode_edit_rounded,
            ),
            SlidableAction(
              onPressed: onDelPressed,
              backgroundColor: Colors.red,
              icon: Icons.delete,
            ),
          ],
        ),
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
      ),
    );
  }
}
