import 'dart:async';
import 'package:flutter/material.dart';
import 'package:untitled/controller/controller.dart';
import 'package:untitled/tools/generat_to_pdf.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class YourWidget extends StatefulWidget {
  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  bool _pdfGeneratedToday = false; // Évite les exécutions multiples
  late Controller globalState;
  @override
  void initState() {
    super.initState();
    _scheduleDailyPDFGeneration();
    globalState = Provider.of<Controller>(context, listen: false);
  }

  void _scheduleDailyPDFGeneration() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var ventesDuJour = globalState.ventes.where((vente) {
      DateTime venteDate = DateTime.parse(vente['date']);
      String venteDateFormatted =
      DateFormat('yyyy-MM-dd').format(venteDate);
      return venteDateFormatted == today;
    }).toList();
    Timer.periodic(Duration(minutes: 1), (timer) {
      final now = DateTime.now();

      if (now.hour == 13 && now.minute == 57 && !_pdfGeneratedToday) {
        _pdfGeneratedToday = true; // Marquer comme exécuté aujourd'hui
        generateAndSavePDF(ventesDuJour, globalState, 0);
      }

      // Réinitialiser le flag après minuit
      if (now.hour == 0 && now.minute == 1) {
        _pdfGeneratedToday = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Votre contenu ici")),
    );
  }
}
