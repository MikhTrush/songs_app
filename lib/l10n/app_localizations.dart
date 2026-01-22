import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello, world!'**
  String get helloWorld;

  /// Search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @songs_app.
  ///
  /// In en, this message translates to:
  /// **'Songs App'**
  String get songs_app;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @search_songs.
  ///
  /// In en, this message translates to:
  /// **'Search songs...'**
  String get search_songs;

  /// No description provided for @statistics_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Statistics page coming soon'**
  String get statistics_coming_soon;

  /// No description provided for @confirm_delete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirm_delete;

  /// No description provided for @are_you_sure_delete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String are_you_sure_delete(Object name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @no_collections_yet.
  ///
  /// In en, this message translates to:
  /// **'No collections yet. Tap the + button to create one.'**
  String get no_collections_yet;

  /// No description provided for @no_songs_in_collection.
  ///
  /// In en, this message translates to:
  /// **'No songs in this collection'**
  String get no_songs_in_collection;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error_occurred(Object error);

  /// No description provided for @edit_collection.
  ///
  /// In en, this message translates to:
  /// **'Edit Collection'**
  String get edit_collection;

  /// No description provided for @create_collection.
  ///
  /// In en, this message translates to:
  /// **'Create Collection'**
  String get create_collection;

  /// No description provided for @name_field.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get name_field;

  /// No description provided for @please_enter_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get please_enter_name;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @select_songs.
  ///
  /// In en, this message translates to:
  /// **'Select Songs:'**
  String get select_songs;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @enter_themes_or_tags.
  ///
  /// In en, this message translates to:
  /// **'Enter themes or tags to get recommendations:'**
  String get enter_themes_or_tags;

  /// No description provided for @by_themes.
  ///
  /// In en, this message translates to:
  /// **'By Themes'**
  String get by_themes;

  /// No description provided for @by_tags.
  ///
  /// In en, this message translates to:
  /// **'By Tags'**
  String get by_tags;

  /// No description provided for @unused.
  ///
  /// In en, this message translates to:
  /// **'Unused'**
  String get unused;

  /// No description provided for @enter_themes_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter themes (comma separated)'**
  String get enter_themes_hint;

  /// No description provided for @enter_tags_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter tags (comma separated)'**
  String get enter_tags_hint;

  /// No description provided for @example_themes.
  ///
  /// In en, this message translates to:
  /// **'e.g., christian, hope, worship'**
  String get example_themes;

  /// No description provided for @example_tags.
  ///
  /// In en, this message translates to:
  /// **'e.g., grace, redemption, faith'**
  String get example_tags;

  /// No description provided for @get_recommendations.
  ///
  /// In en, this message translates to:
  /// **'Get Recommendations'**
  String get get_recommendations;

  /// No description provided for @enter_recommendations_prompt.
  ///
  /// In en, this message translates to:
  /// **'Enter themes or tags to get song recommendations'**
  String get enter_recommendations_prompt;

  /// No description provided for @recommendations_info.
  ///
  /// In en, this message translates to:
  /// **'Recommendations will prioritize less frequently used songs'**
  String get recommendations_info;

  /// No description provided for @songs_app_title.
  ///
  /// In en, this message translates to:
  /// **'Songs app'**
  String get songs_app_title;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @songs_count.
  ///
  /// In en, this message translates to:
  /// **'{count} songs'**
  String songs_count(Object count);

  /// No description provided for @top_songs_by_usage.
  ///
  /// In en, this message translates to:
  /// **'Top Songs by Usage'**
  String get top_songs_by_usage;

  /// No description provided for @usage_over_time.
  ///
  /// In en, this message translates to:
  /// **'Usage Over Time'**
  String get usage_over_time;

  /// No description provided for @usage_by_meeting_type.
  ///
  /// In en, this message translates to:
  /// **'Usage by Meeting Type'**
  String get usage_by_meeting_type;

  /// No description provided for @total_usages.
  ///
  /// In en, this message translates to:
  /// **'Total Usages'**
  String get total_usages;

  /// No description provided for @unique_songs.
  ///
  /// In en, this message translates to:
  /// **'Unique Songs'**
  String get unique_songs;

  /// No description provided for @active_days.
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get active_days;

  /// No description provided for @times_used.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String times_used(Object count);

  /// No description provided for @songs_spoken.
  ///
  /// In en, this message translates to:
  /// **'Speto {date}'**
  String songs_spoken(Object date);

  /// No description provided for @song_added_to_stats.
  ///
  /// In en, this message translates to:
  /// **'Song added to statistics'**
  String get song_added_to_stats;

  /// No description provided for @default_meeting_type.
  ///
  /// In en, this message translates to:
  /// **'Default meeting type'**
  String get default_meeting_type;

  /// No description provided for @theme_settings.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme_settings;

  /// No description provided for @system_theme.
  ///
  /// In en, this message translates to:
  /// **'System theme'**
  String get system_theme;

  /// No description provided for @light_theme.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get light_theme;

  /// No description provided for @dark_theme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get dark_theme;

  /// No description provided for @font_size.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get font_size;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @theme_option.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme_option;

  /// No description provided for @font_size_option.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get font_size_option;

  /// No description provided for @meeting_type_option.
  ///
  /// In en, this message translates to:
  /// **'Default Meeting Type'**
  String get meeting_type_option;

  /// No description provided for @language_option.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language_option;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @record_song_usage.
  ///
  /// In en, this message translates to:
  /// **'Record Song Usage'**
  String get record_song_usage;

  /// No description provided for @date_label.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date_label;

  /// No description provided for @meeting_type_label.
  ///
  /// In en, this message translates to:
  /// **'Meeting Type'**
  String get meeting_type_label;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @manage_meeting_types.
  ///
  /// In en, this message translates to:
  /// **'Manage Meeting Types'**
  String get manage_meeting_types;

  /// No description provided for @add_meeting_type.
  ///
  /// In en, this message translates to:
  /// **'Add Meeting Type'**
  String get add_meeting_type;

  /// No description provided for @enter_meeting_type_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter meeting type'**
  String get enter_meeting_type_hint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
