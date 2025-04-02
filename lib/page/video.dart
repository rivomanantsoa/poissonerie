import 'package:flutter/material.dart';
import 'package:untitled/page/acceuil.dart';
import 'package:untitled/page/ajouter_produit.dart';
import 'package:untitled/page/historique.dart';
import 'package:untitled/page/list_pdf.dart';
import 'package:untitled/page/list_tous_vente.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pour formater la date
import 'package:untitled/controller/controller.dart';
import 'package:untitled/stock_managing/graph.dart';
import 'package:untitled/tools/generat_to_pdf.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Video extends StatefulWidget {
  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  int _currentIndex = 0;

  bool _pdfGeneratedToday = false;
  late Controller globalState;

  @override
  void initState() {
    super.initState();
    globalState = Provider.of<Controller>(context, listen: false);
    globalState.id_vente;
    // 🚀 Lance directement le Timer
    _initializePDFGeneration();
  }

  Future<void> _initializePDFGeneration() async {
    await globalState.id_vente;
    await _loadPdfGeneratedState(); // 🔄 Charger l'état sauvegardé
    if (!_pdfGeneratedToday) {
      _scheduleDailyPDFGeneration(); // 🚀 Démarrer le Timer seulement si nécessaire
    } else {
      print("⏳ Le PDF a déjà été généré aujourd’hui. Pas de nouveau Timer.");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    globalState = Provider.of<Controller>(context, listen: false);
    _scheduleDailyPDFGeneration(); // 🚀 Lance le Timer après insertion dans l'arbre
  }

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _loadPdfGeneratedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastGeneratedDate = prefs.getString('pdf_generated_date') ?? '';

    // Vérifie si le PDF a déjà été généré aujourd'hui
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (lastGeneratedDate == today) {
      _pdfGeneratedToday = true;
    }

    // _scheduleDailyPDFGeneration(); // 🕒 Démarre le timer après avoir chargé l’état
  }

  Future<void> _savePdfGeneratedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('pdf_generated_date', today);
  }

  void _scheduleDailyPDFGeneration() {
    print("les produits sont ivggg: ${(globalState.rapports.toList())}");
    if (_pdfGeneratedToday) {
      print(
          "🚫 Le Timer ne démarre pas car le PDF a déjà été généré aujourd’hui.");
      return;
    }

    print("📌 Timer démarré !");
    Timer.periodic(Duration(minutes: 1), (timer) async {
      final now = DateTime.now();
      print("⏰ Heure actuelle : ${now.hour}:${now.minute}");

      if (now.hour == 20 && now.minute == 15) {
        _pdfGeneratedToday = true;
        _savePdfGeneratedState(); // 🔄 Sauvegarde la date pour éviter la génération multiple
        print("✅ Génération du PDF à 15:59 !");

        String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        var ventesDuJour = globalState.ventes.where((vente) {
          DateTime venteDate = DateTime.parse(vente['date']);
          return DateFormat('yyyy-MM-dd').format(venteDate) == today;
        }).toList();

        generateAndSavePDF(ventesDuJour, globalState);
        try {
          await globalState.addRapport(
              nom: now.toIso8601String(), date: now.toIso8601String());
          print("c tfffafghjkoiuyg");
        } catch (e) {
          print("erreur de l'insertion");
        }
      }

      // 🔄 Réinitialisation après minuit
      if (now.hour == 0 && now.minute == 1) {
        _pdfGeneratedToday = false;
        _savePdfGeneratedState(); // Réinitialise la sauvegarde
        print("🔄 Réinitialisation du flag pour le lendemain.");
      }
    });
  }
  final List<String> _titles = ['Home', 'Historique'];
  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);
    return Scaffold(
    backgroundColor: Colors.cyanAccent.shade700,
      appBar: AppBar(
        title: Center(child: Text(_titles[_currentIndex], style: TextStyle(fontSize: 35, fontWeight: FontWeight.w500,),)),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 🌊 Image de fond
          // 📄 Contenu au-dessus de l'image
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
                Center(
                    child:
                        Text("Page 4", style: TextStyle(color: Colors.white))),

              ],
            ),
          ),

          // ⚡ BottomNavigationBar SUPERPOSÉ avec fond semi-transparent
          Positioned(
            bottom: 4,
            left: 9,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Conteneur arrondi pour Home et Historique
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Fond semi-transparent
                    borderRadius: BorderRadius.circular(10), // Coins arrondis

                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: _currentIndex == 0 ? Colors.teal : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.home_outlined, size: 32, color: Colors.black),
                          onPressed: () => setCurrentIndex(0),
                        ),
                      ),
                      SizedBox(width: 16), // Espacement entre les icônes
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: _currentIndex == 1 ? Colors.teal : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.history, size: 32, color: Colors.black),
                          onPressed: () => setCurrentIndex(1),
                        ),
                      ),
                    ],
                  ),
                ),

                // Icône Print à droite (affichée seulement si globalState.id_vente != 0)
                if (globalState.id_vente != 0)
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.print, size: 32, color: Colors.black),
                      onPressed: () {
                        // Ajoute ici l'action du bouton print
                      },
                    ),
                  ),
              ],
            ),
          ),



        ],
      ),
    );
  }
}
