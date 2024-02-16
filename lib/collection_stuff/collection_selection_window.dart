import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gospl/collection_stuff/collaborative_collection.dart';
import 'package:gospl/collection_stuff/create_new_collection_window.dart';
import 'package:gospl/collection_stuff/generic_collection.dart';
import 'package:gospl/collection_stuff/user_collection.dart';
import 'package:gospl/main.dart';
import 'package:gospl/models/user.dart';
import 'package:gospl/shared/loading.dart';
import 'package:isar/isar.dart';

class CollectionSelectionWindow extends StatefulWidget {
  const CollectionSelectionWindow({super.key, required this.currentUser, required this.showBackArrow});

  final AppUser currentUser;
  final bool showBackArrow;

  @override
  State<CollectionSelectionWindow> createState() => _CollectionSelectionWindowState();
}

class _CollectionSelectionWindowState extends State<CollectionSelectionWindow> {
  PageController controller = PageController();
  int currentPageIndex = 0;
  late List<UserCollection> userCollections;
  List<CollaborativeCollection> collaborativeCollections = [];
  bool loading = true;

  // get a list of all of the shared collections the user is in
  late List<String> sharedCollectionIds;

  @override
  void initState() {
    super.initState();
    getCollections();
  }

  void getCollections() async {
    userCollections = await isar.userCollections.filter().idIsNotNull().findAll();
    //the list of collaborative_scripture_collections exists in two places, one in the user document and the other in a subcollection document titled "collaborative_scripture_collections"
    //the subcollection is open to editing to basically anyone so that an inviter can send an invitation there, the map in the user document is open only to the user
    //this ensures that both the user and the inviter both have to concur in order for a user to be added to a collection, protecting the user from being added to any malicious collections unknowingly
    log('current user uid: ${widget.currentUser.uid}');
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.doc('/users/${widget.currentUser.uid}').get();
    DocumentSnapshot userSubCollectionSnapshot =
        await FirebaseFirestore.instance.doc('/users/${widget.currentUser.uid}/collaborative_scripture_collections/${widget.currentUser.uid}').get();
    sharedCollectionIds = (snapshot.data() as Map)['collaborative_scripture_collections'].keys.toList();
    List userSubCollectionSnapshotSharedCollectionIds = [];
    ((userSubCollectionSnapshot.data() ?? {}) as Map).forEach((key, value) {
      if (value == true) {
        userSubCollectionSnapshotSharedCollectionIds.add(key);
      } else if (value == 'delete') {
        firestoreUsers.doc('/${widget.currentUser.uid}').update({'collaborative_scripture_collections.$key': FieldValue.delete()});
        firestoreUsers.doc('/${widget.currentUser.uid}/collaborative_scripture_collections/${widget.currentUser.uid}').update({key: FieldValue.delete()});
      }
    });
    for (String id in sharedCollectionIds) {
      await firestore.doc(id).get().then((value) {
        Map data = value.data() as Map;
        if (userSubCollectionSnapshotSharedCollectionIds.contains(id)) {
          String owner = data['members'].keys.firstWhere((k) => data['members'][k]['role'] == 'owner');
          collaborativeCollections.add(CollaborativeCollection(name: data['name'], owner: owner, firestoreDocumentId: id));
        }
      }, onError: (e) {});
    }
    setState(() {
      loading = false;
    });
  }

