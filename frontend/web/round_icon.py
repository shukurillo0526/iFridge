import math
from PIL import Image, ImageDraw

def round_and_crop():
    # Open the user's original favicon
    img_path = 'favicon.png'
    try:
        img = Image.open(img_path).convert("RGBA")
    except FileNotFoundError:
        print("Could not find favicon.png in this folder.")
        return

    # 1. Zoom/Crop out the background edges
    # We will crop 12% from each side to remove the white border
    width, height = img.size
    crop_x = int(width * 0.12)
    crop_y = int(height * 0.12)
    cropped = img.crop((crop_x, crop_y, width - crop_x, height - crop_y))
    
    # Resize back to standard 512x512
    size = 512
    cropped = cropped.resize((size, size), Image.Resampling.LANCZOS)
    
    # 2. Apply a rounded mask
    # Create a mask with rounded corners
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    
    # Squircle corner radius
    radius = int(size * 0.25)
    
    # Draw rounded rectangle
    draw.rounded_rectangle((0, 0, size, size), radius=radius, fill=255)
    
    # Apply the mask to the cropped image
    result = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    result.paste(cropped, (0, 0), mask)
    
    # Save over the same file
    result.save('favicon.png')
    print("Successfully cropped and rounded favicon.png!")

if __name__ == '__main__':
    round_and_crop()
