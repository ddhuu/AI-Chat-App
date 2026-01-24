import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

void showLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('profile.language'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Tiếng Việt'),
            trailing: context.locale == const Locale('vi')
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () {
              context.setLocale(const Locale('vi'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('English'),
            trailing: context.locale == const Locale('en')
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () {
              context.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
