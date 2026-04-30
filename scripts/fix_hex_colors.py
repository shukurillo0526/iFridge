"""
Script to fix remaining 86 hardcoded hex colors.
"""
import os
import re

def fix(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content

    # Replace old primary orange
    content = content.replace('Color(0xFFFF6D00)', 'Theme.of(context).colorScheme.primary')
    # Replace secondary orange used in gradients
    content = content.replace('Color(0xFFFF9100)', 'Theme.of(context).colorScheme.tertiary')
    
    # Replace blues used in gradients
    content = content.replace('Color(0xFF2962FF)', 'Colors.blue.shade700')
    content = content.replace('Color(0xFF448AFF)', 'Colors.blue.shade400')
    
    # Replace teals used in gradients
    content = content.replace('Color(0xFF00897B)', 'Colors.teal.shade600')
    content = content.replace('Color(0xFF26A69A)', 'Colors.teal.shade400')
    
    # Replace dark grey
    content = content.replace('Color(0xFF455A64)', 'Colors.blueGrey.shade700')
    
    # Other random hexes found in enforce_theme output
    content = content.replace('Color(0xFF7b1fa2)', 'Colors.purple.shade700')
    content = content.replace('Color(0xFF1b5e20)', 'Colors.green.shade900')
    content = content.replace('Color(0xFF2e7d32)', 'Colors.green.shade800')

    # Since we are using Theme.of(context), we need to strip `const` from arrays that contain them.
    # e.g., `gradient: const [Theme.of(context)...]` is invalid Dart.
    # This regex looks for `const [` and if what follows contains Theme.of(context), strips const.
    def remove_const_from_array(match):
        inner = match.group(1)
        if 'Theme.of(context)' in inner:
            return f'[{inner}]'
        return match.group(0)

    content = re.sub(r'const\s+\[(.*?)\]', remove_const_from_array, content, flags=re.DOTALL)
    
    # Also fix `const Color(...)` which is no longer const if replaced
    content = content.replace('const Theme.of(context)', 'Theme.of(context)')
    content = content.replace('const Colors.', 'Colors.')

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

if __name__ == '__main__':
    base = r'd:\dev\projects\iFridge\frontend\lib'
    fixed = 0
    for root, dirs, files in os.walk(base):
        for f in files:
            if f.endswith('.dart') and f != 'app_theme.dart':
                path = os.path.join(root, f)
                if fix(path):
                    fixed += 1
                    print(f'Fixed {os.path.relpath(path, base)}')
    print(f'Total fixed files: {fixed}')
