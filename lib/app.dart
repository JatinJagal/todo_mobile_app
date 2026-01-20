import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/provider.dart';
import 'package:todo_app/routes/app_router.dart';
import 'package:todo_app/utils/global.dart';
import 'package:todo_app/utils/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MultiBlocProvider(
        providers: providers,
        child: MaterialApp.router(
          //wrap with maltibloc provider later
          routerConfig: appRouter.config(),
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(
              context,
            ).copyWith(boldText: false);
            return MediaQuery(
              data: mediaQueryData,
              child: EasyLoading.init()(context, child),
            );
          },
          debugShowCheckedModeBanner: false,
          title: 'Notes',
          theme: lightTheme,
        ),
      ),
    );
  }
}
