import os, re
scan_path = r'd:\dev\projects\iFridge\frontend\lib\features\scan\presentation\screens\scan_screen.dart'
shelf_path = r'd:\dev\projects\iFridge\frontend\lib\features\shelf\presentation\screens\living_shelf_screen.dart'

def extract(path):
    with open(path, 'r', encoding='utf-8') as f: c = f.read()
    return re.findall(r"Text\(\s*'([^']+)'", c)

print('Scan:', extract(scan_path))
print('Shelf:', extract(shelf_path))
