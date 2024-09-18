import 'package:flutter/material.dart';

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class CustomIntroDialog extends StatelessWidget {
  final String title;
  final List<FeatureItem> features;
  final VoidCallback onClose;

  const CustomIntroDialog({
    super.key,
    required this.title,
    required this.features,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: ListBody(
          children: features
              .map((feature) => ListTile(
                    leading: Icon(feature.icon),
                    title: Text(feature.title),
                    subtitle: Text(feature.description),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: const Text('Got it!'),
        ),
      ],
    );
  }
}

void showIntroDialog(
  BuildContext context, {
  required String title,
  required List<FeatureItem> features,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomIntroDialog(
          title: title,
          features: features,
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  });
}
