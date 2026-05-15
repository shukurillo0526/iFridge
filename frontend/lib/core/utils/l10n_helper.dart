import 'package:flutter/material.dart';

class L10nHelper {
  static String translateCuisine(String cuisine, dynamic localeOrCode) {
    if (cuisine.isEmpty) return cuisine;
    
    final lower = cuisine.toLowerCase();
    
    // Support both String and Locale
    String key;
    if (localeOrCode is Locale) {
      key = _localeKey(localeOrCode);
    } else {
      key = (localeOrCode as String);
    }
    
    if (key == 'uz_Cyrl') {
      switch (lower) {
        case 'asian': return 'Осиёча';
        case 'middle eastern': return 'Яқин Шарқ';
        case 'italian': return 'Италиянча';
        case 'mexican': return 'Мексиканча';
        case 'american': return 'Американча';
        case 'korean': return 'Корейсча';
        case 'japanese': return 'Йапонча';
        case 'uzbek': return 'Ўзбекча';
        case 'indian': return 'Ҳиндча';
        case 'french': return 'Франсузча';
        case 'chinese': return 'Хитойча';
        case 'thai': return 'Тайча';
        case 'mediterranean': return 'Ўртайер денгизи';
        case 'european': return 'Йевропача';
        case 'british': return 'Британча';
        case 'spanish': return 'Испанча';
        case 'greek': return 'Грекча';
        case 'turkish': return 'Туркча';
        case 'vietnamese': return 'Вьетнамча';
        case 'russian': return 'Русча';
        case 'latin': return 'Лотин';
        case 'fusion': return 'Фужн';
        case 'eastern european': return 'Шарқий Йевропа';
        case 'western': return 'Ғарбий';
        default: return cuisine;
      }
    } else if (key == 'uz' || key.startsWith('uz')) {
      switch (lower) {
        case 'asian': return 'Osiyocha';
        case 'middle eastern': return 'Yaqin Sharq';
        case 'italian': return 'Italyancha';
        case 'mexican': return 'Meksikancha';
        case 'american': return 'Amerikancha';
        case 'korean': return 'Koreyscha';
        case 'japanese': return 'Yaponcha';
        case 'uzbek': return 'O\'zbekcha';
        case 'indian': return 'Hindcha';
        case 'french': return 'Fransuzcha';
        case 'chinese': return 'Xitoycha';
        case 'thai': return 'Taycha';
        case 'mediterranean': return 'O\'rtayer dengizi';
        case 'european': return 'Yevropacha';
        case 'british': return 'Britancha';
        case 'spanish': return 'Ispancha';
        case 'greek': return 'Grekcha';
        case 'turkish': return 'Turkcha';
        case 'vietnamese': return 'Vyetnamcha';
        case 'russian': return 'Ruscha';
        case 'latin': return 'Lotin';
        case 'fusion': return 'Fuzhn';
        case 'eastern european': return 'Sharqiy Yevropa';
        case 'western': return 'G\'arbiy';
        default: return cuisine;
      }
    } else if (key == 'ru' || key.startsWith('ru')) {
      switch (lower) {
        case 'asian': return 'Азиатская';
        case 'middle eastern': return 'Ближневосточная';
        case 'italian': return 'Итальянская';
        case 'mexican': return 'Мексиканская';
        case 'american': return 'Американская';
        case 'korean': return 'Корейская';
        case 'japanese': return 'Японская';
        case 'uzbek': return 'Узбекская';
        case 'indian': return 'Индийская';
        case 'french': return 'Французская';
        case 'chinese': return 'Китайская';
        case 'thai': return 'Тайская';
        case 'mediterranean': return 'Средиземноморская';
        case 'european': return 'Европейская';
        case 'british': return 'Британская';
        case 'spanish': return 'Испанская';
        case 'greek': return 'Греческая';
        case 'turkish': return 'Турецкая';
        case 'vietnamese': return 'Вьетнамская';
        case 'russian': return 'Русская';
        case 'latin': return 'Латинская';
        case 'fusion': return 'Фьюжн';
        case 'eastern european': return 'Восточноевропейская';
        case 'western': return 'Западная';
        default: return cuisine;
      }
    } else if (key == 'ko' || key.startsWith('ko')) {
      switch (lower) {
        case 'asian': return '아시아';
        case 'middle eastern': return '중동';
        case 'italian': return '이탈리아';
        case 'mexican': return '멕시코';
        case 'american': return '미국';
        case 'korean': return '한국';
        case 'japanese': return '일본';
        case 'uzbek': return '우즈벡';
        case 'indian': return '인도';
        case 'french': return '프랑스';
        case 'chinese': return '중국';
        case 'thai': return '태국';
        case 'mediterranean': return '지중해';
        case 'european': return '유럽';
        case 'british': return '영국';
        case 'spanish': return '스페인';
        case 'greek': return '그리스';
        case 'turkish': return '터키';
        case 'vietnamese': return '베트남';
        case 'russian': return '러시아';
        case 'latin': return '라틴';
        case 'fusion': return '퓨전';
        case 'eastern european': return '동유럽';
        case 'western': return '서양';
        default: return cuisine;
      }
    }
    
    return cuisine; // Default English
  }

