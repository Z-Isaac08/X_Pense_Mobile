import 'package:expense_tracker/components/my_button.dart';
import 'package:expense_tracker/components/my_calendar.dart';
import 'package:expense_tracker/db/database_helper.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:flutter/material.dart';
import '../components/my_dropdown.dart';
import '../components/my_textfield.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});

  @override
  State<ExpenseForm> createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<ExpenseForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  DateTime today = DateTime.now();
  String value = "None";

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  void onDaySelected(DateTime day, DateTime focus) {
    setState(() {
      today = day;
    });
  }

  void onChanged(newValue) {
    setState(() {
      value = newValue!;
    });
  }

  void saveExpense() async {
    if (nameController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty ||
        value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs.",
            style: TextStyle(fontFamily: "Poppins"),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final double? amount = double.tryParse(amountController.text);
      if (amount == null || amount <= 0) {
        throw "Veuillez entrer un montant valide.";
      }

      final int? categoryId = await _databaseHelper.getCategoryIdByName(value);

      if (categoryId == null) {
        throw "Catégorie invalide, veuillez réessayer.";
      }

      Expense newExpense = Expense(
        note: nameController.text.trim(),
        amount: amount,
        date: today,
        categoryId: categoryId, // Utilise l'ID récupéré
      );

      await _databaseHelper.insertExpense(newExpense);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Dépense ajoutée avec succès !",
            style: TextStyle(fontFamily: "Poppins"),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Réinitialiser les champs
      nameController.clear();
      amountController.clear();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur : $e",
            style: const TextStyle(fontFamily: "Poppins"),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }


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
            "Nouvelle dépense",
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: screenWidth * 0.05,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.03,
            ),

            /*FORM*/
            // NOM
            MyTextField(
              hintText: "Note",
              controller: nameController,
              isPhone: false,
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),

            // AMOUNT
            MyTextField(
              hintText: "Montant",
              controller: amountController,
              isPhone: true,
            ),
            SizedBox(
              height: screenHeight * 0.03,
            ),

            // CATEGORY
            DropCategory(
              valueChoose: value,
              onChanged: onChanged,
            ),

            Calendar(
              today: today,
              onDaySelected: onDaySelected,
            ),

            // CONFIRM BUTTON
            MyButton(text: 'Enregistrer', onTap: saveExpense)
          ],
        ),
      ),
    );
  }
}