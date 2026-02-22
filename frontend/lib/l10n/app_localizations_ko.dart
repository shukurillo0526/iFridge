// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'iFridge (냉장고)';

  @override
  String get tabShelf => '내 냉장고';

  @override
  String get tabCook => '요리';

  @override
  String get tabScan => '스캔';

  @override
  String get tabProfile => '프로필';

  @override
  String get profileTitle => '프로필';

  @override
  String profileGamificationLevel(int level) {
    return '레벨 $level';
  }

  @override
  String get profileMealsCooked => '요리한 횟수';

  @override
  String get profileItemsSaved => '절약한 식재료';

  @override
  String get profileDayStreak => '연속 달성';

  @override
  String get profileFlavorProfile => '나의 입맛 프로필';

  @override
  String get profileBadges => '배지 및 업적';

  @override
  String get profileShoppingList => '장바구니';

  @override
  String get profileMealPlanner => '식단 플래너';

  @override
  String get actionAdd => '추가';

  @override
  String get actionCancel => '취소';

  @override
  String get actionSave => '저장';

  @override
  String get actionDelete => '삭제';

  @override
  String get profileLoadError => '프로필을 불러올 수 없습니다';

  @override
  String get retry => '다시 시도';

  @override
  String get refresh => '새로고침';

  @override
  String get signOut => '로그아웃';

  @override
  String get profileLevelProgress => '레벨 진행도';

  @override
  String profileLevel(int level) {
    return '레벨 $level';
  }

  @override
  String get profileYourImpact => '나의 영향력';

  @override
  String get addShoppingItem => '아이템 추가';

  @override
  String get shoppingListEmpty => '쇼핑 리스트가 비어 있습니다';

  @override
  String get mealPlannerEmpty => '예정된 식사가 없습니다';

  @override
  String get planToday => '오늘 식사 계획하기';

  @override
  String get today => '오늘';

  @override
  String get planMeal => '식사 계획...';
}
