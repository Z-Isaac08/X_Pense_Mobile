import 'package:expense_tracker/components/expense_tile.dart';
import 'package:expense_tracker/components/my_card.dart';
import 'package:expense_tracker/pages/expense_form.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../utils/utils.dart';
import '../db/database_helper.dart';
import '../models/expense_model.dart';
import 'all_expenses.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<ExpensePage> {
  TextEditingController searchController = TextEditingController();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Expense> _expenses = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    List<Expense> expenses = await _databaseHelper.getExpenses();
    List<Category> categories = await _databaseHelper.getCategories();
    setState(() {
      _expenses = expenses;
      _categories = categories;
    });
  }

  String getCategoryName(int categoryId) {
    return _categories
        .firstWhere(
          (cat) => cat.id == categoryId,
          orElse: () => Category(id: categoryId, name: "Catégorie inconnue"),
        )
        .name;
  }

  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Voulez-vous supprimez cette dépense ?",
          style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontFamily: "Poppins",
              fontSize: 15),
        ),
        actions: [
          _cancelButton(),
          _deleteButton(expense.id!),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //getting heigth and width
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.tertiary,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ExpenseForm(
                      onLoad: _loadItems,
                    ))),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 32,
        ),
      ),
      body: Column(
        children: [
          MyCard(totalExpense: 250, totalIncome: 300),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transactions",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AllExpenses())),
                  child: Text(
                    "Tout voir",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                )
              ],
            ),
          ),

          // SEE MY EXPENSE
          Expanded(
            child: FutureBuilder<List<Expense>>(
              future:
                  Future.value(_expenses), // Charge les dépenses une seule fois
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator()); // Indicateur de chargement
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text(
                    "Aucune dépense trouvée",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontFamily: "Poppins",
                    ),
                  ));
                }

                final expenses = snapshot.data!;

                return ListView.separated(
                  itemCount: expenses.length >= 7 ? 7 : expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ExpenseTile(
                      title: expense.note,
                      subtitle:
                          "${formatDate(expense.date)} · ${getCategoryName(expense.categoryId)}",
                      amount: intToString(expense.amount),
                      onEditPressed: (context) {},
                      onDelPressed: (p0) => openDeleteBox(expense),
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _deleteButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);
        try {
          await _databaseHelper.deleteExpense(id);
          _loadItems();
        } catch (error) {
          print(error);
        }
      },
      child: const Text("Supprimer"),
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () => Navigator.pop(context),
      child: const Text("Retour"),
    );
  }
}
