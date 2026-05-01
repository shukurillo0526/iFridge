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
  String get profileShoppingList => 'Xarid ro\'yxati';

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
  String get scanFood => 'Ovqatni skanerlash';

  @override
  String get scanCalories => 'Kaloriya skanerlash';

  @override
  String get takePhoto => 'Suratga olish';

  @override
  String get chooseFromGallery => 'Galereyadan tanlang';

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

  @override
  String get settingsLanguage => 'Til';

  @override
  String get settingsTheme => 'Mavzu';

  @override
  String get aboutApp => 'iFridge haqida';

  @override
  String get myFridge => '🧊 Mening muzlatgichim';

  @override
  String get expiryAlerts => 'Muddati tugashi haqida ogohlantirishlar';

  @override
  String get errorLoadInventory => 'Inventarni yuklab bo‘lmadi';

  @override
  String get errorCheckConnection =>
      'Ulanishingizni tekshiring va qaytadan urining.';

  @override
  String get total => 'Jami';

  @override
  String get fresh => 'Yangi';

  @override
  String get expiring => 'Muddati tugayapti';

  @override
  String get expired => 'Muddati tugagan';

  @override
  String get searchIngredients => 'Ingredientlarni qidirish...';

  @override
  String get all => 'Hammasi';

  @override
  String itemsCount(int count) {
    return '$count elementlari';
  }

  @override
  String zoneEmptyTitle(String zone) {
    return 'Sizning $zone bo\'sh';
  }

  @override
  String get zoneEmptyDesc =>
      'Raqamli oshxonangizni to\'ldirishga tayyor.\nElementlarni qoʻlda qoʻshing yoki skanerlash tugmasini bosing.';

  @override
  String get addIngredient => 'Ingredient qo\'shing';

  @override
  String get urgentCook => 'Hozir pishiring';

  @override
  String urgentUse(String ingredient) {
    return '$ingredient dan foydalaning';
  }

  @override
  String get noItemsMatch => 'Hech qanday element filtringizga mos kelmaydi';

  @override
  String get clearFilters => 'Filtrlarni tozalash';

  @override
  String get expiryAlertsTitle => '🔔 Muddati tugashi haqida ogohlantirishlar';

  @override
  String get allFresh => 'Barcha mahsulotlar yangi! 🎉';

  @override
  String expiredCount(int count) {
    return '❌ Muddati tugagan ($count)';
  }

  @override
  String expiringSoonCount(int count) {
    return '⚠️ Tez orada tugaydi ($count)';
  }

  @override
  String get auto_scanCaloriesIsComingSoon =>
      'Kaloriyalarni skanerlash tez orada!';

  @override
  String get auto_scan => 'Skanerlash';

  @override
  String get auto_addAll => 'Hammasini qo\'shish';

  @override
  String get auto_allAdded => 'Hammasi qo\'shildi';

  @override
  String get auto_scanAnother => 'Boshqasini skanerlash';

  @override
  String get auto_startVisualAudit => 'Vizual auditni boshlang';

  @override
  String get auto_enterBarcode => 'Shtrix kodini kiriting';

  @override
  String get auto_cancel => 'Bekor qilish';

  @override
  String get auto_lookUp => 'Axtarish, izlash';

  @override
  String get auto_fridge => 'Muzlatgich';

  @override
  String get auto_freezer => 'Muzlatish kamerasi';

  @override
  String get auto_pantry => 'Omborxona';

  @override
  String get auto_addToShelf => 'Rafga qo\'shish';

  @override
  String get auto_mealLogged => '✅ Ovqat qayd etildi!';

  @override
  String get auto_snapYourMeal => 'Ovqatlanishni yeng';

  @override
  String get auto_takeAPhotoAndAiWillEstimateCalories =>
      'Suratga oling va AI kaloriyalarni hisoblab chiqadi';

  @override
  String get auto_analyzingFood => 'Oziq-ovqatlarni tahlil qilish...';

  @override
  String get auto_camera => 'Kamera';

  @override
  String get auto_gallery => 'Galereya';

  @override
  String get auto_estimatedCalories => 'taxmin qilingan kaloriyalar';

  @override
  String get auto_cal => 'kal';

  @override
  String get auto_logMeal => 'Kundalik ovqat';

  @override
  String get auto_addSomeIngredientsToYourShelfFirst =>
      'Avval javoningizga ba\'zi ingredientlarni qo\'shing!';

  @override
  String get auto_aiRecipeGenerator => 'AI retsepti generatori';

  @override
  String get auto_any => 'Har qanday';

  @override
  String get auto_shelfOnly => 'Faqat javon';

  @override
  String get auto_generateRecipe => 'Retsept yaratish';

  @override
  String get auto_ingredients => '🧂 Tarkibi';

  @override
  String get auto_steps => '👨‍🍳 Qadamlar';

  @override
  String get auto_importRecipe => 'Import retsepti';

  @override
  String get auto_retry => 'Qayta urinish';

  @override
  String get auto_addItemsToYourShelfToGetRecommendations =>
      'Tavsiyalarni olish uchun javoningizga narsalarni qo\'shing';

  @override
  String get auto_noRecipesMatchThisCuisine =>
      'Hech qanday retsept bu oshxonaga mos kelmaydi';

  @override
  String get auto_clearFilter => 'Filtrni tozalash';

  @override
  String get auto_deleteItem => 'Element oʻchirilsinmi?';

  @override
  String get auto_delete => 'Oʻchirish';

  @override
  String get auto_freshness => 'Yangilik';

  @override
  String get auto_use1Unit => '1 birlikdan foydalaning';

  @override
  String get auto_removeFromInventory => 'Inventarizatsiyadan olib tashlang';

  @override
  String get auto_following => 'Kuzatish';

  @override
  String get auto_follow => 'Kuzatish';

  @override
  String get auto_posts => 'Xabarlar';

  @override
  String get auto_noPostsYet => 'Hozircha postlar yo‘q';

  @override
  String get auto_explore => 'Tadqiq qiling';

  @override
  String get auto_noReelsYet => 'Hali makaralar yo\'q';

  @override
  String get auto_cookThisRecipe => 'Ushbu retseptni pishiring';

  @override
  String get auto_recipeNotFound => 'Retsept topilmadi';

  @override
  String get auto_hasRecipe => 'Retsepti bor';

  @override
  String get auto_noCommunityPostsYet => 'Hozircha hamjamiyat postlari yo‘q';

  @override
  String get auto_beTheFirstToShare => 'Birinchi bo\'lib baham ko\'ring!';

  @override
  String get auto_createPost => 'Post yaratish';

  @override
  String get auto_savedPosts => 'Saqlangan xabarlar';

  @override
  String get auto_noSavedPostsYet => 'Hali hech qanday post saqlangan emas';

  @override
  String get auto_you => 'Siz';

  @override
  String get auto_checkout => 'Ro\'yxatdan o\'chirilish';

  @override
  String get auto_yourCartIsEmpty => 'Savatingiz boʻsh';

  @override
  String get auto_yourOrder => 'Sizning buyurtmangiz';

  @override
  String get auto_total => 'Jami';

  @override
  String get auto_orderConfirmed => 'Buyurtma tasdiqlandi!';

  @override
  String get auto_yourPickupCode => 'Qabul qilish kodingiz';

  @override
  String get auto_showThisCodeAtTheCounter =>
      'Ushbu kodni peshtaxtada ko\'rsating';

  @override
  String get auto_deliveryOnTheWay => 'Yo\'lda yetkazib berish';

  @override
  String get auto_aDriverWillBeAssignedShortly =>
      'Tez orada haydovchi tayinlanadi';

  @override
  String get auto_backToHome => 'Uyga qaytish';

  @override
  String get auto_incomingOrders => 'Kiruvchi Buyurtmalar';

  @override
  String get auto_noFoodVideosYet => 'Hozircha ovqat haqida video yo\'q';

  @override
  String get auto_foodFeed => 'Oziq-ovqat';

  @override
  String get auto_myOrders => 'Mening Buyurtmalarim';

  @override
  String get auto_noOrdersYet => 'Hozircha buyurtmalar yo\'q';

  @override
  String get auto_yourOrderHistoryWillAppearHere =>
      'Buyurtmalaringiz tarixi shu yerda paydo bo\'ladi';

  @override
  String get auto_cancelOrder => 'Buyurtma bekor qilinsinmi?';

  @override
  String get auto_keepOrder => 'Buyurtmani saqlang';

  @override
  String get auto_orderCancelled => 'Buyurtma bekor qilindi';

  @override
  String get auto_pickupCode => 'Olib ketish kodi:';

  @override
  String get auto_closed => 'Yopiq';

  @override
  String get auto_menu => 'Menyu';

  @override
  String get auto_menuComingSoon => 'Menyu tez orada';

  @override
  String get auto_best => '🔥 Eng yaxshi';

  @override
  String get auto_popularDishes => '🍽️ Mashhur taomlar';

  @override
  String get auto_fromVideo => 'Videodan';

  @override
  String get auto_bookATable => 'Jadvalni bron qilish';

  @override
  String get auto_confirmReservation => 'Rezervasyonni tasdiqlang';

  @override
  String get auto_locationDirections => 'Joylashuv va yoʻnalishlar';

  @override
  String get auto_mapView => 'Xarita ko\'rinishi';

  @override
  String get auto_openInGoogleMaps => 'Google Xaritalarda oching';

  @override
  String get auto_writeAReview => 'Sharh yozing';

  @override
  String get auto_viewCart => 'Savatni ko\'rish';

  @override
  String get auto_signOut => 'Tizimdan chiqish?';

  @override
  String get auto_youWillNeedToSignInAgain =>
      'Siz yana tizimga kirishingiz kerak bo\'ladi.';

  @override
  String get auto_deleteAccount => 'Akkauntni o\'chirish';

  @override
  String get auto_deleteForever => 'Abadiy o\'chirish';

  @override
  String get auto_accountDeletionRequestedContactSupportToFinalize =>
      'Hisobni oʻchirish soʻraldi. Tugatish uchun qo‘llab-quvvatlash xizmatiga murojaat qiling.';

  @override
  String get auto_ifridge => 'iFridge';

  @override
  String
  get auto_ifridgeIsYourAipoweredKitchenEcosystemItAutomaticallyTracksYourIngredientsPredictsExpirationsGeneratesPersonalizedRecipesAndLetsYouOrderFromLocalRestaurants =>
      'iFridge sizning sun\'iy intellekt asosida ishlaydigan oshxona ekotizimidir. U avtomatik ravishda ingredientlaringizni kuzatib boradi, amal qilish muddatini bashorat qiladi, moslashtirilgan retseptlar yaratadi va mahalliy restoranlardan buyurtma berish imkonini beradi.';

  @override
  String get auto_gotIt => 'Tushundim';

  @override
  String get auto_editDisplayName => 'Displey nomini tahrirlash';

  @override
  String get auto_save => 'Saqlash';

  @override
  String get auto_addShoppingItem => 'Xarid qilish elementini qo\'shing';

  @override
  String get auto_add => 'Qo\'shish';

  @override
  String get auto_selectRecipeForMeal => 'Ovqatlanish uchun retseptni tanlang';

  @override
  String get auto_failedToLoadRecipes => 'Retseptlar yuklanmadi';

  @override
  String get auto_noRecipesFound => 'Hech qanday retsept topilmadi';

  @override
  String get auto_mealCleared => 'Ovqat tozalandi';

  @override
  String get auto_theme => '🎨 Mavzu';

  @override
  String get whatToCook => 'Nima pishiramiz?';

  @override
  String get tierPerfect => 'Mukammal';

  @override
  String get tierForYou => 'Siz uchun';

  @override
  String get tierUseItUp => 'Tezroq ishlating';

  @override
  String get tierAlmost => 'Deyarli';

  @override
  String get tierExplore => 'Kashf qilish';

  @override
  String noTierRecipesYet(String tier) {
    return 'Hozircha $tier retseptlari yo\'q';
  }

  @override
  String get addItemsForRecommendations =>
      'Tavsiyalar olish uchun javonga mahsulot qo\'shing';

  @override
  String get scanCaloriesTab => 'Kaloriyani skanerlash';

  @override
  String get scanYourIngredients => 'Ingredientlaringizni skanerlang';

  @override
  String get takePhotoToAdd =>
      'Javonga avtomatik qo\'shish uchun ovqat rasmini oling';

  @override
  String get scanReceipt => 'Chek';

  @override
  String get scanPhoto => 'Rasm';

  @override
  String get scanBarcode => 'Shtrix-kodni skanerlash';

  @override
  String get takePhotoBtn => 'Rasmga olish';

  @override
  String get adjustPortions => 'Porsiyalarni sozlash';

  @override
  String currentRecipeMakesNServings(String servings) {
    return 'Joriy retsept ';
  }

  @override
  String scaleToNServings(String newServings) {
    return '$newServings porsiyalariga o\'lchab ko\'ring';
  }

  @override
  String scaledToNServings(String newServings) {
    return '$newServings porsiyalariga oʻlchandi 🍳';
  }

  @override
  String findingSubstitutesForX(String ingredientName) {
    return '$ingredientName o‘rnini bosuvchilar qidirilmoqda...';
  }

  @override
  String get couldNotFindSubstitutes => 'O‘rinbosarlarni topib bo‘lmadi';

  @override
  String substitutesForX(String ingredientName) {
    return '“$ingredientName” o‘rniga';
  }

  @override
  String get noSubstitutesFoundForThisRecipeContext =>
      'Ushbu retsept konteksti uchun hech qanday o\'rinbosar topilmadi.';

  @override
  String nMatch(String match) {
    return '$match% moslik';
  }

  @override
  String ingredientsWithCount(String count) {
    return 'Mahsulotlar ($count)';
  }

  @override
  String get scale => 'Masshtab';

  @override
  String get addedMissingItemsToShoppingList =>
      'Yetishmayotgan mahsulotlar xarid ro\'yxatiga qo\'shildi!';

  @override
  String failedToAddItemsX(String e) {
    return 'Elementlarni qo‘shib bo‘lmadi: $e';
  }

  @override
  String get addMissingToShoppingList =>
      'Yetishmayotganlarni ro\'yxatga qo\'shish';

  @override
  String cookingStepsWithCount(String count) {
    return 'Pishirish qadamlari ($count)';
  }

  @override
  String get noStepsAvailableYet => 'Hali qadamlar mavjud emas';

  @override
  String get recordedTasteProfileEvolving =>
      'Yozib olindi! Didingiz profili rivojlanmoqda 🧠';

  @override
  String failedToRecordX(String e) {
    return 'Yozib bo‘lmadi: $e';
  }

  @override
  String get iCookedThis => 'Men buni pishirdim!';

  @override
  String get startCooking => 'Pishirishni boshlash';

  @override
  String get optional_tag => 'ixtiyoriy';

  @override
  String get servings_tag => 'porsiya';

  @override
  String get min_tag => 'daq';

  @override
  String get difficulty_tag => 'Qiyinchilik';

  @override
  String get expiringSoon => 'Tez orada tugaydi';

  @override
  String nItemsNeedAttention(String count) {
    return '$count element(lar)iga e\'tibor kerak';
  }

  @override
  String get takeAPhotoOfFoodItems =>
      'Oziq-ovqat mahsulotlarini qo\'shish uchun ularni suratga oling\njavoningizga avtomatik ravishda';

  @override
  String get addManually => 'Qo\'lda qo\'shish';

  @override
  String get recognitionFailed => 'Tanib bo‘lmadi. Qayta urinib ko\'ring.';

  @override
  String get analyzingYourFood => 'Oziq-ovqatingiz tahlil qilinmoqda...';

  @override
  String get aiIsIdentifying => 'AI ingredientlarni aniqlaydi';

  @override
  String nItemsDetected(String count) {
    return '$count elementlari aniqlandi';
  }

  @override
  String get photoAnalysisSelected => 'Fotosurat tahlili tanlandi';

  @override
  String nIngredientsDetected(String count) {
    return '$count ingrediyentlari aniqlandi';
  }

  @override
  String nOfNAdded(String added, String total) {
    return '$added / $total qo\'shildi';
  }

  @override
  String addedItem(String item) {
    return '$item qo\'shildi!';
  }

  @override
  String failedToAddItem(String item) {
    return '$item qo‘shib bo‘lmadi';
  }

  @override
  String addedNItemsToShelf(String count) {
    return '$count buyumlari javonga qo\'shildi!';
  }

  @override
  String noProductFoundForBarcode(String barcode) {
    return '$barcode shtrix-kodi uchun mahsulot topilmadi';
  }

  @override
  String addedItemToShelf(String item) {
    return '$item javonga qo\'shildi!';
  }

  @override
  String errorX(String e) {
    return 'Xato: $e';
  }

  @override
  String analysisFailedX(String e) {
    return 'Tahlil bajarilmadi: $e';
  }

  @override
  String failedToLogX(String e) {
    return 'Jurnalga kiritilmadi: $e';
  }

  @override
  String get scanBarcodeShort => 'Shtrix-kod';

  @override
  String get profileAccount => 'Hisob';

  @override
  String get deleteAccount => 'Hisobni o\'chirish';

  @override
  String get tierBadge1 => '✅ Hamma narsa bor!';

  @override
  String get tierBadge2 => '🔥 Siz uchun tavsiya';

  @override
  String get tierBadge3 => '⏰ Muddati tugayotganlarni ishlating';

  @override
  String get tierBadge4 => '🛒 Bir nechta mahsulot yetishmaydi';

  @override
  String get tierBadge5 => '🌍 Yangi narsa kashf eting';

  @override
  String needLabel(String items) {
    return 'Kerak: $items';
  }

  @override
  String nOfNIngredients(String matched, String total) {
    return '$matched/$total ingredient';
  }

  @override
  String get servingsLabel => 'Porsiya';

  @override
  String nHave(String count) {
    return '$count ta bor';
  }

  @override
  String nMissing(String count) {
    return '$count ta yetishmaydi';
  }

  @override
  String get ingredientsHeader => 'Ingredientlar';

  @override
  String get swapButton => 'Almashtirish →';

  @override
  String get aiAssistant => '🤖 AI yordamchi';

  @override
  String get aiHint =>
      'masalan: \"Menda go\'sht yo\'q, o\'rniga nimani ishlatsam bo\'ladi?\"';

  @override
  String get editIngredient => 'Ingredientni tahrirlash';

  @override
  String get nameLabel => 'Nomi';

  @override
  String get qtyLabel => 'Miqdor';

  @override
  String get unitLabel => 'Birlik';

  @override
  String get handsOn => 'Qo\'lda';

  @override
  String get automatic => 'Avtomatik';
}

