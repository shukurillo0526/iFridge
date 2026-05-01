import json
import os
import urllib.request
import urllib.parse
import time

def translate(text, target_lang):
    if not text or text.strip() == "":
        return text
    
    # Handle variables like {tier} -> don't translate
    # For a simple script, we'll just translate the whole string. 
    # If it contains {tier}, we might need to fix it manually, but let's see.
    # Google translate sometimes preserves {tier} or translates it.
    
    try:
        url = f"https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl={target_lang}&dt=t&q={urllib.parse.quote(text)}"
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode('utf-8'))
            return "".join([x[0] for x in data[0]])
    except Exception as e:
        print(f"Error translating '{text}': {e}")
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
    for lat, cyr in mapping.items():
        text = text.replace(lat, cyr)
    return text

def main():
    l10n_dir = r"d:\dev\projects\iFridge\frontend\lib\l10n"
    
    with open(os.path.join(l10n_dir, "app_en.arb"), 'r', encoding='utf-8') as f:
        en_arb = json.load(f)
        
    keys_to_translate = {k: v for k, v in en_arb.items() if (k.startswith('auto_') or k in [
        'whatToCook', 'tierPerfect', 'tierForYou', 'tierUseItUp', 'tierAlmost', 
        'tierExplore', 'noTierRecipesYet', 'addItemsForRecommendations', 
        'scanFood', 'scanCaloriesTab', 'scanYourIngredients', 'takePhotoToAdd', 
        'scanReceipt', 'scanPhoto', 'scanBarcode', 'takePhotoBtn', 'chooseFromGallery'
    ]) and not k.startswith('@')}

    targets = {'ko': 'ko', 'ru': 'ru', 'uz': 'uz'}
    
    for lang_code, google_code in targets.items():
        path = os.path.join(l10n_dir, f"app_{lang_code}.arb")
        with open(path, 'r', encoding='utf-8') as f:
            arb = json.load(f)
            
        print(f"Translating to {lang_code}...")
        for k, en_text in keys_to_translate.items():
            # If it's already translated (i.e. not equal to English), skip
            # Wait, our previous script SET the Korean value to the English value!
            # So we MUST translate if arb[k] == en_text
            if k not in arb or arb[k] == en_text:
                if "{tier}" in en_text:
                    # Special handling
                    translated = translate(en_text.replace("{tier}", "XXX"), google_code)
                    translated = translated.replace("XXX", "{tier}")
                else:
                    translated = translate(en_text, google_code)
                arb[k] = translated
                # print removed
                
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(arb, f, ensure_ascii=False, indent=4)
            
    # Do Cyrl
    print("Generating uz_Cyrl...")
    uz_path = os.path.join(l10n_dir, "app_uz.arb")
    with open(uz_path, 'r', encoding='utf-8') as f: uz_arb = json.load(f)
    
    cyrl_path = os.path.join(l10n_dir, "app_uz_Cyrl.arb")
    with open(cyrl_path, 'r', encoding='utf-8') as f: cyrl_arb = json.load(f)
    
    for k in keys_to_translate.keys():
        if k in uz_arb:
            cyrl_arb[k] = uz_latin_to_cyrillic(uz_arb[k])
            
    with open(cyrl_path, 'w', encoding='utf-8') as f:
        json.dump(cyrl_arb, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    main()
