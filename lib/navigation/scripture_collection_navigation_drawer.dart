import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gospl/book_data/book_data.dart';
import 'package:gospl/collection_stuff/collaborative_collection.dart';
import 'package:gospl/collection_stuff/collection_manager.dart';
import 'package:gospl/collection_stuff/generic_collection.dart';
import 'package:gospl/collection_stuff/invite_collaborators_dialog.dart';
import 'package:gospl/collection_stuff/user_collection.dart';
import 'package:gospl/main.dart';
import 'package:gospl/models/user.dart';
import 'package:gospl/navigation/navigation_drawer_book_item.dart';
import 'package:gospl/random_stuff/faux_upper_case_text.dart';
import 'package:gospl/screens/about_the_developer.dart';
import 'package:gospl/screens/settings_screen.dart';
import 'package:gospl/shared/loading.dart';
import 'package:gospl/study_tools/highlight.dart';
import 'package:isar/isar.dart';

class ScriptureCollectionNavigationDrawer extends StatelessWidget {
  const ScriptureCollectionNavigationDrawer({
    super.key,
    required this.selectBook,
    required this.openCollectionsWindow,
    required this.currentCollection,
    required this.currentlyLoggedInUser,
    required this.collectionManager,
  });

  final Function selectBook;
  final Function openCollectionsWindow;
  final GenericCollection currentCollection;
  final AppUser currentlyLoggedInUser;
  final CollectionManagerState collectionManager;

  void openCatalog(context) {
    showDialog(context: context, builder: (context) {
        return  Dialog (
          child: Container(
            padding: const EdgeInsets.all(20),
            child: const Text('This is the future home of the browse more screen! Here we plan to give users like you access to awesome content including password protected Patriarichal Blessing uploads (so you can study your blessing on your own just like the scriptures in this app), other editions of the Bible and Book of Mormon (For example, the 1830 edition of the Book of Mormon and the full-text Joseph Smith Translation of the Bible), and open-source works like Jesus the Christ by James Talmage. Your continued support for our project will make features like this possible in an update we have planned soon!')),
        );
      });
  }

  List<NavigationDrawerBookItem> buildNavigationDrawerBookItems(context) {
    String collectionId;
    if (preferences.getString('currentCollectionType') == 'personal') {
      collectionId = "${currentCollection.id}";
    } else {
      collectionId = preferences.getString('currentCollaborativeCollection')!;
    }
    List<NavigationDrawerBookItem> items = [];
    //add all the books
    for (String book in allBooksInLibraryNames) {
      items.add(NavigationDrawerBookItem(
        text: book,
        icon: Icons.menu_book,
        function: selectBook,
        collectionId: collectionId,
      ));
    }
    //add browse more
    items.add(NavigationDrawerBookItem(
      text: 'Browse More...',
      icon: Icons.add,
      function: (_, nullValue) {
        openCatalog(context);
      },
      collectionId: collectionId,
    ));
    if (currentCollection.runtimeType == CollaborativeCollection) {
      
    }

    print("owner: ${(currentCollection as CollaborativeCollection).owner}, user: ${isar.appUsers.getSync(0)!.uid}");

    if (!currentCollection.isCollaborative) {
      log('not collaborative');
      items.add(NavigationDrawerBookItem(
        text: 'Collection Options',
        icon: Icons.settings,
        function: (_, nullValue) {
          openSettings(context);
        },
        collectionId: collectionId,
      ));
    } else if ((currentCollection as CollaborativeCollection).owner == isar.appUsers.getSync(0)!.uid) {
      items.add(NavigationDrawerBookItem(
        text: 'Collection Options',
        icon: Icons.settings,
        function: (_, nullValue) {
          openSettings(context);
        },
        collectionId: collectionId,
      ));
    }

    if (currentCollection.isCollaborative) {
      items.add(NavigationDrawerBookItem(
          text: 'Collaborators',
          icon: Icons.people,
          function: (_, nullValue) {
            openCollaborators(context);
          },
          collectionId: collectionId,
          ));
    }
    return items;
  }

