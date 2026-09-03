import 'package:flutter/widgets.dart';
import 'package:yildiz_kadro/app/app.dart';
import 'package:yildiz_kadro/app/localization/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = LocaleController();
  await localeController.restore();
  runApp(YildizKadroApp(localeController: localeController));
}