/// The translations for Uzbek, using the Cyrillic script (`uz_Cyrl`).
class AppLocalizationsUzCyrl extends AppLocalizationsUz {
  AppLocalizationsUzCyrl() : super('uz_Cyrl');

  @override
  String get appTitle => 'иФридге';

  @override
  String get tabShelf => 'Жавон';

  @override
  String get tabCook => 'Пишириш';

  @override
  String get tabScan => 'Сканерлаш';

  @override
  String get tabProfile => 'Профил';

  @override
  String get profileTitle => 'Профил';

  @override
  String profileGamificationLevel(int level) {
    return '$level-даража';
  }

  @override
  String get profileMealsCooked => 'Пиширилган таомлар';

  @override
  String get profileItemsSaved => 'Сақланган маҳсулотлар';

  @override
  String get profileDayStreak => 'Кунлик серийа';

  @override
  String get profileFlavorProfile => 'Та\'м профили';

  @override
  String get profileBadges => 'Нишонлар ва йутуқлар';

  @override
  String get profileShoppingList => 'Харид рўйхати';

  @override
  String get profileMealPlanner => 'Овқатланиш режаси';

  @override
  String get actionAdd => 'Қўшиш';

  @override
  String get actionCancel => 'Бекор қилиш';

  @override
  String get actionSave => 'Сақлаш';

