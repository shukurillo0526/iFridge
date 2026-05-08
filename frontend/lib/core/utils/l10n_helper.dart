import 'package:flutter/material.dart';

class L10nHelper {
  static String translateCuisine(String cuisine, String localeCode) {
    if (cuisine.isEmpty) return cuisine;
    
    final lower = cuisine.toLowerCase();
    
    if (localeCode.startsWith('uz')) {
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
        default: return cuisine;
      }
    } else if (localeCode.startsWith('ru')) {
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
        default: return cuisine;
      }
    }
    
    return cuisine; // Default English
  }

  static String translateUnit(String unit, String localeCode) {
    if (unit.isEmpty) return unit;
    
    final lower = unit.toLowerCase();
    
    if (localeCode.startsWith('uz')) {
      switch (lower) {
        case 'tbsp': return 'osh qoshiq';
        case 'tsp': return 'choy qoshiq';
        case 'cup': return 'stakan';
        case 'clove': return 'dona'; // or bo'lak
        case 'can': return 'banka';
        case 'piece': return 'dona';
        case 'pinch': return 'chimdim';
        case 'slice': return 'bo\'lak';
        case 'g': return 'g';
        case 'kg': return 'kg';
        case 'ml': return 'ml';
        case 'l': return 'l';
        case 'oz': return 'unsiya';
        case 'lb': return 'funt';
        default: return unit;
      }
    } else if (localeCode.startsWith('ru')) {
      switch (lower) {
        case 'tbsp': return 'ст. л.';
        case 'tsp': return 'ч. л.';
        case 'cup': return 'стакан';
        case 'clove': return 'зубчик';
        case 'can': return 'банка';
        case 'piece': return 'шт';
        case 'pinch': return 'щепотка';
        case 'slice': return 'ломтик';
        case 'g': return 'г';
        case 'kg': return 'кг';
        case 'ml': return 'мл';
        case 'l': return 'л';
        case 'oz': return 'унция';
        case 'lb': return 'фунт';
        default: return unit;
      }
    }
    
    return unit; // Default English
  }

  /// Translate an ingredient category for display.
  static String translateCategory(String category, String localeCode) {
    if (category.isEmpty) return category;
    
    final lower = category.toLowerCase();
    
    if (localeCode.startsWith('uz')) {
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
    } else if (localeCode.startsWith('ru')) {
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
    } else if (localeCode.startsWith('ko')) {
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
}