  static String translateUnit(String unit, String localeCode) {
    if (unit.isEmpty) return unit;
    
    final lower = unit.toLowerCase().trim();
    
    if (localeCode.startsWith('uz')) {
      if (localeCode.contains('Cyrl')) {
        // Uzbek Cyrillic
        return _unitMapUzCyrl[lower] ?? unit;
      }
      return _unitMapUz[lower] ?? unit;
    } else if (localeCode.startsWith('ru')) {
      return _unitMapRu[lower] ?? unit;
    } else if (localeCode.startsWith('ko')) {
      return _unitMapKo[lower] ?? unit;
    }
    
    return unit; // Default English
  }

  /// Translate nutrition labels like kcal/srv, P, C, F for the current locale.
  static String translateNutritionLabel(String label, String localeCode) {
    if (label.isEmpty) return label;
    
    if (localeCode.startsWith('ru')) {
      return _nutritionMapRu[label] ?? label;
    } else if (localeCode.startsWith('ko')) {
      return _nutritionMapKo[label] ?? label;
    } else if (localeCode.startsWith('uz')) {
      return _nutritionMapUz[label] ?? label;
    }
    return label;
  }

  /// Translate common prep notes (e.g. "Melted, plus extra for pan")
  static String translatePrepNote(String note, String localeCode) {
    if (note.isEmpty) return note;
    
    final lower = note.toLowerCase().trim();
    
    if (localeCode.startsWith('ru')) {
      return _prepNoteMapRu[lower] ?? note;
    } else if (localeCode.startsWith('ko')) {
      return _prepNoteMapKo[lower] ?? note;
    } else if (localeCode.startsWith('uz')) {
      return _prepNoteMapUz[lower] ?? note;
    }
    return note;
  }

  // ── Unit Translation Maps ──────────────────────────────

  static const _unitMapRu = <String, String>{
    'tbsp': 'ст. л.',
    'tbsp.': 'ст. л.',
    'tablespoon': 'ст. л.',
    'tablespoons': 'ст. л.',
    'tsp': 'ч. л.',
    'tsp.': 'ч. л.',
    'teaspoon': 'ч. л.',
    'teaspoons': 'ч. л.',
    'cup': 'стакан',
    'cups': 'стакана',
    'clove': 'зубчик',
    'cloves': 'зубчика',
    'can': 'банка',
    'cans': 'банки',
    'piece': 'шт',
    'pieces': 'шт',
    'pcs': 'шт',
    'pinch': 'щепотка',
    'slice': 'ломтик',
    'slices': 'ломтика',
    'bunch': 'пучок',
    'g': 'г',
    'gram': 'г',
    'grams': 'г',
    'kg': 'кг',
    'kilogram': 'кг',
    'ml': 'мл',
    'milliliter': 'мл',
    'l': 'л',
    'liter': 'л',
    'liters': 'л',
    'oz': 'унция',
    'ounce': 'унция',
    'ounces': 'унции',
    'lb': 'фунт',
    'lbs': 'фунты',
    'pound': 'фунт',
    'pounds': 'фунты',
    'large': 'крупн.',
    'medium': 'средн.',
    'small': 'мелк.',
    'to taste': 'по вкусу',
    'serving': 'порция',
    'servings': 'порций',
    'package': 'упаковка',
    'stick': 'палочка',
    'head': 'головка',
    'sprig': 'веточка',
    'dash': 'капля',
  };