  @override
  String get actionDelete => 'Ўчириш';

  @override
  String get profileLoadError => 'Профилни йуклаб бўлмади';

  @override
  String get retry => 'Қайта уриниш';

  @override
  String get refresh => 'Йангилаш';

  @override
  String get signOut => 'Чиқиш';

  @override
  String get profileLevelProgress => 'Даража жарайони';

  @override
  String profileLevel(int level) {
    return '$level-даража';
  }

  @override
  String get profileYourImpact => 'Сизнинг та\'сирингиз';

  @override
  String get addShoppingItem => 'Елемент қўшиш';

  @override
  String get shoppingListEmpty => 'Харидлар рўйхати бўш';

  @override
  String get mealPlannerEmpty => 'Режалаштирилган таомлар йўқ';

  @override
  String get planToday => 'Бугунги режа';

  @override
  String get today => 'Бугун';

  @override
  String get planMeal => 'Таом режалаштириш...';

  @override
  String get tabExplore => 'Кашфийот';

  @override
  String get scanFood => 'Овқатни сканерлаш';

  @override
  String get scanCalories => 'Калорийа сканерлаш';

  @override
  String get takePhoto => 'Суратга олиш';

  @override
  String get chooseFromGallery => 'Галерейадан танланг';

  @override
  String get analyzeCalories => 'Калорийаларни таҳлил қилиш';

