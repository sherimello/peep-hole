import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../services/icon_service.dart';

class SearchResultWidget extends StatefulWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const SearchResultWidget({
    Key? key,
    required this.result,
    required this.onTap,
  }) : super(key: key);

  @override
  State<SearchResultWidget> createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget> {
  bool _isHovered = false;
  Future<Uint8List?>? _iconFuture;

  @override
  void initState() {
    super.initState();
    if (widget.result.type == SearchResultType.app) {
      _iconFuture = IconService.getAppIcon(widget.result.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _isHovered
              ? Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  _buildIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.result.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.result.displayPath,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.result.type == SearchResultType.web)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.result.type == SearchResultType.app && _iconFuture != null) {
      return FutureBuilder<Uint8List?>(
        future: _iconFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(
                snapshot.data!,
                width: 36,
                height: 36,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            );
          }
          return _fallbackIcon();
        },
      );
    }
    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _colorForType(widget.result.type),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Icon(
          _iconForType(widget.result.type),
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Color _colorForType(SearchResultType type) => switch (type) {
        SearchResultType.file => const Color(0xFF2196F3),
        SearchResultType.folder => const Color(0xFFFFA726),
        SearchResultType.app => const Color(0xFF66BB6A),
        SearchResultType.web => const Color(0xFF42A5F5),
      };

  IconData _iconForType(SearchResultType type) => switch (type) {
        SearchResultType.file => Icons.insert_drive_file,
        SearchResultType.folder => Icons.folder,
        SearchResultType.app => Icons.apps,
        SearchResultType.web => Icons.public,
      };
}
