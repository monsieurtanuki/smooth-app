import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panels_builder.dart';
import 'package:smooth_app/data_models/onboarding_data_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/onboarding/common/tooltip_shape_border.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/product/knowledge_panel_product_cards.dart';

class KnowledgePanelPageTemplate extends StatefulWidget {
  const KnowledgePanelPageTemplate({
    required this.headerTitle,
    required this.page,
    required this.panelId,
    required this.localDatabase,
    required this.backgroundColor,
    required this.svgAsset,
  });

  final String headerTitle;
  final OnboardingPage page;

  /// We will only display this panel
  final String panelId;

  final LocalDatabase localDatabase;
  final Color backgroundColor;
  final String svgAsset;

  @override
  State<KnowledgePanelPageTemplate> createState() =>
      _KnowledgePanelPageTemplateState();
}

class _KnowledgePanelPageTemplateState
    extends State<KnowledgePanelPageTemplate> {
  late Future<void> _initFuture;
  late KnowledgePanels _knowledgePanels;
  bool _isHintDismissed = false;
  late final AppLocalizations appLocalizations = AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<void> _init() async {
    final Product product =
        await OnboardingDataProduct.forProduct(widget.localDatabase)
            .getData(rootBundle);
    _knowledgePanels = product.knowledgePanels!;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: _initFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasError) {
            final AppLocalizations appLocalizations =
                AppLocalizations.of(context);
            return Text(
              appLocalizations
                  .knowledge_panel_page_loading_error(snapshot.error),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final Widget knowledgePanelWidget =
              const KnowledgePanelsBuilder().buildSingle(
            _knowledgePanels,
            widget.panelId,
            context: context,
          )!;
          return Container(
            color: widget.backgroundColor,
            child: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ListView(
                    // bottom padding is very large because [NextButton] is stacked on top of the page.
                    padding: const EdgeInsets.only(
                      top: LARGE_SPACE,
                      right: LARGE_SPACE,
                      left: LARGE_SPACE,
                      bottom: VERY_LARGE_SPACE * 5,
                    ),
                    shrinkWrap: true,
                    children: <Widget>[
                      SvgPicture.asset(
                        widget.svgAsset,
                        height: MediaQuery.of(context).size.height * .25,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: LARGE_SPACE,
                        ),
                        child: Text(
                          widget.headerTitle,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      KnowledgePanelProductCards(
                          <Widget>[knowledgePanelWidget]),
                    ],
                  ),
                  ..._buildHintPopup(),
                  Positioned(
                    bottom: 0,
                    child: NextButton(
                      widget.page,
                      backgroundColor: widget.backgroundColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  List<Widget> _buildHintPopup() {
    final Widget hintPopup = InkWell(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        color: Theme.of(context).hintColor.withOpacity(0.9),
        shape: const TooltipShapeBorder(arrowArc: 0.5),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Text(
            appLocalizations.hint_knowledge_panel_message,
            style: TextStyle(color: Theme.of(context).cardColor),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _isHintDismissed = true;
        });
      },
    );
    final List<Widget> hitPopup = <Widget>[];
    if (!_isHintDismissed &&
        !OnboardingFlowNavigator.isOnboradingPagedInHistory(
            OnboardingPage.HEALTH_CARD_EXAMPLE) &&
        !OnboardingFlowNavigator.isOnboradingPagedInHistory(
            OnboardingPage.ECO_CARD_EXAMPLE)) {
      hitPopup.add(InkWell(
        child: const DecoratedBox(
          decoration: BoxDecoration(color: Colors.transparent),
        ),
        onTap: () {
          setState(() {
            _isHintDismissed = true;
          });
        },
      ));
      hitPopup.add(Positioned(
        child: Align(alignment: Alignment.center, child: hintPopup),
      ));
    }
    return hitPopup;
  }
}