  @override
  String get caloriesPerServing => 'кал/порсийа';

  @override
  String get totalCalories => 'жами кал';

  @override
  String get creatorProfile => 'Муаллиф профили';

  @override
  String get follow => 'Кузатиш';

  @override
  String get following => 'Кузатилмоқда';

  @override
  String get nutritionTracker => 'Овқатланиш кузатуви';

  @override
  String get reels => 'Риллар';

  @override
  String get community => 'Жамоа';

  @override
  String get hasRecipe => 'Ретсепт бор';

  @override
  String get noReelsYet => 'Ҳозирча риллар йўқ';

  @override
  String get settings => 'Созламалар';

  @override
  String get settingsLanguage => 'Тил';

  @override
  String get settingsTheme => 'Мавзу';

  @override
  String get aboutApp => 'иФридге ҳақида';

  @override
  String get myFridge => '🧊 Менинг музлатгичим';

  @override
  String get expiryAlerts => 'Муддати тугаши ҳақида огоҳлантиришлар';

  @override
  String get errorLoadInventory => 'Инвентарни йуклаб бо‘лмади';

  @override
  String get errorCheckConnection =>
      'Уланишингизни текширинг ва қайтадан урининг.';

  @override
  String get total => 'Жами';

  @override
  String get fresh => 'Йанги';

