class Subtitle {
  final String text;
  final Duration start;
  final Duration end;
  bool? isArabic = false;
  Subtitle(
      {required this.text,
      required this.start,
      required this.end,
      this.isArabic});
}
