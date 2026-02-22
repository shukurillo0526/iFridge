// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'iFridge';

  @override
  String get tabShelf => 'Shelf';

  @override
  String get tabCook => 'Cook';

  @override
  String get tabScan => 'Scan';

  @override
  String get tabProfile => 'Profile';

  @override
  String get profileTitle => 'Profile';

  @override
  String profileGamificationLevel(int level) {
    return 'Level $level';
  }

  @override
  String get profileMealsCooked => 'Meals Cooked';

  @override
  String get profileItemsSaved => 'Items Saved';

  @override
  String get profileDayStreak => 'Day Streak';

  @override
  String get profileFlavorProfile => 'Flavor Profile';

  @override
  String get profileBadges => 'Badges & Achievements';

  @override
  String get profileShoppingList => 'Shopping List';

  @override
  String get profileMealPlanner => 'Meal Planner';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get profileLoadError => 'Couldn\'t load profile';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get signOut => 'Sign Out';

  @override
  String get profileLevelProgress => 'Level Progress';

  @override
  String profileLevel(int level) {
    return 'Level $level';
  }

  @override
  String get profileYourImpact => 'Your Impact';

  @override
  String get addShoppingItem => 'Add Item';

  @override
  String get shoppingListEmpty => 'Your shopping list is empty';

  @override
  String get mealPlannerEmpty => 'No meals planned';

  @override
  String get planToday => 'Plan Today';

  @override
  String get today => 'Today';

  @override
  String get planMeal => 'Plan meal...';
}
