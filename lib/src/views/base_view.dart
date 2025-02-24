import 'package:flutter/material.dart';

class BaseView extends StatelessWidget {
  final Widget child;

  BaseView({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: isDarkMode
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(29, 70, 115, 1),
                    Color.fromRGBO(17, 37, 62, 1),
                  ],
                ),
              )
            : null, // Add a different background for light mode if needed
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    );
  }
}
