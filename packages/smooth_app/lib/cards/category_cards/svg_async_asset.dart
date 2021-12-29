import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget with async load of SVG asset file
///
/// SVG files may need to be optimized before being stored in the cache folder.
/// E.g. with https://jakearchibald.github.io/svgomg/
/// C.f. https://github.com/openfoodfacts/smooth-app/issues/52
class SvgAsyncAsset extends StatelessWidget {
  const SvgAsyncAsset(
    this.fullFilename, {
    this.width,
    this.height,
    this.color,
  });

  final String fullFilename;
  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: rootBundle.loadString(fullFilename),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              return SvgPicture.string(
                snapshot.data!,
                width: width,
                height: height,
                color: color,
                fit: BoxFit.contain,
                placeholderBuilder: (BuildContext context) => SizedBox(
                  width: width ?? height,
                  height: height ?? width,
                ),
              );
            } else {
              debugPrint('unexpected case: svg asset not found $fullFilename');
            }
          }
          return SizedBox(
            width: width ?? height,
            height: height ?? width,
          );
        },
      );
}
