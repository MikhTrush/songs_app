import 'package:flutter/material.dart';
import '../models/song.dart';
// Removed unused import

class CommonTagChip extends StatelessWidget {
  const CommonTagChip({super.key, required this.tag, this.color = Colors.blue});

  final Color color;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Text(tag, style: TextStyle(fontSize: 12, color: Colors.white)),
      ),
    );
  }
}

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.showCategories = true,
    this.showTags = true,
    this.showThemes = true,
    this.highlightText = '',
  });

  final Song song;
  final VoidCallback? onTap;
  final bool showCategories;
  final bool showTags;
  final bool showThemes;
  final String highlightText;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(song.title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (song.verses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _getFirstVersePreview(song.verses[0].text),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 4),
          if (showCategories && song.categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: song.categories
                    .take(3)
                    .map(
                      (cat) => CommonTagChip(
                        tag: cat,
                        color: Colors.blue.withAlpha(40),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (showTags && song.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: song.tags
                    .take(3)
                    .map(
                      (tag) => CommonTagChip(
                        tag: tag,
                        color: Colors.green.withAlpha(40),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (showThemes && song.themes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: song.themes
                    .take(3)
                    .map(
                      (theme) => CommonTagChip(
                        tag: theme,
                        color: Colors.orange.withAlpha(40),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  String _getFirstVersePreview(String verse) {
    // Get first 60 characters of the first verse, or the whole verse if shorter
    if (verse.length <= 60) return verse;
    return '${verse.substring(0, 60)}...';
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category, this.onTap});

  final String category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(category),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.sentiment_dissatisfied,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), elevation: 0, centerTitle: true);
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
      ),
    );
  }
}
