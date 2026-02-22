import sys
from PIL import Image

src = r"C:\Users\shuku\.gemini\antigravity\brain\1af7e7dd-45e9-4d9e-82d3-b950b8bcbf5b\media__1771779969517.jpg"
img = Image.open(src)
w, h = img.size

# The user explicitly asked to crop it the SAME way I did my previous attempt:
left = int(w * 0.16)
top = int(h * 0.16)
right = int(w * 0.84)
bottom = int(h * 0.84)
cropped = img.crop((left, top, right, bottom))

# Resize and save
cropped.resize((512, 512), Image.Resampling.LANCZOS).save(r"d:\New folder\frontend\web\icons\Icon-512.png")
cropped.resize((192, 192), Image.Resampling.LANCZOS).save(r"d:\New folder\frontend\web\icons\Icon-192.png")
cropped.resize((192, 192), Image.Resampling.LANCZOS).save(r"d:\New folder\frontend\web\favicon.png")

print(f"Original: {w}x{h}, Cropped using 0.16 -> 0.84")
print("Cropped user image successfully!")
