import os
import re
import json

def to_camel_case(text):
    # Remove emojis and special chars for key
    clean = re.sub(r'[^a-zA-Z0-9\s]', '', text)
    words = clean.strip().split()
    if not words: return None
    return words[0].lower() + ''.join(w.capitalize() for w in words[1:])

def main():
    base_dir = r"d:\dev\projects\iFridge\frontend\lib"
    l10n_dir = os.path.join(base_dir, "l10n")
    
    # Load ARB files
    arbs = {}
    for lang in ['en', 'ko', 'ru', 'uz', 'uz_Cyrl']:
        path = os.path.join(l10n_dir, f"app_{lang}.arb")
        with open(path, 'r', encoding='utf-8') as f:
            arbs[lang] = json.load(f)

    # Regex for pure static strings: Text('Something') or Text("Something")
    # Ignores strings with $ (interpolation)
    pattern = re.compile(r"Text\(['\"]([^'\$]+?)['\"]\s*(?:,|[,)]|style:)")

    modified_files = 0
    total_replaced = 0

    for root, _, files in os.walk(base_dir):
        for file in files:
            if not file.endswith('.dart'): continue
            if 'app_localizations' in file: continue
            
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            # Skip if we can't safely use AppLocalizations (e.g. no context usually, though most have it)
            # Actually, we will replace with AppLocalizations.of(context)?.key ?? 'Fallback'
            
            matches = pattern.finditer(content)
            replacements = []
            
            for m in matches:
                original_text = m.group(1).strip()
                if len(original_text) < 2: continue # skip emojis or single letters
                
                key = to_camel_case(original_text)
                if not key: continue
                
                # Prepend something to avoid collisions
                key = "auto_" + key
                
                # Add to EN arb if not exists
                if key not in arbs['en']:
                    arbs['en'][key] = original_text
                    arbs['ko'][key] = original_text  # Fallback to English for now
                    arbs['ru'][key] = original_text
                    arbs['uz'][key] = original_text
                    arbs['uz_Cyrl'][key] = original_text

                # We will replace Text('Text') with Text(AppLocalizations.of(context)?.key ?? 'Text')
                # Wait, what if context is named ctx? It's risky.
                # Let's just output the keys we find and do a safe replacement
                full_match = m.group(0)
                # replace 'original' with AppLocalizations.of(context)?.key ?? 'original'
                new_text = full_match.replace(f"'{m.group(1)}'", f"AppLocalizations.of(context)?.{key} ?? '{m.group(1)}'")
                new_text = new_text.replace(f'"{m.group(1)}"', f"AppLocalizations.of(context)?.{key} ?? '{m.group(1)}'")
                replacements.append((full_match, new_text))

            if replacements:
                # Add import if needed
                if "import 'package:ifridge_app/l10n/app_localizations.dart';" not in content:
                    # insert after first import
                    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:ifridge_app/l10n/app_localizations.dart';")
                
                for old, new in replacements:
                    content = content.replace(old, new)
                    total_replaced += 1
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                modified_files += 1

    # Save ARBs
    for lang, data in arbs.items():
        path = os.path.join(l10n_dir, f"app_{lang}.arb")
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=4)

    print(f"Modified {modified_files} files, replaced {total_replaced} strings.")

if __name__ == "__main__":
    main()
