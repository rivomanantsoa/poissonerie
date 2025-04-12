import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pour formater la date
import 'package:untitled/controller/controller.dart';
import 'package:untitled/tools/generat_to_pdf.dart';
import 'dart:async';

class Historique extends StatefulWidget {
  const Historique({super.key});

  @override
  State<Historique> createState() => _HistoriqueState();
}

class _HistoriqueState extends State<Historique> {
  late Controller globalState;
  late Future<void> _loadDataFuture = _initializeData();
  //bool _pdfGeneratedToday = false; // Évite les exécutions multiples

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

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var ventesDuJour = globalState.ventes.where((vente) {
      DateTime venteDate = DateTime.parse(vente['date']);
      String venteDateFormatted = DateFormat('yyyy-MM-dd').format(venteDate);
      return venteDateFormatted == today;
    }).toList();

    double beneficeTotal = 0.0;

    for (var vente in ventesDuJour) {
      // On récupère le produitDetail correspondant à cette vente
      var produitDetail = globalState.produitsDetails.firstWhere(
        (p) => p['id_produitDetail'] == vente['id_produitDetail'],
        orElse: () => {},
      );

      if (produitDetail.isNotEmpty) {
        double prixAchat = produitDetail['prix_unitaire'];
        double prixVente = produitDetail['prix_entrer'];
        double quantiteVendue = vente['qualite'];

        double benefice = (prixVente - prixAchat) * quantiteVendue;
        beneficeTotal += benefice;
      }
    }

    print('Bénéfice total du jour : $beneficeTotal Ar');

    ventesDuJour.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateB.compareTo(dateA);
    });
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 15),
      child: Column(
        children: [
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Aujourd'hui : ${DateFormat("dd MMMM  yyyy", "fr_FR").format(DateTime.parse(today))}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue.shade600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0, bottom: 0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.transparent, // Bleu océan plus clair
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "- Poids total : ${ventesDuJour.fold<double>(0, (total, vente) => total + ((vente['qualite'] ?? 0) as double)).toStringAsFixed(3)} Kg"
                              "\n- Momant total : ${ventesDuJour.fold<double>(0, (total, vente) => total + ((vente['prix_total'] ?? 0) as double)).toStringAsFixed(2)} Ar",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                            if (1 == 0)
                              IconButton(
                                icon: Icon(Icons.picture_as_pdf),
                                onPressed: () {
                                  generateAndSavePDF(
                                      ventesDuJour, globalState, beneficeTotal);
                                },
                              ),
                            Text("- Total bénéfice: $beneficeTotal Ar",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black))
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Divider(
                        color: Colors.blue.shade600,
                        height: 2,
                        thickness: 4,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: ventesDuJour.length,
                        padding: EdgeInsets.only(top: 10),
                        itemBuilder: (context, index) {
                          final vente = ventesDuJour[index];
                          // 1. Trouver le produitDetail lié à cette vente
                          final produitDetail =
                              globalState.produitsDetails.firstWhere(
                            (p) =>
                                p['id_produitDetail'] ==
                                vente['id_produitDetail'],
                            orElse: () => {},
                          );
                          final benefice = (produitDetail['prix_entrer'] -
                                  produitDetail['prix_unitaire']) *
                              vente['qualite'];

// 2. Si trouvé, remonter au produit
                          Map<String, dynamic> nomProduit = {'nom': 'Inconnu'};
                          if (produitDetail.isNotEmpty) {
                            final idProduit = produitDetail['id_produit'];
                            nomProduit = globalState.produits.firstWhere(
                              (p) => p['id_produit'] == idProduit,
                              orElse: () => {'nom': 'Inconnu'},
                            );
                          }

// Tu peux ensuite utiliser :
                          print("Nom : ${nomProduit['nom']}");
                          print(
                              "Description : ${produitDetail['description'] ?? ''}");

                          final descriptionProduit = globalState.produitsDetails
                              .firstWhere((produit) =>
                                  produit['id_produitDetail'] ==
                                  vente['id_produitDetail']);
                          final lanja =
                              (vente['qualite'] * 1000).toStringAsFixed(1);
                          final dateT = DateTime.parse(vente['date']);
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.set_meal_outlined, color: Colors.blue.shade400, size: 25,
                                   ),
                                  Text(
                                    " ${nomProduit['nom']} ${descriptionProduit['description']} ",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade400),
                                  ),
                                ],
                              ),
                              ListTile(
                                title: Text(
                                  "Bénéfice : $benefice Ar",
                                  style: TextStyle(
                                       color: Colors.teal),
                                ),
                                subtitle: Text(
                                  "📦 Poids : ${vente['qualite'].toStringAsFixed(1)} Kg  ~${lanja} g~"
                                  " \n💰 Prix : ${vente['prix_total']} Ar",
                                  style: TextStyle(color: Colors.black),
                                ),
                                trailing: Text(
                                  DateFormat('HH:mm').format(dateT),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0),
                                child: Divider(
                                  color: Colors.blue.shade600,
                                  thickness: 2,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
