import os
import re
import json

def to_camel_case(text):
    clean = re.sub(r'[^a-zA-Z0-9\s]', '', text)
    words = clean.strip().split()
    if not words: return None
    return words[0].lower() + ''.join(w.capitalize() for w in words[1:])

def main():
    files_to_localize = [
        r"d:\dev\projects\iFridge\frontend\lib\features\scan\presentation\screens\scan_screen.dart",
        r"d:\dev\projects\iFridge\frontend\lib\features\cook\presentation\screens\cook_screen.dart",
        r"d:\dev\projects\iFridge\frontend\lib\features\shelf\presentation\widgets\inventory_detail_sheet.dart"
    ]
    
    l10n_dir = r"d:\dev\projects\iFridge\frontend\lib\l10n"
    
    arbs = {}
    for lang in ['en', 'ko', 'ru', 'uz', 'uz_Cyrl']:
        path = os.path.join(l10n_dir, f"app_{lang}.arb")
        with open(path, 'r', encoding='utf-8') as f:
            arbs[lang] = json.load(f)

    # Regex to catch Text('...') or Text("...") or SnackBar(content: Text('...'))
    pattern = re.compile(r"Text\(['\"]([^'\$]+?)['\"]\s*(?:,|[,)]|style:)")

    for filepath in files_to_localize:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        matches = pattern.finditer(content)
        replacements = []
        
        for m in matches:
            original_text = m.group(1).strip()
            if len(original_text) < 2: continue
            if '{' in original_text or '}' in original_text: continue
            if not re.search(r'[a-zA-Z]', original_text): continue
            
            key = to_camel_case(original_text)
            if not key or len(key) < 2: continue
            
            key = "auto_" + key
            
            if key not in arbs['en']:
                for lang in arbs: arbs[lang][key] = original_text

            full_match = m.group(0)
            new_text = full_match.replace(f"'{m.group(1)}'", f"AppLocalizations.of(context)?.{key} ?? '{m.group(1)}'")
            new_text = new_text.replace(f'"{m.group(1)}"', f"AppLocalizations.of(context)?.{key} ?? '{m.group(1)}'")
            replacements.append((full_match, new_text))

        if replacements:
            if "import 'package:ifridge_app/l10n/app_localizations.dart';" not in content:
                content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:ifridge_app/l10n/app_localizations.dart';")
            
            for old, new in replacements:
                content = content.replace(old, new)
            
            # Simple hack to fix common const issues before we even analyze
            content = content.replace("const [ Text(AppLocalizations", "[ Text(AppLocalizations")
            content = content.replace("const [Text(AppLocalizations", "[Text(AppLocalizations")
            content = content.replace("const Text(AppLocalizations", "Text(AppLocalizations")
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)

    for lang, data in arbs.items():
        path = os.path.join(l10n_dir, f"app_{lang}.arb")
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    main()
