// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'iХолодильник';

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
  String get takePhoto => 'Сфотографироваться';

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

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get aboutApp => 'О iFridge';

  @override
  String get myFridge => '🧊 Мой холодильник';

  @override
  String get expiryAlerts => 'Уведомления об истечении срока действия';

  @override
  String get errorLoadInventory => 'Не удалось загрузить инвентарь';

  @override
  String get errorCheckConnection =>
      'Проверьте подключение и повторите попытку.';

  @override
  String get total => 'Общий';

  @override
  String get fresh => 'Свежий';

  @override
  String get expiring => 'Срок действия истекает';

  @override
  String get expired => 'Истекший';

  @override
  String get searchIngredients => 'Поиск ингредиентов...';

  @override
  String get all => 'Все';

  @override
  String itemsCount(int count) {
    return '$count предметов';
  }

  @override
  String zoneEmptyTitle(String zone) {
    return 'Ваш $zone пуст';
  }

  @override
  String get zoneEmptyDesc =>
      'Готовы заполнить вашу цифровую кухню.\nДобавляйте элементы вручную или нажмите «Сканировать».';

  @override
  String get addIngredient => 'Добавить ингредиент';

  @override
  String get urgentCook => 'Готовьте сейчас';

  @override
  String urgentUse(String ingredient) {
    return 'Используйте $ingredient';
  }

  @override
  String get noItemsMatch => 'Нет товаров, соответствующих вашим фильтрам';

  @override
  String get clearFilters => 'Очистить фильтры';

  @override
  String get expiryAlertsTitle => '🔔 Уведомления об истечении срока действия';

  @override
  String get allFresh => 'Все товары свежие! 🎉';

  @override
  String expiredCount(int count) {
    return '❌ Срок действия истек ( $count )';
  }

  @override
  String expiringSoonCount(int count) {
    return '⚠️ Срок действия скоро истекает ( $count )';
  }

  @override
  String get auto_scanCaloriesIsComingSoon =>
      'Сканирование калорий скоро появится!';

  @override
  String get auto_scan => 'Сканировать';

  @override
  String get auto_addAll => 'Добавить все';

  @override
  String get auto_allAdded => 'Все добавлено';

  @override
  String get auto_scanAnother => 'Сканировать другой';

  @override
  String get auto_startVisualAudit => 'Начать визуальный аудит';

  @override
  String get auto_enterBarcode => 'Введите штрих-код';

  @override
  String get auto_cancel => 'Отмена';

  @override
  String get auto_lookUp => 'Искать';

  @override
  String get auto_fridge => 'Холодильник';

  @override
  String get auto_freezer => 'Морозильник';

  @override
  String get auto_pantry => 'Кладовая';

  @override
  String get auto_addToShelf => 'Добавить на полку';

  @override
  String get auto_mealLogged => '✅ Питание зарегистрировано!';

  @override
  String get auto_snapYourMeal => 'Приготовь еду';

  @override
  String get auto_takeAPhotoAndAiWillEstimateCalories =>
      'Сделайте фото, и искусственный интеллект оценит калории.';

  @override
  String get auto_analyzingFood => 'Анализ еды...';

  @override
  String get auto_camera => 'Камера';

  @override
  String get auto_gallery => 'Галерея';

  @override
  String get auto_estimatedCalories => 'расчетные калории';

  @override
  String get auto_cal => 'кал';

  @override
  String get auto_logMeal => 'Бревенчатая еда';

  @override
  String get auto_addSomeIngredientsToYourShelfFirst =>
      'Сначала добавьте несколько ингредиентов на полку!';

  @override
  String get auto_aiRecipeGenerator => 'Генератор рецептов AI';

  @override
  String get auto_any => 'Любой';

  @override
  String get auto_shelfOnly => 'Только полка';

  @override
  String get auto_generateRecipe => 'Создать рецепт';

  @override
  String get auto_ingredients => '🧂 Ингредиенты';

  @override
  String get auto_steps => '👨‍🍳 Шаги';

  @override
  String get auto_importRecipe => 'Импортировать рецепт';

  @override
  String get auto_retry => 'Повторить попытку';

  @override
  String get auto_addItemsToYourShelfToGetRecommendations =>
      'Добавляйте товары на полку, чтобы получать рекомендации.';

  @override
  String get auto_noRecipesMatchThisCuisine =>
      'Нет рецептов, соответствующих этой кухне.';

  @override
  String get auto_clearFilter => 'Очистить фильтр';

  @override
  String get auto_deleteItem => 'Удалить элемент?';

  @override
  String get auto_delete => 'Удалить';

  @override
  String get auto_freshness => 'Свежесть';

  @override
  String get auto_use1Unit => 'Используйте 1 единицу';

  @override
  String get auto_removeFromInventory => 'Удалить из инвентаря';

  @override
  String get auto_following => 'Следующий';

  @override
  String get auto_follow => 'Следовать';

  @override
  String get auto_posts => 'Сообщения';

  @override
  String get auto_noPostsYet => 'Пока нет сообщений';

  @override
  String get auto_explore => 'Исследовать';

  @override
  String get auto_noReelsYet => 'Катушек пока нет';

  @override
  String get auto_cookThisRecipe => 'Приготовьте этот рецепт';

  @override
  String get auto_recipeNotFound => 'Рецепт не найден';

  @override
  String get auto_hasRecipe => 'Есть рецепт';

  @override
  String get auto_noCommunityPostsYet => 'Сообщений в сообществе пока нет.';

  @override
  String get auto_beTheFirstToShare => 'Будьте первым, кто поделитесь!';

  @override
  String get auto_createPost => 'Создать сообщение';

  @override
  String get auto_savedPosts => 'Сохраненные сообщения';

  @override
  String get auto_noSavedPostsYet => 'Пока нет сохраненных сообщений';

  @override
  String get auto_you => 'Ты';

  @override
  String get auto_checkout => 'Проверить';

  @override
  String get auto_yourCartIsEmpty => 'Ваша корзина пуста';

  @override
  String get auto_yourOrder => 'Ваш заказ';

  @override
  String get auto_total => 'Общий';

  @override
  String get auto_orderConfirmed => 'Заказ подтвержден!';

  @override
  String get auto_yourPickupCode => 'Ваш код самовывоза';

  @override
  String get auto_showThisCodeAtTheCounter => 'Покажите этот код на стойке';

  @override
  String get auto_deliveryOnTheWay => 'Доставка в пути';

  @override
  String get auto_aDriverWillBeAssignedShortly =>
      'Водитель будет назначен в ближайшее время';

  @override
  String get auto_backToHome => 'Вернуться домой';

  @override
  String get auto_incomingOrders => 'Входящие заказы';

  @override
  String get auto_noFoodVideosYet => 'Видео о еде пока нет';

  @override
  String get auto_foodFeed => 'Пищевой корм';

  @override
  String get auto_myOrders => 'Мои заказы';

  @override
  String get auto_noOrdersYet => 'Заказов пока нет';

  @override
  String get auto_yourOrderHistoryWillAppearHere =>
      'Здесь появится история ваших заказов';

  @override
  String get auto_cancelOrder => 'Отменить заказ?';

  @override
  String get auto_keepOrder => 'Следите за порядком';

  @override
  String get auto_orderCancelled => 'Заказ отменен';

  @override
  String get auto_pickupCode => 'Код самовывоза:';

  @override
  String get auto_closed => 'Закрыто';

  @override
  String get auto_menu => 'Меню';

  @override
  String get auto_menuComingSoon => 'Меню скоро появится';

  @override
  String get auto_best => '🔥Лучший';

  @override
  String get auto_popularDishes => '🍽️ Популярные блюда';

  @override
  String get auto_fromVideo => 'Из видео';

  @override
  String get auto_bookATable => 'Забронировать столик';

  @override
  String get auto_confirmReservation => 'Подтвердить бронирование';

  @override
  String get auto_locationDirections => 'Местоположение и направление';

  @override
  String get auto_mapView => 'Просмотр карты';

  @override
  String get auto_openInGoogleMaps => 'Открыть в Google Картах';

  @override
  String get auto_writeAReview => 'Написать отзыв';

  @override
  String get auto_viewCart => 'Посмотреть корзину';

  @override
  String get auto_signOut => 'Выход?';

  @override
  String get auto_youWillNeedToSignInAgain => 'Вам нужно будет войти снова.';

  @override
  String get auto_deleteAccount => 'Удалить аккаунт';

  @override
  String get auto_deleteForever => 'Удалить навсегда';

  @override
  String get auto_accountDeletionRequestedContactSupportToFinalize =>
      'Запрошено удаление аккаунта. Свяжитесь со службой поддержки для завершения.';

  @override
  String get auto_ifridge => 'iХолодильник';

  @override
  String
  get auto_ifridgeIsYourAipoweredKitchenEcosystemItAutomaticallyTracksYourIngredientsPredictsExpirationsGeneratesPersonalizedRecipesAndLetsYouOrderFromLocalRestaurants =>
      'iFridge — это ваша кухонная экосистема на базе искусственного интеллекта. Он автоматически отслеживает ваши ингредиенты, прогнозирует срок годности, создает персонализированные рецепты и позволяет делать заказы в местных ресторанах.';

  @override
  String get auto_gotIt => 'Понятно';

  @override
  String get auto_editDisplayName => 'Изменить отображаемое имя';

  @override
  String get auto_save => 'Сохранять';

  @override
  String get auto_addShoppingItem => 'Добавить товар для покупок';

  @override
  String get auto_add => 'Добавлять';

  @override
  String get auto_selectRecipeForMeal => 'Выберите рецепт блюда';

  @override
  String get auto_failedToLoadRecipes => 'Не удалось загрузить рецепты.';

  @override
  String get auto_noRecipesFound => 'Рецептов не найдено';

  @override
  String get auto_mealCleared => 'Еда очищена';

  @override
  String get auto_theme => '🎨 Тема';

  @override
  String get whatToCook => 'Что приготовить?';

  @override
  String get tierPerfect => 'Идеально';

  @override
  String get tierForYou => 'Для вас';

  @override
  String get tierUseItUp => 'Использовать';

  @override
  String get tierAlmost => 'Почти';

  @override
  String get tierExplore => 'Исследовать';

  @override
  String noTierRecipesYet(String tier) {
    return 'Пока нет рецептов $tier';
  }

  @override
  String get addItemsForRecommendations =>
      'Добавьте продукты на полку для рекомендаций';

  @override
  String get scanCaloriesTab => 'Калории';

  @override
  String get scanYourIngredients => 'Сканируйте свои ингредиенты';

  @override
  String get takePhotoToAdd =>
      'Сделайте фото продуктов, чтобы автоматически добавить их на полку';

  @override
  String get scanReceipt => 'Чек';

  @override
  String get scanPhoto => 'Фото';

  @override
  String get scanBarcode => 'Сканировать штрих-код';

  @override
  String get takePhotoBtn => 'Сделать фото';

  @override
  String get adjustPortions => 'Отрегулировать порции';

  @override
  String currentRecipeMakesNServings(String servings) {
    return 'По текущему рецепту рассчитано порций $servings.';
  }

  @override
  String scaleToNServings(String newServings) {
    return 'Масштабируйте до порций $newServings';
  }

  @override
  String scaledToNServings(String newServings) {
    return 'Масштабировано до порций $newServings 🍳';
  }

  @override
  String findingSubstitutesForX(String ingredientName) {
    return 'Поиск заменителей для $ingredientName...';
  }

  @override
  String get couldNotFindSubstitutes => 'Не смог найти заменителей';

  @override
  String substitutesForX(String ingredientName) {
    return 'Заменители «$ingredientName»';
  }

  @override
  String get noSubstitutesFoundForThisRecipeContext =>
      'Для этого контекста рецепта заменителей не найдено.';

  @override
  String nMatch(String match) {
    return '$match% совпадений';
  }

  @override
  String ingredientsWithCount(String count) {
    return 'Ингредиенты ($count)';
  }

  @override
  String get scale => 'Шкала';

  @override
  String get addedMissingItemsToShoppingList =>
      'Добавлены недостающие товары в список покупок!';

  @override
  String failedToAddItemsX(String e) {
    return 'Не удалось добавить элементы: $e.';
  }

  @override
  String get addMissingToShoppingList =>
      'Добавить недостающее в список покупок';

  @override
  String cookingStepsWithCount(String count) {
    return 'Этапы приготовления ($count)';
  }

  @override
  String get noStepsAvailableYet => 'Шагов пока нет';

  @override
  String get recordedTasteProfileEvolving =>
      'Записано! Ваш вкусовой профиль развивается 🧠';

  @override
  String failedToRecordX(String e) {
    return 'Не удалось записать: $e';
  }

  @override
  String get iCookedThis => 'Я приготовил это!';

  @override
  String get startCooking => 'Начать готовить';

  @override
  String get optional_tag => 'необязательный';

  @override
  String get servings_tag => 'порции';

  @override
  String get min_tag => 'мин';

  @override
  String get difficulty_tag => 'Сложность';

  @override
  String get expiringSoon => 'Срок действия скоро истекает';

  @override
  String nItemsNeedAttention(String count) {
    return 'Элемент(ы) $count требуют внимания';
  }

  @override
  String get takeAPhotoOfFoodItems =>
      'Сфотографируйте продукты питания, чтобы добавить их.\nна вашу полку автоматически';

  @override
  String get addManually => 'Добавить вручную';

  @override
  String get recognitionFailed =>
      'Распознавание не удалось. Попробуйте еще раз.';

  @override
  String get analyzingYourFood => 'Анализ вашего питания...';

  @override
  String get aiIsIdentifying => 'ИИ определяет ингредиенты';

  @override
  String nItemsDetected(String count) {
    return 'Обнаружено $count предметов';
  }

  @override
  String get photoAnalysisSelected => 'Анализ фотографий выбран';

  @override
  String nIngredientsDetected(String count) {
    return '$count Обнаружены ингредиенты';
  }

  @override
  String nOfNAdded(String added, String total) {
    return 'Добавлен $added/$total';
  }

  @override
  String addedItem(String item) {
    return 'Добавлен $item!';
  }

  @override
  String failedToAddItem(String item) {
    return 'Не удалось добавить $item';
  }

  @override
  String addedNItemsToShelf(String count) {
    return 'На полку добавлены товары $count!';
  }

  @override
  String noProductFoundForBarcode(String barcode) {
    return 'Товар со штрих-кодом $barcode не найден.';
  }

  @override
  String addedItemToShelf(String item) {
    return 'Добавлен $item на полку!';
  }

  @override
  String errorX(String e) {
    return 'Ошибка: Х0Х';
  }

  @override
  String analysisFailedX(String e) {
    return 'Анализ не удался: $e';
  }

  @override
  String failedToLogX(String e) {
    return 'Не удалось войти: $e';
  }

  @override
  String get scanBarcodeShort => 'Штрих-код';

  @override
  String get profileAccount => 'Счет';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get tierBadge1 => '✅ Все, что нужно!';

  @override
  String get tierBadge2 => '🔥 Рекомендуем вам';

  @override
  String get tierBadge3 => '⏰ Используйте быстрее';

  @override
  String get tierBadge4 => '🛒 Не хватает нескольких продуктов';

  @override
  String get tierBadge5 => '🌍 Откройте для себя что-то новое';

  @override
  String needLabel(String items) {
    return 'Нужно: $items';
  }

  @override
  String nOfNIngredients(String matched, String total) {
    return '$matched/$total ингредиентов';
  }

  @override
  String get servingsLabel => 'Порции';

  @override
  String nHave(String count) {
    return '$count есть';
  }

  @override
  String nMissing(String count) {
    return '$count не хватает';
  }

  @override
  String get ingredientsHeader => 'Ингредиенты';

  @override
  String get swapButton => 'Заменить →';

  @override
  String get aiAssistant => '🤖 ИИ Ассистент';

  @override
  String get aiHint => 'например: \"У меня нет мяса, чем заменить?\"';

  @override
  String get editIngredient => 'Изменить ингредиент';

  @override
  String get nameLabel => 'Название';

  @override
  String get qtyLabel => 'Кол-во';

  @override
  String get unitLabel => 'Ед. изм.';
}
