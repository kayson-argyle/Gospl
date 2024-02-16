import 'package:gospl/collection_stuff/generic_collection.dart';

class CollaborativeCollection extends GenericCollection {
  CollaborativeCollection({
    required super.name,
    required this.owner,
    this.firestoreDocumentId = '',
  });

  final String owner;
  String firestoreDocumentId;

  @override
  bool get isCollaborative => true;
}
