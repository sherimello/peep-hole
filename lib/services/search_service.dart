import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../models/search_result.dart';
import 'click_tracking_service.dart';
import 'index_service.dart';

class SearchService {
  static const int _maxResults = 20;
  static const int _maxAppResults = 5;

  static late Set<String> _systemDirs;
  static late Set<String> _ignorePatterns;
  static late List<String> _userPaths;
  static late List<String> _driveRoots;

  static int _generation = 0;

  static Future<void> init() async {
    _systemDirs = {
      'system volume information',
      'pagefile.sys',
      'hiberfil.sys',
      'programdata',
      'recovery',
      'program files',
      'program files (x86)',
      'perflogs',
      'recycle.bin',
      r'$recycle.bin',
    };

    _ignorePatterns = {
      '.git',
      '.vscode',
      'node_modules',
      '.next',
      'dist',
      'build',
      '.dart_tool',
    };

    // Drives for shallow fallback scan.
    _driveRoots = [];
    for (int i = 67; i <= 90; i++) {
      final d = '${String.fromCharCode(i)}:\\';
      if (Directory(d).existsSync()) _driveRoots.add(d);
    }

    // User-relevant paths — faster live scan + deep index.
    final home = Platform.environment['USERPROFILE'] ?? 'C:\\Users\\Default';
    _userPaths = [
      home,
      '$home\\Desktop',
      '$home\\Documents',
      '$home\\Downloads',
      '$home\\Pictures',
      '$home\\Videos',
      '$home\\Music',
      '$home\\Projects',
      '$home\\dev',
      '$home\\code',
      '$home\\workspace',
      '$home\\repos',
    ].where((p) => Directory(p).existsSync()).toList();

    // Start building the background index (non-blocking).
    IndexService.startBuilding(
      userPaths: _userPaths,
      driveRoots: _driveRoots,
      systemDirs: _systemDirs,
      ignorePatterns: _ignorePatterns,
    );
  }

  static Future<List<SearchResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final gen = ++_generation;
    final queryLower = trimmed.toLowerCase();
    final results = <SearchResult>[];

    // Apps first — always fast.
    results.addAll(await _searchInstalledApps(queryLower));
    if (gen != _generation) return [];

    if (IndexService.isReady) {
      // Fast path: in-memory index query.
      results.addAll(IndexService.query(queryLower, _maxResults - results.length));
    } else {
      // Slow path: live scan of user paths (much smaller than full drives).
      for (final path in _userPaths) {
        if (results.length >= _maxResults || gen != _generation) break;
        await _scanDirectory(Directory(path), queryLower, results, 0, gen, maxDepth: 3);
      }
      // Shallow drive-root scan so top-level folders are reachable.
      for (final drive in _driveRoots) {
        if (results.length >= _maxResults || gen != _generation) break;
        await _scanDirectory(Directory(drive), queryLower, results, 0, gen, maxDepth: 1);
      }
    }

    if (gen != _generation) return [];

    results.sort((a, b) {
      final ac = ClickTrackingService.getClickCount(a.path);
      final bc = ClickTrackingService.getClickCount(b.path);
      if (ac != bc) return bc.compareTo(ac);
      return _typePriority(a.type).compareTo(_typePriority(b.type));
    });

    // Web tile pinned to position 0.
    return [
      SearchResult(name: trimmed, path: 'Search on Google', type: SearchResultType.web),
      ...results.take(_maxResults - 1),
    ];
  }

  static int _typePriority(SearchResultType t) => switch (t) {
        SearchResultType.app => 0,
        SearchResultType.folder => 1,
        SearchResultType.file => 2,
        SearchResultType.web => 3,
      };

  static Future<List<SearchResult>> _searchInstalledApps(String query) async {
    final results = <SearchResult>[];
    final startMenuPaths = [
      '${Platform.environment['ProgramData']}\\Microsoft\\Windows\\Start Menu\\Programs',
      '${Platform.environment['APPDATA']}\\Microsoft\\Windows\\Start Menu\\Programs',
    ];

    for (final path in startMenuPaths) {
      if (results.length >= _maxAppResults) break;
      try {
        await for (final entity
            in Directory(path).list(recursive: true, followLinks: false)) {
          if (results.length >= _maxAppResults) break;
          if (entity is! File) continue;

          final raw = entity.path.split('\\').last;
          if (!raw.toLowerCase().endsWith('.lnk')) continue;

          final displayName = raw.substring(0, raw.length - 4);
          if (displayName.toLowerCase().contains(query)) {
            results.add(SearchResult(
              name: displayName,
              path: entity.path,
              type: SearchResultType.app,
            ));
          }
        }
      } catch (_) {}
    }
    return results;
  }

  static Future<void> _scanDirectory(
    Directory dir,
    String query,
    List<SearchResult> results,
    int depth,
    int gen, {
    required int maxDepth,
  }) async {
    if (depth > maxDepth || results.length >= _maxResults) return;
    if (gen != _generation) return;

    try {
      await for (final entity in dir.list(recursive: false, followLinks: false)) {
        if (results.length >= _maxResults || gen != _generation) break;

        final name = entity.path.split('\\').last;
        if (_shouldSkip(name)) continue;

        final nameLower = name.toLowerCase();
        if (nameLower.contains(query)) {
          try {
            final stat = entity.statSync();
            results.add(SearchResult(
              name: name,
              path: entity.path,
              type: entity is Directory ? SearchResultType.folder : SearchResultType.file,
              lastModified: stat.modified,
              isHidden: name.startsWith('.'),
            ));
          } catch (_) {}
        }

        if (entity is Directory) {
          await _scanDirectory(entity, query, results, depth + 1, gen, maxDepth: maxDepth);
        }
      }
    } catch (_) {}
  }

  static bool _shouldSkip(String name) {
    final lower = name.toLowerCase();
    if (_systemDirs.contains(lower)) return true;
    if (name.startsWith('.') && name != '..') return true;
    for (final p in _ignorePatterns) {
      if (lower.contains(p)) return true;
    }
    const skipExts = ['.tmp', '.log', '.bak', '.cache', '.sys', '.dll'];
    for (final ext in skipExts) {
      if (lower.endsWith(ext)) return true;
    }
    return false;
  }

  static Future<void> openPath(SearchResult result) async {
    try {
      switch (result.type) {
        case SearchResultType.app:
        case SearchResultType.folder:
          await Process.run('explorer', [result.path]);
        case SearchResultType.file:
          await Process.run('cmd', ['/c', 'start', '', result.path]);
        case SearchResultType.web:
          final url = Uri.parse(
            'https://www.google.com/search?q=${Uri.encodeComponent(result.name)}',
          );
          if (await canLaunchUrl(url)) await launchUrl(url);
      }
    } catch (_) {}
  }
}