  @override
  String get expiring => 'Муддати тугайапти';

  @override
  String get expired => 'Муддати тугаган';

  @override
  String get searchIngredients => 'Ингредиентларни қидириш...';

  @override
  String get all => 'Ҳаммаси';

  @override
  String itemsCount(int count) {
    return '$count елементлари';
  }

  @override
  String zoneEmptyTitle(String zone) {
    return 'Сизнинг $zone бўш';
  }

  @override
  String get zoneEmptyDesc =>
      'Рақамли ошхонангизни тўлдиришга таййор.\nЕлементларни қоʻлда қоʻшинг йоки сканерлаш тугмасини босинг.';

  @override
  String get addIngredient => 'Ингредиент қўшинг';

  @override
  String get urgentCook => 'Ҳозир пиширинг';

  @override
  String urgentUse(String ingredient) {
    return '$ingredient дан фойдаланинг';
  }

  @override
  String get noItemsMatch => 'Ҳеч қандай елемент филтрингизга мос келмайди';

  @override
  String get clearFilters => 'Филтрларни тозалаш';

  @override
  String get expiryAlertsTitle => '🔔 Муддати тугаши ҳақида огоҳлантиришлар';

  @override
  String get allFresh => 'Барча маҳсулотлар йанги! 🎉';

  @override
  String expiredCount(int count) {
    return '❌ Муддати тугаган ($count)';
  }

  @override
  String expiringSoonCount(int count) {
    return '⚠️ Тез орада тугайди ($count)';
  }

  @override
  String get auto_scanCaloriesIsComingSoon =>
      'Калорийаларни сканерлаш тез орада!';

  @override
  String get auto_scan => 'Сканерлаш';

  @override
  String get auto_addAll => 'Ҳаммасини қўшиш';

  @override
  String get auto_allAdded => 'Ҳаммаси қўшилди';

