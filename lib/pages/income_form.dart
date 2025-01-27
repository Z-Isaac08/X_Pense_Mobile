import 'package:expense_tracker/components/my_button.dart';
import 'package:expense_tracker/db/database_helper.dart';
import 'package:expense_tracker/models/income_model.dart';
import 'package:expense_tracker/utils/utils.dart';
import 'package:flutter/material.dart';
import '../components/my_dropdown.dart';
import '../components/my_textfield.dart';

class IncomeForm extends StatefulWidget {
  const IncomeForm({super.key});

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  TextEditingController sourceController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  void saveIncome() async {
    if (sourceController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty ) {
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

      Income newIncome = Income(
        source: sourceController.text.trim(),
        amount: amount,
        date: convertStringToDate(dateController.text.trim()), // Utilise l'ID récupéré
      );

      await _databaseHelper.insertIncome(newIncome);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Revenu ajouté avec succès !",
            style: TextStyle(fontFamily: "Poppins"),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Réinitialiser les champs
      sourceController.clear();
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

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.03,
          ),

          /*FORM*/
          // NOM
          MyTextField(
            hintText: "Source",
            controller: sourceController,
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

          DateField(
            controller: dateController,
            onDateSelected: (selectedDate) {
              print("Date sélectionnée: $selectedDate");
              // Effectuez des actions avec la date sélectionnée
            },
          ),
          SizedBox(
            height: screenHeight * 0.03,
          ),

          // CONFIRM BUTTON
          MyButton(text: 'Enregistrer', onTap: saveIncome)
        ],
      ),
    );
  }
}