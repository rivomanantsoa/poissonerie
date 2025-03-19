import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pour formater la date
import 'package:untitled/controller/controller.dart';
import 'package:untitled/tools/generat_to_pdf.dart';

class Historique extends StatefulWidget {
  const Historique({super.key});

  @override
  State<Historique> createState() => _HistoriqueState();
}

class _HistoriqueState extends State<Historique> {
  late Controller globalState;
  late Future<void> _loadDataFuture = _initializeData();

  @override
  void initState() {
    super.initState();
    globalState = Provider.of<Controller>(context, listen: false);
    _loadDataFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    await globalState.loadVentes();
    setState(() {});
  }

  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _getProduitQuantities(List ventes, List produits, List produitsDetails) {
    Map<int, Map<String, dynamic>> produitQuantites = {};

    for (var vente in ventes) {
      int idProduit = vente['id_produit'];

      if (!produitQuantites.containsKey(idProduit)) {
        var produit = produits.firstWhere(
              (p) => p['id_produit'] == idProduit,
          orElse: () => {'nom': 'Inconnu',},
        );
        var produitDetails = produitsDetails.firstWhere(
              (p) => p['id_produit'] == idProduit,
          orElse: () => {'nom': 'Inconnu', 'description': ''},
        );

        produitQuantites[idProduit] = {
          'nom': produit['nom'],
          'description': produitDetails['description'],
          'quantite': 0.0,
        };
      }

      produitQuantites[idProduit]!['quantite'] += vente['qualite'] ?? 0.0;
    }

    List<Map<String, dynamic>> sortedProduits = produitQuantites.values.toList()
      ..sort((a, b) => b['quantite'].compareTo(a['quantite']));

    return sortedProduits;
  }

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var ventesDuJour = globalState.ventes.where((vente) {
      DateTime venteDate = DateTime.parse(vente['date']);
      String venteDateFormatted =
      DateFormat('yyyy-MM-dd').format(venteDate);
      return venteDateFormatted == today;
    }).toList();

    ventesDuJour.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateB.compareTo(dateA);
    });
    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 5, bottom: 1),
            decoration: BoxDecoration(
              color: Colors.transparent, // Bleu profond
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  "Varotra androany",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Texte blanc
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.picture_as_pdf),
                  onPressed: () {
                    generateAndSavePDF(ventesDuJour, globalState);
                  },
                )

              ],
            ),
          ),
          //SizedBox(height: 5),
          Expanded(
            child: FutureBuilder<void>(
              future: _loadDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }



                if (ventesDuJour.isEmpty) {
                  return Center(
                      child: Text("Aucune vente aujourd'hui",
                          style: TextStyle(
                              fontSize: 16, color: Colors.teal.shade800)));
                }

                return Column(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade300 , // Bleu océan plus clair
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          " - Totalin'ny lafo : ${ventesDuJour.fold<double>(0, (total, vente) => total + ((vente['qualite'] ?? 0) as double)).toStringAsFixed(2)} Kg\n"
                              " - Vola: ${ventesDuJour.fold<double>(0, (total, vente) => total + ((vente['prix_total'] ?? 0) as double)).toStringAsFixed(2)} Ariary",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: ventesDuJour.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final vente = ventesDuJour[index];
                          final nomProduit = globalState.produits.firstWhere(
                                  (produit) =>
                              produit['id_produit'] == vente['id_produit']);
                          final descriptionProduit = globalState.produitsDetails.firstWhere(
                                  (produit) =>
                              produit['id_produit'] == vente['id_produit']);

                          final dateT = DateTime.parse(vente['date']);
                          return Card(
                            color: Colors.cyan.shade300, // Bleu très clair
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: ListTile(
                              title: Text(
                                " ${nomProduit['nom']} ${descriptionProduit['description']} ",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade900),
                              ),
                              subtitle: Text(
                                  "📦 Lanja : ${vente['qualite']} Kg - 💰 Vidiny : ${vente['prix_total']} Ar"),
                              trailing: Text(
                                DateFormat('HH:mm').format(dateT),
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
