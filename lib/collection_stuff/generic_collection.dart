// a private collection of works

abstract class GenericCollection {

  GenericCollection({required this.name});

  final int? id = 0;
  String name;
  bool archived = false;
  bool isCollaborative = false;
  List<String> works = [
    'Old Testament',
    'New Testament',
    'Book of Mormon',
    'Doctrine and Covenants',
    'Pearl of Great Price',
  ];

  void addWork(String work) {}
}
