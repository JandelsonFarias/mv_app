import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mvapp/pages/Login.dart';

void main() {
    HttpOverrides.global = new MyHttpOverrides();
    runApp(
        MaterialApp(
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




