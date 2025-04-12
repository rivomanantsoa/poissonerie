import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/controller/controller.dart';


class Graph extends StatefulWidget {
  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  String searchQuery = "";


  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);

    // Calcul du stock actuel par produit
    Map<int, double> stockActuel = {};
    for (var produit in globalState.produitsDetails) {
      int idProduit = produit['id_produitDetail'];
      double stock = produit['stock'] ?? 0.0;
      stockActuel[idProduit] = stock;
    }

    // Calcul de la somme des quantités ajoutées depuis l'historique
    Map<int, double> totalAjoute = {};
    for (var historique in globalState.historiques) {
      int idProduit = historique['id_produitDetail'];
      double qualite = historique['qualite'] ?? 0.0;
      print("les id_produit detail dans la quantilete : $qualite 020020202");
      totalAjoute[idProduit] = (totalAjoute[idProduit] ?? 0) + qualite;
      print("les chose apres dans graph : ${totalAjoute[idProduit]}");
    }

    // Calcul du pourcentage de stock restant
    List<Map<String, dynamic>> stockData = [];

    for (var detail in globalState.produitsDetails) {
      int idProduit = detail['id_produit'];
      int idDetailProduit = detail['id_produitDetail'];
      String description = detail['description'];
      double stockRestant = detail['stock'] ?? 0.0;

      var produit = globalState.produits.firstWhere(
            (prod) => prod['id_produit'] == idProduit,
        orElse: () => {'nom': 'Produit inconnu'},
      );

      String nom = produit['nom'];
      double stockInitial = totalAjoute[idDetailProduit] ?? 0.0;
      print("stockRestant : $stockRestant, stockInitial : $stockInitial voici le nom : $nom");
      double pourcentageStock = stockInitial > 0 ? (stockRestant / stockInitial) * 100 : 0.0;

      stockData.add({
        'id_produitDetail': idDetailProduit,
        'nom': nom,
        'description': description,
        'pourcentage': pourcentageStock.clamp(0, 100),
      });
    }


    // Trier les produits par nom
    stockData.sort((a, b) => a['nom'].compareTo(b['nom']));

    // Filtrer les résultats en fonction de la recherche
    List<Map<String, dynamic>> filteredStockData = stockData
        .where((item) => item['nom'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:  Text("Analyse du Stock", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, shadows: [
          Shadow(
            blurRadius: 4.0,
            color: Colors.black.withOpacity(0.5),
            offset: Offset(2.0, 2.0),
          ),
        ],)),
       // backgroundColor: Colors.blue.shade900,
        centerTitle: true,
        backgroundColor: Colors.orange.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Rechercher un produit...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),

              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: filteredStockData.isEmpty
                  ? Center(child: Text("Aucune donnée disponible"))
                  : ListView.builder(
                itemCount: filteredStockData.length,
                itemBuilder: (context, index) {
                  double pourcentage = filteredStockData[index]['pourcentage'].toDouble();

                  Color barColor = pourcentage == 100
                      ? Colors.black
                      : (pourcentage >= 50
                      ? Colors.blueAccent
                      : (pourcentage >= 10
                      ? Colors.yellowAccent
                      : Colors.red));
                  return Card(
                    color: Colors.orange.shade600,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.inventory, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                "${filteredStockData[index]['nom']} (${filteredStockData[index]['description']})",
                                style: TextStyle(fontSize: 18,color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value: pourcentage / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(barColor),
                              minHeight: 10,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Stock restant: ${pourcentage.toStringAsFixed(1)}%",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),

      ),

    );
  }
}
