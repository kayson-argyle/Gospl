import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gospl/collection_stuff/collaborative_collection.dart';
import 'package:gospl/main.dart';
import 'package:gospl/study_tools/display_highlight.dart';
import 'package:gospl/study_tools/glyph_data.dart';
import 'package:gospl/study_tools/highlight.dart';
import 'package:gospl/study_tools/scripture_text/generic_scripture_text.dart';
import 'package:gospl/study_tools/text_box_painter.dart';

class CollaborativeScriptureText extends GenericScriptureText {
  const CollaborativeScriptureText({super.key, required super.text, required super.textStyle, required super.locationString, required super.collection});

  @override
  State<GenericScriptureText> createState() => _CollaborativeScriptureTextState();
}

class _CollaborativeScriptureTextState extends GenericScriptureTextState {
  late StreamSubscription<QuerySnapshot> subscription;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void deleteCurrentlySelectedDisplayHighlight() {
    if (currentlySelectedHighlight != null && currentlySelectedHighlight?.highlight != null) {
      firestore
          .doc((widget.collection as CollaborativeCollection).firestoreDocumentId)
          .collection('highlights')
          .doc('${currentlySelectedHighlight?.highlight.firestoreId}')
          .delete()
          .then((value) => null, onError: (e) => log('Error updating document $e'));
      setState(() {
        currentlySelectedHighlight = null;
      });
      selectableTextController.selection = const TextSelection(baseOffset: 0, extentOffset: 0);
      selectableTextController.hideContextMenu();
    }
  }

  @override
  Highlight createHighlight(Highlight highlight) {
    DocumentReference doc = firestore.doc((widget.collection as CollaborativeCollection).firestoreDocumentId).collection('highlights').doc()
      ..set(highlight.toMap()).then((value) => null, onError: (e) => log('Error updating document $e'));
    highlight.firestoreId = doc.id;
    highlight.firestoreScriptureCollectionDocumentId = (widget.collection as CollaborativeCollection).firestoreDocumentId;
    return highlight;
  }

  @override
  void loadHighlights(GlyphData glyphData) async {
    //subscribe to the stream from firestore and get all updates, call addPaintToSavedDisplayHighlights for each one
    subscription = firestore
        .doc((widget.collection as CollaborativeCollection).firestoreDocumentId)
        .collection('highlights')
        .where('location', isEqualTo: widget.locationString)
        .snapshots()
        .listen((snapshot) {
      final List<Highlight> chapterHighlights = [];
      for (var change in snapshot.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            chapterHighlights.add(querySnapshotToListOfHighlights(change));

            break;
          case DocumentChangeType.modified:
          for (DisplayHighlight displayHighlight in savedDisplayHighlights) {
              if (displayHighlight.highlight.firestoreId == change.doc.id) {
                setState(() {
                  savedDisplayHighlights.remove(displayHighlight);
                  chapterHighlights.add(querySnapshotToListOfHighlights(change));
                });
                break;
              }
            }
            break;
          case DocumentChangeType.removed:
            for (DisplayHighlight displayHighlight in savedDisplayHighlights) {
              if (displayHighlight.highlight.firestoreId == change.doc.id) {
                setState(() {
                  savedDisplayHighlights.remove(displayHighlight);
                });
                break;
              }
            }
            break;
        }
      }
      for (Highlight highlight in chapterHighlights) {
        addPaintToSavedDisplayHighlights(
            highlight, TextBoxPainter(selection: TextSelection(baseOffset: highlight.start, extentOffset: highlight.end), color: Color(highlight.color), glyphData: glyphData));
      }
    }, onError: (e) {});
  }

  Highlight querySnapshotToListOfHighlights(DocumentChange change) {
    Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
    return Highlight(
      start: data['start'],
      end: data['end'],
      color: data['color'],
      note: data['note'],
      location: data['location'],
      collectionId: data['collectionId'] ?? 0,
      isCollaborative: data['isCollaborative'] ?? true,
      timeCreated: data['timeCreated'].toDate(),
      owner: data['owner'],
      firestoreId: change.doc.id,
      firestoreScriptureCollectionDocumentId: (widget.collection as CollaborativeCollection).firestoreDocumentId,
    );
  }

  @override
  void addPaintToSavedDisplayHighlights(Highlight highlight, TextBoxPainter textBoxPainter) {
    for (DisplayHighlight displayHighlight in savedDisplayHighlights) {
      if (highlight.firestoreId == displayHighlight.highlight.firestoreId) {
        return;
      }
    }
    super.addPaintToSavedDisplayHighlights(highlight, textBoxPainter);
  }
}
