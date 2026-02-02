// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello, world!';

  @override
  String get search => 'Search';

  @override
  String get home => 'Home';

  @override
  String get songs_app => 'Songs App';

  @override
  String get collections => 'Collections';

  @override
  String get settings => 'Settings';

  @override
  String get statistics => 'Statistics';

  @override
  String get search_songs => 'Search songs...';

  @override
  String get statistics_coming_soon => 'Statistics page coming soon';

  @override
  String get confirm_delete => 'Confirm Delete';

  @override
  String are_you_sure_delete(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get no_collections_yet =>
      'No collections yet. Tap the + button to create one.';

  @override
  String get no_songs_in_collection => 'No songs in this collection';

  @override
  String error_occurred(Object error) {
    return 'Error: $error';
  }

  @override
  String get edit_collection => 'Edit Collection';

  @override
  String get create_collection => 'Create Collection';

  @override
  String get name_field => 'Name *';

  @override
  String get please_enter_name => 'Please enter a name';

  @override
  String get description => 'Description';

  @override
  String get select_songs => 'Select Songs:';

  @override
  String get update => 'Update';

  @override
  String get create => 'Create';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get enter_themes_or_tags =>
      'Enter themes or tags to get recommendations:';

  @override
  String get by_themes => 'By Themes';

  @override
  String get by_tags => 'By Tags';

  @override
  String get unused => 'Unused';

  @override
  String get enter_themes_hint => 'Enter themes (comma separated)';

  @override
  String get enter_tags_hint => 'Enter tags (comma separated)';

  @override
  String get example_themes => 'e.g., christian, hope, worship';

  @override
  String get example_tags => 'e.g., grace, redemption, faith';

  @override
  String get get_recommendations => 'Get Recommendations';

  @override
  String get enter_recommendations_prompt =>
      'Enter themes or tags to get song recommendations';

  @override
  String get recommendations_info =>
      'Recommendations will prioritize less frequently used songs';

  @override
  String get songs_app_title => 'Songs app';

  @override
  String get menu => 'Menu';

  @override
  String songs_count(Object count) {
    return '$count songs';
  }

  @override
  String get top_songs_by_usage => 'Top Songs by Usage';

  @override
  String get usage_over_time => 'Usage Over Time';

  @override
  String get usage_by_meeting_type => 'Usage by Meeting Type';

  @override
  String get total_usages => 'Total Usages';

  @override
  String get unique_songs => 'Unique Songs';

  @override
  String get active_days => 'Active Days';

  @override
  String times_used(Object count) {
    return '$count times';
  }

  @override
  String songs_spoken(Object date) {
    return 'Speto $date';
  }

  @override
  String get song_added_to_stats => 'Song added to statistics';

  @override
  String get default_meeting_type => 'Default meeting type';

  @override
  String get theme_settings => 'Theme';

  @override
  String get system_theme => 'System theme';

  @override
  String get light_theme => 'Light theme';

  @override
  String get dark_theme => 'Dark theme';

  @override
  String get font_size => 'Font size';

  @override
  String get settings_title => 'Settings';

  @override
  String get theme_option => 'Theme';

  @override
  String get font_size_option => 'Font Size';

  @override
  String get meeting_type_option => 'Default Meeting Type';

  @override
  String get language_option => 'Language';

  @override
  String get color => 'Color';

  @override
  String get record_song_usage => 'Record Song Usage';

  @override
  String get date_label => 'Date';

  @override
  String get meeting_type_label => 'Meeting Type';

  @override
  String get record => 'Record';

  @override
  String get manage_meeting_types => 'Manage Meeting Types';

  @override
  String get enter_meeting_type_hint => 'Enter meeting type';

  @override
  String get add_meeting_type => 'Add Meeting Type';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get remove_meeting_type => 'Remove meeting type?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get no_collection => 'Songs without collection';

  @override
  String get no_collection_desc =>
      'All songs that are not part of any collection';

  @override
  String get edit_song => 'Edit Song';

  @override
  String get delete_song => 'Delete Song';

  @override
  String get remove_from_collection => 'Remove from Collection';

  @override
  String get confirm_remove => 'Confirm Remove';

  @override
  String confirm_remove_from_collection(
    Object collectionName,
    Object songTitle,
  ) {
    return 'Remove \"$songTitle\" from \"$collectionName\"?';
  }

  @override
  String confirm_delete_song(Object songTitle) {
    return 'Are you sure you want to delete \"$songTitle\"?';
  }

  @override
  String get remove => 'Remove';

  @override
  String get add_song => 'Add New Song';

  @override
  String get create_song => 'Create Song';

  @override
  String get title => 'Title';

  @override
  String get verses => 'Verses';

  @override
  String get categories => 'Categories';

  @override
  String get tags => 'Tags';

  @override
  String get themes => 'Themes';

  @override
  String get please_enter_title => 'Please enter a title';

  @override
  String get recently_used_songs => 'Recently Used Songs';

  @override
  String get recently_used_list_desc =>
      'List of songs used in the last sessions';

  @override
  String get no_data_available => 'No data available';

  @override
  String get see_all => 'See All';

  @override
  String get app_info => 'App Info';

  @override
  String get starting_chorus => 'Starting chorus';

  @override
  String get verse => 'Verse';

  @override
  String get chorus => 'Chorus';

  @override
  String get ending_chorus => 'Ending chorus';
}
