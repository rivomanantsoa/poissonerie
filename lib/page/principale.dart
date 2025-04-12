import 'package:flutter/material.dart';
import 'package:untitled/analyse/gestion_de_graph.dart';
import 'package:untitled/page/list_pdf.dart';

import 'package:untitled/stock_managing/scaff.dart';

import 'package:untitled/page/video.dart';

class Principale extends StatefulWidget {
  const Principale({super.key});

  @override
  State<Principale> createState() => _PrincipaleState();
}

class _PrincipaleState extends State<Principale> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Gestion de Poissonnerie", style: TextStyle(fontSize:25, shadows: [
          Shadow(
            blurRadius: 4.0,
            color: Colors.black.withOpacity(0.5),
            offset: Offset(2.0, 2.0),
          ),
        ],)),
        centerTitle: true,
        //backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            SizedBox(
              width: 100,
              height: 100,
              child: Transform.scale(
                scale: 1.2, // 50% de la taille originale
                child: Image.asset("assets/image/carpe.png"),
              ),
            ),


            SizedBox(height: 10),
            Text(
              "Bienvenue dans votre gestionnaire",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),

            SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5, // Rend chaque case plus petite
                children: [
                  _buildMenuButton("Vente", Icons.store_mall_directory, Colors.blue.shade600, Video()),
                  _buildMenuButton("Rapport", Icons.chat, Colors.green.shade600, Video()),
                  _buildMenuButton("Stock", Icons.storage_rounded, Colors.orange.shade600, Scaff()),
                  _buildMenuButton("Analyse", Icons.waterfall_chart_rounded, Colors.purple.shade600, GestionDeGraph()),
                  _buildMenuButton("Fichier", Icons.file_open, Colors.red.shade600, ListPdf()),
                  _buildMenuButton("État Financier", Icons.monetization_on_rounded, Colors.teal.shade600, Video()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, Color color, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page), // Redirige vers la page donnée
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.white, shadows: [
            Shadow(
              blurRadius: 4.0,
              color: Colors.black.withOpacity(0.5),
              offset: Offset(2.0, 2.0),
            ),
          ],),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
