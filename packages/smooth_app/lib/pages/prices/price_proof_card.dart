import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/prices_proofs_page.dart';
import 'package:smooth_app/pages/proof_crop_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// Card that displays the proof for price adding.
class PriceProofCard extends StatelessWidget {
  const PriceProofCard();

  static const IconData _iconTodo = CupertinoIcons.exclamationmark;
  static const IconData _iconDone = Icons.receipt;

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothCard(
      child: Column(
        children: <Widget>[
          Text(appLocalizations.prices_proof_subtitle),
          if (model.proof != null)
            Image(
              image: NetworkImage(
                model.proof!
                    .getFileUrl(
                      uriProductHelper: ProductQuery.uriPricesHelper,
                      isThumbnail: true,
                    )!
                    .toString(),
              ),
            )
          else if (model.cropParameters != null)
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) =>
                  Image(
                image: FileImage(
                  File(model.cropParameters!.smallCroppedFile.path),
                ),
                width: constraints.maxWidth,
                height: constraints.maxWidth,
              ),
            ),
          SmoothLargeButtonWithIcon(
            text: !model.hasImage
                ? appLocalizations.prices_proof_find
                : model.proofType == ProofType.receipt
                    ? appLocalizations.prices_proof_receipt
                    : appLocalizations.prices_proof_price_tag,
            icon: !model.hasImage ? _iconTodo : _iconDone,
            onPressed: () async {
              final _ProofSource? proofSource =
                  await _ProofSource.select(context);
              if (proofSource == null) {
                return;
              }
              if (!context.mounted) {
                return;
              }
              return proofSource.process(context, model);
            },
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) => Row(
              children: <Widget>[
                SizedBox(
                  width: constraints.maxWidth / 2,
                  child: RadioListTile<ProofType>(
                    title: Text(appLocalizations.prices_proof_receipt),
                    value: ProofType.receipt,
                    groupValue: model.proofType,
                    onChanged: model.proof != null
                        ? null
                        : (final ProofType? proofType) =>
                            model.proofType = proofType!,
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth / 2,
                  child: RadioListTile<ProofType>(
                    title: Text(appLocalizations.prices_proof_price_tag),
                    value: ProofType.priceTag,
                    groupValue: model.proofType,
                    onChanged: model.proof != null
                        ? null
                        : (final ProofType? proofType) =>
                            model.proofType = proofType!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ProofSource {
  camera,
  gallery,
  history;

  Future<void> process(
    final BuildContext context,
    final PriceModel model,
  ) async {
    switch (this) {
      case _ProofSource.history:
        final Proof? proof = await Navigator.of(context).push<Proof>(
          MaterialPageRoute<Proof>(
            builder: (BuildContext context) => const PricesProofsPage(
              selectProof: true,
            ),
          ),
        );
        if (proof != null) {
          model.setProof(proof);
          model.notifyListeners();
        }
        return;
      case _ProofSource.camera:
      case _ProofSource.gallery:
        final UserPictureSource source = this == _ProofSource.gallery
            ? UserPictureSource.GALLERY
            : UserPictureSource.CAMERA;
        final CropParameters? cropParameters = await confirmAndUploadNewImage(
          context,
          cropHelper: ProofCropHelper(model: model),
          isLoggedInMandatory: true,
          forcedSource: source,
        );
        if (cropParameters != null) {
          model.cropParameters = cropParameters;
        }
    }
  }

  static Future<_ProofSource?> select(final BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return showCupertinoModalPopup<_ProofSource>(
      context: context,
      builder: (final BuildContext context) => CupertinoActionSheet(
        title: Text(appLocalizations.prices_proof_find),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            appLocalizations.cancel,
          ),
        ),
        actions: <Widget>[
          if (CameraHelper.hasACamera)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(
                _ProofSource.camera,
              ),
              child: Text(
                appLocalizations.settings_app_camera,
              ),
            ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(
              _ProofSource.gallery,
            ),
            child: Text(
              appLocalizations.gallery_source_label,
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(
              _ProofSource.history,
            ),
            child: Text(
              appLocalizations.user_search_proofs_title,
            ),
          ),
        ],
      ),
    );
  }
}