  static const _unitMapKo = <String, String>{
    'tbsp': '큰술',
    'tbsp.': '큰술',
    'tablespoon': '큰술',
    'tablespoons': '큰술',
    'tsp': '티스푼',
    'tsp.': '티스푼',
    'teaspoon': '티스푼',
    'teaspoons': '티스푼',
    'cup': '컵',
    'cups': '컵',
    'clove': '쪽',
    'cloves': '쪽',
    'can': '캔',
    'cans': '캔',
    'piece': '개',
    'pieces': '개',
    'pcs': '개',
    'pinch': '꼬집',
    'slice': '조각',
    'slices': '조각',
    'bunch': '다발',
    'g': 'g',
    'gram': 'g',
    'grams': 'g',
    'kg': 'kg',
    'ml': 'ml',
    'l': '리터',
    'liter': '리터',
    'oz': '온스',
    'ounce': '온스',
    'lb': '파운드',
    'lbs': '파운드',
    'large': '큰',
    'medium': '중간',
    'small': '작은',
    'to taste': '적당량',
    'serving': '인분',
    'servings': '인분',
    'package': '봉지',
    'stick': '개',
    'head': '통',
    'sprig': '줄기',
    'dash': '약간',
  };

  static const _unitMapUz = <String, String>{
    'tbsp': 'osh-q.',
    'tbsp.': 'osh-q.',
    'tablespoon': 'osh qoshiq',
    'tablespoons': 'osh qoshiq',
    'tsp': 'choy-q.',
    'tsp.': 'choy-q.',
    'teaspoon': 'choy qoshiq',
    'teaspoons': 'choy qoshiq',
    'cup': 'stakan',
    'cups': 'stakan',
    'clove': 'bo\'lak',
    'cloves': 'bo\'lak',
    'can': 'banka',
    'piece': 'dona',
    'pieces': 'dona',
    'pcs': 'dona',
    'pinch': 'chimdim',
    'slice': 'tilim',
    'slices': 'tilim',
    'bunch': 'bog\'lam',
    'g': 'g',
    'gram': 'g',
    'kg': 'kg',
    'ml': 'ml',
    'l': 'l',
    'oz': 'unsiya',
    'lb': 'funt',
    'large': 'katta',
    'medium': 'o\'rtacha',
    'small': 'kichik',
    'to taste': 'didiga qarab',
    'serving': 'porsiya',
    'servings': 'porsiya',
  };

  static const _unitMapUzCyrl = <String, String>{
    'tbsp': 'ош-қ.',
    'tablespoon': 'ош қошиқ',
    'tsp': 'чой-қ.',
    'teaspoon': 'чой қошиқ',
    'cup': 'стакан',
    'cups': 'стакан',
    'clove': 'бўлак',
    'can': 'банка',
    'piece': 'дона',
    'pieces': 'дона',
    'pcs': 'дона',
    'pinch': 'чимдим',
    'slice': 'тилим',
    'bunch': 'боғлам',
    'g': 'г',
    'kg': 'кг',
    'ml': 'мл',
    'l': 'л',
    'large': 'катта',
    'medium': 'ўртача',
    'small': 'кичик',
    'to taste': 'дидига қараб',
    'serving': 'порсийа',
    'servings': 'порсийа',
  };

  // ── Nutrition Label Maps ──────────────────────────────

  static const _nutritionMapRu = <String, String>{
    'g': 'г',
    'kcal/srv': 'ккал/пор',
    'kcal': 'ккал',
    'cal': 'кал',
    'P': 'Б',        // Белки (Protein)
    'C': 'У',        // Углеводы (Carbs)
    'F': 'Ж',        // Жиры (Fat)
    'Protein': 'Белки',
    'Carbs': 'Углеводы',
    'Fat': 'Жиры',
  };