  void openCollaborators(context) async {
    DocumentSnapshot snapshot = await firestore.doc((currentCollection as CollaborativeCollection).firestoreDocumentId).get();
    Map data = snapshot.data() as Map;
    List<String> uids = data['members'].keys.toList();
    bool isOwner = (currentCollection as CollaborativeCollection).owner == currentlyLoggedInUser.uid;
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const FauxUpperCaseText(
                    text: 'Collaborators',
                    fontSize: 25,
                    style: TextStyle(color: Colors.black),
                  ),
                  ...[
                    for (String uid in uids)
                      CollaboratorListItem(
                          uid: uid, name: data['members'][uid]['name'], role: data['members'][uid]['role'], currentCollection: currentCollection, isOwner: isOwner),
                  ],
                ],
              ),
            ),
          );
        });
  }

  void openSettings(context) {
    showDialog(
        context: context,
        builder: (context) {
          return CollectionSettingsDialog(currentCollection: currentCollection, collectionManager: collectionManager);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 350,
      child: Container(
          alignment: Alignment.center,
          // decoration: const BoxDecoration(
          //   gradient: LinearGradient(
          //       colors: [Color(0xff000418), Color(0xff013770), Color(0xff4dfdff), Color(0xff013770), Color(0xff000418)],
          //       begin: Alignment.bottomLeft,
          //       end: Alignment.topRight,
          //       stops: [0.3, 0.47, 0.5, 0.53, 0.7],
          //       transform: GradientRotation(0.7)),
          // ),
          child: Scaffold(
            appBar: AppBar(
                toolbarHeight: 120,
                backgroundColor: const Color.fromARGB(255, 3, 73, 130),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      width: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: const Color.fromARGB(255, 2, 55, 99),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            currentCollection.name,
                            style: GoogleFonts.tinos(color: Colors.white, fontSize: 25),
                            overflow: TextOverflow.ellipsis,
                          ),
                          currentCollection.isCollaborative ? const Icon(Icons.people) : Container()
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 4,
                          child: ElevatedButton(
                            onPressed: () {
                              openCollectionsWindow();
                            },
                            style: const ButtonStyle(
                              elevation: MaterialStatePropertyAll(10),
                              padding: MaterialStatePropertyAll(EdgeInsets.all(8)),
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  'ALL \nCOLLECTIONS',
                                  style: TextStyle(color: Colors.black, fontSize: 10),
                                ),
                                Icon(
                                  Icons.collections_bookmark,
                                  shadows: [
                                    Shadow(
                                      color: const Color.fromARGB(255, 49, 0, 86).withAlpha(100),
                                      blurRadius: 6,
                                      offset: const Offset(-2, 2),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          flex: 5,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return InviteCollaboratorsDialog(
                                      currentCollection: currentCollection,
                                      currentlyLoggedInUser: currentlyLoggedInUser,
                                    );
                                  });
                            },
                            style: const ButtonStyle(
                              elevation: MaterialStatePropertyAll(10),
                              padding: MaterialStatePropertyAll(EdgeInsets.all(8)),
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  'INVITE \nCOLLABORATORS',
                                  style: TextStyle(color: Colors.black, fontSize: 10),
                                ),
                                Icon(
                                  Icons.add_moderator_rounded,
                                  shadows: [
                                    Shadow(
                                      color: const Color.fromARGB(255, 49, 0, 86).withAlpha(100),
                                      blurRadius: 6,
                                      offset: const Offset(-2, 2),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(5, 5, 10, 0),
                    child: Column(
                      children: buildNavigationDrawerBookItems(context),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AboutTheDeveloper()),
                            );
                          },
                          icon: const Icon(
                            Icons.info,
                            size: 30,
                          )),
                      IconButton(
                          onPressed: () {
                            //open settings
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                          icon: const Icon(
                            Icons.settings,
                            size: 30,
                          ))
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }
}

class CollectionSettingsDialog extends StatelessWidget {
  const CollectionSettingsDialog({
    super.key,
    required this.currentCollection,
    required this.collectionManager,
  });

  final GenericCollection currentCollection;
  final CollectionManagerState collectionManager;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Delete collection? This cannot be undone!'),
          ElevatedButton(
            style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red)),
            onPressed: () {
              showDialog(context: context, builder: (context) => AreYouSureDialog(currentCollection: currentCollection, collectionManager: collectionManager));
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          )
        ]),
      ),
    );
  }
}

