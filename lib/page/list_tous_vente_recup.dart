import 'package:flutter/material.dart';
import 'package:untitled/controller/controller.dart';
import 'package:provider/provider.dart';


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
