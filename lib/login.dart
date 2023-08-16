import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  ///Funcion para insertar la data del usuario
  ///
  ///Esta data se guarda en las preferencias
  Future<void> saveData(userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userDataSave = json.encode(userData);
    await prefs.setString('user_login', userDataSave);
  }

  /// Funcion para loggear un usuario
  ///
  /// Esta funcion manda a guardar los datos a la funcion @saveData
  void loggin(userName, password) {
    setState(() {
      Map<String, dynamic> userData = {};
      userData['userName'] = userName;
      userData['password'] = password;
      saveData(userData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Welcome to BiscoGallery')),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                      width: 150,
                      height: 150,
                      child: const Image(
                        image: NetworkImage(
                            'https://cdn.pixabay.com/animation/2022/12/01/17/03/17-03-11-60_512.gif'),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      controller: userNameController,
                      decoration:
                          const InputDecoration(labelText: 'Nombre de usuario'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (userNameController.text.isEmpty) return;
                      if (passwordController.text.isEmpty) return;
                      loggin(userNameController.text, passwordController.text);
                      Navigator.pushReplacementNamed(context, '/app');
                    },
                    child: const Text('Inicar secion'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
