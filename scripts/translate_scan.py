import json
import os
import urllib.request
import urllib.parse
import time
import re

def translate(text, target_lang):
    if not text or text.strip() == '': return text
    try:
        url = f'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl={target_lang}&dt=t&q={urllib.parse.quote(text)}'
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode('utf-8'))
            return ''.join([x[0] for x in data[0]])
    except Exception as e:
        return text

new_keys = {
    'expiringSoon': 'Expiring Soon',
    'nItemsNeedAttention': '{count} item(s) need attention',
    'scanYourIngredients': 'Scan Your Ingredients',
    'takeAPhotoOfFoodItems': 'Take a photo of food items to add them\nto your shelf automatically',
    'takePhoto': 'Take Photo',
    'scanBarcode': 'Scan Barcode',
    'chooseFromGallery': 'Choose from Gallery',
    'addManually': 'Add Manually',
    'recognitionFailed': 'Recognition failed. Try again.',
    'analyzingYourFood': 'Analyzing your food...',
    'aiIsIdentifying': 'AI is identifying ingredients',
    'nItemsDetected': '{count} Items Detected',
    'photoAnalysisSelected': 'Photo Analysis Selected',
    'nIngredientsDetected': '{count} Ingredients Detected',
    'nOfNAdded': '{added} / {total} added',
    'addedItem': 'Added {item}!',
    'failedToAddItem': 'Failed to add {item}',
    'addedNItemsToShelf': 'Added {count} items to shelf!',
    'noProductFoundForBarcode': 'No product found for barcode {barcode}',
    'addedItemToShelf': 'Added {item} to shelf!',
    'errorX': 'Error: {e}',
    'analysisFailedX': 'Analysis failed: {e}',
    'failedToLogX': 'Failed to log: {e}'
}

l10n_dir = r'd:\dev\projects\iFridge\frontend\lib\l10n'
en_path = os.path.join(l10n_dir, 'app_en.arb')

with open(en_path, 'r', encoding='utf-8') as f: data = json.load(f)
for k, v in new_keys.items():
    data[k] = v.replace('\\n', '\n')
    if '{' in v:
        placeholders = {}
        for var in ['count', 'added', 'total', 'item', 'barcode', 'e']:
            if '{'+var+'}' in v: placeholders[var] = {'type': 'String'}
        data['@'+k] = {'placeholders': placeholders}
with open(en_path, 'w', encoding='utf-8') as f: json.dump(data, f, indent=4, ensure_ascii=False)

targets = {'ko': 'ko', 'ru': 'ru', 'uz': 'uz'}
for lang, gcode in targets.items():
    path = os.path.join(l10n_dir, f'app_{lang}.arb')
    with open(path, 'r', encoding='utf-8') as f: data = json.load(f)
    for k, v in new_keys.items():
        if '{' in v:
            parts = []
            def replace_var(m):
                parts.append(m.group(0))
                return f' X{len(parts)-1}X '
            masked = re.sub(r'\{[^}]+\}', replace_var, v.replace('\\n', '\n'))
            translated = translate(masked, gcode)
            for i, p in enumerate(parts):
                translated = translated.replace(f'X{i}X', p).replace(f' X{i}X ', p)
            data[k] = translated.replace('  ', ' ')
        else:
            data[k] = translate(v.replace('\\n', '\n'), gcode)
        time.sleep(0.01)
    with open(path, 'w', encoding='utf-8') as f: json.dump(data, f, indent=4, ensure_ascii=False)

# Cyrl
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

uz_path = os.path.join(l10n_dir, 'app_uz.arb')
with open(uz_path, 'r', encoding='utf-8') as f: uz_arb = json.load(f)
cyrl_path = os.path.join(l10n_dir, 'app_uz_Cyrl.arb')
with open(cyrl_path, 'r', encoding='utf-8') as f: cyrl_arb = json.load(f)
for k in new_keys.keys():
    v = uz_arb[k]
    # save variables from being localized
    parts = []
    def replace_var(m):
        parts.append(m.group(0))
        return f'X{len(parts)-1}X'
    masked = re.sub(r'\{[^}]+\}', replace_var, v)
    cyr_masked = uz_latin_to_cyrillic(masked)
    for i, p in enumerate(parts):
        cyr_masked = cyr_masked.replace(f'X{i}X', p)
    cyrl_arb[k] = cyr_masked
with open(cyrl_path, 'w', encoding='utf-8') as f: json.dump(cyrl_arb, f, indent=4, ensure_ascii=False)
print('Success translating new keys')
