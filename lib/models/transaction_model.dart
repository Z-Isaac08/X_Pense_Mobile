import 'expense_model.dart';
import 'income_model.dart';

class FinancialItem {
  final Expense? expense;
  final Income? income;

  FinancialItem({this.expense, this.income});

  bool get isExpense => expense != null;
  bool get isIncome => income != null;
}
