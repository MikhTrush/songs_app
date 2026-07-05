import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/filter_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterModel initialFilters;

  const FilterBottomSheet({super.key, required this.initialFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterModel _filters;
  final _titleController = TextEditingController();
  final _lyricsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _titleController.text = widget.initialFilters.title ?? '';
    _lyricsController.text = widget.initialFilters.lyrics ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (_filters.dateFrom ?? DateTime.now())
          : (_filters.dateTo ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _filters = _filters.copyWith(dateFrom: picked);
        } else {
          _filters = _filters.copyWith(dateTo: picked);
        }
      });
    }
  }

  String _formatDate(DateTime? date, BuildContext ctx) {
    if (date == null) return AppLocalizations.of(ctx)!.date_not_set;
    return DateFormat.yMd(Localizations.localeOf(context).languageCode).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filters,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Поле: Название
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.title,
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                _filters = _filters.copyWith(
                  name: value.isNotEmpty ? value : null,
                );
              },
            ),
            const SizedBox(height: 16),

            // Поле: Автор
            TextField(
              controller: _lyricsController,
              decoration: InputDecoration(
                labelText: l10n.lyrics,
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                _filters = _filters.copyWith(
                  author: value.isNotEmpty ? value : null,
                );
              },
            ),
            const SizedBox(height: 16),

            // Поле: Дата от
            InkWell(
              onTap: () => _selectDate(true),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.date_label,
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  _formatDate(_filters.dateFrom, context),
                  style: _filters.dateFrom == null
                      ? TextStyle(color: Colors.grey[500])
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Поле: Дата до
            InkWell(
              onTap: () => _selectDate(false),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.date_label,
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  _formatDate(_filters.dateTo, context),
                  style: _filters.dateTo == null
                      ? TextStyle(color: Colors.grey[500])
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Кнопки
            Row(
              children: [
                // Кнопка: Сбросить
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _filters = FilterModel();
                        _titleController.clear();
                        _lyricsController.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(l10n.reset),
                  ),
                ),
                const SizedBox(width: 12),
                // Кнопка: Применить
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _filters);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(l10n.accept),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
