// a private collection of works

import 'package:gospl/collection_stuff/generic_collection.dart';
import 'package:gospl/main.dart';
import 'package:isar/isar.dart';


part 'user_collection.g.dart';

@Collection()
class UserCollection extends GenericCollection{
  @override
  Id? id;

  UserCollection({required super.name});

  @override
  void addWork(String work) {
    works.add(work);
    isar.writeTxn(() async {
      isar.userCollections.put(this);
    });
  }
}
