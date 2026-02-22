import sys
from PIL import Image

src = r"C:\Users\shuku\.gemini\antigravity\brain\1af7e7dd-45e9-4d9e-82d3-b950b8bcbf5b\ifridge_icon_v2_1771778862604.png"
img = Image.open(src)
w, h = img.size

# Crop the central square (about 70% of the image)
# Based on visually inspecting the generated image
left = w * 0.16
top = h * 0.16
right = w * 0.84
bottom = h * 0.84

cropped = img.crop((left, top, right, bottom))

# Resize and save
cropped.resize((512, 512), Image.Resampling.LANCZOS).save(r"d:\New folder\frontend\web\icons\Icon-512.png")
cropped.resize((192, 192), Image.Resampling.LANCZOS).save(r"d:\New folder\frontend\web\icons\Icon-192.png")
cropped.resize((192, 192), Image.Resampling.LANCZOS).save(r"d:\New folder\frontend\web\favicon.png")

print("Cropped and saved successfully!")
