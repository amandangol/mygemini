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
    Key? key,
    required this.title,
    required this.features,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final feature = features[index];
                  return ListTile(
                    leading: Icon(feature.icon,
                        color: Theme.of(context).primaryColor),
                    title: Text(feature.title,
                        style: Theme.of(context).textTheme.bodyLarge),
                    subtitle: Text(feature.description,
                        style: Theme.of(context).textTheme.bodySmall),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Got it!'),
            ),
          ],
        ),
      ),
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
