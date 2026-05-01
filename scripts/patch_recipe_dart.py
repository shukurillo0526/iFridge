import os
path = r'd:\dev\projects\iFridge\frontend\lib\features\cook\presentation\screens\recipe_detail_screen.dart'
with open(path, 'r', encoding='utf-8') as f: c = f.read()

reps = {
    "Text(\n                      'Adjust Portions',": "Text(\n                      AppLocalizations.of(context)?.adjustPortions ?? 'Adjust Portions',",
    "Text(\n                      'Current recipe makes ${widget.servings ?? \"?\"} servings.',": "Text(\n                      AppLocalizations.of(context)?.currentRecipeMakesNServings(widget.servings?.toString() ?? \"?\") ?? 'Current recipe makes ${widget.servings ?? \"?\"} servings.',",
    "label: Text('Scale to $newServings Servings')": "label: Text(AppLocalizations.of(context)?.scaleToNServings(newServings.toString()) ?? 'Scale to $newServings Servings')",
    "content: Text('Scaled to $newServings servings 🍳')": "content: Text(AppLocalizations.of(context)?.scaledToNServings(newServings.toString()) ?? 'Scaled to $newServings servings 🍳')",
    "Text(\n                      'Finding substitutes for $ingredientName...',": "Text(\n                      AppLocalizations.of(context)?.findingSubstitutesForX(ingredientName) ?? 'Finding substitutes for $ingredientName...',",
    "Text(\n                      'Could not find substitutes',": "Text(\n                      AppLocalizations.of(context)?.couldNotFindSubstitutes ?? 'Could not find substitutes',",
    "child: Text(\n                            'Substitutes for \"$ingredientName\"',": "child: Text(\n                            AppLocalizations.of(context)?.substitutesForX(ingredientName) ?? 'Substitutes for \"$ingredientName\"',",
    "child: Text(\n                          'No substitutes found for this recipe context.',": "child: Text(\n                          AppLocalizations.of(context)?.noSubstitutesFoundForThisRecipeContext ?? 'No substitutes found for this recipe context.',",
    "child: Text(\n                              '${(widget.matchPct * 100).toInt()}% Match',": "child: Text(\n                              AppLocalizations.of(context)?.nMatch((widget.matchPct * 100).toInt().toString()) ?? '${(widget.matchPct * 100).toInt()}% Match',",
    "Text(\n                        'Ingredients (${_ingredients.length})',": "Text(\n                        AppLocalizations.of(context)?.ingredientsWithCount(_ingredients.length.toString()) ?? 'Ingredients (${_ingredients.length})',",
    "label: Text('Scale')": "label: Text(AppLocalizations.of(context)?.scale ?? 'Scale')",
    "content: Text('Added missing items to Shopping List!')": "content: Text(AppLocalizations.of(context)?.addedMissingItemsToShoppingList ?? 'Added missing items to Shopping List!')",
    "content: Text('Failed to add items: $e')": "content: Text(AppLocalizations.of(context)?.failedToAddItemsX(e.toString()) ?? 'Failed to add items: $e')",
    "label: Text(\n                        'Add missing to Shopping List',": "label: Text(\n                        AppLocalizations.of(context)?.addMissingToShoppingList ?? 'Add missing to Shopping List',",
    "Text(\n                        'Cooking Steps (${_steps.length})',": "Text(\n                        AppLocalizations.of(context)?.cookingStepsWithCount(_steps.length.toString()) ?? 'Cooking Steps (${_steps.length})',",
    "Text(\n                            'No steps available yet',": "Text(\n                            AppLocalizations.of(context)?.noStepsAvailableYet ?? 'No steps available yet',",
    "Text('Recorded! Your taste profile is evolving 🧠')": "Text(AppLocalizations.of(context)?.recordedTasteProfileEvolving ?? 'Recorded! Your taste profile is evolving 🧠')",
    "SnackBar(content: Text('Failed to record: $e'))": "SnackBar(content: Text(AppLocalizations.of(context)?.failedToRecordX(e.toString()) ?? 'Failed to record: $e'))",
    "label: Text(\n                      'I Cooked This!',": "label: Text(\n                      AppLocalizations.of(context)?.iCookedThis ?? 'I Cooked This!',",
    "label: Text(\n                        'Start Cooking',": "label: Text(\n                        AppLocalizations.of(context)?.startCooking ?? 'Start Cooking',",
    "child: Text(\n                            'optional',": "child: Text(\n                            AppLocalizations.of(context)?.optional_tag ?? 'optional',",
    "'${widget.servings} servings'": "'${widget.servings} ${AppLocalizations.of(context)?.servings_tag ?? \"servings\"}'",
    "'1 servings'": "'1 ${AppLocalizations.of(context)?.servings_tag ?? \"servings\"}'",
    "Text(\n                          'Difficulty',": "Text(\n                          AppLocalizations.of(context)?.difficulty_tag ?? 'Difficulty',",
    "'${widget.prepTime + widget.cookTime} min'": "'${widget.prepTime! + widget.cookTime!} ${AppLocalizations.of(context)?.min_tag ?? \"min\"}'",
    "'${widget.prepTime} min'": "'${widget.prepTime} ${AppLocalizations.of(context)?.min_tag ?? \"min\"}'"
}

for k, v in reps.items():
    c = c.replace(k, v)

with open(path, 'w', encoding='utf-8') as f: f.write(c)
