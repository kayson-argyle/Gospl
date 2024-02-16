import 'package:flutter/material.dart';

Map allBooksInLibrary = {
  0: {
    'file': 'assets/old-testament.json',
    'hasSubBooks': true,
    'chapterTotals': [1, 50, 40, 27, 36, 34, 24, 21, 4, 31, 24, 22, 25, 29, 36, 10, 13, 10, 42, 150, 31, 12, 8, 66, 52, 5, 48, 12, 14, 3, 9, 1, 4, 7, 3, 3, 3, 2, 14, 4],
    'bookNames': [
      "Genesis",
      "Exodus",
      "Leviticus",
      "Numbers",
      "Deuteronomy",
      "Joshua",
      "Judges",
      "Ruth",
      "1 Samuel",
      "2 Samuel",
      "1 Kings",
      "2 Kings",
      "1 Chronicles",
      "2 Chronicles",
      "Ezra",
      "Nehemiah",
      "Esther",
      "Job",
      "Psalms",
      "Proverbs",
      "Ecclesiastes",
      "Song of Solomon",
      "Isaiah",
      "Jeremiah",
      "Lamentations",
      "Ezekiel",
      "Daniel",
      "Hosea",
      "Joel",
      "Amos",
      "Obadiah",
      "Jonah",
      "Micah",
      "Nahum",
      "Habakkuk",
      "Zephaniah",
      "Haggai",
      "Zechariah",
      "Malachi"
    ],
    'order': ['Title Page'],
    'Title Page': {
      'contents': const TextSpan(
        children: [
          TextSpan(text: "\n\nTHE HOLY BIBLE\n", style: TextStyle(fontSize: 2.5)),
          TextSpan(text: "Containing the Old and New Testaments\n\n", style: TextStyle(fontSize: 1.2)),
          TextSpan(text: "Translated out of the original tongues and with the former translations diligently compared and revised by His Majesty's special command", style: TextStyle(fontSize: 1)),
        ],
      ),
    }
  },
  1: {
    'file': 'assets/new-testament.json',
    'hasSubBooks': true,
    'chapterTotals': [1, 28, 16, 24, 21, 28, 16, 16, 13, 6, 6, 4, 4, 5, 3, 6, 4, 3, 1, 13, 5, 5, 3, 5, 1, 1, 1, 22],
    'bookNames': [
      "Matthew",
      "Mark",
      "Luke",
      "John",
      "Acts",
      "Romans",
      "1 Corinthians",
      "2 Corinthians",
      "Galatians",
      "Ephesians",
      "Philippians",
      "Colossians",
      "1 Thessalonians",
      "2 Thessalonians",
      "1 Timothy",
      "2 Timothy",
      "Titus",
      "Philemon",
      "Hebrews",
      "James",
      "1 Peter",
      "2 Peter",
      "1 John",
      "2 John",
      "3 John",
      "Jude",
      "Revelation"
    ],
    'order': ['Title Page'],
    'Title Page': {
      'contents': const TextSpan(
        children: [
          TextSpan(text: "\n\n\nTHE NEW TESTAMENT\n", style: TextStyle(fontSize: 1.8)),
          TextSpan(text: "of Our Lord and Savior Jesus Christ\n\n", style: TextStyle(fontSize: 1.3)),
          TextSpan(
              text: "Translated out of the Original Greek: and with the Former Translations Diligently Compared and Revised, by His Majesty's Special Command",
              style: TextStyle(fontSize: 1.2)),
        ],
      ),
    }
  },
  2: {
    'file': 'assets/book-of-mormon.json',
    'hasSubBooks': true,
    'chapterTotals': [1, 1, 1, 22, 33, 7, 1, 1, 1, 1, 29, 63, 16, 30, 1, 9, 15, 10],
    'bookNames': [
      "1 Nephi",
      "2 Nephi",
      "Jacob",
      "Enos",
      "Jarom",
      "Omni",
      "Words of Mormon",
      "Mosiah",
      "Alma",
      "Helaman",
      "3 Nephi",
      "4 Nephi",
      "Mormon",
      "Ether",
      "Moroni",
    ],
    'order': ['Title Page', 'Testimony of Three Witnesses', 'Testimony of Eight Witnesses'],
    'Title Page': {
      'contents': const TextSpan(
        children: [
          TextSpan(text: "THE BOOK OF MORMON\n", style: TextStyle(fontSize: 1.7)),
          TextSpan(text: "Another Testament of Jesus Christ\n\n", style: TextStyle(fontSize: 1.4)),
          TextSpan(text: "An Account Written by the Hand of Mormon upon Plates Taken from the Plates of Nephi\n\n", style: TextStyle(fontSize: 1.2)),
          TextSpan(
              text:
                  "Wherefore, it is an abridgment of the record of the people of Nephi, and also of the Lamanites—Written to the Lamanites, who are a remnant of the house of Israel; and also to Jew and Gentile—Written by way of commandment, and also by the spirit of prophecy and of revelation—Written and sealed up, and hid up unto the Lord, that they might not be destroyed—To come forth by the gift and power of God unto the interpretation thereof—Sealed by the hand of Moroni, and hid up unto the Lord, to come forth in due time by way of the Gentile—The interpretation thereof by the gift of God.\n\n",
              style: TextStyle(fontSize: 1)),
          TextSpan(
              text:
                  "An abridgment taken from the Book of Ether also, which is a record of the people of Jared, who were scattered at the time the Lord confounded the language of the people, when they were building a tower to get to heaven—Which is to show unto the remnant of the house of Israel what great things the Lord hath done for their fathers; and that they may know the covenants of the Lord, that they are not cast off forever—And also to the convincing of the Jew and Gentile that Jesus is the Christ, the Eternal God, manifesting himself unto all nations—And now, if there are faults they are the mistakes of men; wherefore, condemn not the things of God, that ye may be found spotless at the judgment-seat of Christ.\n\n",
              style: TextStyle(fontSize: 1)),
        ],
      ),
    },
    'Testimony of Three Witnesses': {
      'contents': const TextSpan(
        children: [
          TextSpan(text: "The Testimony of Three Witnesses\n\n", style: TextStyle(fontSize: 1.8)),
          TextSpan(
              text:
                  "Be it known unto all nations, kindreds, tongues, and people, unto whom this work shall come: That we, through the grace of God the Father, and our Lord Jesus Christ, have seen the plates which contain this record, which is a record of the people of Nephi, and also of the Lamanites, their brethren, and also of the people of Jared, who came from the tower of which hath been spoken. And we also know that they have been translated by the gift and power of God, for his voice hath declared it unto us; wherefore we know of a surety that the work is true. And we also testify that we have seen the engravings which are upon the plates; and they have been shown unto us by the power of God, and not of man. And we declare with words of soberness, that an angel of God came down from heaven, and he brought and laid before our eyes, that we beheld and saw the plates, and the engravings thereon; and we know that it is by the grace of God the Father, and our Lord Jesus Christ, that we beheld and bear record that these things are true. And it is marvelous in our eyes. Nevertheless, the voice of the Lord commanded us that we should bear record of it; wherefore, to be obedient unto the commandments of God, we bear testimony of these things. And we know that if we are faithful in Christ, we shall rid our garments of the blood of all men, and be found spotless before the judgment-seat of Christ, and shall dwell with him eternally in the heavens. And the honor be to the Father, and to the Son, and to the Holy Ghost, which is one God. Amen.\n\n\tOliver Cowdery\n\tDavid Whitmer\n\tMartin Harris\n\n",
              style: TextStyle(fontSize: 1)),
        ],
      ),
    },
    'Testimony of Eight Witnesses': {
      'contents': const TextSpan(
        children: [
          TextSpan(text: "The Testimony of Eight Witnesses\n\n", style: TextStyle(fontSize: 1.8)),
          TextSpan(
              text:
                  "Be it known unto all nations, kindreds, tongues, and people, unto whom this work shall come: That Joseph Smith, Jun., the translator of this work, has shown unto us the plates of which hath been spoken, which have the appearance of gold; and as many of the leaves as the said Smith has translated we did handle with our hands; and we also saw the engravings thereon, all of which has the appearance of ancient work, and of curious workmanship. And this we bear record with words of soberness, that the said Smith has shown unto us, for we have seen and hefted, and know of a surety that the said Smith has got the plates of which we have spoken. And we give our names unto the world, to witness unto the world that which we have seen. And we lie not, God bearing witness of it.\n\n\tChristian Whitmer\n\tJacob Whitmer\n\tPeter Whitmer, Jun.\n\tJohn Whitmer\n\tHiram Page\n\tJoseph Smith, Sen.\n\tHyrum Smith\n\tSamuel H. Smith\n\n",
              style: TextStyle(fontSize: 1)),
        ],
      ),
    },
  },
  3: {
    'file': 'assets/doctrine-and-covenants.json',
    'hasSubBooks': false,
    'chapterTotal': 138,
    'order': ['Title Page'],
    'Title Page': {
      'contents': const TextSpan(
        children: [
          TextSpan(text: "\n\n\n\n\nTHE DOCTRINE AND COVENANTS\n", style: TextStyle(fontSize: 1.28)),
          TextSpan(text: "of The Church of Jesus Christ of Latter-day Saints\n\n", style: TextStyle(fontSize: 1)),
          TextSpan(
              text: "Containing Revelations Given to Joseph Smith, the Prophet with Some Additions by His Successors in the Presidency of the Church",
              style: TextStyle(fontSize: 0.95)),
        ],
      ),
    }
  },
  4: {
    'hasSubBooks': true,
    'file': 'assets/pearl-of-great-price.json',
    'chapterTotals': [1, 8, 5, 1, 1, 1],
    'bookNames': ["Moses", "Abraham", "Joseph Smith—Matthew", "Joseph Smith—History", "Articles of Faith"],
    'order': ['Title Page'],
    'Title Page': {
      'contents': const TextSpan(
        children: [
          TextSpan(text: "\n\n\n\nTHE PEARL OF GREAT PRICE\n\n", style: TextStyle(fontSize: 1.5)),
          TextSpan(
              text:
                  "A Selection from the Revelations, Translations, and Narrations of Joseph Smith First Prophet, Seer, and Revelator to The Church of Jesus Christ of Latter-day Saints",
              style: TextStyle(fontSize: 1)),
        ],
      ),
    }
  },
};

List<String> allBooksInLibraryNames = [
  'Old Testament',
  'New Testament',
  'Book of Mormon',
  'Doctrine and Covenants',
  'Pearl of Great Price',
];