class AreYouSureDialog extends StatefulWidget {
  const AreYouSureDialog({
    super.key,
    required this.currentCollection,
    required this.collectionManager,
  });

  final GenericCollection currentCollection;
  final CollectionManagerState collectionManager;

  @override
  State<AreYouSureDialog> createState() => _AreYouSureDialogState();
}

class _AreYouSureDialogState extends State<AreYouSureDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Are you sure?'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const Dialog(
                          clipBehavior: Clip.hardEdge,
                          child: Loading(
                            backgroundColor: Colors.red,
                            text: 'Deleting',
                          ),
                        );
                      });
                  if (widget.currentCollection.isCollaborative) {
                    //firebase delete
                    DocumentSnapshot snapshot = await firestore.doc((widget.currentCollection as CollaborativeCollection).firestoreDocumentId).get();
                    Map data = snapshot.data() as Map;
                    Map members = data['members'];
                    members.forEach((key, value) async {
                      await firestoreUsers
                          .doc('/$key/collaborative_scripture_collections/$key')
                          .update({(widget.currentCollection as CollaborativeCollection).firestoreDocumentId: 'delete'});
                    });
                    await firestore.doc((widget.currentCollection as CollaborativeCollection).firestoreDocumentId).delete();
                    preferences.setString('currentCollectionType', 'personal');
                  } else {
                    //isar delete
                    isar.writeTxn(() async {
                      await isar.userCollections.delete((widget.currentCollection as UserCollection).id!);
                      await isar.highlights.filter().collectionIdEqualTo((widget.currentCollection as UserCollection).id!).deleteAll();
                    });
                  }
                  Future.delayed(const Duration(seconds: 4)).then((value) {
                    setState(() {
                      int count = 0;
                      Navigator.of(context).popUntil((_) => count++ >= 3);
                      widget.collectionManager.openCollectionsWindow(showBackArrow: false);
                    });
                  });
                },
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red)),
                child: const Text('Yes', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.green)),
                child: const Text('No', style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CollaboratorListItem extends StatefulWidget {
  const CollaboratorListItem({super.key, required this.uid, required this.name, required this.role, required this.currentCollection, required this.isOwner});

  final String uid;
  final String name;
  final String role;
  final GenericCollection currentCollection;
  final bool isOwner;

  @override
  State<CollaboratorListItem> createState() => _CollaboratorListItemState();
}

class _CollaboratorListItemState extends State<CollaboratorListItem> {
  bool deleted = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.person),
                Text(widget.name),
              ],
            ),
            widget.isOwner
                ? (widget.role == 'owner'
                    ? const Row(
                        children: [
                          Text('Owner '),
                          Icon(Icons.shield),
                        ],
                      )
                    : !deleted
                        ? (PopupMenuButton(
                            icon: const Icon(Icons.more_horiz),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: TextButton(
                                  child: const Text('Remove collaborator'),
                                  onPressed: () {
                                    log("document id: ${(widget.currentCollection as CollaborativeCollection).firestoreDocumentId} user to delete id: ${widget.uid}");
                                    firestore
                                        .doc((widget.currentCollection as CollaborativeCollection).firestoreDocumentId)
                                        .update({'members.${widget.uid}': FieldValue.delete()}).then((value) {
                                      setState(() {
                                        deleted = true;
                                      });
                                    }, onError: (e) {
                                      log('error');
                                    });
                                  },
                                ),
                              ),
                            ],
                          ))
                        : const Text(
                            'Deleted',
                            style: TextStyle(color: Colors.red),
                          ))
                : Icon(widget.role == 'owner' ? Icons.shield : Icons.person)
          ],
        ),
      ),
    );
  }
}
