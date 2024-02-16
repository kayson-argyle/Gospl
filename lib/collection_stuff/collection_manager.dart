import 'package:flutter/material.dart';
import 'package:gospl/collection_stuff/collaborative_collection.dart';
import 'package:gospl/collection_stuff/collection_selection_window.dart';
import 'package:gospl/collection_stuff/generic_collection.dart';
import 'package:gospl/collection_stuff/user_collection.dart';
import 'package:gospl/main.dart';
import 'package:gospl/models/user.dart';
import 'package:gospl/reader.dart';
import 'package:gospl/shared/loading.dart';
import 'package:isar/isar.dart';

class CollectionManager extends StatefulWidget {
  const CollectionManager({super.key, required this.currentUser});

  final AppUser currentUser;

  @override
  State<CollectionManager> createState() => CollectionManagerState();
}

class CollectionManagerState extends State<CollectionManager> {
  late GenericCollection currentCollection;
  late Reader currentReader;
  int readerCounter = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    //initialize persistence
    if (preferences.get('currentCollectionType') == null || preferences.get('currentCollectionType') == "") {
      currentCollection = isar.userCollections.filter().idIsNotNull().findFirstSync()!;
      currentReader = Reader(
        currentCollection: currentCollection,
        openCollectionsWindow: openCollectionsWindow,
        currentlyLoggedInUser: widget.currentUser,
        collectionManager: this,
      );
      preferences.setInt('currentPersonalCollection', currentCollection.id!);
      preferences.setString('currentCollectionType', 'personal');
    } else {
      if (preferences.getString('currentCollectionType') == 'personal') {
        loadPersonalCollection();
      } else {
        setState(() {
          loading = true;
        });
        loadCollaborativeCollection();
      }
    }
  }

  void loadPersonalCollection() {
    currentCollection = isar.userCollections.getSync(preferences.getInt('currentPersonalCollection')!)!;
        currentReader = Reader(
          currentCollection: currentCollection,
          openCollectionsWindow: openCollectionsWindow,
          currentlyLoggedInUser: widget.currentUser,
          collectionManager: this,
        );
  }

  void loadCollaborativeCollection() async {
    await firestore.doc(preferences.getString('currentCollaborativeCollection')!).get().then((value) {
      Map data = value.data() as Map;
      String owner = data['members'].keys.firstWhere((k) => data['members'][k]['role'] == 'owner');
      currentCollection = CollaborativeCollection(name: data['name'], owner: owner, firestoreDocumentId: preferences.getString('currentCollaborativeCollection')!);

      currentReader = Reader(
        currentCollection: currentCollection,
        openCollectionsWindow: openCollectionsWindow,
        currentlyLoggedInUser: widget.currentUser,
        collectionManager: this,
      );
      setState(() {
        loading = false;
      });
    }, onError: (e) {
      setState(() {
        loading = false;
      });
      loadPersonalCollection();
    });
  }

  void openCollectionsWindow({bool showBackArrow = true}) async {
    GenericCollection? newCollection = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CollectionSelectionWindow(currentUser: widget.currentUser, showBackArrow: showBackArrow)),
    );
    if (newCollection != null) {
      currentCollection = newCollection;
      if (currentCollection.isCollaborative) {
        preferences.setString('currentCollectionType', 'collaborative');
        preferences.setString('currentCollaborativeCollection', (currentCollection as CollaborativeCollection).firestoreDocumentId);
      } else {
        preferences.setString('currentCollectionType', 'personal');
        preferences.setInt('currentPersonalCollection', currentCollection.id!);
      }
      setState(() {
        currentReader = Reader(
            key: Key(readerCounter.toString()),
            currentCollection: currentCollection,
            openCollectionsWindow: openCollectionsWindow,
            currentlyLoggedInUser: widget.currentUser,
            collectionManager: this);
      });
      readerCounter++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading(text: "Loading collaborative collection from server...",) : currentReader;
  }
}
