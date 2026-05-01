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

l10n_dir = r'd:\dev\projects\iFridge\frontend\lib\l10n'
en_path = os.path.join(l10n_dir, 'app_en.arb')

with open(en_path, 'r', encoding='utf-8') as f: en = json.load(f)

targets = {'ko': 'ko', 'ru': 'ru', 'uz': 'uz'}
for lang, gcode in targets.items():
    path = os.path.join(l10n_dir, f'app_{lang}.arb')
    with open(path, 'r', encoding='utf-8') as f: data = json.load(f)
    
    # Find untranslated keys
    untranslated = [k for k,v in data.items() if not k.startswith('@') and v == en.get(k)]
    print(f"{lang} has {len(untranslated)} untranslated keys.")
    
    for k in untranslated:
        v = en[k]
        if '{' in v:
            # Mask variables
            parts = []
            import re
            def replace_var(m):
                parts.append(m.group(0))
                return f' X{len(parts)-1}X '
            masked = re.sub(r'\{[^}]+\}', replace_var, v)
            translated = translate(masked, gcode)
            for i, p in enumerate(parts):
                translated = translated.replace(f'X{i}X', p)
                # also try without spaces in case google removed them
                translated = translated.replace(f' X{i}X ', p)
            data[k] = translated.replace('  ', ' ')
        else:
            data[k] = translate(v, gcode)
        # Avoid rate limit somewhat
        time.sleep(0.01)
        
    with open(path, 'w', encoding='utf-8') as f: json.dump(data, f, indent=4, ensure_ascii=False)

# Cyrl
uz_path = os.path.join(l10n_dir, 'app_uz.arb')
with open(uz_path, 'r', encoding='utf-8') as f: uz_arb = json.load(f)
cyrl_path = os.path.join(l10n_dir, 'app_uz_Cyrl.arb')
with open(cyrl_path, 'r', encoding='utf-8') as f: cyrl_arb = json.load(f)
for k in en.keys():
    if not k.startswith('@') and k in uz_arb:
        cyrl_arb[k] = uz_latin_to_cyrillic(uz_arb[k])
with open(cyrl_path, 'w', encoding='utf-8') as f: json.dump(cyrl_arb, f, indent=4, ensure_ascii=False)

# Need to manually fix the placeholders that might have been touched by Cyrl
# We know the specific Cyrl placeholders that need to be reverted
cyrl_to_latin = {
    '{сервингс}': '{servings}',
    '{неwСервингс}': '{newServings}',
    '{ингредиентНаме}': '{ingredientName}',
    '{матч}': '{match}',
    '{cоунт}': '{count}',
    '{е}': '{e}',
    '{тиер}': '{tier}',
}
for k, v in cyrl_arb.items():
    if isinstance(v, str):
        for cyr, lat in cyrl_to_latin.items():
            v = v.replace(cyr, lat)
        cyrl_arb[k] = v

with open(cyrl_path, 'w', encoding='utf-8') as f: json.dump(cyrl_arb, f, indent=4, ensure_ascii=False)

print("Done translating missing strings!")
