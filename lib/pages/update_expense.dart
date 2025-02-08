import 'package:expense_tracker/components/my_button.dart';
import 'package:expense_tracker/db/database_helper.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/utils/utils.dart';
import 'package:flutter/material.dart';
import '../components/my_dropdown.dart';
import '../components/my_textfield.dart';

class UpdateExpenseForm extends StatefulWidget {
  final Expense expense;

  const UpdateExpenseForm({super.key, required this.expense});

  @override
  State<UpdateExpenseForm> createState() => _UpdateExpenseFormState();
}

class _UpdateExpenseFormState extends State<UpdateExpenseForm> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController dateController;
  late String selectedCategory;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.expense.note);
    amountController =
        TextEditingController(text: widget.expense.amount.toString());
    dateController =
        TextEditingController(text: formatDate(widget.expense.date));
    selectedCategory = "None";

    _loadCategoryName();
  }

  void _loadCategoryName() async {
    String? categoryName =
        await _databaseHelper.getCategoryNameById(widget.expense.categoryId);
    if (categoryName != null) {
      setState(() {
        selectedCategory = categoryName;
      });
    }
  }

  void onChanged(String? newValue) {
    setState(() {
      selectedCategory = newValue ?? "None";
    });
  }

  void updateExpense() async {
    if (nameController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty ||
        selectedCategory.isEmpty) {
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

      final int? categoryId =
          await _databaseHelper.getCategoryIdByName(selectedCategory);
      if (categoryId == null) {
        throw "Catégorie invalide, veuillez réessayer.";
      }

      Expense updatedExpense = Expense(
        id: widget.expense.id,
        note: nameController.text.trim(),
        amount: amount,
        date: convertStringToDate(dateController.text.trim()),
        categoryId: categoryId,
      );

      await _databaseHelper.updateExpense(updatedExpense);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Dépense mise à jour avec succès !",
            style: TextStyle(fontFamily: "Poppins"),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      if (!mounted) return;

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
            "Modifier une dépense",
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
            DropCategory(
              valueChoose: selectedCategory,
              onChanged: onChanged,
            ),
            SizedBox(height: screenHeight * 0.03),
            DateField(
              controller: dateController,
            ),
            SizedBox(height: screenHeight * 0.03),
            MyButton(text: 'Mettre à jour', onTap: updateExpense)
          ],
        ),
      ),
    );
  }
}
