class FilterModel {
  String? title;
  String? lyrics;
  DateTime? dateFrom;
  DateTime? dateTo;

  FilterModel({this.title, this.lyrics, this.dateFrom, this.dateTo});

  FilterModel copyWith({
    String? name,
    String? author,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return FilterModel(
      title: name ?? this.title,
      lyrics: author ?? this.lyrics,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  bool get hasFilters =>
      title != null || lyrics != null || dateFrom != null || dateTo != null;
}
