import 'package:flutter/material.dart';
import 'package:untitled/page/acceuil.dart';
import 'package:untitled/page/historique.dart';
import 'package:untitled/page/principale.dart';
import 'package:provider/provider.dart';
import 'package:untitled/controller/controller.dart';
import 'dart:math';

import 'package:untitled/ticket/ticket.dart';

class Video extends StatefulWidget {
  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
      showMenu = false;
    });
  }

  bool showMenu = false;

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey,

      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.home,
            color: Colors.black,
            size: 40,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Principale()),
            );
          }, // ou Navigator.pop(context), selon ton besoin
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _currentIndex == 0 ? 'Vente' : 'Historique',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w500),
            ),
            IconButton(
                icon:!showMenu ? Icon(Icons.menu, color: Colors.black, size: 40) : Icon(Icons.playlist_remove_sharp, color: Colors.black, size: 40),
                onPressed: () {
                  setState(() {
                    showMenu = !showMenu;
                  });
                }),
          ],
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                Acceuil(),
                Historique(),
              ],
            ),
          ),
          // Bouton à gauche (inchangé)
          if (showMenu)
            Positioned(
              top: 20,
              left: 60,
              right: 60,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => setCurrentIndex(0),
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(15),
                          backgroundColor: _currentIndex == 0
                              ? Colors.green
                              : Colors.transparent,
                          elevation: _currentIndex == 0 ? 5 : 0,
                        ),
                        child: Icon(
                          Icons.store_mall_directory,
                          size: 35,
                          color:
                              _currentIndex == 0 ? Colors.black : Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => setCurrentIndex(1),
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(15),
                          backgroundColor: _currentIndex == 1
                              ? Colors.green
                              : Colors.transparent,
                          elevation: _currentIndex == 1 ? 5 : 0,
                        ),
                        child: Icon(
                          Icons.history,
                          size: 35,
                          color:
                              _currentIndex == 1 ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),

      // Remplace la colonne de boutons à droite par une BottomNavigationBar


      floatingActionButton: globalState.id_vente != 0 ? SpinningFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class SpinningFAB extends StatefulWidget {
  @override
  _SpinningFABState createState() => _SpinningFABState();
}

class _SpinningFABState extends State<SpinningFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Fait tourner l'animation en boucle
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * pi, // Tourne en continu
              child: child,
            );
          },
          child: CustomPaint(
            size: Size(70, 70),
            painter: SpinnerPainter(),
          ),
        ),
        FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Ticket();
              },
            );
          },
          shape: CircleBorder(),
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.print, size: 25, color: Colors.white),
        ),
      ],
    );
  }
}

class SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final colors = [
      Colors.redAccent,
      Colors.redAccent.shade400,
      Colors.transparent,
      Colors.transparent
    ];

    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      double startAngle = (pi / 2) * i;
      double sweepAngle = pi / 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Utilisation du widget
