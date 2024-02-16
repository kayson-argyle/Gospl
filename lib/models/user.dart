import 'package:isar/isar.dart';

part 'user.g.dart';

@Collection()
class AppUser {
  Id id = 0;

  final String uid;
  final String name;

  AppUser({required this.uid, required this.name});

}