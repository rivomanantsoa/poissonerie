import 'package:flutter/material.dart';
import 'package:untitled/page/acceuil.dart';
import 'package:untitled/page/ajouter_produit.dart';
import 'package:untitled/page/historique.dart';
import 'package:untitled/page/list_pdf.dart';
import 'package:untitled/page/list_tous_vente.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pour formater la date
import 'package:untitled/controller/controller.dart';
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
     // 🚀 Lance directement le Timer
    _initializePDFGeneration();

  }
  Future<void> _initializePDFGeneration() async {
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
      print("🚫 Le Timer ne démarre pas car le PDF a déjà été généré aujourd’hui.");
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
        try{
          await globalState.addRapport(nom: now.toIso8601String(), date: now.toIso8601String());
          print("c tfffafghjkoiuyg");
        }catch(e){
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌊 Image de fond
          Positioned.fill(
            child: Image.asset(
              "assets/image/bleu.png",
              fit: BoxFit.cover,
            ),
          ),

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
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)),
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
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
                        width: 50,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_circle,
                          size: 37,
                          color: Colors.black,
                        ),
                      ),
                      label: "",
                      backgroundColor: Colors.blue,
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
