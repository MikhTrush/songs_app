import 'package:flutter/material.dart';
import 'package:songs_app/models/song.dart';
import 'package:songs_app/widgets/tag_chip.dart';

class SongSearchItem extends StatelessWidget {
  const SongSearchItem({
    super.key,
    required this.song,
    required this.verseToDisplay,
    required this.context,
    required this.currentQuery,
    required this.onTap,
  });

  final Song song;
  final String verseToDisplay;
  final BuildContext context;
  final String currentQuery;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildHighlightedText(
        '${song.number} ${song.title}',
        currentQuery,
        isTitle: true,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHighlightedText(verseToDisplay, currentQuery),
          if (song.categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Wrap(
                spacing: 4,
                children: song.categories
                    .take(3)
                    .map(
                      (cat) =>
                          TagChip(cat: cat, color: Colors.blue.withAlpha(40)),
                    )
                    .toList(),
              ),
            ),
          if (song.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Wrap(
                spacing: 4,
                children: song.tags
                    .take(3)
                    .map(
                      (tag) =>
                          TagChip(cat: tag, color: Colors.green.withAlpha(40)),
                    )
                    .toList(),
              ),
            ),
          if (song.themes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: song.themes
                    .take(3)
                    .map(
                      (theme) => TagChip(
                        cat: theme,
                        color: Colors.orange.withAlpha(40),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildHighlightedText(
    String fullText,
    String searchTerm, {
    bool isTitle = false,
  }) {
    if (searchTerm.isEmpty) {
      return Text(
        fullText,
        style: isTitle ? Theme.of(context).textTheme.titleLarge : null,
      );
    }

    final lowerFullText = fullText.toLowerCase();
    final lowerSearchTerm = searchTerm.toLowerCase();

    // Use case-insensitive search to find all matches
    final matches = <(int start, int end)>[]; // Store match positions
    int searchStart = 0;

    while (searchStart <= lowerFullText.length - lowerSearchTerm.length) {
      final matchIndex = lowerFullText.indexOf(lowerSearchTerm, searchStart);
      if (matchIndex == -1) break;

      matches.add((matchIndex, matchIndex + lowerSearchTerm.length));
      searchStart = matchIndex + 1; // Move by 1 to catch overlapping matches
    }

    if (matches.isEmpty) {
      return Text(
        fullText,
        style: isTitle ? Theme.of(context).textTheme.titleLarge : null,
      );
    }

    // Build text spans based on match positions
    final List<TextSpan> spans = [];
    int currentPosition = 0;

    for (final (start, end) in matches) {
      // Add text before match
      if (currentPosition < start) {
        spans.add(TextSpan(text: fullText.substring(currentPosition, start)));
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: fullText.substring(start, end),
          style: TextStyle(
            backgroundColor: Colors.yellow.withOpacity(0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      currentPosition = end;
    }

    // Add remaining text after last match
    if (currentPosition < fullText.length) {
      spans.add(TextSpan(text: fullText.substring(currentPosition)));
    }

    return RichText(
      text: TextSpan(
        style: isTitle
            ? Theme.of(context).textTheme.titleLarge
            : DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }
}
