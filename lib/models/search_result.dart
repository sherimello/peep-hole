enum SearchResultType { file, folder, app, web }

class SearchResult {
  final String name;
  final String path;
  final SearchResultType type;
  final DateTime? lastModified;
  final bool isHidden;
  final String? icon;

  SearchResult({
    required this.name,
    required this.path,
    required this.type,
    this.lastModified,
    this.isHidden = false,
    this.icon,
  });

  String get displayPath {
    if (path.length > 50) {
      return '...${path.substring(path.length - 47)}';
    }
    return path;
  }

  String get displayName {
    if (type == SearchResultType.web) {
      return 'Search: "$name"';
    }
    return name;
  }
}
