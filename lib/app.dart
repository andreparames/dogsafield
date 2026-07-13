import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'i18n/strings.g.dart';
import 'routes.dart';

class DogsAfieldApp extends ConsumerWidget {
  const DogsAfieldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return TranslationProvider(
      child: MaterialApp.router(
        title: 'Dogs Afield',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF9E8E7A),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6F5F0),
          useMaterial3: true,
        ),
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: appRouter,
      ),
    );
  }
}
