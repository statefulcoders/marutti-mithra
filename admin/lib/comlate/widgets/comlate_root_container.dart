import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ComlateRootContainer extends StatelessWidget {
  final Widget child;
  final Color? navigationColor;
  final Color? statusBarColor;
  final Brightness? navigationBarBrightness;
  final Brightness? statusBarBrightness;

  const ComlateRootContainer({super.key, required this.child, this.navigationColor, this.statusBarBrightness, this.statusBarColor, this.navigationBarBrightness});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invertedBrightness = Brightness.dark;
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
            systemNavigationBarColor: navigationColor ?? theme.scaffoldBackgroundColor,
            systemNavigationBarIconBrightness: navigationBarBrightness ?? invertedBrightness,
            statusBarColor: statusBarColor ?? theme.scaffoldBackgroundColor,
            statusBarIconBrightness: statusBarBrightness ?? invertedBrightness
        ),
        child: child
    );
  }
}
