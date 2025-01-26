class Income {
  int? id;
  String source;
  double amount;
  DateTime date;

  Income({
    this.id,
    required this.source,
    required this.amount,
    required this.date,
  });

  // Convertir une dépense en Map pour l'enregistrement en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source': source,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  // Créer une dépense à partir d'une Map SQLite
  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      source: map['source'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }
}