  @override
  String get auto_scanAnother => 'Бошқасини сканерлаш';

  @override
  String get auto_startVisualAudit => 'Визуал аудитни бошланг';

  @override
  String get auto_enterBarcode => 'Штрих кодини киритинг';

  @override
  String get auto_cancel => 'Бекор қилиш';

  @override
  String get auto_lookUp => 'Ахтариш, излаш';

  @override
  String get auto_fridge => 'Музлатгич';

  @override
  String get auto_freezer => 'Музлатиш камераси';

  @override
  String get auto_pantry => 'Омборхона';

  @override
  String get auto_addToShelf => 'Рафга қўшиш';

  @override
  String get auto_mealLogged => '✅ Овқат қайд етилди!';

  @override
  String get auto_snapYourMeal => 'Овқатланишни йенг';

  @override
  String get auto_takeAPhotoAndAiWillEstimateCalories =>
      'Суратга олинг ва АИ калорийаларни ҳисоблаб чиқади';

  @override
  String get auto_analyzingFood => 'Озиқ-овқатларни таҳлил қилиш...';

  @override
  String get auto_camera => 'Камера';

  @override
  String get auto_gallery => 'Галерейа';

  @override
  String get auto_estimatedCalories => 'тахмин қилинган калорийалар';

  @override
  String get auto_cal => 'кал';

  @override
  String get auto_logMeal => 'Кундалик овқат';

  @override
  String get auto_addSomeIngredientsToYourShelfFirst =>
      'Аввал жавонингизга ба\'зи ингредиентларни қўшинг!';

  @override
  String get auto_aiRecipeGenerator => 'АИ ретсепти генератори';

  @override
  String get auto_any => 'Ҳар қандай';

  @override
  String get auto_shelfOnly => 'Фақат жавон';

  @override
  String get auto_generateRecipe => 'Ретсепт йаратиш';

  @override
  String get auto_ingredients => '🧂 Таркиби';

  @override
  String get auto_steps => '👨‍🍳 Қадамлар';

  @override
  String get auto_importRecipe => 'Импорт ретсепти';

  @override
  String get auto_retry => 'Қайта уриниш';

  @override
  String get auto_addItemsToYourShelfToGetRecommendations =>
      'Тавсийаларни олиш учун жавонингизга нарсаларни қўшинг';

  @override
  String get auto_noRecipesMatchThisCuisine =>
      'Ҳеч қандай ретсепт бу ошхонага мос келмайди';

  @override
  String get auto_clearFilter => 'Филтрни тозалаш';

  @override
  String get auto_deleteItem => 'Елемент оʻчирилсинми?';

  @override
  String get auto_delete => 'Оʻчириш';

  @override
  String get auto_freshness => 'Йангилик';

  @override
  String get auto_use1Unit => '1 бирликдан фойдаланинг';

  @override
  String get auto_removeFromInventory => 'Инвентаризатсийадан олиб ташланг';

  @override
  String get auto_following => 'Кузатиш';

  @override
  String get auto_follow => 'Кузатиш';

  @override
  String get auto_posts => 'Хабарлар';

  @override
  String get auto_noPostsYet => 'Ҳозирча постлар йо‘қ';

  @override
  String get auto_explore => 'Тадқиқ қилинг';

  @override
  String get auto_noReelsYet => 'Ҳали макаралар йўқ';

  @override
  String get auto_cookThisRecipe => 'Ушбу ретсептни пиширинг';

  @override
  String get auto_recipeNotFound => 'Ретсепт топилмади';

  @override
  String get auto_hasRecipe => 'Ретсепти бор';

  @override
  String get auto_noCommunityPostsYet => 'Ҳозирча ҳамжамийат постлари йо‘қ';

  @override
  String get auto_beTheFirstToShare => 'Биринчи бўлиб баҳам кўринг!';

  @override
  String get auto_createPost => 'Пост йаратиш';

  @override
  String get auto_savedPosts => 'Сақланган хабарлар';

  @override
  String get auto_noSavedPostsYet => 'Ҳали ҳеч қандай пост сақланган емас';

  @override
  String get auto_you => 'Сиз';

  @override
  String get auto_checkout => 'Рўйхатдан ўчирилиш';

  @override
  String get auto_yourCartIsEmpty => 'Саватингиз боʻш';

  @override
  String get auto_yourOrder => 'Сизнинг буйуртмангиз';

  @override
  String get auto_total => 'Жами';

  @override
  String get auto_orderConfirmed => 'Буйуртма тасдиқланди!';

  @override
  String get auto_yourPickupCode => 'Қабул қилиш кодингиз';

  @override
  String get auto_showThisCodeAtTheCounter => 'Ушбу кодни пештахтада кўрсатинг';

  @override
  String get auto_deliveryOnTheWay => 'Йўлда йетказиб бериш';

  @override
  String get auto_aDriverWillBeAssignedShortly =>
      'Тез орада ҳайдовчи тайинланади';

