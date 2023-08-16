import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:valdi_proyect/gallery.dart';
import 'package:valdi_proyect/login.dart';

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});
  @override
  State<GalleryApp> createState() => _GalleryApp();
}

class _GalleryApp extends State<GalleryApp> {
  dynamic userData;

  @override
  void initState() {
    super.initState();
    getDataUserLogged();
  }

  ///Funcion para obtener la informacion del usuario
  ///
  ///Consulta las prefrencias y trae la data que en haya.
  ///
  Future<void> getDataUserLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = json.decode(prefs.getString('user_login') ?? '{}');
    });
  }

  /// Funcion para setear la ruta a la cual se accedera
  ///
  /// Esto se hace para evitar que usuarios que no esten registrados entren a la app,
  /// Esta data se obtiene de las preferencias.
  String setRoute() {
    if (userData['userName'] == null) return '/login';
    if (userData['userName'] != null) return '/app';
    return '/login';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiscoGallery',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      //Tema Oscuro, se usa cuando se activa el modo oscuro
      darkTheme: ThemeData(
        //Se indica que el tema tiene un brillo oscuro
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
      ),
      initialRoute: setRoute(),
      routes: {
        '/app': (context) => const Gallery(),
        '/login': (context) => const Login(),
      },
    );
  }
}
