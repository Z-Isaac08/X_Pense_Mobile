import '../models/expense_model.dart';
import '../models/income_model.dart';

class FinancialItem {
  final Expense? expense;
  final Income? income;

  FinancialItem({this.expense, this.income});

  // Si tu veux une méthode pour déterminer si c'est une dépense ou un revenu
  bool get isExpense => expense != null;
  bool get isIncome => income != null;
}
