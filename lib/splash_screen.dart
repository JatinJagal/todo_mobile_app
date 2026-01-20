import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/routes/app_router.gr.dart';
import 'package:todo_app/services/local_storage_service.dart';
import 'package:todo_app/utils/global.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      // context.router.replace(const LoginRoute());
      navigateToNextScreen();
    });
  }

  Future<void> navigateToNextScreen() async {
    final token = await LocalStorageService.i.getStorageValue(kToken);
    if (token.isNotEmpty || token != '') {
      context.router.replace(const BottomNavRoute());
    } else {
      context.router.replace(const LoginRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(children: [Text('Splash Screen')])),
    );
  }
}
