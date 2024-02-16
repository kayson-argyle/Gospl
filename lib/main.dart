import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gospl/collection_stuff/user_collection.dart';
import 'package:gospl/firebase_options.dart';
import 'package:gospl/models/user.dart';
import 'package:gospl/screens/wrapper.dart';
import 'package:gospl/services/auth.dart';
import 'package:gospl/study_tools/highlight.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Isar isar;
late SharedPreferences preferences;
late CollectionReference firestore;
late CollectionReference firestoreUsers;

void main() async {
  //initialize isar
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();

  if (Isar.instanceNames.isEmpty) {
    isar = await Isar.open([HighlightSchema, UserCollectionSchema, AppUserSchema], directory: dir.path);
    if (await isar.userCollections.filter().idIsNotNull().findFirst() == null) {
      isar.writeTxn(() async {
        await isar.userCollections.put(UserCollection(name: 'My Collection'));
        
      });
    }
    if (await isar.appUsers.getSize() == 0) {
      isar.writeTxn(() async {await isar.appUsers.put(AppUser(uid: '0', name: 'blank'));});
      
    }
  }


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  firestore = FirebaseFirestore.instance.collection('collaborative_scripture_collections');
  firestoreUsers = FirebaseFirestore.instance.collection('users');


  preferences = await SharedPreferences.getInstance();
  if (preferences.getInt('mostRecentHighlightColor') == null) {
    preferences.setInt('mostRecentHighlightColor', 0xFFE5977B);

    //initialize persistence settings
  }

  precacheGoogleFonts().then((_) {
    runApp(const MainApp());
  });
}

//precache the google font to be used, otherwise there will be rendering errors
Future<void> precacheGoogleFonts() async {
  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(text: '', style: GoogleFonts.tinos()),
  );
  textPainter.layout();
  textPainter.paint(Canvas(PictureRecorder()), Offset.zero);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser?>.value(
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
      home: const Wrapper(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFF3E0D0), // Soft Beige
        scaffoldBackgroundColor: const Color(0xFF010B1C), // Soft Beige

        appBarTheme: const AppBarTheme(
          color: Colors.transparent,
          iconTheme: IconThemeData(color: Color(0xFF031526)), // Warm Gray
        ),

        primaryTextTheme: const TextTheme(titleLarge: TextStyle(color: Colors.white)),

        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color.fromARGB(255, 246, 246, 246)), // Warm Gray
          bodyLarge: TextStyle(color: Color.fromARGB(255, 231, 231, 231)), // Light Gray
          // Add other styles as needed
        ),

        // Add additional theming as needed
      ),
    ));
  }
}

