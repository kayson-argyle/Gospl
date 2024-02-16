
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gospl/collection_stuff/collaborative_collection.dart';
import 'package:gospl/collection_stuff/generic_collection.dart';
import 'package:gospl/main.dart';
import 'package:gospl/models/user.dart';
import 'package:gospl/random_stuff/faux_upper_case_text.dart';
import 'package:gospl/shared/loading.dart';

class InviteCollaboratorsDialog extends StatefulWidget {
  const InviteCollaboratorsDialog({
    super.key,
    required this.currentCollection,
    required this.currentlyLoggedInUser,
  });

  final GenericCollection currentCollection;
  final AppUser currentlyLoggedInUser;

  @override
  State<InviteCollaboratorsDialog> createState() => _InviteCollaboratorsDialogState();
}

class _InviteCollaboratorsDialogState extends State<InviteCollaboratorsDialog> {
  Future<Map> getJoinRequests() async {
    var requests = await firestore.doc((widget.currentCollection as CollaborativeCollection).firestoreDocumentId).collection('join_requests').doc('requests').get();
    Map data = requests.data() as Map;
    return data;
  }

  int keyIterator = 0;
  Key futureBuilderKey = const Key('0');

  void rebuild() {
    keyIterator++;
    setState(() {
      futureBuilderKey = Key('$keyIterator');
    });
  }

  bool linkCopied = false;


  List<Widget> populateColumn(Map data) {
    List<Widget> children = [];
    data.forEach((key, value) {
      children.add(AcceptJoinRequest(
        uid: key,
        name: value,
        currentCollection: widget.currentCollection,
        rebuild: rebuild,
      ));
    });
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 2, 45, 80),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FauxUpperCaseText(
                text: '- INVITE COLLABORATORS -',
                style: GoogleFonts.tinos(),
                fontSize: 20,
              ),
              const SizedBox(
                height: 10,
              ),
              widget.currentCollection.isCollaborative
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Collection ID: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4,),
                                SelectableText((widget.currentCollection as CollaborativeCollection).firestoreDocumentId),
                              ],
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: "Study the scriputures with me on Gospl! Paste this code into the 'Collection ID' section of your app to join my collection: \n\n${(widget.currentCollection as CollaborativeCollection).firestoreDocumentId}"));
                                  setState(() {
                                    linkCopied = true;
                                  });
                                  // copied successfully
                                },
                                child: linkCopied ? const Text('Copied!') : const Text('Copy ID'))
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        (widget.currentCollection as CollaborativeCollection).owner == widget.currentlyLoggedInUser.uid
                            ? Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: const Color.fromARGB(100, 8, 2, 56), width: 2),
                                  color: Colors.blue,
                                ),
                                child: FutureBuilder(
                                    key: futureBuilderKey,
                                    future: getJoinRequests(),
                                    initialData: null,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data!.isEmpty) {
                                          return const Text('Invite collaborators to join this collection and their requests will show up here for you to accept!');
                                        } else {
                                          return Column(
                                            children: [...populateColumn(snapshot.data!)],
                                          );
                                        }
                                      } else {
                                        return const Loading();
                                      }
                                    }),
                              )
                            : const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('The owner of the shared collection will admit new collaborators here'),
                            )
                      ],
                    )
                  : const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Create a collaborative collection to share a copy of the scriptures with friends and family!'),
                  ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AcceptJoinRequest extends StatefulWidget {
  const AcceptJoinRequest({
    super.key,
    required this.uid,
    required this.currentCollection,
    required this.rebuild,
    required this.name,
  });

  final String uid;
  final GenericCollection currentCollection;
  final Function rebuild;
  final String name;

  @override
  State<AcceptJoinRequest> createState() => _AcceptJoinRequestState();
}

class _AcceptJoinRequestState extends State<AcceptJoinRequest> {
  bool buttonClicked = false;
  final ButtonStyle buttonStyle = const ButtonStyle(padding: MaterialStatePropertyAll(EdgeInsets.all(3)), textStyle: MaterialStatePropertyAll(TextStyle(color: Colors.white38)));

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(50, 2, 30, 69),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const SizedBox(
          width: 0,
        ),
        Text(
          widget.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        !buttonClicked
            ? Row(
                children: [
                  ElevatedButton(
                    style: buttonStyle.copyWith(backgroundColor: const MaterialStatePropertyAll(Colors.green)),
                    onPressed: () {
                      firestore.doc((widget.currentCollection as CollaborativeCollection).firestoreDocumentId).update({'members.${widget.uid}': {'role' : 'editor', 'name' : widget.name}}).then((value) async {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.uid)
                            .collection('collaborative_scripture_collections')
                            .doc(widget.uid)
                            .update({(widget.currentCollection as CollaborativeCollection).firestoreDocumentId: true});

                        firestore
                            .doc((widget.currentCollection as CollaborativeCollection).firestoreDocumentId)
                            .collection('join_requests')
                            .doc('requests')
                            .update({widget.uid: FieldValue.delete()});
                        setState(() {
                          buttonClicked = true;
                        });
                      }, onError: (e) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: Column(
                                  children: [
                                    const Text('Failed to add user to collection, please try again'),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            });
                      });
                    },
                    child: const Text(
                      'Accept',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                      style: buttonStyle.copyWith(backgroundColor: const MaterialStatePropertyAll(Colors.red)),
                      onPressed: () {
                        firestore
                            .doc((widget.currentCollection as CollaborativeCollection).firestoreDocumentId)
                            .collection('join_requests')
                            .doc('requests')
                            .update({widget.uid: FieldValue.delete});
                        setState(() {
                          buttonClicked = true;
                        });
                      },
                      child: const Text(
                        'Reject',
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              )
            : const Icon(Icons.check)
      ]),
    );
  }
}
