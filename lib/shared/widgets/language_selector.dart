import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/localization/locale_scope.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = Localizations.localeOf(context).languageCode;
    final controller = LocaleScope.maybeOf(context);
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'tr', label: Text('TR')),
        ButtonSegment(value: 'en', label: Text('EN')),
      ],
      selected: {selected == 'tr' ? 'tr' : 'en'},
      showSelectedIcon: false,
      onSelectionChanged: controller == null
          ? null
          : (selection) => controller.select(Locale(selection.first)),
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
