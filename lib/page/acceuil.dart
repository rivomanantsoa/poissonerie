import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/controller/controller.dart'; // Assurez-vous d'importer votre contrôleur
import 'acheter_produit.dart';

class Acceuil extends StatefulWidget {
  @override
  _AcceuilState createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    final globalState = Provider.of<Controller>(context, listen: false);
    await globalState.loadProduits(); // Charge les produits depuis le contrôleur
  }

  // Regrouper les produits par première lettre et ne garder qu'un seul élément par nom
  // Regrouper les produits par première lettre et ne garder qu'un seul élément par nom
  Map<String, List<Map<String, dynamic>>> groupProduitsByFirstLetter(List<Map<String, dynamic>> produits) {
    Map<String, List<Map<String, dynamic>>> groupedProduits = {};
    Set<String> seenNames = {}; // Pour éviter les doublons

    // Copier la liste pour éviter l'erreur de modification d'une liste en lecture seule
    List<Map<String, dynamic>> produitsCopy = List.from(produits);
    produitsCopy.sort((a, b) => a['nom'].compareTo(b['nom']));

    for (var produit in produitsCopy) {
      if (produit['nom'] == null || produit['nom'].isEmpty) continue;
      String firstLetter = produit['nom'][0].toUpperCase(); // Première lettre du nom

      if (!groupedProduits.containsKey(firstLetter)) {
        groupedProduits[firstLetter] = [];
      }

      if (!seenNames.contains(produit['nom'])) { // Vérifie si ce nom a déjà été ajouté
        groupedProduits[firstLetter]!.add(produit);
        seenNames.add(produit['nom']); // Ajoute le nom à la liste des produits déjà affichés
      }
    }

    // Trier les groupes par ordre alphabétique
    var sortedKeys = groupedProduits.keys.toList()..sort();
    Map<String, List<Map<String, dynamic>>> sortedGroupedProduits = {};
    for (var key in sortedKeys) {
      sortedGroupedProduits[key] = groupedProduits[key]!;
    }

    return sortedGroupedProduits;
  }



  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top:35.0, left: 10, right: 10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Recherche...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {}); // Met à jour l'affichage en fonction de la recherche
              },
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<void>(
            future: _loadDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final filteredProduits = globalState.produits.where((produit) {
                final nom = produit['nom']?.toLowerCase() ?? ''; // Vérifier null et convertir en minuscule
                return nom.contains(searchController.text.toLowerCase());
              }).toList();

              final produitsGrouped = groupProduitsByFirstLetter(filteredProduits);
             // final Map<String, List<Map<String, dynamic>>> produitsGrouped = groupProduitsByFirstLetter(globalState.produits);

              if (produitsGrouped.isEmpty) {
                return Center(child: Text("Aucun produit trouvé"));
              }

              return ListView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                children: produitsGrouped.keys.map((firstLetter) {
                  var produits = produitsGrouped[firstLetter]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        child: Text(
                          firstLetter, // Affiche la lettre regroupant les produits
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: produits.map((produit) {
                            return GestureDetector(
                              onTap: () {
                                // Récupérer toutes les variantes de ce produit
                                List<Map<String, dynamic>> items = globalState.produits
                                    .where((p) => p['nom'] == produit['nom'])
                                    .toList();

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    print("les element dans le groupement: $items");
                                    return AcheterProduit(
                                      id: items.first['id_produit'],
                                      nom: produit['nom'],
                                      lanja: items.first['stock'],
                                      prix: items.first['prix_entrer'],
                                      items: items,
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: AssetImage('assets/image/poisson.png'),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      produit['nom'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
