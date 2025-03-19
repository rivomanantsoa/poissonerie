import 'package:flutter/material.dart';
import 'package:untitled/page/acceuil.dart';
import 'package:untitled/page/ajouter_produit.dart';
import 'package:untitled/page/historique.dart';
import 'package:untitled/page/list_pdf.dart';
import 'package:untitled/page/list_tous_vente.dart';
import 'package:video_player/video_player.dart';
//import 'package:video_player/list_tous_vente.dart';

class Video extends StatefulWidget {
  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  late VideoPlayerController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/icons/background.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.setPlaybackSpeed(0.5); // Ralentir la vidéo
        _controller.play();
      })
      ..setLooping(true)
      ..setVolume(0.0);
  }

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🖥️ Vidéo en arrière-plan
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
              fit: BoxFit.cover, // Assure que la vidéo couvre tout l'écran sans zoom excessif
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
                : Center(child: CircularProgressIndicator()),
          ),

          // 📄 Contenu au-dessus de la vidéo
          // 📄 Contenu au-dessus de la vidéo
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                 Padding(
                   padding: const EdgeInsets.only(bottom: 85.0),
                   child: Acceuil(),
                 ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 85.0),
                  child: Historique(),
                ),

                Center(child: Text("Page 4", style: TextStyle(color: Colors.white))),
                Padding(
                  padding: const EdgeInsets.only(bottom: 85.0),
                  child: ListTousVente(),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 85.0),
                  child: ListPdf(),
                ),
              ],
            ),
          ),


          // ⚡ BottomNavigationBar SUPERPOSÉ avec fond semi-transparent
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5), // Fond semi-transparent
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)),
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent, // Permet de voir la vidéo derrière
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    if (index == 2) {
                      showDialog(
                          context: context,
                          builder: (context) => AjouterProduit());
                    } else {
                      setCurrentIndex(index);
                    }
                  },
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.yellow,
                  unselectedItemColor: Colors.white,
                  items: [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trano"),
                    BottomNavigationBarItem(icon: Icon(Icons.history), label: "Zava-nisy"),
                    BottomNavigationBarItem(
                      icon: Container(
                        width: 50, // Largeur personnalisée pour l'icône "add"
                        height: 40, // Hauteur personnalisée pour l'icône "add"
                        decoration: BoxDecoration(
                          color: Colors.white, // Couleur de fond
                          shape: BoxShape.circle, // Forme circulaire
                        ),
                        child: const Icon(
                          Icons.add_circle, // Icône principale
                          size: 37, // Taille augmentée
                          color: Colors.black, // Couleur de l'icône
                        ),
                      ),
                      label: "",
                      backgroundColor: Colors.blue, // Couleur si sélectionnée
                    ),
                    BottomNavigationBarItem(icon: Icon(Icons.library_books), label: "Lisitra"),
                    BottomNavigationBarItem(icon: Icon(Icons.add_alert_sharp), label: "Tatitra"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//site:docs.google.com/spreadsheets"remote jobs"