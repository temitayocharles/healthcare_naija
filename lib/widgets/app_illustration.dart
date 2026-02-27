import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIllustration extends StatelessWidget {
  const AppIllustration({
    super.key,
    required this.asset,
    this.height = 140,
    this.width,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final double height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      height: height,
      width: width,
      fit: fit,
      placeholderBuilder: (context) => SizedBox(
        height: height,
        width: width,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}
