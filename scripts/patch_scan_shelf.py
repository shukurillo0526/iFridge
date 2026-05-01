import os

scan_path = r'd:\dev\projects\iFridge\frontend\lib\features\scan\presentation\screens\scan_screen.dart'
shelf_path = r'd:\dev\projects\iFridge\frontend\lib\features\shelf\presentation\screens\living_shelf_screen.dart'

with open(scan_path, 'r', encoding='utf-8') as f: scan = f.read()
with open(shelf_path, 'r', encoding='utf-8') as f: shelf = f.read()

scan_reps = {
    "Text(\n                'Scan Your Ingredients',": "Text(\n                AppLocalizations.of(context)?.scanYourIngredients ?? 'Scan Your Ingredients',",
    "Text(\n                'Take a photo of food items to add them\\nto your shelf automatically',": "Text(\n                AppLocalizations.of(context)?.takeAPhotoOfFoodItems ?? 'Take a photo of food items to add them\\nto your shelf automatically',",
    "label: Text(\n                      'Take Photo',": "label: Text(\n                      AppLocalizations.of(context)?.takePhoto ?? 'Take Photo',",
    "label: Text(\n                      'Scan Barcode',": "label: Text(\n                      AppLocalizations.of(context)?.scanBarcode ?? 'Scan Barcode',",
    "label: Text(\n                      'Choose from Gallery',": "label: Text(\n                      AppLocalizations.of(context)?.chooseFromGallery ?? 'Choose from Gallery',",
    "label: Text(\n                    'Add Manually',": "label: Text(\n                    AppLocalizations.of(context)?.addManually ?? 'Add Manually',",
    "child: Text(\n                          'Recognition failed. Try again.',": "child: Text(\n                          AppLocalizations.of(context)?.recognitionFailed ?? 'Recognition failed. Try again.',",
    "Text(\n              'Analyzing your food...',": "Text(\n              AppLocalizations.of(context)?.analyzingYourFood ?? 'Analyzing your food...',",
    "Text(\n              'AI is identifying ingredients',": "Text(\n              AppLocalizations.of(context)?.aiIsIdentifying ?? 'AI is identifying ingredients',",
    "child: Text(\n                        '${items.length} Items Detected',": "child: Text(\n                        AppLocalizations.of(context)?.nItemsDetected(items.length.toString()) ?? '${items.length} Items Detected',",
    "Text(\n                      'Photo Analysis Selected',": "Text(\n                      AppLocalizations.of(context)?.photoAnalysisSelected ?? 'Photo Analysis Selected',",
    "child: Text(\n                        '${items.length} Ingredients Detected',": "child: Text(\n                        AppLocalizations.of(context)?.nIngredientsDetected(items.length.toString()) ?? '${items.length} Ingredients Detected',",
    "child: Text(\n                      '${_addedIndices.length} / ${items.length} added',": "child: Text(\n                      AppLocalizations.of(context)?.nOfNAdded(_addedIndices.length.toString(), items.length.toString()) ?? '${_addedIndices.length} / ${items.length} added',",
    "content: Text('Added $canonicalName!')": "content: Text(AppLocalizations.of(context)?.addedItem(canonicalName) ?? 'Added $canonicalName!')",
    "content: Text('Failed to add $canonicalName')": "content: Text(AppLocalizations.of(context)?.failedToAddItem(canonicalName) ?? 'Failed to add $canonicalName')",
    "content: Text('Added $added items to shelf!')": "content: Text(AppLocalizations.of(context)?.addedNItemsToShelf(added.toString()) ?? 'Added $added items to shelf!')",
    "Text('No product found for barcode $barcode')": "Text(AppLocalizations.of(context)?.noProductFoundForBarcode(barcode) ?? 'No product found for barcode $barcode')",
    "Text('Added $_ingredientName to shelf!')": "Text(AppLocalizations.of(context)?.addedItemToShelf(_ingredientName) ?? 'Added $_ingredientName to shelf!')",
    "Text('Error: $e')": "Text(AppLocalizations.of(context)?.errorX(e.toString()) ?? 'Error: $e')",
    "Text('Analysis failed: $e')": "Text(AppLocalizations.of(context)?.analysisFailedX(e.toString()) ?? 'Analysis failed: $e')",
    "Text('Failed to log: $e')": "Text(AppLocalizations.of(context)?.failedToLogX(e.toString()) ?? 'Failed to log: $e')"
}

shelf_reps = {
    "Text('⚠️',": "Text('⚠️',",
    "Text('Expiring Soon',": "Text(AppLocalizations.of(context)?.expiringSoon ?? 'Expiring Soon',",
    "Text('${urgentItems.length} item(s) need attention',": "Text(AppLocalizations.of(context)?.nItemsNeedAttention(urgentItems.length.toString()) ?? '${urgentItems.length} item(s) need attention',"
}

for k, v in scan_reps.items(): scan = scan.replace(k, v)
for k, v in shelf_reps.items(): shelf = shelf.replace(k, v)

with open(scan_path, 'w', encoding='utf-8') as f: f.write(scan)
with open(shelf_path, 'w', encoding='utf-8') as f: f.write(shelf)
