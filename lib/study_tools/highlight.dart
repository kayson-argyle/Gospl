import 'package:isar/isar.dart';

part 'highlight.g.dart';

@Collection()
class Highlight {
  Id? id;

  late int start;
  late int end;
  late int color;
  late String location; // format: 'Work_Book_Chapter'
  late int collectionId;
  late bool isCollaborative;
  late DateTime timeCreated;
  String firestoreId;
  String firestoreScriptureCollectionDocumentId;
  String note;
  String type; //TODO: Add different types of highlights, currently block is default but adding underline, vertical, bracket, square quote, etc
  String owner;

  Map<String, dynamic> toMap() {
    return {
      'start': start,
      'end': end,
      'color': color,
      'location': location,
      'note': note,
      'type': type,
      'owner': owner,
      'timeCreated': timeCreated,
    };
  }

  Highlight({
    required this.start,
    required this.end,
    required this.color,
    required this.location,
    required this.collectionId,
    required this.isCollaborative,
    required this.timeCreated,
    this.note = '',
    this.type = 'block',
    required this.owner,
    this.firestoreId = '',
    this.firestoreScriptureCollectionDocumentId = '',
  });
}
