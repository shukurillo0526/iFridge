import os
import re

# Dictionary mapping static theme calls to context-aware theme calls
REPLACEMENTS = {
    # Backgrounds
    r'IFridgeTheme\.bgDark': r'Theme.of(context).scaffoldBackgroundColor',
    r'AppTheme\.background': r'Theme.of(context).scaffoldBackgroundColor',
    r'IFridgeTheme\.bgCard': r'Theme.of(context).colorScheme.surface',
    r'AppTheme\.surface': r'Theme.of(context).colorScheme.surface',
    r'IFridgeTheme\.bgElevated': r'Theme.of(context).colorScheme.surfaceContainerHighest',
    r'IFridgeTheme\.bgGlass': r'Theme.of(context).colorScheme.surface.withOpacity(0.1)',
    
    # Brand Colors
    r'IFridgeTheme\.primary': r'Theme.of(context).colorScheme.primary',
    r'IFridgeTheme\.accent': r'Theme.of(context).colorScheme.secondary',
    r'IFridgeTheme\.secondary': r'Theme.of(context).colorScheme.secondary',
    r'AppTheme\.accent': r'Theme.of(context).colorScheme.primary',
    
    # Text
    r'IFridgeTheme\.textPrimary': r'Theme.of(context).colorScheme.onSurface',
    r'IFridgeTheme\.textSecondary': r'(Theme.of(context).brightness == Brightness.dark ? const Color(0xFFA1A8B8) : const Color(0xFF5B6370))',
    r'IFridgeTheme\.textMuted': r'(Theme.of(context).brightness == Brightness.dark ? const Color(0xFF5B6370) : const Color(0xFF8B949E))',
    
    # Status / Tier
    r'IFridgeTheme\.success': r'Theme.of(context).colorScheme.tertiary',
    r'IFridgeTheme\.freshGreen': r'Theme.of(context).colorScheme.tertiary',
    r'AppTheme\.freshGreen': r'Theme.of(context).colorScheme.tertiary',
    r'IFridgeTheme\.error': r'Theme.of(context).colorScheme.error',
    r'IFridgeTheme\.criticalRed': r'Theme.of(context).colorScheme.error',
    r'IFridgeTheme\.urgentOrange': r'Theme.of(context).colorScheme.primary',
    r'IFridgeTheme\.agingAmber': r'Theme.of(context).colorScheme.secondary',
    r'IFridgeTheme\.expiredGrey': r'(Theme.of(context).brightness == Brightness.dark ? const Color(0xFFA1A8B8) : const Color(0xFF5B6370))',
}

def remove_invalid_consts(content):
    # This is a basic heuristic to remove `const` before widgets that now use Theme.of(context)
    # It removes 'const ' if it's on the same line as Theme.of
    lines = content.split('\n')
    for i in range(len(lines)):
        if 'Theme.of(context)' in lines[i] or 'Brightness.dark' in lines[i]:
            # Replace `const ` with ` ` but carefully
            lines[i] = re.sub(r'\bconst\s+(?=[A-Z])', '', lines[i])
            # Remove const from BoxConstraints, EdgeInsets, etc if they are inside a tree that got un-consted?
            # Actually, just removing const from the immediate line helps flutter analyze find the rest.
    return '\n'.join(lines)

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    original = content
    
    # Apply replacements
    for pattern, replacement in REPLACEMENTS.items():
        content = re.sub(pattern, replacement, content)
        
    if content != original:
        content = remove_invalid_consts(content)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

if __name__ == '__main__':
    base_dir = r'd:\dev\projects\iFridge\frontend\lib'
    changed_files = 0
    
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                if process_file(filepath):
                    changed_files += 1
                    print(f"Updated: {filepath}")
                    
    print(f"\nTotal files updated: {changed_files}")
