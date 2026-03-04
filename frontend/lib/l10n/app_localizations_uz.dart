// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'iFridge';

  @override
  String get tabShelf => 'Javon';

  @override
  String get tabCook => 'Pishirish';

  @override
  String get tabScan => 'Skanerlash';

  @override
  String get tabProfile => 'Profil';

  @override
  String get profileTitle => 'Profil';

  @override
  String profileGamificationLevel(int level) {
    return '$level-daraja';
  }

  @override
  String get profileMealsCooked => 'Pishirilgan taomlar';

  @override
  String get profileItemsSaved => 'Saqlangan mahsulotlar';

  @override
  String get profileDayStreak => 'Kunlik seriya';

  @override
  String get profileFlavorProfile => 'Ta\'m profili';

  @override
  String get profileBadges => 'Nishonlar va yutuqlar';

  @override
  String get profileShoppingList => 'Xaridlar ro\'yxati';

  @override
  String get profileMealPlanner => 'Ovqatlanish rejasi';

  @override
  String get actionAdd => 'Qo\'shish';

  @override
  String get actionCancel => 'Bekor qilish';

  @override
  String get actionSave => 'Saqlash';

  @override
  String get actionDelete => 'O\'chirish';

  @override
  String get profileLoadError => 'Profilni yuklab bo\'lmadi';

  @override
  String get retry => 'Qayta urinish';

  @override
  String get refresh => 'Yangilash';

  @override
  String get signOut => 'Chiqish';

  @override
  String get profileLevelProgress => 'Daraja jarayoni';

  @override
  String profileLevel(int level) {
    return '$level-daraja';
  }

  @override
  String get profileYourImpact => 'Sizning ta\'siringiz';

  @override
  String get addShoppingItem => 'Element qo\'shish';

  @override
  String get shoppingListEmpty => 'Xaridlar ro\'yxati bo\'sh';

  @override
  String get mealPlannerEmpty => 'Rejalashtirilgan taomlar yo\'q';

  @override
  String get planToday => 'Bugungi reja';

  @override
  String get today => 'Bugun';

  @override
  String get planMeal => 'Taom rejalashtirish...';

  @override
  String get tabExplore => 'Kashfiyot';

  @override
  String get scanFood => 'Taom skanerlash';

  @override
  String get scanCalories => 'Kaloriya skanerlash';

  @override
  String get takePhoto => 'Rasm olish';

  @override
  String get chooseFromGallery => 'Galereyadan tanlash';

  @override
  String get analyzeCalories => 'Kaloriyalarni tahlil qilish';

  @override
  String get caloriesPerServing => 'kal/porsiya';

  @override
  String get totalCalories => 'jami kal';

  @override
  String get creatorProfile => 'Muallif profili';

  @override
  String get follow => 'Kuzatish';

  @override
  String get following => 'Kuzatilmoqda';

  @override
  String get nutritionTracker => 'Ovqatlanish kuzatuvi';

  @override
  String get reels => 'Rillar';

  @override
  String get community => 'Jamoa';

  @override
  String get hasRecipe => 'Retsept bor';

  @override
  String get noReelsYet => 'Hozircha rillar yo\'q';

  @override
  String get settings => 'Sozlamalar';
}
