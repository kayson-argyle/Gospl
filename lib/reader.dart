import 'dart:convert';
import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:gospl/book_data/book_data.dart';
import 'package:gospl/collection_stuff/collaborative_collection.dart';
import 'package:gospl/collection_stuff/collection_manager.dart';
import 'package:gospl/collection_stuff/generic_collection.dart';
import 'package:gospl/custom_dropdown_button.dart';
import 'package:gospl/main.dart';
import 'package:gospl/models/user.dart';
import 'package:gospl/navigation/scripture_collection_navigation_drawer.dart';
import 'package:gospl/shared/loading.dart';
import 'package:gospl/study_tools/scripture_text/collaborative_scripture_text.dart';
import 'package:gospl/study_tools/scripture_text/user_scripture_text.dart';
import 'chapter.dart';

class Reader extends StatefulWidget {
  const Reader({super.key, required this.currentCollection, required this.openCollectionsWindow, required this.currentlyLoggedInUser, required this.collectionManager});

  final GenericCollection currentCollection;
  final Function openCollectionsWindow;
  final AppUser currentlyLoggedInUser;
  final CollectionManagerState collectionManager;

  @override
  State<Reader> createState() => _Reader();
}

class _Reader extends State<Reader> {
  bool loadingJson = true;
  late PageController controller;
  late Map<String, dynamic> json;
  bool addVerseNumbers = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late int currentPage = controller.initialPage;
  String currentWork = '';
  bool workHasSubBooks = false;

  List<int> chapterTotals = [];
  List<String> bookNames = [];
  List<String> titlesFromOrder = [];

  TextStyle style = GoogleFonts.tinos(fontSize: 19, height: 1.5, color: Colors.white, letterSpacing: 0, wordSpacing: 0, fontWeight: FontWeight.w400);

  int bookLength() {
    int counter = 0;
    for (int i in chapterTotals) {
      counter += i;
    }
    return counter;
  }

  int pageToChapter(int page) {
    int bookIndex = -1;
    while (page >= 0) {
      bookIndex++;
      page -= chapterTotals[bookIndex];
    }
    page += chapterTotals[bookIndex];
    return page + 1;
  }

  String pageToBook(int page) {
    int bookIndex = -1;
    while (page >= 0) {
      bookIndex++;
      page -= chapterTotals[bookIndex];
    }
    page += chapterTotals[bookIndex];
    return bookNames[bookIndex];
  }

  int bookIndexFromPage(int page) {
    int bookIndex = -1;
    while (page >= 0) {
      bookIndex++;
      page -= chapterTotals[bookIndex];
    }
    return bookIndex;
  }