  @override
  String get auto_backToHome => 'Уйга қайтиш';

  @override
  String get auto_incomingOrders => 'Кирувчи Буйуртмалар';

  @override
  String get auto_noFoodVideosYet => 'Ҳозирча овқат ҳақида видео йўқ';

  @override
  String get auto_foodFeed => 'Озиқ-овқат';

  @override
  String get auto_myOrders => 'Менинг Буйуртмаларим';

  @override
  String get auto_noOrdersYet => 'Ҳозирча буйуртмалар йўқ';

  @override
  String get auto_yourOrderHistoryWillAppearHere =>
      'Буйуртмаларингиз тарихи шу йерда пайдо бўлади';

  @override
  String get auto_cancelOrder => 'Буйуртма бекор қилинсинми?';

  @override
  String get auto_keepOrder => 'Буйуртмани сақланг';

  @override
  String get auto_orderCancelled => 'Буйуртма бекор қилинди';

  @override
  String get auto_pickupCode => 'Олиб кетиш коди:';

  @override
  String get auto_closed => 'Йопиқ';

  @override
  String get auto_menu => 'Менйу';

  @override
  String get auto_menuComingSoon => 'Менйу тез орада';

  @override
  String get auto_best => '🔥 Енг йахши';

  @override
  String get auto_popularDishes => '🍽️ Машҳур таомлар';

  @override
  String get auto_fromVideo => 'Видеодан';

  @override
  String get auto_bookATable => 'Жадвални брон қилиш';

  @override
  String get auto_confirmReservation => 'Резервасйонни тасдиқланг';

  @override
  String get auto_locationDirections => 'Жойлашув ва йоʻналишлар';

  @override
  String get auto_mapView => 'Харита кўриниши';

  @override
  String get auto_openInGoogleMaps => 'Гоогле Хариталарда очинг';

  @override
  String get auto_writeAReview => 'Шарҳ йозинг';

  @override
  String get auto_viewCart => 'Саватни кўриш';

  @override
  String get auto_signOut => 'Тизимдан чиқиш?';

  @override
  String get auto_youWillNeedToSignInAgain =>
      'Сиз йана тизимга киришингиз керак бўлади.';

  @override
  String get auto_deleteAccount => 'Аккаунтни ўчириш';

  @override
  String get auto_deleteForever => 'Абадий ўчириш';

  @override
  String get auto_accountDeletionRequestedContactSupportToFinalize =>
      'Ҳисобни оʻчириш соʻралди. Тугатиш учун қо‘ллаб-қувватлаш хизматига мурожаат қилинг.';

  @override
  String get auto_ifridge => 'иФридге';

  @override
  String
  get auto_ifridgeIsYourAipoweredKitchenEcosystemItAutomaticallyTracksYourIngredientsPredictsExpirationsGeneratesPersonalizedRecipesAndLetsYouOrderFromLocalRestaurants =>
      'иФридге сизнинг сун\'ий интеллект асосида ишлайдиган ошхона екотизимидир. У автоматик равишда ингредиентларингизни кузатиб боради, амал қилиш муддатини башорат қилади, мослаштирилган ретсептлар йаратади ва маҳаллий ресторанлардан буйуртма бериш имконини беради.';

  @override
  String get auto_gotIt => 'Тушундим';

  @override
  String get auto_editDisplayName => 'Дисплей номини таҳрирлаш';

  @override
  String get auto_save => 'Сақлаш';

  @override
  String get auto_addShoppingItem => 'Харид қилиш елементини қўшинг';

  @override
  String get auto_add => 'Қўшиш';

  @override
  String get auto_selectRecipeForMeal => 'Овқатланиш учун ретсептни танланг';

  @override
  String get auto_failedToLoadRecipes => 'Ретсептлар йукланмади';

  @override
  String get auto_noRecipesFound => 'Ҳеч қандай ретсепт топилмади';

  @override
  String get auto_mealCleared => 'Овқат тозаланди';

  @override
  String get auto_theme => '🎨 Мавзу';

  @override
  String get whatToCook => 'Нима пиширамиз?';

  @override
  String get tierPerfect => 'Мукаммал';

  @override
  String get tierForYou => 'Сиз учун';

  @override
  String get tierUseItUp => 'Тезроқ ишлатинг';

  @override
  String get tierAlmost => 'Дейарли';

  @override
  String get tierExplore => 'Кашф қилиш';

  @override
  String noTierRecipesYet(String tier) {
    return 'Ҳозирча $tier ретсептлари йўқ';
  }

  @override
  String get addItemsForRecommendations =>
      'Тавсийалар олиш учун жавонга маҳсулот қўшинг';

  @override
  String get scanCaloriesTab => 'Калорийани сканерлаш';

  @override
  String get scanYourIngredients => 'Ингредиентларингизни сканерланг';

  @override
  String get takePhotoToAdd =>
      'Жавонга автоматик қўшиш учун овқат расмини олинг';

  @override
  String get scanReceipt => 'Чек';

