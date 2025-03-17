import 'package:flutter/material.dart';
import 'package:untitled/controller/controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart'; // Pour formater la date

class ListTousVente extends StatefulWidget {
  const ListTousVente({super.key});

  @override
  State<ListTousVente> createState() => _ListTousVenteState();
}

class _ListTousVenteState extends State<ListTousVente> {
  late Controller globalState;
  late Future<void> _loadDataFuture = _initializeData();

  @override
  void initState() {
    super.initState();
    globalState = Provider.of<Controller>(context, listen: false);
    _loadDataFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    await globalState
        .loadVentes(); // Assurez-vous que cette méthode charge bien les ventes
    setState(() {});
  }

  final ScrollController _scrollController = ScrollController();

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent, // Aller à droite
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      0.0, // Aller à gauche
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  List<Map<String, dynamic>> _getProduitQuantities(List ventes, List produits) {
    Map<int, Map<String, dynamic>> produitQuantites = {};

    print("Les produits sont : $produits");
    print("Les ventes sont : $ventes");

    for (var vente in ventes) {
      int idProduit = vente['id_produit'];

      // Vérifier si le produit est déjà ajouté
      if (!produitQuantites.containsKey(idProduit)) {
        var produit = produits.firstWhere(
          (p) => p['id_produit'] == idProduit,
          orElse: () => {'nom': 'Inconnu', 'description': ''},
        );

        produitQuantites[idProduit] = {
          'nom': produit['nom'],
          'description': produit['description'],
          'quantite': 0.0, // Initialisation à 0 pour éviter le null
        };
      }

      // Ajouter la quantité de la vente au total
      produitQuantites[idProduit]!['quantite'] += vente['qualite'] ?? 0.0;
    }

    // Trier la liste des produits en fonction de la quantité vendue (du plus grand au plus petit)
    List<Map<String, dynamic>> sortedProduits = produitQuantites.values.toList()
      ..sort((a, b) => b['quantite'].compareTo(a['quantite']));

    return sortedProduits;
  }
  Map<String, List<Map<String, dynamic>>> groupVentesByDate(List<Map<String, dynamic>> ventes) {
    Map<String, List<Map<String, dynamic>>> groupedVentes = {};

    for (var vente in ventes) {
      DateTime venteDate = DateTime.parse(vente['date']);
      String dateFormatted = DateFormat('yyyy-MM-dd').format(venteDate);

      if (!groupedVentes.containsKey(dateFormatted)) {
        groupedVentes[dateFormatted] = [];
      }
      groupedVentes[dateFormatted]!.add(vente);
    }

    return groupedVentes;
  }


  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Text(
            "Ventes par date",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: _loadDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Grouper les ventes par date
                var ventesGrouped = groupVentesByDate(globalState.ventes);

                if (ventesGrouped.isEmpty) {
                  return Center(child: Text("Aucune vente trouvée"));
                }

                return ListView(
                  padding: EdgeInsets.zero,
                  children: ventesGrouped.entries.map((entry) {
                    String date = entry.key;
                    List<Map<String, dynamic>> ventes = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Afficher la date en tant que section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          child: Text(
                            DateFormat('EEEE d MMMM y', 'fr_FR').format(DateTime.parse(date)),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                        // Afficher les ventes de cette date
                        ...ventes.map((vente) {
                          final nomProduit = globalState.produits.firstWhere(
                                  (produit) => produit['id_produit'] == vente['id_produit'], orElse: () => {});
                          final dateT = DateTime.parse(vente['date']);

                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              title: Text(
                                "${nomProduit['nom'] ?? 'Produit inconnu'} - ${nomProduit['description'] ?? ''}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                              subtitle: Text("Quantité : ${vente['qualite']} Kg - Prix : ${vente['prix_total']} Ariary"),
                              trailing: Text(
                                DateFormat('HH:mm').format(dateT),
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
