import 'package:expense_tracker/components/expense_tile.dart';
import 'package:expense_tracker/components/my_card.dart';
import 'package:expense_tracker/pages/expense_income_toggle.dart';
import 'package:flutter/material.dart';
import '../components/transaction_model.dart';
import '../models/category_model.dart';
import '../models/income_model.dart';
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
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<FinancialItem> _financialItems = [];
  List<Category> _categories = [];
  double totalExpense = 0.0;
  double totalIncome = 0.0;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    List<Expense> expenses = await _databaseHelper.getExpenses();
    List<Income> incomes = await _databaseHelper.getIncomes();
    List<Category> categories = await _databaseHelper.getCategories();
    totalExpense = await _databaseHelper.getTotalExpenses();
    totalIncome = await _databaseHelper.getTotalIncomes();

    List<FinancialItem> items = [];

    for (var expense in expenses) {
      items.add(FinancialItem(expense: expense));
    }

    for (var income in incomes) {
      items.add(FinancialItem(income: income));
    }

    // Trier la liste par date du plus récent au plus ancien
    items.sort((a, b) {
      DateTime dateA, dateB;
      if (a.isExpense) {
        dateA = a.expense!.date;
      } else {
        dateA = a.income!.date;
      }
      if (b.isExpense) {
        dateB = b.expense!.date;
      } else {
        dateB = b.income!.date;
      }

      return dateB.compareTo(dateA); // Trier du plus récent au plus ancien
    });

    setState(() {
      _financialItems = items;
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

  void openDeleteBox(FinancialItem item) {
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
          _deleteButton(item),
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExpenseIncomeToggle()),
          );
          _loadItems();
        },
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 32,
        ),
      ),
      body: Column(
        children: [
          MyCard(totalExpense: totalExpense, totalIncome: totalIncome),

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
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AllExpenses())),
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
            child: FutureBuilder<List<FinancialItem>>(
              future: Future.value(
                  _financialItems), // Charge les dépenses une seule fois
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator()); // Indicateur de chargement
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text(
                    "Aucune transactions trouvée",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontFamily: "Poppins",
                    ),
                  ));
                }

                final financialItems = snapshot.data!;

                return ListView.separated(
                  itemCount:
                      financialItems.length >= 7 ? 7 : financialItems.length,
                  itemBuilder: (context, index) {
                    final item = financialItems[index];
                    if (item.isExpense) {
                      return ExpenseTile(
                        isIncome: false,
                        title: item.expense!.note,
                        subtitle:
                            "${formatDate(item.expense!.date)} · ${getCategoryName(item.expense!.categoryId)}",
                        amount: intToString(item.expense!.amount),
                        onEditPressed: (context) {},
                        onDelPressed: (p0) => openDeleteBox(item),
                      );
                    } else if (item.isIncome) {
                      return ExpenseTile(
                        isIncome: true,
                        title: item.income!.source,
                        subtitle: formatDate(item.income!.date),
                        amount: intToString(item.income!.amount),
                        onEditPressed: (context) {},
                        onDelPressed: (p0) => openDeleteBox(item),
                      );
                    }
                    return null;
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

  Widget _deleteButton(FinancialItem item) {
    return TextButton(
      onPressed: () async {
        if (item.isExpense) {
          await _databaseHelper
              .deleteExpense(item.expense!.id!); // Suppression de la dépense
        } else if (item.isIncome) {
          await _databaseHelper
              .deleteIncome(item.income!.id!); // Suppression du revenu
        }
        _loadItems();
        Navigator.pop(context); // Fermer la boîte de dialogue
      },
      child: Text(
        "Supprimer",
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () => Navigator.pop(context),
      child: const Text("Retour"),
    );
  }
}