  @override
  String get scanPhoto => 'Расм';

  @override
  String get scanBarcode => 'Штрих-кодни сканерлаш';

  @override
  String get takePhotoBtn => 'Расмга олиш';

  @override
  String get adjustPortions => 'Порсийаларни созлаш';

  @override
  String currentRecipeMakesNServings(String servings) {
    return 'Жорий ретсепт $servings порсийа қилади.';
  }

  @override
  String scaleToNServings(String newServings) {
    return '$newServings порсийаларига ўлчаб кўринг';
  }

  @override
  String scaledToNServings(String newServings) {
    return '$newServings порсийаларига оʻлчанди 🍳';
  }

  @override
  String findingSubstitutesForX(String ingredientName) {
    return '$ingredientName о‘рнини босувчилар қидирилмоқда...';
  }

  @override
  String get couldNotFindSubstitutes => 'О‘ринбосарларни топиб бо‘лмади';

  @override
  String substitutesForX(String ingredientName) {
    return '“$ingredientName” о‘рнига';
  }

  @override
  String get noSubstitutesFoundForThisRecipeContext =>
      'Ушбу ретсепт контексти учун ҳеч қандай ўринбосар топилмади.';

  @override
  String nMatch(String match) {
    return '$match% мослик';
  }

  @override
  String ingredientsWithCount(String count) {
    return 'Ингредиентлар ($count)';
  }

  @override
  String get scale => 'Масштаб';

  @override
  String get addedMissingItemsToShoppingList =>
      'Харид қилиш рўйхатига етишмайотган нарсалар қўшилди!';

  @override
  String failedToAddItemsX(String e) {
    return 'Елементларни қо‘шиб бо‘лмади: $e';
  }

  @override
  String get addMissingToShoppingList =>
      'Харид қилиш рўйхатига етишмайотган нарсаларни қўшинг';

  @override
  String cookingStepsWithCount(String count) {
    return 'Пишириш босқичлари ($count)';
  }

  @override
  String get noStepsAvailableYet => 'Ҳали қадамлар мавжуд емас';

  @override
  String get recordedTasteProfileEvolving =>
      'Йозиб олинган! Сизнинг дидингиз профили ривожланмоқда 🧠';

  @override
  String failedToRecordX(String e) {
    return 'Йозиб бо‘лмади: $e';
  }

  @override
  String get iCookedThis => 'Мен буни пиширдим!';

  @override
  String get startCooking => 'Овқат пиширишни бошланг';

  @override
  String get optional_tag => 'ихтийорий';

  @override
  String get servings_tag => 'порсийа';

  @override
  String get min_tag => 'мин';

  @override
  String get difficulty_tag => 'Қийинчилик';

  @override
  String get expiringSoon => 'Тез орада тугайди';

  @override
  String nItemsNeedAttention(String count) {
    return 'Х0Х елемент(лар)ига е\'тибор керак';
  }

  @override
  String get takeAPhotoOfFoodItems =>
      'Озиқ-овқат маҳсулотларини қўшиш учун уларни суратга олинг\nжавонингизга автоматик равишда';

  @override
  String get addManually => 'Қўлда қўшиш';

  @override
  String get recognitionFailed => 'Таниб бо‘лмади. Қайта уриниб кўринг.';

  @override
  String get analyzingYourFood => 'Озиқ-овқатингиз таҳлил қилинмоқда...';

  @override
  String get aiIsIdentifying => 'АИ ингредиентларни аниқлайди';

  @override
  String nItemsDetected(String count) {
    return 'Х0Х елементлари аниқланди';
  }

  @override
  String get photoAnalysisSelected => 'Фотосурат таҳлили танланди';

  @override
  String nIngredientsDetected(String count) {
    return 'Х0Х ингредийентлари аниқланди';
  }

  @override
  String nOfNAdded(String added, String total) {
    return 'Х0Х / Х1Х қўшилди';
  }

  @override
  String addedItem(String item) {
    return 'Х0Х қўшилди!';
  }

  @override
  String failedToAddItem(String item) {
    return 'Х0Х қо‘шиб бо‘лмади';
  }

  @override
  String addedNItemsToShelf(String count) {
    return 'Х0Х буйумлари жавонга қўшилди!';
  }

  @override
  String noProductFoundForBarcode(String barcode) {
    return 'Х0Х штрих-коди учун маҳсулот топилмади';
  }

  @override
  String addedItemToShelf(String item) {
    return 'Х0Х жавонга қўшилди!';
  }

  @override
  String errorX(String e) {
    return 'Хато: Х0Х';
  }

  @override
  String analysisFailedX(String e) {
    return 'Таҳлил бажарилмади: Х0Х';
  }

  @override
  String failedToLogX(String e) {
    return 'Журналга киритилмади: Х0Х';
  }

  @override
  String get scanBarcodeShort => 'Штрих-код';

  @override
  String get profileAccount => 'Ҳисоб';

  @override
  String get deleteAccount => 'Ҳисобни ўчириш';
}
