class Note {
  DateTime day;
  String title;
  String note;

  Note(this.day, this.title, this.note);

  //retorna os dados de um objeto em forma de Json/Map
  factory Note.fromJson(Map<String, dynamic> json) =>
      Note(DateTime.parse(json['day']), json['title'], json['note']);

  Map<String, dynamic> toJson() =>
      {"day": day.toIso8601String(), "title": title, "note": note};

  String get weekday {
    var weekdays = [
      "segunda-feira",
      "terça-feira",
      "quarta-feira",
      "quinta-feira",
      "sexta-feira",
      "sábado",
      "domingo"
    ];
    return weekdays[this.day.weekday - 1];
  }
}
