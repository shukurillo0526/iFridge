import os
import re

def nuke_consts(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    
    widgets = [
        'Text', 'Row', 'Column', 'Center', 'SizedBox', 'Icon', 'Padding', 
        'Container', 'Stack', 'Positioned', 'Expanded', 'Flexible', 'Align', 
        'ListView', 'GridView', 'SingleChildScrollView', 'BoxDecoration', 
        'EdgeInsets', 'BorderRadius', 'Border', 'BoxShadow', 'SweepGradient', 
        'LinearGradient', 'CircularProgressIndicator', 'LinearProgressIndicator', 
        'Spacer', 'TextStyle', 'Color', 'BorderSide', 'IconThemeData', 'SnackBar'
    ]
    
    for w in widgets:
        content = re.sub(r'\bconst\s+' + w + r'\b', w, content)
        
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

if __name__ == '__main__':
    base_dir = r'd:\dev\projects\iFridge\frontend\lib'
    count = 0
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                if nuke_consts(filepath):
                    count += 1
    print(f"Nuked consts in {count} files. Now run 'dart fix --apply'.")
