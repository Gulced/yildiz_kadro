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
    final name = controller.text.trim();
    if (name.isEmpty || name.length > 24) {
      setState(() => error = name.isEmpty
          ? 'Grup adı boş bırakılamaz.'
          : 'Grup adı en fazla 24 karakter olabilir.');
      return;
    }
    GameScope.of(context).nameAndCompleteGroup(name);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => PopScope(
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
                      Text('SON DOKUNUŞ',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  color: AppColors.accentBright,
                                  letterSpacing: 1.3)),
                      Text('GRUBUNA İSİM VER',
                          style: Theme.of(context).textTheme.displayLarge),
                      const Text(
                          'Bu isim debut sahnesinde ve grup arşivinde kullanılacak.'),
                      const SizedBox(height: AppSpacing.xl),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        maxLength: 24,
                        textCapitalization: TextCapitalization.words,
                        style: Theme.of(context).textTheme.headlineSmall,
                        decoration: InputDecoration(
                          labelText: 'GRUP ADI',
                          hintText: 'Yeni grubunun adı',
                          errorText: error,
                          filled: true,
                          fillColor: AppColors.inkSoft,
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.line)),
                          focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.accentBright)),
                        ),
                        onChanged: (_) {
                          if (error != null) setState(() => error = null);
                        },
                        onSubmitted: (_) => submit(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(label: 'İSMİ ONAYLA  ★ →', onPressed: submit),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