  static const _nutritionMapKo = <String, String>{
    'g': 'g',
    'kcal/srv': 'kcal/인분',
    'kcal': 'kcal',
    'cal': '칼',
    'P': '단',        // 단백질 (Protein)
    'C': '탄',        // 탄수화물 (Carbs)
    'F': '지',        // 지방 (Fat)
    'Protein': '단백질',
    'Carbs': '탄수화물',
    'Fat': '지방',
  };

  static const _nutritionMapUz = <String, String>{
    'g': 'g',
    'kcal/srv': 'kkal/por',
    'kcal': 'kkal',
    'cal': 'kal',
    'P': 'O',        // Oqsil (Protein)
    'C': 'U',        // Uglevodlar (Carbs)
    'F': 'Y',        // Yog' (Fat)
    'Protein': 'Oqsil',
    'Carbs': 'Uglevodlar',
    'Fat': 'Yog\'',
  };

  // ── Common Prep Note Maps ──────────────────────────────

  static const _prepNoteMapRu = <String, String>{
    'melted': 'растопленное',
    'melted, plus extra for pan': 'растопленное, плюс для сковороды',
    'diced': 'нарезанное кубиками',
    'minced': 'измельчённое',
    'chopped': 'нарезанное',
    'finely chopped': 'мелко нарезанное',
    'sliced': 'нарезанное ломтиками',
    'grated': 'натёртое',
    'peeled': 'очищенное',
    'beaten': 'взбитое',
    'room temperature': 'комнатной температуры',
    'softened': 'размягчённое',
    'to taste': 'по вкусу',
    'optional': 'по желанию',
  };

  static const _prepNoteMapKo = <String, String>{
    'melted': '녹인',
    'melted, plus extra for pan': '녹인, 팬용 추가',
    'diced': '깍둑썰기',
    'minced': '다진',
    'chopped': '썬',
    'finely chopped': '잘게 썬',
    'sliced': '슬라이스',
    'grated': '간',
    'peeled': '껍질 벗긴',
    'beaten': '풀어놓은',
    'room temperature': '실온',
    'softened': '부드럽게 한',
    'to taste': '적당량',
    'optional': '선택사항',
  };

  static const _prepNoteMapUz = <String, String>{
    'melted': 'eritilgan',
    'melted, plus extra for pan': 'eritilgan, qozoncha uchun qo\'shimcha',
    'diced': 'kubik qilib kesilgan',
    'minced': 'maydalangan',
    'chopped': 'kesilgan',
    'finely chopped': 'mayda kesilgan',
    'sliced': 'tilim qilingan',
    'grated': 'qirg\'ichdan o\'tkazilgan',
    'peeled': 'tozalangan',
    'beaten': 'ko\'pirtirilgan',
    'room temperature': 'xona haroratida',
    'softened': 'yumshatilgan',
    'to taste': 'didiga qarab',
    'optional': 'ixtiyoriy',
  };

  /// Helper to get effective locale key for switches.
  static String _localeKey(Locale locale) {
    if (locale.languageCode == 'uz' && locale.scriptCode == 'Cyrl') return 'uz_Cyrl';
    return locale.languageCode; // 'en', 'uz', 'ru', 'ko'
  }

