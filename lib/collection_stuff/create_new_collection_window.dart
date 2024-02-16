import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gospl/collection_stuff/collaborative_collection.dart';
import 'package:gospl/collection_stuff/generic_collection.dart';
import 'package:gospl/collection_stuff/user_collection.dart';
import 'package:gospl/main.dart';
import 'package:gospl/models/user.dart';

class CreateNewCollectionWindow extends StatefulWidget {
  const CreateNewCollectionWindow({super.key, required this.currentUser, required this.collaborative});

  final AppUser currentUser;
  final bool collaborative;

  @override
  State<CreateNewCollectionWindow> createState() => _CreateNewCollectionWindowState();
}

class _CreateNewCollectionWindowState extends State<CreateNewCollectionWindow> {
  late bool togglePosition = widget.collaborative;
  TextStyle style = const TextStyle(color: Color.fromARGB(210, 228, 228, 228));
  TextEditingController controller = TextEditingController();
  TextEditingController joinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CREATE NEW COLLECTION',
          style: style,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        hintText: 'New collection name:',
                        hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Collaborative',
                            style: style,
                          ),
                          SizedBox.square(
                            dimension: 20,
                            child: IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const Dialog(
                                          child: Padding(
                                            padding: EdgeInsets.all(20.0),
                                            child: Text(
                                                'Collaborative collections are the most powerful feature of Gospl. A collaborative collection is a shared copy of the scriptures (a collection of the whole standard works) that can have multiple collaborators, ie people whose notes and highlight will appear for everyone else in the collection to see- but don\'t worry! Your personal collections will still be kept private and secure.'),
                                          ),
                                        );
                                      });
                                },
                                icon: const Icon(Icons.help),
                                iconSize: 20,
                                visualDensity: VisualDensity.compact),
                          )
                        ],
                      ),
                      Switch.adaptive(
                          value: togglePosition,
                          onChanged: (value) {
                            setState(() {
                              togglePosition = value;
                            });
                          }),
                    ],
                  )
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                GenericCollection collection =
                    togglePosition ? CollaborativeCollection(name: controller.text, owner: widget.currentUser.uid) : UserCollection(name: controller.text);
                if (!togglePosition) {
                  //save user collection to isar
                  await isar.writeTxn(() async {
                    await isar.userCollections.put(collection as UserCollection);
                  });
                } else {
                  //create user collection in firestore
                  AppUser? currentUser = await isar.appUsers.get(0);
                  Map<String, dynamic> data = {
                    'archived': false,
                    'members': {
                      widget.currentUser.uid: {'role': 'owner', 'name': currentUser?.name}
                    },
                    'name': controller.text,
                    'works': collection.works,
                  };
                  DocumentReference doc = firestore.doc();
                  doc.set(data);
                  await doc.collection('join_requests').doc('requests').set({});
                  await FirebaseFirestore.instance.doc('/users/${widget.currentUser.uid}').update({'collaborative_scripture_collections.${doc.id}': 'owner'});
                  await firestoreUsers.doc('/${widget.currentUser.uid}/collaborative_scripture_collections/${widget.currentUser.uid}').update({doc.id: true});
                  (collection as CollaborativeCollection).firestoreDocumentId = doc.id;
                }
                Navigator.pop(context, collection);
              },
              child: const Text('Create'),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              "-  OR  -",
              style: style.copyWith(fontSize: 16),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              "JOIN A FRIEND'S COLLECTION",
              style: style.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(30),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: joinController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        hintText: 'Collection ID:',
                        hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                      onPressed: () async {
                        print(joinController.text);
                        if (joinController.text.isNotEmpty) {
                          AppUser? user = await isar.appUsers.get(0);
                          await firestore.doc('/${joinController.text}/join_requests/requests').update({widget.currentUser.uid: user?.name}).then((value) async {
                            await firestoreUsers.doc(widget.currentUser.uid).update({'collaborative_scripture_collections.${joinController.text}': 'editor'});
                            joinController.text = '';
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const AlertDialog.adaptive(
                                    content: Text('Request sent!'),
                                  );
                                });
                          }, onError: (e) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const AlertDialog.adaptive(
                                    content: Text('This collection does not exist, please try again'),
                                  );
                                });
                          });
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog.adaptive(
                                  content: Text('Please enter a collection id'),
                                );
                              });
                        }
                      },
                      child: const Text('Request to Join'))
                ],
              ),
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                child: Text(
                  "The owner of a collection can find their unique Collection ID by clicking 'Invite Collaborators' in the scripture selection menu, your request to join their collection will also appear there",
                  style: style,
                ))
          ],
        ),
      ),
    );
  }
}
