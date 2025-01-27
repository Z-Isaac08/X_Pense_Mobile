import 'package:expense_tracker/components/expense_tile.dart';
import 'package:expense_tracker/components/my_textfield.dart';
import 'package:flutter/material.dart';
import '../components/transaction_model.dart';
import '../models/category_model.dart';
import '../models/income_model.dart';
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
  List<FinancialItem> _financialItems = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    List<Expense> expenses = await _databaseHelper.getExpenses();
    List<Income> incomes = await _databaseHelper.getIncomes();
    List<Category> categories = await _databaseHelper.getCategories();

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
          "Voulez-vous supprimez cette transaction ?",
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

  void _filterTransactions(String query) async {
    if (query.isEmpty) {
      _loadItems();
      return;
    }

    List<Expense> filteredExpenses = await _databaseHelper.searchExpense(query);
    List<Income> filteredIncomes = await _databaseHelper.searchIncome(query);

    List<FinancialItem> filteredTransactions = [];

    for (var expense in filteredExpenses) {
      filteredTransactions.add(FinancialItem(expense: expense));
    }

    for (var income in filteredIncomes) {
      filteredTransactions.add(FinancialItem(income: income));
    }

    // Trier les transactions par date (du plus récent au plus ancien)
    filteredTransactions.sort((a, b) {
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
      _financialItems = filteredTransactions;
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
                _filterTransactions(value);
              }),

          SizedBox(
            height: screenHeight * 0.007,
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
                    "Aucune dépense trouvée",
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
