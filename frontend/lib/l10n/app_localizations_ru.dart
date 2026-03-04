// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'iFridge';

  @override
  String get tabShelf => 'Полка';

  @override
  String get tabCook => 'Готовить';

  @override
  String get tabScan => 'Сканер';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get profileTitle => 'Профиль';

  @override
  String profileGamificationLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String get profileMealsCooked => 'Приготовлено блюд';

  @override
  String get profileItemsSaved => 'Сохранено продуктов';

  @override
  String get profileDayStreak => 'Дней подряд';

  @override
  String get profileFlavorProfile => 'Вкусовой профиль';

  @override
  String get profileBadges => 'Значки и достижения';

  @override
  String get profileShoppingList => 'Список покупок';

  @override
  String get profileMealPlanner => 'Планировщик питания';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get profileLoadError => 'Не удалось загрузить профиль';

  @override
  String get retry => 'Повторить';

  @override
  String get refresh => 'Обновить';

  @override
  String get signOut => 'Выйти';

  @override
  String get profileLevelProgress => 'Прогресс уровня';

  @override
  String profileLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String get profileYourImpact => 'Ваш вклад';

  @override
  String get addShoppingItem => 'Добавить';

  @override
  String get shoppingListEmpty => 'Список покупок пуст';

  @override
  String get mealPlannerEmpty => 'Нет запланированных блюд';

  @override
  String get planToday => 'Запланировать';

  @override
  String get today => 'Сегодня';

  @override
  String get planMeal => 'Спланировать...';

  @override
  String get tabExplore => 'Обзор';

  @override
  String get scanFood => 'Сканировать еду';

  @override
  String get scanCalories => 'Сканировать калории';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get chooseFromGallery => 'Выбрать из галереи';

  @override
  String get analyzeCalories => 'Анализ калорий';

  @override
  String get caloriesPerServing => 'ккал/порция';

  @override
  String get totalCalories => 'ккал всего';

  @override
  String get creatorProfile => 'Профиль автора';

  @override
  String get follow => 'Подписаться';

  @override
  String get following => 'Подписан';

  @override
  String get nutritionTracker => 'Трекер питания';

  @override
  String get reels => 'Рилсы';

  @override
  String get community => 'Сообщество';

  @override
  String get hasRecipe => 'Есть рецепт';

  @override
  String get noReelsYet => 'Рилсов пока нет';

  @override
  String get settings => 'Настройки';
}
