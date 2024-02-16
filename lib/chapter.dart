class Chapter {
  late List<dynamic> text;
  late String title;

  Chapter(this.title, this.text);

  Chapter.fromJson(Map<String, dynamic> json, int book, int chapter) {
    title = json["books"][book]["chapters"][chapter]["reference"];
    text = json["books"][book]["chapters"][chapter]["verses"];
  }
  Chapter.noSubBookfromJson(Map<String, dynamic> json, int chapter) {
    title = json["sections"][chapter]["reference"];
    text = json["sections"][chapter]["verses"];
  }
}
