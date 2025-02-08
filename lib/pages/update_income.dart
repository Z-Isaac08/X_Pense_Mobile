import 'package:expense_tracker/components/my_button.dart';
import 'package:expense_tracker/db/database_helper.dart';
import 'package:expense_tracker/models/income_model.dart';
import 'package:expense_tracker/utils/utils.dart';
import 'package:flutter/material.dart';
import '../components/my_textfield.dart';

class UpdateIncomeForm extends StatefulWidget {
  final Income income;

  const UpdateIncomeForm({super.key, required this.income});

  @override
  State<UpdateIncomeForm> createState() => _UpdateIncomeFormState();
}

class _UpdateIncomeFormState extends State<UpdateIncomeForm> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController dateController;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.income.source);
    amountController =
        TextEditingController(text: widget.income.amount.toString());
    dateController =
        TextEditingController(text: formatDate(widget.income.date));
  }

  void updateIncome() async {
    if (nameController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty) {
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

      Income updatedIncome = Income(
        id: widget.income.id,
        source: nameController.text.trim(),
        amount: amount,
        date: convertStringToDate(dateController.text.trim()),
      );

      await _databaseHelper.updateIncome(updatedIncome);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Revenu mis à jour avec succès !",
            style: TextStyle(fontFamily: "Poppins"),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

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
            "Modifier un revenu",
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
            SizedBox(height: screenHeight * 0.03),
            MyTextField(
              hintText: "Note",
              controller: nameController,
              isPhone: false,
            ),
            SizedBox(height: screenHeight * 0.03),
            MyTextField(
              hintText: "Montant",
              controller: amountController,
              isPhone: true,
            ),
            SizedBox(height: screenHeight * 0.03),
            DateField(
              controller: dateController,
            ),
            SizedBox(height: screenHeight * 0.03),
            MyButton(text: 'Mettre à jour', onTap: updateIncome)
          ],
        ),
      ),
    );
  }
}
