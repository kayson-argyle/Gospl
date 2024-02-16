import 'package:flutter/widgets.dart';
import 'package:gospl/collection_stuff/collection_manager.dart';
import 'package:gospl/models/user.dart';
import 'package:gospl/screens/authenticate/authenticate.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<AppUser?>(context);
    //return home or authenticate
    if (user == null) {
      return const Authenticate();
    } else {
      return CollectionManager(currentUser: user,);
    }
  }
}