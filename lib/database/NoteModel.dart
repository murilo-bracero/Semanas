import 'dart:convert';

//Resgata um Objeto Semanas em um Json
Notes notesFromJson(String str){
  final jsonData = json.decode(str);
  return Notes.fromJson(jsonData);
}

//Coloca um objeto Semanas em um Json
String notesToJson(Notes data){
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Notes{
  String day;
  String weekday;
  String title;
  String note;

  Notes({this.day,this.weekday,this.title, this.note});

  //retorna os dados de um objeto em forma de Json/Map
  factory Notes.fromJson(Map<String, dynamic> json) => new Notes(
    day: json['day'],
    weekday: json['weekday'],
    title: json['title'],
    note: json['note']
  );

  Map<String, dynamic> toJson() =>{
    "day":day,
    "weekday":weekday,
    "title":title,
    "note":note
  };

}