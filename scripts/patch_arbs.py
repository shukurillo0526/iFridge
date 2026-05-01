import json
import os

translations = {
    'ko': {
        'whatToCook': '무엇을 요리할까요?', 'tierPerfect': '완벽', 'tierForYou': '추천', 'tierUseItUp': '빨리 소비', 
        'tierAlmost': '거의 비슷', 'tierExplore': '탐색', 'noTierRecipesYet': '{tier} 레시피가 아직 없습니다', 
        'addItemsForRecommendations': '선반에 재료를 추가하여 추천을 받으세요',
        'scanFood': '음식 스캔', 'scanCaloriesTab': '칼로리 스캔', 'scanYourIngredients': '재료 스캔',
        'takePhotoToAdd': '음식 사진을 찍어 선반에 자동으로 추가하세요', 'scanReceipt': '영수증', 'scanPhoto': '사진',
        'scanBarcode': '바코드', 'takePhotoBtn': '사진 찍기', 'chooseFromGallery': '갤러리에서 선택',
        'auto_fridge': '냉장고', 'auto_freezer': '냉동고', 'auto_pantry': '팬트리', 'auto_account': '계정',
        'auto_deleteAccount': '계정 삭제', 'auto_settings': '설정', 'profileShoppingList': '쇼핑 리스트'
    },
    'ru': {
        'whatToCook': 'Что приготовить?', 'tierPerfect': 'Идеально', 'tierForYou': 'Для вас', 'tierUseItUp': 'Использовать', 
        'tierAlmost': 'Почти', 'tierExplore': 'Исследовать', 'noTierRecipesYet': 'Пока нет рецептов {tier}', 
        'addItemsForRecommendations': 'Добавьте продукты на полку для рекомендаций',
        'scanFood': 'Сканировать еду', 'scanCaloriesTab': 'Калории', 'scanYourIngredients': 'Сканируйте ингредиенты',
        'takePhotoToAdd': 'Сделайте фото продуктов, чтобы автоматически добавить их на полку', 'scanReceipt': 'Чек', 'scanPhoto': 'Фото',
        'scanBarcode': 'Штрих-код', 'takePhotoBtn': 'Сделать фото', 'chooseFromGallery': 'Выбрать из галереи',
        'auto_fridge': 'Холодильник', 'auto_freezer': 'Морозильник', 'auto_pantry': 'Кладовая', 'auto_account': 'Аккаунт',
        'auto_deleteAccount': 'Удалить аккаунт', 'auto_settings': 'Настройки', 'profileShoppingList': 'Список покупок'
    },
    'uz': {
        'whatToCook': 'Nima pishiramiz?', 'tierPerfect': 'Mukammal', 'tierForYou': 'Siz uchun', 'tierUseItUp': 'Tezroq ishlating', 
        'tierAlmost': 'Deyarli', 'tierExplore': 'Kashf qilish', 'noTierRecipesYet': "Hozircha {tier} retseptlari yo'q", 
        'addItemsForRecommendations': "Tavsiyalar olish uchun javonga mahsulot qo'shing",
        'scanFood': 'Ovqatni skanerlash', 'scanCaloriesTab': 'Kaloriyani skanerlash', 'scanYourIngredients': 'Masalliqlarni skanerlash',
        'takePhotoToAdd': "Javonga avtomatik qo'shish uchun ovqat rasmini oling", 'scanReceipt': 'Chek', 'scanPhoto': 'Rasm',
        'scanBarcode': 'Shtrix-kod', 'takePhotoBtn': 'Rasmga olish', 'chooseFromGallery': 'Galereyadan tanlash',
        'auto_fridge': 'Muzlatgich', 'auto_freezer': 'Muzlatish kamerasi', 'auto_pantry': 'Omborxona', 'auto_account': 'Akkaunt',
        'auto_deleteAccount': "Akkauntni o'chirish", 'auto_settings': 'Sozlamalar', 'profileShoppingList': "Xarid ro'yxati"
    }
}

def uz_latin_to_cyrillic(text):
    mapping = {
        "sh": "ш", "Sh": "Ш", "ch": "ч", "Ch": "Ч",
        "o'": "ў", "O'": "Ў", "g'": "ғ", "G'": "Ғ",
        "a": "а", "b": "б", "d": "д", "e": "е", "f": "ф", "g": "г", "h": "ҳ",
        "i": "и", "j": "ж", "k": "к", "l": "л", "m": "м", "n": "н", "o": "о",
        "p": "п", "q": "қ", "r": "р", "s": "с", "t": "т", "u": "у", "v": "в",
        "x": "х", "y": "й", "z": "з",
        "A": "А", "B": "Б", "D": "Д", "E": "Е", "F": "Ф", "G": "Г", "H": "Ҳ",
        "I": "И", "J": "Ж", "K": "К", "L": "Л", "M": "М", "N": "Н", "O": "О",
        "P": "П", "Q": "Қ", "R": "Р", "S": "С", "T": "Т", "U": "У", "V": "В",
        "X": "Х", "Y": "Й", "Z": "З"
    }
    for lat, cyr in mapping.items(): text = text.replace(lat, cyr)
    return text

translations['uz_Cyrl'] = {k: uz_latin_to_cyrillic(v) for k, v in translations['uz'].items()}

l10n_dir = r'd:\dev\projects\iFridge\frontend\lib\l10n'
for lang, trans in translations.items():
    path = os.path.join(l10n_dir, f'app_{lang}.arb')
    with open(path, 'r', encoding='utf-8') as f: data = json.load(f)
    for k, v in trans.items():
        data[k] = v
        if '{tier}' in v:
            data['@'+k] = {'placeholders': {'tier': {'type': 'String'}}}
    with open(path, 'w', encoding='utf-8') as f: json.dump(data, f, indent=4, ensure_ascii=False)
