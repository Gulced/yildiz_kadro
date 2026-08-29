import 'package:flutter/widgets.dart';

class GameNavigationObserver extends NavigatorObserver with ChangeNotifier {
  Route<dynamic>? _currentRoute;
  bool _notificationScheduled = false;
  bool _disposed = false;

  Route<dynamic>? get currentRoute => _currentRoute;
  bool get isPopup => _currentRoute is PopupRoute<dynamic>;
  bool get isDashboard =>
      _currentRoute?.settings.name == GameNavigationObserver.dashboardRoute;
  bool get canReturn => navigator?.canPop() ?? false;

  static const dashboardRoute = '/producer-dashboard';

  void _set(Route<dynamic>? route) {
    _currentRoute = route;
    if (_notificationScheduled) return;
    _notificationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationScheduled = false;
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _set(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _set(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _set(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _set(previousRoute);
  }
}
