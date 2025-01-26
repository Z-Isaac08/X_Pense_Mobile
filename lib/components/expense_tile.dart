import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ExpenseTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDelPressed;

  const ExpenseTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.onEditPressed,
    required this.onDelPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
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
            title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600),
          ),
          trailing: Text(amount,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontFamily: "Poppins",
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w700)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}