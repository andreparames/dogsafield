import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'i18n/strings.g.dart';
import 'routes.dart';

class DogsAfieldApp extends ConsumerWidget {
  const DogsAfieldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TranslationProvider(
      child: MaterialApp.router(
        title: 'Dogs Afield',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: appRouter,
      ),
    );
  }
}
