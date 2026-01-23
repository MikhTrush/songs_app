// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get helloWorld => 'Привет, мир!';

  @override
  String get search => 'Поиск';

  @override
  String get home => 'Главная';

  @override
  String get songs_app => 'Приложение для песен';

  @override
  String get collections => 'Коллекции';

  @override
  String get settings => 'Настройки';

  @override
  String get statistics => 'Статистика';

  @override
  String get search_songs => 'Поиск песен...';

  @override
  String get statistics_coming_soon => 'Страница статистики скоро появится';

  @override
  String get confirm_delete => 'Подтвердите удаление';

  @override
  String are_you_sure_delete(Object name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get no_collections_yet =>
      'Пока нет ни одной коллекции. Нажмите кнопку +, чтобы создать одну.';

  @override
  String get no_songs_in_collection => 'В этой коллекции нет песен';

  @override
  String error_occurred(Object error) {
    return 'Ошибка: $error';
  }

  @override
  String get edit_collection => 'Редактировать коллекцию';

  @override
  String get create_collection => 'Создать коллекцию';

  @override
  String get name_field => 'Название *';

  @override
  String get please_enter_name => 'Пожалуйста, введите название';

  @override
  String get description => 'Описание';

  @override
  String get select_songs => 'Выберите песни:';

  @override
  String get update => 'Обновить';

  @override
  String get create => 'Создать';

  @override
  String get recommendations => 'Рекомендации';

  @override
  String get enter_themes_or_tags =>
      'Введите темы или теги, чтобы получить рекомендации:';

  @override
  String get by_themes => 'По темам';

  @override
  String get by_tags => 'По тегам';

  @override
  String get unused => 'Неиспользованные';

  @override
  String get enter_themes_hint => 'Введите темы (через запятую)';

  @override
  String get enter_tags_hint => 'Введите теги (через запятую)';

  @override
  String get example_themes => 'например: христианские, надежда, поклонение';

  @override
  String get example_tags => 'например: благодать, искупление, вера';

  @override
  String get get_recommendations => 'Получить рекомендации';

  @override
  String get enter_recommendations_prompt =>
      'Введите темы или теги, чтобы получить рекомендации песен';

  @override
  String get recommendations_info =>
      'Рекомендации будут отдавать приоритет редко используемым песням';

  @override
  String get songs_app_title => 'Песни';

  @override
  String get menu => 'Меню';

  @override
  String songs_count(Object count) {
    return 'Песен: $count';
  }

  @override
  String get top_songs_by_usage => 'Топ песен по использованию';

  @override
  String get usage_over_time => 'Использование за время';

  @override
  String get usage_by_meeting_type => 'Использование по типу встречи';

  @override
  String get total_usages => 'Всего использований';

  @override
  String get unique_songs => 'Уникальные песни';

  @override
  String get active_days => 'Активных дней';

  @override
  String times_used(Object count) {
    return '$count раз(а)';
  }

  @override
  String songs_spoken(Object date) {
    return 'Спето $date';
  }

  @override
  String get song_added_to_stats => 'Песня добавлена в статистику';

  @override
  String get default_meeting_type => 'Тип встречи по умолчанию';

  @override
  String get theme_settings => 'Тема';

  @override
  String get system_theme => 'Как в системе';

  @override
  String get light_theme => 'Светлая тема';

  @override
  String get dark_theme => 'Темная тема';

  @override
  String get font_size => 'Размер шрифта';

  @override
  String get settings_title => 'Настройки';

  @override
  String get theme_option => 'Тема';

  @override
  String get font_size_option => 'Размер шрифта';

  @override
  String get meeting_type_option => 'Тип встречи по умолчанию';

  @override
  String get language_option => 'Язык';

  @override
  String get color => 'Цвет';

  @override
  String get record_song_usage => 'Записать использование песни';

  @override
  String get date_label => 'Дата';

  @override
  String get meeting_type_label => 'Тип встречи';

  @override
  String get record => 'Записать';

  @override
  String get manage_meeting_types => 'Управление типами встреч';

  @override
  String get enter_meeting_type_hint => 'Введите тип встречи';

  @override
  String get add_meeting_type => 'Добавить тип встречи';

  @override
  String get add => 'Добавить';

  @override
  String get save => 'Сохранить';

  @override
  String get remove_meeting_type => 'Удалить тип встречи?';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get no_collection => 'Песни без коллекции';

  @override
  String get no_collection_desc =>
      'Все песни, которые не являются частью какой-либо коллекции';

  @override
  String get edit_song => 'Редактировать песню';

  @override
  String get delete_song => 'Удалить песню';

  @override
  String get remove_from_collection => 'Удалить из коллекции';

  @override
  String get confirm_remove => 'Подтвердить удаление';

  @override
  String confirm_remove_from_collection(
    Object collectionName,
    Object songTitle,
  ) {
    return 'Удалить \"$songTitle\" из \"$collectionName\"?';
  }

  @override
  String confirm_delete_song(Object songTitle) {
    return 'Вы уверены, что хотите удалить \"$songTitle\"?';
  }

  @override
  String get remove => 'Удалить';

  @override
  String get add_song => 'Добавить новую песню';

  @override
  String get create_song => 'Создать песню';

  @override
  String get title => 'Название';

  @override
  String get verses => 'Куплеты';

  @override
  String get categories => 'Категории';

  @override
  String get tags => 'Теги';

  @override
  String get themes => 'Темы';

  @override
  String get please_enter_title => 'Пожалуйста, введите название';

  @override
  String get recently_used_songs => 'Недавно использованные песни';

  @override
  String get recently_used_list_desc =>
      'Список песен, использованных на последних сессиях';
}
