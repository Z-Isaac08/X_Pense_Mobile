import 'package:expense_tracker/pages/expense_form.dart';
import 'package:expense_tracker/pages/income_form.dart';
import 'package:flutter/material.dart';

class ExpenseIncomeToggle extends StatefulWidget {
  const ExpenseIncomeToggle({super.key});

  @override
  State<ExpenseIncomeToggle> createState() => _ExpenseIncomeToggleState();
}

class _ExpenseIncomeToggleState extends State<ExpenseIncomeToggle> {
  bool isExpense = true;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            "Nouvelle transaction",
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: screenWidth * 0.05,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded))),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          ToggleButtons(
            borderRadius: BorderRadius.circular(8),
            selectedColor: Theme.of(context).colorScheme.tertiary,
            fillColor: Theme.of(context).colorScheme.inversePrimary,
            color: Theme.of(context).colorScheme.primary,
            isSelected: [isExpense, !isExpense],
            onPressed: (index) {
              setState(() {
                isExpense = (index ==
                    0); // bascule entre true (Expense) et false (Income)
              });
            },
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                  child: Text(
                    "Dépense",
                    style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600),
                  )),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                  child: Text(
                    "Revenu",
                    style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600),
                  )),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // Afficher soit le formulaire de dépense soit de revenu
          isExpense ? ExpenseForm() : IncomeForm(),
        ],
      ),
    );
  }
}
