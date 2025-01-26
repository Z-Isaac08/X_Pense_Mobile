class Expense {
  int? id;
  String note;
  double amount;
  DateTime date;
  int categoryId;

  Expense({
    this.id,
    required this.note,
    required this.amount,
    required this.date,
    required this.categoryId,
  });

  // Convertir une dépense en Map pour l'enregistrement en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note': note,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
    };
  }

  // Créer une dépense à partir d'une Map SQLite
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      note: map['note'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      categoryId: map['categoryId'],
    );
  }
}