import json
import os
import urllib.request
import urllib.parse
import time

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

new_keys = {
    'adjustPortions': 'Adjust Portions',
    'currentRecipeMakesNServings': 'Current recipe makes {servings} servings.',
    'scaleToNServings': 'Scale to {newServings} Servings',
    'scaledToNServings': 'Scaled to {newServings} servings 🍳',
    'findingSubstitutesForX': 'Finding substitutes for {ingredientName}...',
    'couldNotFindSubstitutes': 'Could not find substitutes',
    'substitutesForX': 'Substitutes for "{ingredientName}"',
    'noSubstitutesFoundForThisRecipeContext': 'No substitutes found for this recipe context.',
    'nMatch': '{match}% Match',
    'ingredientsWithCount': 'Ingredients ({count})',
    'scale': 'Scale',
    'addedMissingItemsToShoppingList': 'Added missing items to Shopping List!',
    'failedToAddItemsX': 'Failed to add items: {e}',
    'addMissingToShoppingList': 'Add missing to Shopping List',
    'cookingStepsWithCount': 'Cooking Steps ({count})',
    'noStepsAvailableYet': 'No steps available yet',
    'recordedTasteProfileEvolving': 'Recorded! Your taste profile is evolving 🧠',
    'failedToRecordX': 'Failed to record: {e}',
    'iCookedThis': 'I Cooked This!',
    'startCooking': 'Start Cooking',
    'optional_tag': 'optional',
    'servings_tag': 'servings',
    'min_tag': 'min',
    'difficulty_tag': 'Difficulty'
}

l10n_dir = r'd:\dev\projects\iFridge\frontend\lib\l10n'
en_path = os.path.join(l10n_dir, 'app_en.arb')

with open(en_path, 'r', encoding='utf-8') as f: data = json.load(f)
for k, v in new_keys.items():
    data[k] = v
    if '{' in v:
        placeholders = {}
        for var in ['servings', 'newServings', 'ingredientName', 'match', 'count', 'e']:
            if '{'+var+'}' in v: placeholders[var] = {'type': 'String'}
        data['@'+k] = {'placeholders': placeholders}
with open(en_path, 'w', encoding='utf-8') as f: json.dump(data, f, indent=4, ensure_ascii=False)

targets = {'ko': 'ko', 'ru': 'ru', 'uz': 'uz'}
for lang, gcode in targets.items():
    path = os.path.join(l10n_dir, f'app_{lang}.arb')
    with open(path, 'r', encoding='utf-8') as f: data = json.load(f)
    for k, v in new_keys.items():
        if '{' in v:
            var_name = v[v.find('{')+1:v.find('}')]
            translated = translate(v.replace('{', 'XXX').replace('}', 'YYY'), gcode)
            translated = translated.replace('XXXYYY', '{' + var_name + '}')
            data[k] = translated.replace('XXX', '{').replace('YYY', '}')
        else:
            data[k] = translate(v, gcode)
        time.sleep(0.05)
    with open(path, 'w', encoding='utf-8') as f: json.dump(data, f, indent=4, ensure_ascii=False)

# Cyrl
uz_path = os.path.join(l10n_dir, 'app_uz.arb')
with open(uz_path, 'r', encoding='utf-8') as f: uz_arb = json.load(f)
cyrl_path = os.path.join(l10n_dir, 'app_uz_Cyrl.arb')
with open(cyrl_path, 'r', encoding='utf-8') as f: cyrl_arb = json.load(f)
for k in new_keys.keys():
    cyrl_arb[k] = uz_latin_to_cyrillic(uz_arb[k])
with open(cyrl_path, 'w', encoding='utf-8') as f: json.dump(cyrl_arb, f, indent=4, ensure_ascii=False)