  /// Translate an ingredient category for display.
  static String translateCategory(String category, Locale locale) {
    if (category.isEmpty) return category;
    
    final lower = category.toLowerCase();
    final key = _localeKey(locale);
    
    if (key == 'uz_Cyrl') {
      switch (lower) {
        case 'produce': return 'Маҳсулотлар';
        case 'vegetable': return 'Сабзавот';
        case 'fruit': return 'Мева';
        case 'meat': return 'Гўшт';
        case 'poultry': return 'Парранда';
        case 'seafood': return 'Денгиз маҳсулоти';
        case 'dairy': return 'Сут маҳсулоти';
        case 'milk': return 'Сут';
        case 'cheese': return 'Пишлоқ';
        case 'yogurt': return 'Йогурт';
        case 'eggs': return 'Тухум';
        case 'bakery': return 'Новвойхона';
        case 'bread': return 'Нон';
        case 'grain': return 'Дон';
        case 'pasta': return 'Макарон';
        case 'pantry': return 'Омбор';
        case 'canned': return 'Консерва';
        case 'frozen': return 'Музлатилган';
        case 'beverage': return 'Ичимлик';
        case 'juice': return 'Шарбат';
        case 'snack': return 'Газак';
        case 'condiment': return 'Зираворлар';
        case 'spice': return 'Зиравор';
        case 'oil': return 'Йоғ';
        case 'sauce': return 'Соус';
        case 'nuts': return 'Йонғоқ';
        case 'legumes': return 'Дуккакли';
        case 'tofu': return 'Тофу';
        case 'protein': return 'Оқсил';
        case 'baking': return 'Пиширилади';
        case 'seasoning': return 'Зираворлар';
        default: return category;
      }
    } else if (key == 'uz') {
      switch (lower) {
        case 'produce': return 'Mahsulotlar';
        case 'vegetable': return 'Sabzavot';
        case 'fruit': return 'Meva';
        case 'meat': return 'Go\'sht';
        case 'poultry': return 'Parranda';
        case 'seafood': return 'Dengiz mahsuloti';
        case 'dairy': return 'Sut mahsuloti';
        case 'milk': return 'Sut';
        case 'cheese': return 'Pishloq';
        case 'yogurt': return 'Yogurt';
        case 'eggs': return 'Tuxum';
        case 'bakery': return 'Novvoyxona';
        case 'bread': return 'Non';
        case 'grain': return 'Don';
        case 'pasta': return 'Makaron';
        case 'pantry': return 'Ombor';
        case 'canned': return 'Konserva';
        case 'frozen': return 'Muzlatilgan';
        case 'beverage': return 'Ichimlik';
        case 'juice': return 'Sharbat';
        case 'snack': return 'Gazak';
        case 'condiment': return 'Ziravorlar';
        case 'spice': return 'Ziravor';
        case 'oil': return 'Yog\'';
        case 'sauce': return 'Sous';
        case 'nuts': return 'Yong\'oq';
        case 'legumes': return 'Dukkakli';
        case 'tofu': return 'Tofu';
        case 'protein': return 'Oqsil';
        case 'baking': return 'Pishirish';
        case 'seasoning': return 'Ziravorlar';
        default: return category;
      }
    } else if (key == 'ru') {
      switch (lower) {
        case 'produce': return 'Продукты';
        case 'vegetable': return 'Овощи';
        case 'fruit': return 'Фрукты';
        case 'meat': return 'Мясо';
        case 'poultry': return 'Птица';
        case 'seafood': return 'Морепродукты';
        case 'dairy': return 'Молочные';
        case 'milk': return 'Молоко';
        case 'cheese': return 'Сыр';
        case 'yogurt': return 'Йогурт';
        case 'eggs': return 'Яйца';
        case 'bakery': return 'Выпечка';
        case 'bread': return 'Хлеб';
        case 'grain': return 'Крупы';
        case 'pasta': return 'Макароны';
        case 'pantry': return 'Кладовая';
        case 'canned': return 'Консервы';
        case 'frozen': return 'Заморож.';
        case 'beverage': return 'Напитки';
        case 'juice': return 'Соки';
        case 'snack': return 'Закуски';
        case 'condiment': return 'Приправы';
        case 'spice': return 'Специи';
        case 'oil': return 'Масло';
        case 'sauce': return 'Соус';
        case 'nuts': return 'Орехи';
        case 'legumes': return 'Бобовые';
        case 'tofu': return 'Тофу';
        case 'protein': return 'Белки';
        case 'baking': return 'Выпечка';
        case 'seasoning': return 'Приправы';
        default: return category;
      }
    } else if (key == 'ko') {
      switch (lower) {
        case 'produce': return '농산물';
        case 'vegetable': return '채소';
        case 'fruit': return '과일';
        case 'meat': return '고기';
        case 'poultry': return '가금류';
        case 'seafood': return '해산물';
        case 'dairy': return '유제품';
        case 'milk': return '우유';
        case 'cheese': return '치즈';
        case 'yogurt': return '요거트';
        case 'eggs': return '계란';
        case 'bakery': return '베이커리';
        case 'bread': return '빵';
        case 'grain': return '곡물';
        case 'pasta': return '파스타';
        case 'pantry': return '식료품';
        case 'canned': return '통조림';
        case 'frozen': return '냉동';
        case 'beverage': return '음료';
        case 'juice': return '주스';
        case 'snack': return '간식';
        case 'condiment': return '양념';
        case 'spice': return '향신료';
        case 'oil': return '기름';
        case 'sauce': return '소스';
        case 'nuts': return '견과류';
        case 'legumes': return '콩류';
        case 'tofu': return '두부';
        case 'protein': return '단백질';
        case 'baking': return '베이킹';
        case 'seasoning': return '조미료';
        default: return category;
      }
    }
    
    return category; // Default English
  }

