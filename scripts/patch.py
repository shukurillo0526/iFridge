import os
cook_path = r'd:\dev\projects\iFridge\frontend\lib\features\cook\presentation\screens\cook_screen.dart'
scan_path = r'd:\dev\projects\iFridge\frontend\lib\features\scan\presentation\screens\scan_screen.dart'

with open(cook_path, 'r', encoding='utf-8') as f: cook = f.read()
cook = cook.replace("Text(\n          'What to Cook?',", "Text(\n          AppLocalizations.of(context)?.whatToCook ?? 'What to Cook?',")
cook = cook.replace("label: 'Perfect'", "label: AppLocalizations.of(context)?.tierPerfect ?? 'Perfect'")
cook = cook.replace("label: 'For You'", "label: AppLocalizations.of(context)?.tierForYou ?? 'For You'")
cook = cook.replace("label: 'Use It Up'", "label: AppLocalizations.of(context)?.tierUseItUp ?? 'Use It Up'")
cook = cook.replace("label: 'Almost'", "label: AppLocalizations.of(context)?.tierAlmost ?? 'Almost'")
cook = cook.replace("label: 'Explore'", "label: AppLocalizations.of(context)?.tierExplore ?? 'Explore'")
cook = cook.replace("Text('No ${meta.label} recipes yet'", "Text(AppLocalizations.of(context)?.noTierRecipesYet(meta.label) ?? 'No ${meta.label} recipes yet'")
cook = cook.replace("Text('Add items to your shelf to get recommendations'", "Text(AppLocalizations.of(context)?.addItemsForRecommendations ?? 'Add items to your shelf to get recommendations'")
with open(cook_path, 'w', encoding='utf-8') as f: f.write(cook)

with open(scan_path, 'r', encoding='utf-8') as f: scan = f.read()
scan = scan.replace("text: 'Scan Food'", "text: AppLocalizations.of(context)?.scanFood ?? 'Scan Food'")
scan = scan.replace("text: 'Scan Calories'", "text: AppLocalizations.of(context)?.scanCaloriesTab ?? 'Scan Calories'")
scan = scan.replace("Text('Scan Your Ingredients'", "Text(AppLocalizations.of(context)?.scanYourIngredients ?? 'Scan Your Ingredients'")
scan = scan.replace("Text('Take a photo of food items to add them to your shelf automatically'", "Text(AppLocalizations.of(context)?.takePhotoToAdd ?? 'Take a photo of food items to add them to your shelf automatically'")
scan = scan.replace("value: 'Receipt', label: Text('Receipt')", "value: 'Receipt', label: Text(AppLocalizations.of(context)?.scanReceipt ?? 'Receipt')")
scan = scan.replace("value: 'Photo', label: Text('Photo')", "value: 'Photo', label: Text(AppLocalizations.of(context)?.scanPhoto ?? 'Photo')")
scan = scan.replace("value: 'Barcode', label: Text('Barcode')", "value: 'Barcode', label: Text(AppLocalizations.of(context)?.scanBarcode ?? 'Barcode')")
scan = scan.replace("Text('Take Photo'", "Text(AppLocalizations.of(context)?.takePhotoBtn ?? 'Take Photo'")
scan = scan.replace("Text('Choose from Gallery'", "Text(AppLocalizations.of(context)?.chooseFromGallery ?? 'Choose from Gallery'")
with open(scan_path, 'w', encoding='utf-8') as f: f.write(scan)
