import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppRootContainer extends StatelessWidget {
  final Widget child;
  final Color? navigationColor;
  final Brightness? statusBarBrightness;

  const AppRootContainer({super.key, required this.child, this.navigationColor, this.statusBarBrightness});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invertedBrightness = Brightness.dark;
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
            systemNavigationBarColor: navigationColor ?? theme.scaffoldBackgroundColor,
            systemNavigationBarIconBrightness: invertedBrightness,
            statusBarColor: theme.scaffoldBackgroundColor,
            statusBarIconBrightness: statusBarBrightness ?? invertedBrightness
        ),
        child: child
    );
  }
}