  getJson(String filePath, String collectionId) async {
    String jsonString;
    jsonString = await rootBundle.loadString(filePath);
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      json = jsonDecode(jsonString);
      loadingJson = false;
    });
  }

  List<CustomDropdownMenuItem<String>> getBookList() {
    List<CustomDropdownMenuItem<String>> list = [];
    for (String name in bookNames) {
      list.add(CustomDropdownMenuItem<String>(
          alignment: Alignment.center,
          value: name,
          child: SizedBox(
            width: 170,
            child: Text(
              name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
            ),
          )));
    }
    return list;
  }

  List<CustomDropdownMenuItem<String>> getChapterList(int page) {
    List<CustomDropdownMenuItem<String>> list = [];
    String addedSpace = '';
    if (chapterTotals[bookIndexFromPage(page)] < 10) {
      addedSpace = ' ';
    }
    for (int i = 1; i <= chapterTotals[bookIndexFromPage(page)]; i++) {
      list.add(
        CustomDropdownMenuItem<String>(
          alignment: Alignment.center,
          value: '$i',
          child: Text(
            '$addedSpace$i',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return list;
  }

  TextSpan getText(int page) {
    int originalPage = page;
    int bookIndex = -1;
    while (page >= 0) {
      bookIndex++;
      page -= chapterTotals[bookIndex];
    }
    int workIndex = allBooksInLibraryNames.indexOf(currentWork);
    if (allBooksInLibrary[workIndex]['order'].contains(bookNames[bookIndex])) {
      //for introduction, title pages and such
      List<TextSpan> children = [];
      //get the text spans out of the parent text span
      for (TextSpan span in allBooksInLibrary[workIndex][bookNames[bookIndex]]['contents'].children) {
        children.add(TextSpan(text: span.text, style: style.copyWith(fontSize: (style.fontSize! * span.style!.fontSize!))));
      }
      TextSpan textSpan = TextSpan(children: children);
      return textSpan;
    } else {
      // for all of the books
      page += chapterTotals[bookIndex];
      Chapter chapter2;
      int extraLength = 0;
      allBooksInLibrary[workIndex]['order'].forEach((_) {
        extraLength += 1;
      });
      List<TextSpan> children = [
        
      ];
      if (workHasSubBooks) {
        log('current page: $page');
        log('current book index: $bookIndex');
        // need to get the right book index, ie adjusted for the extra intro stuff like title page

        chapter2 = Chapter.fromJson(json, bookIndex - extraLength, page);
        if (json["books"][bookIndex - extraLength].containsKey("full_title") && page == 0) {
          children.add(TextSpan(text: '\n', style: style.copyWith(fontSize: style.fontSize!)));
          children.add(
            TextSpan(
              text: '${json["books"][bookIndex - extraLength]["full_title"]}\n',
              style: style.copyWith(fontSize: style.fontSize! * 2),
            ),
          );
        }
        if (json["books"][bookIndex - extraLength].containsKey("full_subtitle") && page == 0) {
          children.add(
            TextSpan(
              text: '${json["books"][bookIndex - extraLength]["full_subtitle"]}\n',
              style: style.copyWith(fontSize: style.fontSize! * 1.3),
            ),
          );
        }
        if (json["books"][bookIndex - extraLength].containsKey("heading") && page == 0) {
          children.add(
            TextSpan(
              text: '\n${json["books"][bookIndex - extraLength]["heading"]}\n',
              style: style.copyWith(fontSize: style.fontSize! * 1),
            ),
          );
        }
      } else {
        chapter2 = Chapter.noSubBookfromJson(json, page);
      }
      String verses = '';
      for (int i = 0; i < chapter2.text.length; i++) {
        verses += "${(addVerseNumbers ? '${i + 1} ' : '') + chapter2.text[i]['text']}\n\n";
      }

      return TextSpan(
          children: [...children, ...[TextSpan(text: '\n', style: style.copyWith(fontSize: style.fontSize!)), TextSpan(text: 'Chapter ${(pageToChapter(originalPage))}\n\n', style: style.copyWith(fontSize: style.fontSize! * 1.7)), TextSpan(text: verses, style: style)]]);
    }
  }

  @override
  void initState() {
    super.initState();
    String collectionId;
    if (preferences.getString('currentCollectionType') == 'personal') {
      collectionId = "${widget.currentCollection.id}";
    } else {
      collectionId = preferences.getString('currentCollaborativeCollection')!;
    }
    if (preferences.getString("${collectionId}_work") == null) {
      preferences.setString("${collectionId}_work", 'Book of Mormon');
    }

    selectWork(preferences.getString("${collectionId}_work")!, collectionId);
  }

  void selectWork(String workName, String collectionId) {
    preferences.setString("${collectionId}_work", workName);
    if (preferences.getInt("${collectionId}_${workName}_page") == null) {
      preferences.setInt("${collectionId}_${workName}_page", 0);
    }

    if (!loadingJson) {
      setState(() {
        loadingJson = true;
        log("${collectionId}_${workName}_page is ${preferences.getInt("${collectionId}_${workName}_page")!}");
      });
    }
    currentWork = workName;
    controller = PageController(initialPage: preferences.getInt("${collectionId}_${workName}_page")!);
    currentPage = preferences.getInt("${collectionId}_${workName}_page")!;
    int bookIndex = allBooksInLibraryNames.indexOf(workName);
    if (allBooksInLibrary[bookIndex]['hasSubBooks']) {
      workHasSubBooks = true;
      titlesFromOrder = allBooksInLibrary[bookIndex]['order'];

      bookNames = [...titlesFromOrder, ...allBooksInLibrary[bookIndex]['bookNames']];
      chapterTotals = allBooksInLibrary[bookIndex]['chapterTotals'];
      getJson(allBooksInLibrary[bookIndex]['file'], collectionId);
    } else {
      titlesFromOrder = allBooksInLibrary[bookIndex]['order'];
      workHasSubBooks = false;
      bookNames = [...titlesFromOrder, workName];
      log('$bookNames');
      chapterTotals = [allBooksInLibrary[bookIndex]['order'].length, allBooksInLibrary[bookIndex]['chapterTotal']];
      getJson(allBooksInLibrary[bookIndex]['file'], collectionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loadingJson
        ? const Loading()
        : Scaffold(
            key: _scaffoldKey,
            drawer: ScriptureCollectionNavigationDrawer(
                selectBook: selectWork,
                openCollectionsWindow: widget.openCollectionsWindow,
                currentCollection: widget.currentCollection,
                currentlyLoggedInUser: widget.currentlyLoggedInUser,
                collectionManager: widget.collectionManager),
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Color(0xFF6d4941)),
              scrolledUnderElevation: 100,
              // leading: IconButton(
              //   onPressed: () {},
              //   icon: const Icon(Icons.menu),
              //   color: const Color(0xFF6d4941),
              // ),
              actions: const [
                SizedBox(
                  width: 40,
                )
                // IconButton(
                //     onPressed: () {},
                //     icon: const Icon(
                //       Icons.settings,
                //       color: Color(0xFF6d4941),
                //     ))
              ],
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF6d4941), width: 1),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                    ),
                    child: SizedBox(
                      width: 180,
                      child: CustomDropdownButton<String>(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), bottomLeft: Radius.circular(40)),
                        isExpanded: true,
                        alignment: Alignment.center,
                        dropdownColor: const Color(0xFF031526),
                        style: GoogleFonts.lora(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 232, 216, 199),
                        ),
                        underline: const SizedBox(),
                        iconEnabledColor: const Color(0xFFe7d3bd),
                        items: getBookList(),
                        onChanged: (item) {
                          int pageIndex = 0;
                          int times = bookNames.indexOf(item!);
                          for (int i = 0; i < times; i++) {
                            pageIndex += chapterTotals[i];
                          }
                          controller.jumpToPage(pageIndex);
                        },
                        value: pageToBook(currentPage),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF6d4941), width: 1),
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                    ),
                    child: CustomDropdownButton<String>(
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(40), bottomRight: Radius.circular(40)),
                      alignment: Alignment.center,
                      dropdownColor: const Color(0xFF031526),
                      iconEnabledColor: const Color(0xFFe7d3bd),
                      style: GoogleFonts.lora(
                        fontSize: 20,
                        color: const Color(0xFFe7d3bd),
                      ),
                      underline: const SizedBox(),
                      items: getChapterList(currentPage),
                      onChanged: (item) {
                        bookIndexFromPage(currentPage);
                        int pageIndex = 0;
                        for (int i = 0; i < bookIndexFromPage(currentPage); i++) {
                          pageIndex += chapterTotals[i];
                        }
                        pageIndex += int.parse(item!) - 1;
                        controller.jumpToPage(pageIndex);
                      },
                      value: pageToChapter(currentPage).toString(),
                    ),
                  ),
                ],
              ),
            ),
            body: MediaQuery(
              data: MediaQueryData(
                gestureSettings: const DeviceGestureSettings(touchSlop: 8.0),
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              ),
              child: PageView.builder(
                itemCount: bookLength(),
                controller: controller,
                onPageChanged: (newPage) {
                  String collectionId;
                  if (preferences.getString('currentCollectionType') == 'personal') {
                    collectionId = "${widget.currentCollection.id}";
                  } else {
                    collectionId = (widget.currentCollection as CollaborativeCollection).firestoreDocumentId;
                  }
                  preferences.setInt("${collectionId}_${currentWork}_page", newPage);
                  setState(() {
                    currentPage = newPage;
                  });
                },
                itemBuilder: (context, page) {
                  return widget.currentCollection.isCollaborative
                      ? CollaborativeScriptureText(
                          collection: widget.currentCollection,
                          locationString: "${currentWork}_${pageToBook(page)}_${pageToChapter(page)}",
                          text: getText(page),
                          textStyle: style,
                        )
                      : UserScriptureText(
                          collection: widget.currentCollection,
                          locationString: "${currentWork}_${pageToBook(page)}_${pageToChapter(page)}",
                          text: getText(page),
                          textStyle: style,
                        );
                },
              ),
            ));
  }
}
