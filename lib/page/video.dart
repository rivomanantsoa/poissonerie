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
  double get menuTopPosition => showMenu ? -8 : -200; // 70 si visible, -200 si caché

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.home,
            color: Colors.white,
            size: 40,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black.withOpacity(0.5),
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Principale()),
            );
          }, // ou Navigator.pop(context), selon ton besoin
        ),
        title: Text(
          _currentIndex == 0 ? 'Vente' : 'Historique',
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.w500, color: Colors.white, shadows: [
            Shadow(
              blurRadius: 4.0,
              color: Colors.black.withOpacity(0.5),
              offset: Offset(2.0, 2.0),
            ),
          ],),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        actions: [
          IconButton(
          icon: !showMenu
              ? Icon(Icons.menu, color: Colors.white, size: 40,
            shadows: [
            Shadow(
              blurRadius: 4.0,
              color: Colors.black.withOpacity(0.5),
              offset: Offset(2.0, 2.0),
            ),
          ],)
              : Icon(Icons.playlist_remove_sharp, color: Colors.black, size: 40, shadows: [
            Shadow(
              blurRadius: 4.0,
              color: Colors.blue.withOpacity(0.5),
              offset: Offset(2.0, 2.0),
            ),
          ],),

          onPressed: () {
            setState(() {
              showMenu = !showMenu;
            });
          },

        ),
        ],
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
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: menuTopPosition,
              // dynamique
              right: 6,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(color: Colors.black,),
                      Tooltip(
                        message: 'Vente',
                        child: ElevatedButton(
                          onPressed: () {
                            setCurrentIndex(0);
                            setState(() {
                              showMenu = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                           // shape: CircleBorder(),
                            padding: EdgeInsets.all(0),
                            backgroundColor: _currentIndex == 0
                                ? Colors.cyanAccent.shade400
                                : Colors.transparent,
                            shadowColor: Colors.transparent,
                          //  elevation: _currentIndex == 0 ? 6 : 2,
                          ),
                          child: Icon(
                            Icons.store_mall_directory,
                            size: 30,
                            color: _currentIndex == 0
                                ? Colors.white
                                : Colors.black,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(color: Colors.black,),
                      Tooltip(
                        message: 'Historique',
                        child: ElevatedButton(
                          onPressed: () {
                            setCurrentIndex(1);
                            setState(() {
                             showMenu = true;
                            });
                          },

                          style: ElevatedButton.styleFrom(
                        //    shape: CircleBorder(),
                            padding: EdgeInsets.all(0),
                            backgroundColor: _currentIndex == 1
                                ? Colors.cyanAccent.shade400
                                : Colors.transparent,
                            shadowColor: Colors.transparent,
                            //elevation: _currentIndex == 1 ? 6 : 2,
                          ),
                          child: Icon(
                            Icons.history,
                            size: 30,
                            color: _currentIndex == 1
                                ? Colors.white
                                : Colors.black,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            ),
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
          child: Icon(Icons.shopping_basket_rounded,
              size: 25, color: Colors.white),
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
