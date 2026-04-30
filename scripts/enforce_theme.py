"""
iFridge Theme Enforcer Script
================================
Run this script to ensure that no hardcoded colors break the Dual-Mode (Light/Dark) design system.
This script checks all .dart files in the lib/ folder (except app_theme.dart and painters).
If forbidden colors are found, the script will print the violations and exit with code 1.
"""

import os
import re
import sys

# Regex definitions
FORBIDDEN_PATTERNS = [
    (r'(?<!\.)Colors\.(white|black)(?!\d|\.)', 'Hardcoded Colors.white or Colors.black. Use Theme.of(context).colorScheme.onSurface or .surface instead.'),
    (r'Colors\.(black|white)\d+', 'Hardcoded Colors.black87 etc. Use Theme.of(context).colorScheme.onSurface.withValues(alpha: X) instead.'),
    (r'Color\(0xFF[a-fA-F0-9]{6}\)', 'Hardcoded hex Color(0xFF...). Add it to app_theme.dart and reference it via Theme.of(context) instead.'),
    (r'isDark\s*\?\s*Theme\.of\(context\)\.colorScheme\.surface\s*:\s*Theme\.of\(context\)\.colorScheme\.onSurface', 'Broken ternary: Using onSurface as a light mode background! Use just surface instead.')
]

# Files that are allowed to define colors
ALLOWED_FILES = [
    'app_theme.dart',
    'app_colors.dart'
]

# We skip checking inside CustomPainters because they don't have BuildContext
PAINTER_CLASS_RE = re.compile(
    r'class\s+(\w+)\s+extends\s+CustomPainter\s*\{.*?\n\}',
    re.DOTALL
)

def extract_painters(content):
    painters = []
    for m in PAINTER_CLASS_RE.finditer(content):
        painters.append((m.start(), m.end(), m.group(0)))
    return painters

def is_inside_painter(pos, painters):
    for start, end, _ in painters:
        if start <= pos < end:
            return True
    return False

def check_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    painters = extract_painters(content)
    violations = []
    
    lines = content.split('\n')
    
    for idx, line in enumerate(lines):
        line_num = idx + 1
        # To avoid calculating exact offset for each line, we just do a quick check:
        # if the line contains a forbidden pattern, we find its global position to check if it's in a painter.
        for pattern, message in FORBIDDEN_PATTERNS:
            for match in re.finditer(pattern, line):
                # find global pos roughly
                global_pos = content.find(line) + match.start()
                if not is_inside_painter(global_pos, painters):
                    violations.append(f"  Line {line_num}: {match.group(0)} -> {message}")
                    
    return violations

def main():
    # Allow running from either root or scripts/ folder
    base = 'frontend/lib' if os.path.exists('frontend/lib') else '../frontend/lib'
    if not os.path.exists(base):
        base = 'lib' # if running inside frontend/

    if not os.path.exists(base):
        print("Error: Could not find lib/ directory.")
        sys.exit(1)

    total_violations = 0

    for root, _, files in os.walk(base):
        for f in files:
            if f.endswith('.dart') and f not in ALLOWED_FILES:
                path = os.path.join(root, f)
                violations = check_file(path)
                
                if violations:
                    print(f"\n[FAIL] {os.path.relpath(path, base)}")
                    for v in violations:
                        print(v)
                    total_violations += len(violations)

    if total_violations > 0:
        print(f"\n[ALERT] Theme check failed! {total_violations} hardcoded color violations found.")
        print("Please replace them with context-aware Theme.of(context) references.")
        sys.exit(1)
    else:
        print("\n[OK] Theme check passed! No hardcoded colors found.")
        sys.exit(0)

if __name__ == '__main__':
    main()
