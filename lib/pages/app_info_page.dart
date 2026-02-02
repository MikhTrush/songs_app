import 'package:flutter/material.dart';
import 'package:songs_app/l10n/app_localizations.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(AppLocalizations.of(context)!.app_info),
      ),
      body: Column(
        children: [
          // TODO: Add localization
          Center(child: Text('This is the App Info page')),
          ListTile(title: Text('version')),
        ],
      ),
    );
  }
}
