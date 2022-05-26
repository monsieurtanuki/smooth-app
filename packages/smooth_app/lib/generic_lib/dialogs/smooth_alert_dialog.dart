import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Custom Dialog to use in the app
///
/// ```dart
/// showDialog<void>(
///        context: context,
///        builder: (BuildContext context) {
///          return SmoothAlertDialog(...)
///	       }
/// )
/// ```
///
/// If only one action button is provided, simply pass a [positiveAction]

class SmoothAlertDialog extends StatelessWidget {
  /// The most simple alert dialog: no fancy effects.
  const SmoothAlertDialog({
    this.title,
    required this.body,
    this.positiveAction,
    this.neutralAction,
    this.negativeAction,
  })  : close = false,
        maxHeight = null,
        _simpleMode = true;

  /// Advanced alert dialog with fancy effects.
  const SmoothAlertDialog.advanced({
    this.title,
    this.close = true,
    this.maxHeight,
    required this.body,
    this.positiveAction,
    this.neutralAction,
    this.negativeAction,
  }) : _simpleMode = false;

  final String? title;
  final bool close;
  final double? maxHeight;
  final Widget body;
  final SmoothActionButton? positiveAction;
  final SmoothActionButton? neutralAction;
  final SmoothActionButton? negativeAction;
  final bool _simpleMode;

  @override
  Widget build(BuildContext context) {
    final Widget content = _buildContent(context);
    return AlertDialog(
      elevation: 4.0,
      shape: const RoundedRectangleBorder(borderRadius: ROUNDED_BORDER_RADIUS),
      content: _simpleMode
          ? content
          : ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: maxHeight ?? double.infinity * 0.5),
              child: content,
            ),
      actions: _buildActions(
        context,
        positiveAction: positiveAction,
        neutralAction: neutralAction,
        negativeAction: negativeAction,
      ),
    );
  }

  Widget _buildContent(final BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title != null) ...<Widget>[
            SizedBox(
              height: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildCross(true, context),
                  if (title != null)
                    Expanded(
                      child: FittedBox(
                        child: Text(
                          title!,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ),
                    ),
                  _buildCross(false, context),
                ],
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.onBackground),
            const SizedBox(height: 12),
          ],
          if (_simpleMode)
            body
          else
            Expanded(child: SingleChildScrollView(child: body)),
        ],
      );

  Widget _buildCross(final bool isPlaceHolder, final BuildContext context) {
    if (close) {
      return Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: !isPlaceHolder,
        child: InkWell(
          child: const Icon(
            Icons.close,
            size: 29.0,
          ),
          onTap: () => Navigator.of(context, rootNavigator: true).pop('dialog'),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class SmoothActionButtonsBar extends StatelessWidget {
  const SmoothActionButtonsBar({
    this.positiveAction,
    this.neutralAction,
    this.negativeAction,
    Key? key,
  })  : assert(
            positiveAction != null ||
                neutralAction != null ||
                negativeAction != null,
            'At least one action must be passed!'),
        super(key: key);

  const SmoothActionButtonsBar.single({
    required SmoothActionButton action,
    Key? key,
  }) : this(
          positiveAction: action,
          key: key,
        );

  final SmoothActionButton? positiveAction;
  final SmoothActionButton? neutralAction;
  final SmoothActionButton? negativeAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _buildActions(
        context,
        positiveAction: positiveAction,
        neutralAction: neutralAction,
        negativeAction: negativeAction,
      )!,
    );
  }
}

/// Generates Actions buttons with:
/// In LTR mode: Negative - Neutral - Positive
/// In RTL mode: Positive - Neutral - Negative
List<Widget>? _buildActions(
  BuildContext context, {
  SmoothActionButton? positiveAction,
  SmoothActionButton? neutralAction,
  SmoothActionButton? negativeAction,
}) {
  final int count = (positiveAction != null ? 1 : 0) +
      (neutralAction != null ? 1 : 0) +
      (negativeAction != null ? 1 : 0);

  if (count == 0) {
    return null;
  }

  final Size size = Size(
    MediaQuery.of(context).size.width / (count == 1 ? 1.5 : count),
    36.0,
  );

  final List<Widget> actions = <Widget>[
    if (negativeAction != null)
      SizedBox.fromSize(
        size: size,
        child: _SmoothActionFlatButton(
          buttonData: negativeAction,
        ),
      ),
    if (neutralAction != null)
      SizedBox.fromSize(
        size: size,
        child: _SmoothActionFlatButton(
          buttonData: neutralAction,
        ),
      ),
    if (positiveAction != null)
      SizedBox.fromSize(
        size: size,
        child: _SmoothActionElevatedButton(
          buttonData: positiveAction,
        ),
      ),
  ];

  if (Directionality.of(context) == TextDirection.rtl) {
    return actions.reversed.toList(growable: false);
  } else {
    return actions;
  }
}

class SmoothActionButton {
  SmoothActionButton({
    required this.text,
    required this.onPressed,
    this.minWidth = 15,
    this.height = 20,
  }) : assert(text.isNotEmpty);

  final String text;
  final VoidCallback? onPressed;
  final double minWidth;
  final double height;
}

class _SmoothActionElevatedButton extends StatelessWidget {
  const _SmoothActionElevatedButton({
    required this.buttonData,
  });

  final SmoothActionButton buttonData;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return SmoothSimpleButton(
      onPressed: buttonData.onPressed,
      height: buttonData.height,
      minWidth: buttonData.minWidth,
      child: AutoSizeText(
        buttonData.text.toUpperCase(),
        style: themeData.textTheme.bodyText2!
            .copyWith(color: themeData.colorScheme.onPrimary),
        maxLines: 1,
      ),
    );
  }
}

class _SmoothActionFlatButton extends StatelessWidget {
  const _SmoothActionFlatButton({
    required this.buttonData,
  });

  final SmoothActionButton buttonData;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Theme(
      data: themeData.copyWith(
        buttonTheme: const ButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: ROUNDED_BORDER_RADIUS,
          ),
        ),
      ),
      child: TextButton(
        onPressed: buttonData.onPressed,
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: ROUNDED_BORDER_RADIUS,
          ),
          textStyle: themeData.textTheme.bodyText2!
              .copyWith(color: themeData.colorScheme.onPrimary),
        ),
        child: AutoSizeText(
          buttonData.text.toUpperCase(),
          maxLines: 1,
        ),
      ),
    );
  }
}
