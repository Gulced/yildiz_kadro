import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

class GroupNamingScreen extends StatefulWidget {
  const GroupNamingScreen({super.key});
  @override
  State<GroupNamingScreen> createState() => _GroupNamingScreenState();
}

class _GroupNamingScreenState extends State<GroupNamingScreen> {
  final controller = TextEditingController();
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit() {
    final isEn = isAppEnglish(context);
    final name = controller.text.trim();
    if (name.isEmpty || name.length > 24) {
      setState(
        () => error = name.isEmpty
            ? (isEn
                ? 'Group name cannot be empty.'
                : 'Grup adı boş bırakılamaz.')
            : (isEn
                ? 'Group name can be at most 24 characters.'
                : 'Grup adı en fazla 24 karakter olabilir.'),
      );
      return;
    }
    GameScope.of(context).nameAndCompleteGroup(name);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: MaxWidthContainer(
                maxWidth: 620,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'FINAL TOUCH' : 'SON DOKUNUŞ',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.accentBright,
                            letterSpacing: 1.3,
                          ),
                    ),
                    Text(
                      isEn ? 'NAME YOUR GROUP' : 'GRUBUNA İSİM VER',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Text(
                      isEn
                          ? 'This name will be displayed on the debut stage and stored in the group archive.'
                          : 'Bu isim debut sahnesinde ve grup arşivinde kullanılacak.',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      maxLength: 24,
                      textCapitalization: TextCapitalization.words,
                      style: Theme.of(context).textTheme.headlineSmall,
                      decoration: InputDecoration(
                        labelText: isEn ? 'GROUP NAME' : 'GRUP ADI',
                        hintText: isEn
                            ? 'Name of your new group'
                            : 'Yeni grubunun adı',
                        errorText: error,
                        filled: true,
                        fillColor: AppColors.inkSoft,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.line),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.accentBright),
                        ),
                      ),
                      onChanged: (_) {
                        if (error != null) setState(() => error = null);
                      },
                      onSubmitted: (_) => submit(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: isEn ? 'CONFIRM NAME  ★ →' : 'İSMİ ONAYLA  ★ →',
                      onPressed: submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
