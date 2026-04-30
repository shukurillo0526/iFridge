import os
import subprocess
import re

def main():
    print("Running flutter build to find const errors...")
    result = subprocess.run(["flutter", "build", "apk", "--debug"], cwd=r"d:\dev\projects\iFridge\frontend", capture_output=True, text=True, shell=True)
    
    error_pattern = re.compile(r"lib/(.*?\.dart):(\d+):\d+: Error: Not a constant expression.")
    
    files_to_fix = {}
    
    for line in result.stdout.split('\n') + result.stderr.split('\n'):
        match = error_pattern.search(line)
        if match:
            filepath = os.path.join(r"d:\dev\projects\iFridge\frontend\lib", match.group(1).replace('/', '\\'))
            line_num = int(match.group(2))
            
            if filepath not in files_to_fix:
                files_to_fix[filepath] = set()
            files_to_fix[filepath].add(line_num)
            
    if not files_to_fix:
        print("No const errors found.")
        return
        
    for filepath, lines in files_to_fix.items():
        print(f"Fixing {filepath}...")
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read().split('\n')
            
        for line_num in lines:
            # line_num is 1-indexed
            idx = line_num - 1
            if idx < len(content):
                # We simply remove 'const ' from the line
                # It might be in a preceding line if formatted weirdly, but usually it's on the same line or we can just replace 'const '
                content[idx] = re.sub(r'\bconst\s+', '', content[idx])
                
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(content))

if __name__ == '__main__':
    # Run it twice just in case removing one exposes another
    main()
    main()
