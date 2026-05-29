import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import '../models/search_result.dart';
import '../services/click_tracking_service.dart';
import '../services/search_service.dart';
import '../widgets/search_result_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with WindowListener {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  int _selectedIndex = -1;
  Timer? _debounce;
  int _searchSeq = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    windowManager.addListener(this);
    SearchService.init();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _debounce?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    windowManager.removeListener(this);
    super.dispose();
  }

  // Global key handler — fires regardless of which widget has focus.
  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        _dismiss();
        return true;
      case LogicalKeyboardKey.arrowDown:
        setState(() {
          if (_selectedIndex < _searchResults.length - 1) _selectedIndex++;
        });
        return true;
      case LogicalKeyboardKey.arrowUp:
        setState(() {
          if (_selectedIndex > 0) _selectedIndex--;
        });
        return true;
      case LogicalKeyboardKey.enter:
        _openSelectedResult();
        return true;
      default:
        return false;
    }
  }

  @override
  void onWindowFocus() {
    // addPostFrameCallback ensures the widget tree is ready before we steal focus.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _searchFocusNode.requestFocus();
      _searchController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _searchController.text.length,
      );
    });
  }

  Future<void> _performSearch(String raw) async {
    final query = raw.trim();
    final seq = ++_searchSeq;

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _selectedIndex = -1;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _selectedIndex = -1;
    });

    final results = await SearchService.search(query);

    // Discard if a newer search already fired.
    if (seq != _searchSeq || !mounted) return;

    setState(() {
      _searchResults = results;
      _isSearching = false;
      // results[0] is always the web tile; pre-select the first real result if any.
      _selectedIndex = results.length > 1 ? 1 : 0;
    });
  }

  void _openSelectedResult() {
    if (_selectedIndex < 0 || _selectedIndex >= _searchResults.length) return;
    final result = _searchResults[_selectedIndex];
    ClickTrackingService.recordClick(result.path);
    SearchService.openPath(result);
    _dismiss();
  }

  void _dismiss() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _selectedIndex = -1;
    });
    windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF1A1A1A).withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Container(
                color: const Color(0xFF252525),
                child: Column(
                  children: [
                    GestureDetector(
                      onPanStart: (_) => windowManager.startDragging(),
                      child: Container(
                        height: 24,
                        color: Colors.transparent,
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.grey[700]!,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        autofocus: true,
                        onChanged: (value) {
                          _debounce?.cancel();
                          _debounce = Timer(
                            const Duration(milliseconds: 300),
                            () => _performSearch(value),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Search files, folders, apps... (Alt+X)',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchResults = [];
                                      _selectedIndex = -1;
                                    });
                                  },
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.grey[600],
                                    size: 18,
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[700]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[700]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.blueAccent,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isSearching
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF2196F3),
                            ),
                          ),
                        ),
                      )
                    : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 48, color: Colors.grey[700]),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.trim().isEmpty
                                  ? 'Start typing to search...'
                                  : 'No results found',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          final isSelected = index == _selectedIndex;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2196F3).withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF2196F3)
                                          .withValues(alpha: 0.5),
                                    )
                                  : null,
                            ),
                            child: SearchResultWidget(
                              result: result,
                              onTap: () {
                                setState(() => _selectedIndex = index);
                                _openSelectedResult();
                              },
                            ),
                          );
                        },
                      ),
              ),
              if (_searchResults.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[800]!)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedIndex + 1}/${_searchResults.length}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      Text(
                        'Press ↑↓ to navigate, ↵ to open, ESC to exit',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
