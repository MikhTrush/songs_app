import 'package:flutter/material.dart';
import 'package:songs_app/l10n/app_localizations.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    this.filterWidget,
  });

  final TextEditingController controller;
  final Widget? filterWidget;

  Widget _buildSuffixIcon(BuildContext context, Widget filterWidget, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: SizedBox(
        width: 50,
        height: 40,
        child: Row(
          spacing: 0,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            VerticalDivider(
              width: 2,
              color: theme.colorScheme.secondary,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            filterWidget,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withAlpha(96), blurRadius: 10),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          contentPadding: EdgeInsets.all(5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintText: l10n.search,
          hintStyle: theme.textTheme.labelMedium,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Icon(Icons.search),
          ),
          suffixIcon: filterWidget != null ? _buildSuffixIcon(context, filterWidget!, theme) : null,
        ),
      ),
    );
  }
}
