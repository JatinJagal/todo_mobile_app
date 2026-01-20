import 'package:auto_route/auto_route.dart';
import 'package:todo_app/routes/app_router.gr.dart';
// import 'package:todo_app/splash.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  // TODO: implement routes
  List<AutoRoute> get routes => [
    AutoRoute(initial: true, page: SplashRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: BottomNavRoute.page),
  ];
}
