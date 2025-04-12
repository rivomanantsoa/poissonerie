import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/controller/controller.dart';

import 'acheter_produit.dart';

class Acceuil extends StatefulWidget {
  @override
  _AcceuilState createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {
  final TextEditingController searchController = TextEditingController();
  late Future<void> _loadDataFuture;
  late PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
    _pageController = PageController(initialPage: 0);
  }

  Future<void> _loadData() async {
    final globalState = Provider.of<Controller>(context, listen: false);
    await globalState.loadProduits();
  }

  String getImageForProduct(String productName) {
    productName = productName.toLowerCase();

    Map<String, List<String>> imageKeywords = {
      'merlin.png': ['merlin', 'marlin', 'poisson à bec'],
      'fish.png': ['tilapia', 'tilapie'],
      'eau.png': ['thon', 'tuna'],
    };

    for (var entry in imageKeywords.entries) {
      for (var keyword in entry.value) {
        if (productName.contains(keyword.toLowerCase())) {
          return 'assets/image/${entry.key}';
        }
      }
    }

    return 'assets/image/carpe.png'; // Image par défaut si rien ne matche
  }

  String selectedGroup = 'Poissons';

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0, top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Poissons', 'Crustacés', 'Mollusques'].map((group) {
                final isSelected = selectedGroup == group;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedGroup = group;
                      _pageController.animateToPage(
                        ['Poissons', 'Crustacés', 'Mollusques'].indexOf(group),
                        duration: Duration(milliseconds: 2000),
                        curve: Curves.easeInOut,
                      );
                    });
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF0288D1) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFF0288D1)),
                    ),
                    child: Text(
                      group,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Color(0xFF0288D1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 5, left: 80, right: 80),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Recherche...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Color(0xffF1FfEf),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),

              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          /// Partie qui peux etre scrollable pour afficher la group suivant
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index) {
                setState(() {
                  selectedGroup =
                      ['Poissons', 'Crustacés', 'Mollusques'][index];
                });
              },
              itemCount: 3,
              // Nombre de groupes
              itemBuilder: (context, index) {
                final group = ['Poissons', 'Crustacés', 'Mollusques'][index];

                List filteredProduits = globalState.produits
                    .where((produit) =>
                        produit['nom']
                            .toLowerCase()
                            .contains(searchController.text.toLowerCase()) &&
                        produit['genre'].toString().toLowerCase() ==
                            group.toLowerCase())
                    .toList();

                filteredProduits.sort((a, b) => a['nom'].compareTo(b['nom']));

                if (filteredProduits.isEmpty) {
                  return Center(
                      child: Text("Aucun produit trouvé dans $group"));
                }
                String? lastInitial;

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  itemCount: filteredProduits.length,
                  itemBuilder: (context, index) {
                    final produit = filteredProduits[index];
                    final variantes = globalState.produitsDetails
                        .where((p) => p['id_produit'] == produit['id_produit'])
                        .toList();

                    String currentInitial = produit['nom'][0].toUpperCase();

                    bool showHeader = lastInitial != currentInitial;
                    lastInitial =
                        currentInitial; // Mettre à jour la dernière initiale traitée

                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader) // Affiche la première lettre si elle change
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 10),
                              child: Text(
                                currentInitial,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ),
                          Card(
                            color:  Colors.blue.shade600,//Color(0xFFF1F8E9),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),

                            margin: EdgeInsets.symmetric(vertical: 8),

                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: 2,
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: AssetImage(
                                              getImageForProduct(
                                                  produit['nom'])),
                                        ),
                                      ),
                                      const SizedBox(width: 60, ),
                                      Expanded(
                                        child: Text(
                                          produit['nom'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),

                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Table(
                                    border: TableBorder.all(color: Colors.white),
                                    columnWidths: {
                                      0: FlexColumnWidth(1),
                                      1: FlexColumnWidth(1),
                                      2: FlexColumnWidth(1),
                                      3: FlexColumnWidth(1),
                                    },
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFB3E5FC),
                                        ),

                                        children: [
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text("Variante",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text("Stock",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text("Prix",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text("Acheter",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      for (var variante in variantes)
                                        TableRow(
                                          children: [
                                            TableCell(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              child: Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                    variante['description'],  style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold)),

                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              child: Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                    "${variante['stock']} Kg", style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.w400)),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              child: Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                    "${variante['prix_entrer']} Ar", style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.w400)),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    // Bleu-vert aquatique
                                                    foregroundColor:
                                                        Colors.white,
                                                    // Couleur de l'icône
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50), // Coins arrondis
                                                    ),
                                                    elevation:
                                                        0, // Légère ombre pour donner du relief
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        print(
                                                            "le id_produit : ${variante['id_produit']} 000000000000");
                                                        return AcheterProduit(
                                                          id: variante[
                                                              'id_produitDetail'],
                                                          nom: produit['nom'],
                                                          lanja:
                                                              variante['stock'],
                                                          prix: variante[
                                                              'prix_entrer'],

                                                          items: [],
                                                          descriptionT: variante[
                                                              'description'],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.shopping_cart,
                                                    color: Colors.white,
                                                    size: 30,
                                                    shadows: [
                                                      Shadow(
                                                        blurRadius: 4.0,
                                                        color: Colors.black.withOpacity(0.5),
                                                        offset: Offset(2.0, 2.0),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 30,
                                  )
                                ],
                              ),
                            ),
                          )
                        ]);
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
