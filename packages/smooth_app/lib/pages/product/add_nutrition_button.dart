import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';

/// "Add nutrition facts" button for user contribution.
class AddNutritionButton extends StatelessWidget {
  const AddNutritionButton(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) => addPanelButton(
        AppLocalizations.of(context).score_add_missing_nutrition_facts,
        onPressed: () async => NutritionPageLoaded.showNutritionPage(
          product: product,
          isLoggedInMandatory: true,
          context: context,
        ),
      );
}
