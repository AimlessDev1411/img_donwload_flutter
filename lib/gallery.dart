import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _ListImgs();
}

class _ListImgs extends State<Gallery> {
  List<String> itemlist = [];
  List<Map> itemlistPrefs = [];
  static List<dynamic> itemlistResponse = [];
  TextEditingController itemController = TextEditingController();
  bool isDownload = false;
  bool downloading = false;
  bool loading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    isDownload = true;
    loadData();
    loadFavoritesData();
  }

  ///Funcion para cambiar de vista
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Funcion para mostrar un Toast
  void showMyToast(status) {
    Fluttertoast.showToast(
        msg: status
            ? "Imagen descargada satisfactoriamente"
            : "Error al descargar la imagen",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: status ? Colors.green[400] : Colors.red[400],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  /// Funcion para el Toast de descarga
  void showDownLoadToast(status) {
    if (status) {
      Fluttertoast.showToast(
          msg: "Descargando...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          // timeInSecForIosWeb: 0,
          backgroundColor: Colors.blue[300],
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.cancel();
    }
  }

  /// Funcion para descargar
  void download(dynamic item) {
    setState(() {
      downloadImg(item);
    });
  }

  /// Funcion para guardar favoritos
  void saveFavorites(dynamic item) {
    setState(() {
      String itemStr = json.encode(item);
      itemlist.add(itemStr);
      saveData(false);
    });
  }

  /// Funcion para remover un favorito
  void removeFavorite(item) {
    setState(() {
      itemlist.remove(item);
      saveData(true);
    });
  }

  void logout() {
    setState(() {
      logoutUser();
    });
  }

  /// Funcion para traer los datos del API
  ///
  /// Esta informacion se obtiene del api de unsplash
  Future<void> loadData() async {
    try {
      loading = true;
      List<dynamic> responseAPI = [];
      String clientID = 'eWuCI7ZcGMvsttQL1af81vMwoqoWq5OowCQE_3X2SsE';
      final response = await http.get(Uri.parse(
          'https://api.unsplash.com/photos?client_id=$clientID&page=1&per_page=50'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        responseAPI = data;
      } else {
        throw Exception('Failed to load data');
      }

      setState(() {
        itemlistResponse = responseAPI;
      });
    } catch (error) {
      loading = false;
      print(error);
    } finally {
      loading = false;
    }
  }

  ///Funcion para eliminar la informacion del usuario
  ///
  ///Consulta las prefrencias y trae la data que en haya.
  ///
  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user_login');
  }

  ///Funcion para cargar las imagenes favoritas
  Future<void> loadFavoritesData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      itemlist = prefs.getStringList('favorites') ?? [];
    });
  }

  /// Funcion para guardar la data
  Future<void> saveData(bool isFavoriteRemote) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', itemlist);
      Fluttertoast.showToast(
          msg: isFavoriteRemote
              ? "Imagen eliminada de favoritos"
              : "Imagen añadida a favoritos",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blue[300],
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (error) {
      print(error);
      Fluttertoast.showToast(
          msg: "Error al guardar la foto en favoritos",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red[400],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  /// Funcion para descargar una imagen
  Future<void> downloadImg(item) async {
    try {
      showDownLoadToast(true);
      var imageId =
          await ImageDownloader.downloadImage(item['links']['download']);
      if (imageId == null) {
        showMyToast(false);
        return;
      } else {
        showDownLoadToast(false);
        showMyToast(true);
      }
    } catch (error) {
      print('error: $error');
    } finally {
      showDownLoadToast(false);
    }
  }

  Future<void> playSoundDelete() async {
    final AudioPlayer audioPlayerDownload = AudioPlayer();
    await audioPlayerDownload.play(AssetSource(
        '/sounds/delete.mp3')); // Cambia la ruta al archivo de sonido
  }

  Future<void> playSoundFavorite() async {
    final AudioPlayer audioPlayerDownload = AudioPlayer();
    await audioPlayerDownload.play(AssetSource(
        '/sounds/favorite.mp3')); // Cambia la ruta al archivo de sonido
  }

  Future<void> playSoundDownload() async {
    AudioPlayer audioPlayerDownload = AudioPlayer();
    await audioPlayerDownload.play(AssetSource('/sounds/download.mp3'));
  }

  /// Componente para la card
  miCardImage(item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(15),
      elevation: 10,
      child: Column(
        children: <Widget>[
          Image(
            image: NetworkImage(item['urls']['small']),
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              return child;
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Row(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border_outlined),
                  onPressed: () {
                    saveFavorites(item);
                    playSoundFavorite();
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    download(item);
                    playSoundDownload();
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Componente para la card
  miCardImageFavorites(item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(15),
      elevation: 10,
      child: Column(
        children: <Widget>[
          Image(
            image: NetworkImage(item['urls']['small']),
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              return child;
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Row(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                child: IconButton(
                    icon: const Icon(Icons.favorite),
                    onPressed: () {
                      removeFavorite(json.encode(item));
                      playSoundDelete();
                    }),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    download(item);
                    playSoundDownload();
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  List<Widget> _widgetOptions(index) {
    return <Widget>[
      Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: itemlistResponse.length,
              itemBuilder: (BuildContext context, int index) {
                final item = itemlistResponse[index];
                return miCardImage(item);
              },
            ),
          ),
        ],
      ),
      Column(
        children: <Widget>[
          itemlist.isEmpty
              ? const Image(
                  image: NetworkImage(
                      'https://cdn.ntmx.me/media/2023/06/14/_hd950c3715c5eed99fd1baa7d33d81997780f6c615.JPG'),
                )
              : const Text(''),
          itemlist.isEmpty
              ? const Text('Aun no tienes favoritos!!!')
              : const Text(
                  'Favoritos',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
          Expanded(
            child: ListView.builder(
              itemCount: itemlist.length,
              itemBuilder: (BuildContext context, int index2) {
                final item2 = itemlist[index2];
                return miCardImageFavorites(json.decode(item2));
              },
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BiscoGallery"), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.logout_outlined),
          tooltip: 'Show Snackbar',
          onPressed: () {
            logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ]),
      body: Container(
        color: Colors.white,
        child: _widgetOptions(_selectedIndex)[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