  /// Translate storage location for chip display.
  static String translateLocation(String location, Locale locale) {
    final key = _localeKey(locale);
    final lower = location.toLowerCase();
    switch (key) {
      case 'uz_Cyrl':
        if (lower == 'fridge') return 'Музлатгич';
        if (lower == 'freezer') return 'Музлатиш камераси';
        if (lower == 'pantry') return 'Омборхона';
        return location;
      case 'uz':
        if (lower == 'fridge') return 'Muzlatgich';
        if (lower == 'freezer') return 'Muzlatish kamerasi';
        if (lower == 'pantry') return 'Omborxona';
        return location;
      case 'ru':
        if (lower == 'fridge') return 'Холодильник';
        if (lower == 'freezer') return 'Морозилка';
        if (lower == 'pantry') return 'Кладовая';
        return location;
      case 'ko':
        if (lower == 'fridge') return '냉장고';
        if (lower == 'freezer') return '냉동실';
        if (lower == 'pantry') return '식료품장';
        return location;
      default:
        return location;
    }
  }

  /// Translate item state for chip display.
  static String translateState(String state, Locale locale) {
    final key = _localeKey(locale);
    final lower = state.toLowerCase();
    switch (key) {
      case 'uz_Cyrl':
        if (lower == 'sealed') return 'Йопиқ';
        if (lower == 'opened') return 'Очилган';
        if (lower == 'frozen') return 'Музлатилган';
        return state;
      case 'uz':
        if (lower == 'sealed') return 'Yopiq';
        if (lower == 'opened') return 'Ochilgan';
        if (lower == 'frozen') return 'Muzlatilgan';
        return state;
      case 'ru':
        if (lower == 'sealed') return 'Закрытый';
        if (lower == 'opened') return 'Открытый';
        if (lower == 'frozen') return 'Замороженный';
        return state;
      case 'ko':
        if (lower == 'sealed') return '밀봉';
        if (lower == 'opened') return '개봉';
        if (lower == 'frozen') return '냉동';
        return state;
      default:
        return state;
    }
  }

  /// Translate source value for display.
  static String translateSource(String source, Locale locale) {
    final key = _localeKey(locale);
    final lower = source.toLowerCase();
    switch (key) {
      case 'uz_Cyrl':
        if (lower == 'manual') return 'Қўлда';
        if (lower == 'scan') return 'Сканер';
        if (lower == 'receipt') return 'Чек';
        if (lower == 'barcode') return 'Штрих-код';
        return source;
      case 'uz':
        if (lower == 'manual') return 'Qo\'lda';
        if (lower == 'scan') return 'Skaner';
        if (lower == 'receipt') return 'Chek';
        if (lower == 'barcode') return 'Shtrix-kod';
        return source;
      case 'ru':
        if (lower == 'manual') return 'Вручную';
        if (lower == 'scan') return 'Сканер';
        if (lower == 'receipt') return 'Чек';
        if (lower == 'barcode') return 'Штрих-код';
        return source;
      case 'ko':
        if (lower == 'manual') return '수동';
        if (lower == 'scan') return '스캔';
        if (lower == 'receipt') return '영수증';
        if (lower == 'barcode') return '바코드';
        return source;
      default:
        return source;
    }
  }
}
