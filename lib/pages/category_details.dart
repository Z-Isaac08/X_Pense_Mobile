import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/utils/utils.dart';
import 'package:flutter/material.dart';
import '../components/expense_tile.dart';
import '../db/database_helper.dart';
import '../models/expense_model.dart';

class CategoryDetails extends StatefulWidget {
  final Category category;
  const CategoryDetails({super.key, required this.category});

  @override
  State<CategoryDetails> createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Expense> _expenses = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    List<Expense> expenses =
        await _databaseHelper.getExpensesByCategory(widget.category.id!);
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
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            widget.category.name,
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
            height: screenWidth * 0.02,
          ),
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
                      isIncome: false,
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
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "$error",
                style: TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: const Text(
        "Supprimer",
        style: TextStyle(
          fontFamily: "Poppins",
        ),
      ),
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        "Retour",
        style: TextStyle(
          fontFamily: "Poppins",
        ),
      ),
    );
  }
}
