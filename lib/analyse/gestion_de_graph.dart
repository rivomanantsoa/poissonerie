import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/controller/controller.dart';
import 'package:untitled/page/principale.dart';


class GestionDeGraph extends StatefulWidget {
  @override
  _GestionDeGraphState createState() => _GestionDeGraphState();
}

class _GestionDeGraphState extends State<GestionDeGraph> {
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _getProduitQuantities(
      List ventes, List produits, List produitsDetails) {
    Map<int, Map<String, dynamic>> produitQuantites = {};

    for (var vente in ventes) {
      // Étape 1 : Trouver le produitDetail correspondant
      var produitDetail = produitsDetails.firstWhere(
            (p) => p['id_produitDetail'] == vente['id_produitDetail'],
        orElse: () => <String, dynamic>{},
      );

      if (produitDetail.isEmpty) continue;

      int idProduit = produitDetail['id_produit'];

      // Étape 2 : Si le produit n’est pas encore ajouté, on le prépare
      if (!produitQuantites.containsKey(idProduit)) {
        var produit = produits.firstWhere(
              (p) => p['id_produit'] == idProduit,
          orElse: () => {'nom': 'Inconnu'},
        );

        produitQuantites[idProduit] = {
          'nom': produit['nom'],
          'description': produitDetail['description'],
          'quantite': 0.0,
        };
      }

      // Étape 3 : Ajouter la qualité à la quantité totale
      produitQuantites[idProduit]!['quantite'] += vente['qualite'] ?? 0.0;
    }

    // Étape 4 : Retourner les produits triés par quantité décroissante
    List<Map<String, dynamic>> sortedProduits = produitQuantites.values.toList()
      ..sort((a, b) => b['quantite'].compareTo(a['quantite']));

    return sortedProduits;
  }

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
      print("les chose apres dans GestionDeGraph : ${totalAjoute[idProduit]}");
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

        title:  Text("Analyse du Stock", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, shadows: [
          Shadow(
            blurRadius: 4.0,
            color: Colors.black.withOpacity(0.5),
            offset: Offset(2.0, 2.0),
          ),
        ],)),
        // backgroundColor: Colors.blue.shade900,
        centerTitle: true,
        backgroundColor: Colors.purple.shade600,
      ),
      body: Column(
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
                    ? Colors.lightGreenAccent.shade400
                    : (pourcentage >= 50
                    ? Colors.amber.shade400
                    : (pourcentage >= 10
                    ? Colors.yellowAccent
                    : Colors.red));
                return Card(
                  color: Colors.purple.shade600,
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
                            Icon(Icons.inventory, color: Colors.blue.shade900),
                            SizedBox(width: 10),
                            Text(
                              "${filteredStockData[index]['nom']} (${filteredStockData[index]['description']})",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Container(
                height: 100,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._getProduitQuantities(
                          globalState.ventes, globalState.produits, globalState.produitsDetails)
                          .asMap()
                          .entries
                          .map(
                            (entry) {
                          int index = entry.key + 1;
                          var produitQuantite = entry.value;

                          return Card(
                            color: Colors.teal.shade100, // Bleu clair/turquoise
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              width: 180,
                              padding: EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange, // Jaune/orange
                                          borderRadius:
                                          BorderRadius.circular(100),
                                        ),
                                        child: Text(
                                          "$index",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 40),
                                      Text(produitQuantite['nom'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(produitQuantite['description']
                                      .toString()),
                                  SizedBox(height: 5),
                                  Text(
                                    "Totaly lafo: ${produitQuantite['quantite'].toStringAsFixed(2)} Kg",
                                    style: TextStyle(
                                        color: Colors.teal.shade900,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }
}
