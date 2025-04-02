/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/controller/controller.dart';
import 'package:intl/intl.dart';
import 'package:untitled/page/ajouter_produit.dart';

class Stock extends StatefulWidget {
  const Stock({super.key});

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  int? selectedProductId;
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredProduitsDetails = [];

  @override
  void initState() {
    super.initState();
    final globalState = Provider.of<Controller>(context, listen: false);
    filteredProduitsDetails = globalState.produitsDetails;
    globalState.loadProduitsDetails();
    globalState.loadProduits();
    globalState.loadHistoriques();
  }

  void filterProduits(String query, List<Map<String, dynamic>> produitsDetails, List<Map<String, dynamic>> produits) {
    setState(() {
      if (query.isEmpty) {
        filteredProduitsDetails = produitsDetails;
      } else {
        filteredProduitsDetails = produitsDetails.where((item) {
          final produit = produits.firstWhere((p) => p['id_produit'] == item['id_produit']);
          final nom = produit['nom'].toString().toLowerCase();
          return nom.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Disponible":
        return Colors.blueAccent;
      case "Bientôt épuisé":
        return Colors.orangeAccent;
      case "Rupture":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion de Stock", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AjouterProduit());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Champ de recherche
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 10, right: 10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Recherche...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.red),
                  onPressed: () {
                    searchController.clear();
                    filterProduits("", globalState.produitsDetails, globalState.produits);
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                filterProduits(value, globalState.produitsDetails, globalState.produits);
              },
            ),
          ),

          // Liste des produits filtrés
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: filteredProduitsDetails.length,
                itemBuilder: (context, index) {
                  var item = filteredProduitsDetails[index];
                  final nom = globalState.produits.firstWhere(
                        (produit) => produit['id_produit'] == item['id_produit'],
                  );
                  final status = item['stock'] == 0
                      ? "Rupture"
                      : item['stock'] > 0 && item['stock'] <= 3
                      ? "Bientôt épuisé"
                      : "Disponible";
                  bool isSelected = selectedProductId == item['id_produit'];

                  // Filtrer les historiques liés au produit
                  var historiques = globalState.historiques
                      .where((h) => h['id_produit'] == item['id_produit'])
                      .toList();

                  // Calcul de la hauteur dynamique
                  double historiqueHeight = isSelected
                      ? (historiques.length >= 3 ? 261 : historiques.length * 90.0)
                      : 0; // 0 si non sélectionné

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300), // Animation fluide
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.fiber_manual_record_rounded,
                            color: getStatusColor(status),
                            size: 30,
                          ),
                          title: Text(
                            "${nom['nom']} ${item['description']} : ${item['stock'].toStringAsFixed(2)} Kg",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Statut: $status",
                            style: TextStyle(color: getStatusColor(status)),
                          ),
                          onTap: () {
                            setState(() {
                              selectedProductId = isSelected ? null : item['id_produit'];
                            });
                          },
                        ),

                        // Affichage de l'historique si sélectionné
                        if (isSelected)
                          Divider(thickness: 1, height: 1,),
                        if (isSelected)
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: historiqueHeight,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                                child: Column(
                                  children: historiques.map((historique) {
                                    final dateT = DateTime.parse(historique['date']);
                                    return Card(
                                      color: Colors.blue.shade50,
                                      margin: EdgeInsets.only(top: 5),
                                      child: ListTile(
                                        leading: Icon(Icons.add_shopping_cart_outlined , color: Colors.blueAccent),
                                        title: Text(
                                          "${DateFormat('d MMMM y', 'fr').format(dateT)} : ${historique['qualite'].toStringAsFixed(2)} Kg",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          "- Achat : ${historique['prix_achat']} Ar \n- Vente : ${historique['prix_vente']} Ar",
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),


        ],
            )

          );
  }
}*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/controller/controller.dart';
import 'package:intl/intl.dart';
import 'package:untitled/page/ajouter_produit.dart';

class Stock extends StatefulWidget {
  const Stock({super.key});

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  int? selectedProductId;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredProduitsDetails = [];
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    final globalState = Provider.of<Controller>(context, listen: false);
    await globalState.loadProduits();
    await globalState.loadProduitsDetails();
    await globalState.loadHistoriques();

    setState(() {
      filteredProduitsDetails = globalState.produitsDetails;
    });
  }

  void filterProduits(String query, List<Map<String, dynamic>> produitsDetails,
      List<Map<String, dynamic>> produits) {
    setState(() {
      filteredProduitsDetails = query.isEmpty
          ? produitsDetails
          : produitsDetails.where((item) {
        final produit = produits
            .firstWhere((p) => p['id_produit'] == item['id_produit']);
        return produit['nom']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Disponible":
        return Colors.green;
      case "Bientôt épuisé":
        return Colors.orange;
      case "Rupture":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Gestion de Stock",
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.blue.shade900,
          actions: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                showDialog(
                    context: context, builder: (context) => AjouterProduit());
              },
            ),
          ],
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Rechercher un produit...",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.red),
                  onPressed: () {
                    searchController.clear();
                    filterProduits("", globalState.produitsDetails,
                        globalState.produits);
                  },
                )
                    : null,
              ),
              onChanged: (value) => filterProduits(
                  value, globalState.produitsDetails, globalState.produits),
            ),
          ),
          Expanded(
            child: FutureBuilder<void>(
                future: _loadDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text("Erreur de chargement des données"));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemCount: filteredProduitsDetails.length,
                    controller: _scrollController, // Ajout du contrôleur
                    itemBuilder: (context, index) {
                      var item = filteredProduitsDetails[index];
                      final produit = globalState.produits.firstWhere(
                              (p) => p['id_produit'] == item['id_produit'],
                          orElse: () => {'nom': 'Produit inconnu'});
                      final status = item['stock'] == 0
                          ? "Rupture"
                          : item['stock'] <= 3
                          ? "Bientôt épuisé"
                          : "Disponible";
                      bool isSelected = selectedProductId == item['id_produit'];
                      var historiques = globalState.historiques
                          .where((h) => h['id_produit'] == item['id_produit'])
                          .toList();

                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                getStatusColor(status).withOpacity(0.2),
                                child: Icon(Icons.fiber_manual_record,
                                    color: getStatusColor(status)),
                              ),
                              title: Text(
                                "${produit['nom']} ${item['description']} : ${item['stock'].toStringAsFixed(2)} Kg",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("Statut: $status",
                                  style:
                                  TextStyle(color: getStatusColor(status))),
                              trailing: Icon(isSelected
                                  ? Icons.expand_less
                                  : Icons.expand_more),
                              onTap: () {
                                setState(() {
                                  selectedProductId =
                                  isSelected ? null : item['id_produit'];
                                });

                                if (!isSelected) {
                                  _scrollController.animateTo(
                                    index * 100.0,
                                    // Ajustez la valeur selon la hauteur des éléments
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                            if (isSelected)
                              Container(
                                color: Colors.white,
                                // Couleur de fond différente pour l'historique
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Column(
                                  children: [
                                    Divider(thickness: 2),
                                    SizedBox(
                                      height: historiques.length >= 3
                                          ? 268
                                          : historiques.length * 90.0,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children:
                                          historiques.map((historique) {
                                            final dateT = DateTime.parse(
                                                historique['date']);
                                            return Card(
                                              color: Colors.white,
                                              // Fond blanc pour les cartes
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundColor: Colors
                                                      .blueAccent
                                                      .withOpacity(0.1),
                                                  child: Icon(
                                                      Icons
                                                          .add_shopping_cart_outlined,
                                                      color: Colors.blueAccent),
                                                ),
                                                title: Text(
                                                  "${DateFormat('d MMMM y', 'fr').format(dateT)} : ${historique['qualite'].toStringAsFixed(2)} Kg",
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                                subtitle: Text(
                                                  "   - Achat : ${historique['prix_achat']} Ar\n   - Vente : ${historique['prix_vente']} Ar",
                                                  style: TextStyle(
                                                      color: Colors.black87),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }),
          ),
        ]));
  }
}


/*
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/controller/controller.dart';

class Graph extends StatefulWidget {
  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  List<Map<String, dynamic>> filteredProduitsDetails = [];
  Map<String, Color> productColors = {}; // Stocke les couleurs uniques des produits

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final globalState = Provider.of<Controller>(context, listen: false);
    await globalState.loadProduits();
    await globalState.loadProduitsDetails();
    await globalState.loadHistoriques();

    setState(() {
      filteredProduitsDetails = globalState.produitsDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Stock des Produits")),
      body: filteredProduitsDetails.isEmpty
          ? Center(child: CircularProgressIndicator()) // Indicateur de chargement
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sections: filteredProduitsDetails.map((item) {
                  final produit = globalState.produits.firstWhere(
                        (p) => p['id_produit'] == item['id_produit'],
                    orElse: () => {'nom': 'Produit inconnu', 'qualite': 'Inconnue'},
                  );

                  return PieChartSectionData(
                    value: item['stock'].toDouble(), // Stock du produit
                    title: produit['qualite'], // Affiche la qualité du produit
                    color: _getColor(produit['nom']), // Couleur unique
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 20), // Espacement entre le graph et la légende
          _buildLegend(globalState), // Affichage de la légende
        ],
      ),
    );
  }

  // Fonction pour construire la légende
  Widget _buildLegend(Controller globalState) {
    return Wrap(
      spacing: 10,
      runSpacing: 5,
      children: filteredProduitsDetails.map((item) {
        final produit = globalState.produits.firstWhere(
              (p) => p['id_produit'] == item['id_produit'],
          orElse: () => {'nom': 'Produit inconnu'},
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getColor(produit['nom']),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: 5),
            Text(produit['nom'], style: TextStyle(fontSize: 14)),
          ],
        );
      }).toList(),
    );
  }

  // Génère et stocke une couleur unique pour chaque produit
  Color _getColor(String name) {
    if (!productColors.containsKey(name)) {
      productColors[name] = _generateUniqueColor(name);
    }
    return productColors[name]!;
  }

  // Fonction pour générer une couleur unique basée sur le hash du nom
  Color _generateUniqueColor(String name) {
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.yellow, Colors.purple, Colors.orange, Colors.cyan];
    return colors[name.hashCode % colors.length];
  }
}
 */

// acceuil: ************************************ Acceuill******************/

/*import 'package:flutter/material.dart';
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
                                List<Map<String, dynamic>> items = globalState.produitsDetails
                                    .where((p) => p['id_produit'] == produit['id_produit'])
                                    .toList();
                                final sommeStock = globalState.produitsDetails.firstWhere((detailProduit) => detailProduit['id_produit'] == produit['id_produit']);
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    print("les element dans le groupement: $items");
                                    return AcheterProduit(
                                      id: items.first['id_produit'],
                                      nom: produit['nom'],
                                      lanja: sommeStock['stock'],
                                      prix: sommeStock['prix_entrer'],
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
}**/

/******************************************* ***********************************/
