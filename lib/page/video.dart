import 'package:flutter/material.dart';
import 'package:untitled/page/acceuil.dart';
import 'package:untitled/page/historique.dart';
import 'package:provider/provider.dart';
import 'package:untitled/controller/controller.dart';
import 'dart:math';

class Video extends StatefulWidget {
  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;


  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);

    return Scaffold(
      backgroundColor: Colors.cyanAccent.shade700,
      /*appBar: AppBar(
        title: Center(
          child: Text(
            _currentIndex == 0 ? 'Home' : 'Historique',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w500),
          ),
        ),
        backgroundColor: Colors.white,
      ),*/
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
          Positioned(
            right: 6,
            top: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => setCurrentIndex(0),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(15),
                    elevation: 5,
                    backgroundColor:
                        _currentIndex == 0 ? Colors.greenAccent : Colors.white,
                  ),
                  child: Icon(Icons.home, size: 25, color: Colors.black),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setCurrentIndex(1),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    elevation: 5,
                    padding: EdgeInsets.all(15),
                    backgroundColor:
                        _currentIndex == 1 ? Colors.greenAccent : Colors.white,
                  ),
                  child: Icon(Icons.history, size: 25, color: Colors.black),
                ),
              ],
            ),
          ),

        ],
      ),
      floatingActionButton: globalState.id_vente != 0 ? SpinningFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

    );
  }
}


class SpinningFAB extends StatefulWidget {
  @override
  _SpinningFABState createState() => _SpinningFABState();
}

class _SpinningFABState extends State<SpinningFAB> with SingleTickerProviderStateMixin {
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
            // Action du bouton print
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

    final colors = [Colors.redAccent, Colors.redAccent.shade400, Colors.transparent, Colors.transparent];

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

