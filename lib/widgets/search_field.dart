import 'package:flutter/material.dart';
import 'package:songs_app/l10n/app_localizations.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.context,
    required this.controller,
  });

  final BuildContext context;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40, left: 20, right: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.30),
            blurRadius: 40,
            spreadRadius: 0.0,
          ),
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
          hintText: AppLocalizations.of(context)!.search,
          hintStyle: Theme.of(context).textTheme.labelMedium,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Icon(Icons.search),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: SizedBox(
              width: 60,
              height: 40,
              child: Row(
                spacing: 0,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  VerticalDivider(
                    color: Theme.of(context).colorScheme.secondary,
                    thickness: 1,
                    indent: 5,
                    endIndent: 5,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.filter_list_outlined),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
