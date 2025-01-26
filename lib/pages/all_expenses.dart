import 'package:expense_tracker/components/expense_tile.dart';
import 'package:expense_tracker/components/my_textfield.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../utils/utils.dart';
import '../db/database_helper.dart';
import '../models/expense_model.dart';

class AllExpenses extends StatefulWidget {
  const AllExpenses({super.key});

  @override
  State<AllExpenses> createState() => _AllExpensesState();
}

class _AllExpensesState extends State<AllExpenses> {
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

  void _filterExpenses(String query) async {
    if (query.isEmpty) {
      _loadItems(); //
      return;
    }

    List<Expense> filteredExpenses = await _databaseHelper.searchExpense(query);

    setState(() {
      _expenses = filteredExpenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    //getting heigth and width
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            "Historique",
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
          SizedBox(
            height: screenHeight * 0.02,
          ),

          // CHAMP DE RECHERCHE
          SearchField(
              controller: searchController,
              onChanged: (value) {
                _filterExpenses(value);
              }),

          SizedBox(
            height: screenHeight * 0.007,
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
                  itemCount: expenses.length,
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
                  separatorBuilder: (context, index) => SizedBox(height: screenHeight * 0.007),
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
          // Handle the error appropriately (e.g., show a snackbar)
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
