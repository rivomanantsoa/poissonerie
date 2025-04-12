import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/controller/controller.dart';
import 'package:untitled/page/acheter_produit.dart';



class Acceuil extends StatefulWidget {
  @override
  _AcceuilState createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {
  final TextEditingController searchController = TextEditingController();
  late Future<void> _loadDataFuture;


  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();

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
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(
                  group,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.blue,
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          /// Partie qui peux etre scrollable pour afficher la group suivant
          Expanded(
            child: FutureBuilder<void>(
              future: _loadDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                List filteredProduits = globalState.produits
                    .where((produit) =>
                produit['nom']
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()) &&
                    produit['genre'].toString().toLowerCase() ==
                        selectedGroup.toLowerCase())
                    .toList();


                // Tri par ordre alphabétique
                filteredProduits.sort((a, b) => a['nom'].compareTo(b['nom']));

                if (filteredProduits.isEmpty) {
                  return Center(child: Text("Aucun produit trouvé"));
                }

                String?
                    lastInitial; // Variable pour stocker la première lettre précédente

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
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Card(
                          color: Colors.white54,
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Transform.scale(
                                      scale:2,
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage(
                                            getImageForProduct(produit['nom'])),
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    Expanded(
                                      child: Text(
                                        produit['nom'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,color: Colors.blueAccent
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Table(
                                  border: TableBorder.all(color: Colors.grey),
                                  columnWidths: {
                                    0: FlexColumnWidth(1),
                                    1: FlexColumnWidth(1),
                                    2: FlexColumnWidth(1),
                                    3: FlexColumnWidth(1),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200]),
                                      children: [
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
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
                                              TableCellVerticalAlignment.middle,
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
                                              TableCellVerticalAlignment.middle,
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
                                              TableCellVerticalAlignment.middle,
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
                                              child:
                                                  Text(variante['description']),
                                            ),
                                          ),
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                  "${variante['stock']} Kg"),
                                            ),
                                          ),
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                  "${variante['prix_entrer']} Ar"),
                                            ),
                                          ),
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue.shade400,
                                                  // Bleu-vert aquatique
                                                  foregroundColor: Colors.white,
                                                  // Couleur de l'icône
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50), // Coins arrondis
                                                  ),
                                                  elevation:
                                                      5, // Légère ombre pour donner du relief
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
                                                child: Icon(Icons.shopping_cart,
                                                    color: Colors.white, size: 20,),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                SizedBox(height: 30,)
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