  TextStyle style = const TextStyle(color: Color.fromARGB(210, 228, 228, 228));

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Colors.white.withAlpha(180),
              unselectedItemColor: const Color(0xff6650a4),
              backgroundColor: Colors.transparent,
              onTap: (value) {
                setState(() {
                  currentPageIndex = value;
                });
                controller.animateToPage(value, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
              currentIndex: currentPageIndex,
              items: const [
                BottomNavigationBarItem(
                  label: 'Personal',
                  icon: Icon(Icons.person),
                ),
                BottomNavigationBarItem(label: 'Collaborative', icon: Icon(Icons.people)),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                  gradient: RadialGradient(colors: [
                Color(0xff76aad5),
                Color(0xff1f64a1),
                Color.fromARGB(255, 4, 47, 94),
                Color.fromARGB(255, 1, 30, 65),
                Color.fromARGB(255, 1, 16, 37),
                Color.fromARGB(255, 0, 10, 28)
              ], center: Alignment.topCenter, radius: 1.5)),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox.square(
                            dimension: 110,
                            child: Transform.flip(
                                flipX: true,
                                child: Image.asset(
                                  'assets/leaf_decoration.png',
                                ))),
                        Transform.scale(
                          scale: 2.3,
                          origin: const Offset(0, -10),
                          child: Row(
                            children: [
                              widget.showBackArrow
                                  ? SizedBox.square(
                                      dimension: 30,
                                      child: TextButton(
                                        style: const ButtonStyle(padding: MaterialStatePropertyAll(EdgeInsets.zero)),
                                        child: const Icon(
                                          Icons.arrow_back,
                                          color: Color.fromARGB(210, 255, 255, 255),
                                          size: 12,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context, null);
                                        },
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              Text(
                                'Collections',
                                style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.grey.shade100, fontSize: 13, letterSpacing: 1.2),
                              ),
                              widget.showBackArrow
                                  ? const SizedBox.square(
                                    dimension: 17,
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                        SizedBox.square(
                            dimension: 110,
                            child: Image.asset(
                              'assets/leaf_decoration.png',
                            )),
                      ],
                    ),
                    Expanded(
                      child: PageView(
                        controller: controller,
                        onPageChanged: (page) {
                          setState(() {
                            currentPageIndex = page;
                          });
                        },
                        children: [
                          CollectionContainer(
                            collaborative: false,
                            collections: userCollections,
                            currentUser: widget.currentUser,
                            text:
                                'These are your personal copies of the scriptures. No one else can see the notes and highlights in them. To start fresh with a blank new copy of the scriptures, click the plus below and add one to your library.',
                          ),
                          CollectionContainer(
                            collaborative: true,
                            collections: collaborativeCollections,
                            currentUser: widget.currentUser,
                            text:
                                'These are your your collaborative copies of the scriptures. You and anyone else in a collaborative collection can start making notes and highlights that will be shared in real-time across the internet. To start fresh with a blank new copy of the scriptures that you can share, click the plus below and add one to your library.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class CollectionContainer extends StatelessWidget {
  const CollectionContainer({super.key, required this.collections, required this.currentUser, required this.text, required this.collaborative});
  final List<GenericCollection> collections;
  final AppUser currentUser;
  final String text;
  final bool collaborative;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.max, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade200, fontStyle: FontStyle.italic),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                children: [
                  for (GenericCollection collection in collections) CollectionButton(collection),
                  AddCollectionButton(
                    currentUser: currentUser, collaborative: collaborative,
                  ),
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }
}

class AddCollectionButton extends StatelessWidget {
  const AddCollectionButton({super.key, required this.currentUser, required this.collaborative});

  final AppUser currentUser;
  final bool collaborative;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 4, 47, 94),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(150), blurRadius: 30, spreadRadius: 1, offset: const Offset(0, 20)),
                  BoxShadow(color: Colors.black.withAlpha(150), blurRadius: 30, spreadRadius: 1, offset: const Offset(0, 20)),
                ]),
            child: ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.transparent),
                padding: MaterialStatePropertyAll(EdgeInsets.all(5)),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
              ),
              onPressed: () async {
                GenericCollection? newCollection = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateNewCollectionWindow(currentUser: currentUser, collaborative: collaborative,)));
                if (newCollection != null) {
                  Navigator.pop(context, newCollection);
                }
              },
              child: Icon(
                Icons.add,
                size: 70,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'New Collection',
            style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 255, 255, 255)),
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}

class CollectionButton extends StatelessWidget {
  const CollectionButton(
    this.collection, {
    super.key,
  });

  final GenericCollection collection;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 4, 47, 94),
                borderRadius: BorderRadius.circular(20),
                boxShadow:  [
                  BoxShadow(color: Colors.black.withAlpha(150), blurRadius: 30, spreadRadius: 1, offset: const Offset(0, 20)),
                  BoxShadow(color: Colors.black.withAlpha(150), blurRadius: 30, spreadRadius: 1, offset: const Offset(0, 20)),
                ]),
            child: ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.transparent),
                padding: MaterialStatePropertyAll(EdgeInsets.all(5)),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, collection);
              },
              child: SizedBox.square(
                dimension: 70,
                child: Icon(
                  Icons.menu_book,
                  size: 55,
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            collection.name,
            style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 255, 255, 255)),
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
