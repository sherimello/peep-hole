import 'dart:io';
import 'dart:isolate';
import '../models/search_result.dart';

class IndexService {
  // Each entry: (name, path, isDir)
  static List<(String, String, bool)> _entries = [];
  static bool _ready = false;
  static bool _building = false;

  static bool get isReady => _ready;
  static int get size => _entries.length;

  static void startBuilding({
    required List<String> userPaths,
    required List<String> driveRoots,
    required Set<String> systemDirs,
    required Set<String> ignorePatterns,
  }) {
    if (_building) return;
    _building = true;

    final params = [
      userPaths,
      driveRoots,
      systemDirs.toList(),
      ignorePatterns.toList(),
    ];

    Isolate.run(() => _buildIndex(params))
        .then((raw) {
          _entries = raw.map((e) => (e[0] as String, e[1] as String, e[2] as bool)).toList();
          _ready = true;
          _building = false;
        })
        .catchError((_) {
          _building = false;
        });
  }

  static List<SearchResult> query(String queryLower, int max) {
    final out = <SearchResult>[];
    for (final (name, path, isDir) in _entries) {
      if (out.length >= max) break;
      if (name.toLowerCase().contains(queryLower)) {
        out.add(SearchResult(
          name: name,
          path: path,
          type: isDir ? SearchResultType.folder : SearchResultType.file,
        ));
      }
    }
    return out;
  }
}

// Top-level so the isolate can call it without capturing any closures.
List<List<Object>> _buildIndex(List<dynamic> params) {
  final userPaths = (params[0] as List).cast<String>();
  final driveRoots = (params[1] as List).cast<String>();
  final systemDirs = (params[2] as List).cast<String>().toSet();
  final ignorePatterns = (params[3] as List).cast<String>().toSet();

  final entries = <List<Object>>[];
  final cfg = _Cfg(systemDirs, ignorePatterns);

  // Deep scan of user-relevant paths.
  for (final p in userPaths) {
    _scan(Directory(p), entries, cfg, 0, 6);
  }

  // Shallow scan of drive roots so top-level folders are findable.
  for (final d in driveRoots) {
    _scan(Directory(d), entries, cfg, 0, 1);
  }

  return entries;
}

class _Cfg {
  final Set<String> systemDirs;
  final Set<String> ignorePatterns;
  _Cfg(this.systemDirs, this.ignorePatterns);
}

const _skipExts = ['.tmp', '.log', '.bak', '.cache', '.sys', '.dll', '.pdb', '.lnk'];

void _scan(Directory dir, List<List<Object>> out, _Cfg cfg, int depth, int max) {
  if (depth > max) return;
  try {
    for (final e in dir.listSync(recursive: false, followLinks: false)) {
      final name = e.path.split('\\').last;
      final lower = name.toLowerCase();

      if (cfg.systemDirs.contains(lower)) continue;
      if (name.startsWith('.')) continue;
      if (cfg.ignorePatterns.any((p) => lower.contains(p))) continue;
      if (_skipExts.any((x) => lower.endsWith(x))) continue;

      out.add([name, e.path, e is Directory]);

      if (e is Directory) _scan(e, out, cfg, depth + 1, max);
    }
  } catch (_) {}
}
