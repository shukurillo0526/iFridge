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
}
