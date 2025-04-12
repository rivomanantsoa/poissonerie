import 'package:flutter/material.dart';
import 'package:untitled/stock_managing/graph.dart';
import 'package:untitled/stock_managing/stock.dart';


class Scaff extends StatefulWidget {
  @override
  _ScaffState createState() => _ScaffState();
}

class _ScaffState extends State<Scaff> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
      showMenu = false;
    });
  }

  bool showMenu = false;

  double get menuTopPosition =>
      showMenu ? -10 : -200; // 70 si visible, -200 si caché

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                Stock(),
                Graph(),
              ],
            ),
          ),
          // Bouton à gauche (inchangé)
        ],
      ),

      // Remplace la colonne de boutons à droite par une BottomNavigationBar

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setCurrentIndex(_currentIndex == 0 ? 1 : 0);
        },
        child: Icon(_currentIndex == 0 ? Icons.bar_chart : Icons.list , color: Colors.white,),
        // Icône de graphique
        backgroundColor: Colors.orange.shade600, // Couleur du bouton
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}

// Utilisation du widget
