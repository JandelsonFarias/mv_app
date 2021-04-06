import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mvapp/pages/Login.dart';

void main() {
    HttpOverrides.global = new MyHttpOverrides();

    Map<int, Color> color =
    {
      50:Color.fromRGBO(36, 177, 139, 1),
      100:Color.fromRGBO(36, 177, 139, 1),
      200:Color.fromRGBO(36, 177, 139, 1),
      300:Color.fromRGBO(36, 177, 139, 1),
      400:Color.fromRGBO(36, 177, 139, 1),
      500:Color.fromRGBO(36, 177, 139, 1),
      600:Color.fromRGBO(36, 177, 139, 1),
      700:Color.fromRGBO(36, 177, 139, 1),
      800:Color.fromRGBO(36, 177, 139, 1),
      900:Color.fromRGBO(36, 177, 139, 1)
    };

    runApp(
        MaterialApp(
            localizationsDelegates: [
                GlobalMaterialLocalizations.delegate
            ],
            supportedLocales: [
                const Locale('pt')
            ],
            title: "MVT App",
            theme: ThemeData(
              primarySwatch: MaterialColor(Color.fromRGBO(36, 177, 139, 1).hashCode, color),
              primaryColor: Color.fromRGBO(36, 177, 139, 1),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            debugShowCheckedModeBanner: false,
            home: Login()
        )
    );
}

class MyHttpOverrides extends HttpOverrides{
    @override
    HttpClient createHttpClient(SecurityContext context){
        return super.createHttpClient(context)
            ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
    }
}




