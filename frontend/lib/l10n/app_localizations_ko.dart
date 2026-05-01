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
  String get profileShoppingList => '쇼핑 리스트';

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

  @override
  String get tabExplore => '탐색';

  @override
  String get scanFood => '음식 스캔';

  @override
  String get scanCalories => '칼로리 스캔';

  @override
  String get takePhoto => '사진 찍기';

  @override
  String get chooseFromGallery => '갤러리에서 선택';

  @override
  String get analyzeCalories => '칼로리 분석';

  @override
  String get caloriesPerServing => 'kcal/인분';

  @override
  String get totalCalories => 'kcal 합계';

  @override
  String get creatorProfile => '크리에이터 프로필';

  @override
  String get follow => '팔로우';

  @override
  String get following => '팔로잉';

  @override
  String get nutritionTracker => '영양 추적기';

  @override
  String get reels => '릴스';

  @override
  String get community => '커뮤니티';

  @override
  String get hasRecipe => '레시피 있음';

  @override
  String get noReelsYet => '아직 릴스가 없습니다';

  @override
  String get settings => '설정';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsTheme => '테마';

  @override
  String get aboutApp => 'iFridge 정보';

  @override
  String get myFridge => '🧊 내 냉장고';

  @override
  String get expiryAlerts => '만료 알림';

  @override
  String get errorLoadInventory => '인벤토리를 로드할 수 없습니다.';

  @override
  String get errorCheckConnection => '연결을 확인하고 다시 시도하세요.';

  @override
  String get total => '총';

  @override
  String get fresh => '신선한';

  @override
  String get expiring => '만료 예정';

  @override
  String get expired => '만료됨';

  @override
  String get searchIngredients => '성분 검색...';

  @override
  String get all => '모두';

  @override
  String itemsCount(int count) {
    return '$count개 항목';
  }

  @override
  String zoneEmptyTitle(String zone) {
    return '$zone가 비어 있습니다';
  }

  @override
  String get zoneEmptyDesc =>
      '디지털 주방을 가득 채울 준비가 되었습니다.\n수동으로 항목을 추가하거나 스캔을 탭하세요.';

  @override
  String get addIngredient => '성분 추가';

  @override
  String get urgentCook => '지금 요리하세요';

  @override
  String urgentUse(String ingredient) {
    return '$ingredient 사용';
  }

  @override
  String get noItemsMatch => '필터와 일치하는 항목이 없습니다.';

  @override
  String get clearFilters => '필터 지우기';

  @override
  String get expiryAlertsTitle => '🔔 만료 알림';

  @override
  String get allFresh => '모든 항목이 신선합니다! 🎉';

  @override
  String expiredCount(int count) {
    return '❌ 만료됨( $count )';
  }

  @override
  String expiringSoonCount(int count) {
    return '⚠️ 곧 만료됨( $count )';
  }

  @override
  String get auto_scanCaloriesIsComingSoon => '스캔 칼로리가 곧 출시됩니다!';

  @override
  String get auto_scan => '주사';

  @override
  String get auto_addAll => '모두 추가';

  @override
  String get auto_allAdded => '모두 추가됨';

  @override
  String get auto_scanAnother => '다른 스캔';

  @override
  String get auto_startVisualAudit => '시각적 감사 시작';

  @override
  String get auto_enterBarcode => '바코드 입력';

  @override
  String get auto_cancel => '취소';

  @override
  String get auto_lookUp => '찾다';

  @override
  String get auto_fridge => '냉장고';

  @override
  String get auto_freezer => '냉동고';

  @override
  String get auto_pantry => '팬트리';

  @override
  String get auto_addToShelf => '선반에 추가';

  @override
  String get auto_mealLogged => '✅ 식사 기록!';

  @override
  String get auto_snapYourMeal => '식사를 스냅하세요';

  @override
  String get auto_takeAPhotoAndAiWillEstimateCalories =>
      '사진을 찍으면 AI가 칼로리를 추정합니다.';

  @override
  String get auto_analyzingFood => '음식을 분석하는 중...';

  @override
  String get auto_camera => '카메라';

  @override
  String get auto_gallery => '갱도';

  @override
  String get auto_estimatedCalories => '예상 칼로리';

  @override
  String get auto_cal => '칼';

  @override
  String get auto_logMeal => '식사 기록';

  @override
  String get auto_addSomeIngredientsToYourShelfFirst =>
      '먼저 선반에 몇 가지 재료를 추가하세요!';

  @override
  String get auto_aiRecipeGenerator => 'AI 레시피 생성기';

  @override
  String get auto_any => '어느';

  @override
  String get auto_shelfOnly => '선반만';

  @override
  String get auto_generateRecipe => '레시피 생성';

  @override
  String get auto_ingredients => '🧂 재료';

  @override
  String get auto_steps => '👨‍🍳 단계';

  @override
  String get auto_importRecipe => '레시피 가져오기';

  @override
  String get auto_retry => '다시 해 보다';

  @override
  String get auto_addItemsToYourShelfToGetRecommendations =>
      '추천을 받으려면 서가에 항목을 추가하세요.';

  @override
  String get auto_noRecipesMatchThisCuisine => '이 요리와 일치하는 레시피가 없습니다.';

  @override
  String get auto_clearFilter => '필터 지우기';

  @override
  String get auto_deleteItem => '항목을 삭제하시겠습니까?';

  @override
  String get auto_delete => '삭제';

  @override
  String get auto_freshness => '선도';

  @override
  String get auto_use1Unit => '1개 사용';

  @override
  String get auto_removeFromInventory => '인벤토리에서 제거';

  @override
  String get auto_following => '수행원';

  @override
  String get auto_follow => '따르다';

  @override
  String get auto_posts => '게시물';

  @override
  String get auto_noPostsYet => '아직 게시물이 없습니다';

  @override
  String get auto_explore => '탐구하다';

  @override
  String get auto_noReelsYet => '아직 릴이 없습니다.';

  @override
  String get auto_cookThisRecipe => '이 조리법을 요리';

  @override
  String get auto_recipeNotFound => '레시피를 찾을 수 없습니다';

  @override
  String get auto_hasRecipe => '레시피 있음';

  @override
  String get auto_noCommunityPostsYet => '아직 커뮤니티 게시물이 없습니다.';

  @override
  String get auto_beTheFirstToShare => '가장 먼저 공유해 보세요!';

  @override
  String get auto_createPost => '게시물 작성';

  @override
  String get auto_savedPosts => '저장된 게시물';

  @override
  String get auto_noSavedPostsYet => '아직 저장된 게시물이 없습니다.';

  @override
  String get auto_you => '너';

  @override
  String get auto_checkout => '점검';

  @override
  String get auto_yourCartIsEmpty => '장바구니가 비어 있습니다.';

  @override
  String get auto_yourOrder => '귀하의 주문';

  @override
  String get auto_total => '총';

  @override
  String get auto_orderConfirmed => '주문이 확인되었습니다!';

  @override
  String get auto_yourPickupCode => '픽업 코드';

  @override
  String get auto_showThisCodeAtTheCounter => '카운터에서 이 코드를 제시하세요';

  @override
  String get auto_deliveryOnTheWay => '배송 중';

  @override
  String get auto_aDriverWillBeAssignedShortly => '곧 운전기사가 배정될 예정입니다.';

  @override
  String get auto_backToHome => '홈으로 돌아가기';

  @override
  String get auto_incomingOrders => '들어오는 주문';

  @override
  String get auto_noFoodVideosYet => '아직 음식 동영상이 없습니다.';

  @override
  String get auto_foodFeed => '식품 사료';

  @override
  String get auto_myOrders => '내 주문';

  @override
  String get auto_noOrdersYet => '아직 주문이 없습니다';

  @override
  String get auto_yourOrderHistoryWillAppearHere => '주문 내역이 여기에 표시됩니다';

  @override
  String get auto_cancelOrder => '주문을 취소하시겠습니까?';

  @override
  String get auto_keepOrder => '질서 유지';

  @override
  String get auto_orderCancelled => '주문이 취소됨';

  @override
  String get auto_pickupCode => '픽업 코드:';

  @override
  String get auto_closed => '닫은';

  @override
  String get auto_menu => '메뉴';

  @override
  String get auto_menuComingSoon => '곧 나올 메뉴';

  @override
  String get auto_best => '🔥 최고';

  @override
  String get auto_popularDishes => '🍽️ 인기 요리';

  @override
  String get auto_fromVideo => '비디오에서';

  @override
  String get auto_bookATable => '테이블 예약';

  @override
  String get auto_confirmReservation => '예약 확인';

  @override
  String get auto_locationDirections => '위치 및 오시는 길';

  @override
  String get auto_mapView => '지도 보기';

  @override
  String get auto_openInGoogleMaps => 'Google 지도에서 열기';

  @override
  String get auto_writeAReview => '리뷰 작성';

  @override
  String get auto_viewCart => '장바구니 보기';

  @override
  String get auto_signOut => '로그아웃하시겠습니까?';

  @override
  String get auto_youWillNeedToSignInAgain => '다시 로그인해야 합니다.';

  @override
  String get auto_deleteAccount => '계정 삭제';

  @override
  String get auto_deleteForever => '영원히 삭제';

  @override
  String get auto_accountDeletionRequestedContactSupportToFinalize =>
      '계정 삭제를 요청했습니다. 마무리하려면 지원팀에 문의하세요.';

  @override
  String get auto_ifridge => '아이냉장고';

  @override
  String
  get auto_ifridgeIsYourAipoweredKitchenEcosystemItAutomaticallyTracksYourIngredientsPredictsExpirationsGeneratesPersonalizedRecipesAndLetsYouOrderFromLocalRestaurants =>
      'iFridge는 AI 기반 주방 생태계입니다. 자동으로 재료를 추적하고, 유통기한을 예측하고, 맞춤형 레시피를 생성하고, 현지 레스토랑에서 주문할 수 있습니다.';

  @override
  String get auto_gotIt => '알았어요';

  @override
  String get auto_editDisplayName => '표시 이름 편집';

  @override
  String get auto_save => '구하다';

  @override
  String get auto_addShoppingItem => '쇼핑 아이템 추가';

  @override
  String get auto_add => '추가하다';

  @override
  String get auto_selectRecipeForMeal => '식사 레시피 선택';

  @override
  String get auto_failedToLoadRecipes => '레시피를 로드하지 못했습니다.';

  @override
  String get auto_noRecipesFound => '레시피를 찾을 수 없습니다.';

  @override
  String get auto_mealCleared => '식사 클리어';

  @override
  String get auto_theme => '🎨 테마';

  @override
  String get whatToCook => '무엇을 요리할까요?';

  @override
  String get tierPerfect => '완벽';

  @override
  String get tierForYou => '추천';

  @override
  String get tierUseItUp => '빨리 소비';

  @override
  String get tierAlmost => '거의 비슷';

  @override
  String get tierExplore => '탐색';

  @override
  String noTierRecipesYet(String tier) {
    return '$tier 레시피가 아직 없습니다';
  }

  @override
  String get addItemsForRecommendations => '선반에 재료를 추가하여 추천을 받으세요';

  @override
  String get scanCaloriesTab => '칼로리 스캔';

  @override
  String get scanYourIngredients => '재료를 스캔하세요';

  @override
  String get takePhotoToAdd => '음식 사진을 찍어 선반에 자동으로 추가하세요';

  @override
  String get scanReceipt => '영수증';

  @override
  String get scanPhoto => '사진';

  @override
  String get scanBarcode => '바코드 스캔';

  @override
  String get takePhotoBtn => '사진 찍기';

  @override
  String get adjustPortions => '부분 조정';

  @override
  String currentRecipeMakesNServings(String servings) {
    return '현재 레시피는 $servings인분입니다.';
  }

  @override
  String scaleToNServings(String newServings) {
    return '$newServings회 제공량으로 확장';
  }

  @override
  String scaledToNServings(String newServings) {
    return '$newServings인분으로 확장되었습니다 🍳';
  }

  @override
  String findingSubstitutesForX(String ingredientName) {
    return '$ingredientName의 대체품을 찾는 중...';
  }

  @override
  String get couldNotFindSubstitutes => '대체품을 찾을 수 없습니다.';

  @override
  String substitutesForX(String ingredientName) {
    return '\"$ingredientName\"를 대체합니다.';
  }

  @override
  String get noSubstitutesFoundForThisRecipeContext =>
      '이 레시피 컨텍스트에 대한 대체 항목을 찾을 수 없습니다.';

  @override
  String nMatch(String match) {
    return '$match% 일치';
  }

  @override
  String ingredientsWithCount(String count) {
    return '성분($count)';
  }

  @override
  String get scale => '규모';

  @override
  String get addedMissingItemsToShoppingList => '쇼핑 목록에 누락된 품목을 추가했습니다!';

  @override
  String failedToAddItemsX(String e) {
    return '항목 추가 실패: $e';
  }

  @override
  String get addMissingToShoppingList => '쇼핑 목록에 누락된 항목 추가';

  @override
  String cookingStepsWithCount(String count) {
    return '요리 단계($count)';
  }

  @override
  String get noStepsAvailableYet => '아직 사용 가능한 단계가 없습니다.';

  @override
  String get recordedTasteProfileEvolving =>
      '녹음되었습니다! 당신의 취향 프로필이 진화하고 있습니다 🧠';

  @override
  String failedToRecordX(String e) {
    return '기록 실패: $e';
  }

  @override
  String get iCookedThis => '내가 이걸 요리했어!';

  @override
  String get startCooking => '요리 시작';

  @override
  String get optional_tag => '선택 과목';

  @override
  String get servings_tag => '인분';

  @override
  String get min_tag => '분';

  @override
  String get difficulty_tag => '어려움';

  @override
  String get expiringSoon => '곧 만료됨';

  @override
  String nItemsNeedAttention(String count) {
    return '$count개 항목에 주의가 필요합니다.';
  }

  @override
  String get takeAPhotoOfFoodItems => '추가하려면 음식 사진을 찍으세요.\n자동으로 선반에';

  @override
  String get addManually => '수동으로 추가';

  @override
  String get recognitionFailed => '인식에 실패했습니다. 다시 시도해 보세요.';

  @override
  String get analyzingYourFood => '음식을 분석하는 중...';

  @override
  String get aiIsIdentifying => 'AI가 성분을 식별하고 있다';

  @override
  String nItemsDetected(String count) {
    return '$count개 항목이 감지되었습니다.';
  }

  @override
  String get photoAnalysisSelected => '사진 분석 선택';

  @override
  String nIngredientsDetected(String count) {
    return '$count 성분이 감지되었습니다';
  }

  @override
  String nOfNAdded(String added, String total) {
    return '$added / $total 추가됨';
  }

  @override
  String addedItem(String item) {
    return '$item를 추가했습니다!';
  }

  @override
  String failedToAddItem(String item) {
    return '$item를 추가하지 못했습니다.';
  }

  @override
  String addedNItemsToShelf(String count) {
    return '$count 항목을 선반에 추가했습니다!';
  }

  @override
  String noProductFoundForBarcode(String barcode) {
    return '바코드 $barcode에 해당하는 제품을 찾을 수 없습니다.';
  }

  @override
  String addedItemToShelf(String item) {
    return '선반에 $item를 추가했습니다!';
  }

  @override
  String errorX(String e) {
    return '오류: $e';
  }

  @override
  String analysisFailedX(String e) {
    return '분석 실패: $e';
  }

  @override
  String failedToLogX(String e) {
    return '로그 실패: $e';
  }

  @override
  String get scanBarcodeShort => '바코드';

  @override
  String get profileAccount => '계정';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get tierBadge1 => '✅ Everything you need!';

  @override
  String get tierBadge2 => '🔥 Recommended for you';

  @override
  String get tierBadge3 => '⏰ Use expiring items';

  @override
  String get tierBadge4 => '🛒 Just a few items away';

  @override
  String get tierBadge5 => '🌍 Discover something new';

  @override
  String needLabel(String items) {
    return 'Need: $items';
  }

  @override
  String nOfNIngredients(String matched, String total) {
    return '$matched/$total ingredients';
  }

  @override
  String get servingsLabel => 'Servings';

  @override
  String nHave(String count) {
    return '$count have';
  }

  @override
  String nMissing(String count) {
    return '$count missing';
  }

  @override
  String get ingredientsHeader => 'Ingredients';

  @override
  String get swapButton => 'Swap →';

  @override
  String get aiAssistant => '🤖 AI Assistant';

  @override
  String get aiHint => 'e.g. \"I don\'t have lamb, suggest alternatives\"';

  @override
  String get editIngredient => 'Edit Ingredient';

  @override
  String get nameLabel => 'Name';

  @override
  String get qtyLabel => 'Qty';

  @override
  String get unitLabel => 'Unit';

  @override
  String get handsOn => 'Hands-on';

  @override
  String get automatic => 'Automatic';
}
