import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/controller/controller.dart';
import 'package:intl/intl.dart';
import 'package:untitled/page/ajouter_produit.dart';
import 'package:untitled/stock_managing/graph.dart';

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
  Map<int, GlobalKey> itemKeys = {};

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
    filteredProduitsDetails = globalState.produitsDetails;
    setState(() {

    });
  }

  void filterProduits(String query, List<Map<String, dynamic>> produitsDetails,
      List<Map<String, dynamic>> produits) {
    filteredProduitsDetails = query.isEmpty
        ? produitsDetails
        : produitsDetails.where((item) {
      final produit = produits.firstWhere(
              (p) => p['id_produit'] == item['id_produit'],
          orElse: () => {});
      print("Produit trouvé pour id_produit ${item['id_produit']}: $produit");
      return produit.isNotEmpty &&
          produit['nom']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase());
    }).toList();
    setState(() {

      // Tri basé sur le nom du produit
      filteredProduitsDetails.sort((a, b) {
        final produitA = produits.firstWhere(
                (p) => p['id_produit'] == a['id_produit'],
            orElse: () => {});
        final produitB = produits.firstWhere(
                (p) => p['id_produit'] == b['id_produit'],
            orElse: () => {});

        final nomA = produitA.isNotEmpty ? produitA['nom'] ?? '' : '';
        final nomB = produitB.isNotEmpty ? produitB['nom'] ?? '' : '';
   print("nomA : $nomA et nomB : $nomB");
        return nomA.compareTo(nomB);
      });
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
  // Fonction pour défiler vers l'élément sélectionné
  void _scrollToItem(int idProduit) {
    final key = itemKeys[idProduit];
    if (key == null) return;

    // Obtenir la position exacte de l'élément
    final context = key.currentContext;
    if (context == null) return;

    final box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    // Faire défiler la liste pour amener l’élément à y = 20 pixels
    _scrollController.animateTo(
      _scrollController.offset + position.dy - 120.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Gestion de Stock",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.blue.shade900,
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                await showDialog(
                    context: context, builder: (context) => const AjouterProduit());
                await _loadData(); // Recharge les données après ajout
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () {
                    searchController.clear();
                    filterProduits("", globalState.produitsDetails, globalState.produits);
                  },
                )
                    : null,
              ),
              onChanged: (value) =>
                  filterProduits(value, globalState.produitsDetails, globalState.produits),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),

              itemCount: filteredProduitsDetails.length,
              controller: _scrollController,
              itemBuilder: (context, index) {
                var item = filteredProduitsDetails[index];
                if (!itemKeys.containsKey(item['id_produit'])) {
                  itemKeys[item['id_produit']] = GlobalKey();
                }

                print("l index pour notre scroll : $index");
                final produit = globalState.produits.firstWhere(
                        (p) => p['id_produit'] == item['id_produit'],
                    orElse: () => {'nom': 'Produit inconnu'});

                final produitDetail = globalState.produitsDetails.firstWhere(
                        (p) => p['id_produit'] == item['id_produit'] &&
                            p['id_produitDetail'] == item['id_produitDetail']);
                print("mitovy ve ny id produit detail? ${item['id_produitDetail']} et l id produit: ${produit['id_produit']}");
                final status = item['stock'] == 0
                    ? "Rupture"
                    : item['stock'] <= 3
                    ? "Bientôt épuisé"
                    : "Disponible";
                bool isSelected = selectedProductId == item['id_produitDetail'];
                var historiques = globalState.historiques
                    .where((h) => h['id_produit'] == produitDetail['id_produit']
                    && h['id_produitDetail'] == item['id_produitDetail']) // Vérification variante
                    .toList();
                print("les historiue sont : $historiques");


                return Card(
                  color: Colors.blue.shade50,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: getStatusColor(status).withOpacity(0.2),
                          child:
                          Icon(Icons.fiber_manual_record, color: getStatusColor(status)),
                        ),
                        title: Text(
                          "${produit['nom']} ${item['description']} : ${item['stock'].toStringAsFixed(2)} Kg",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Statut: $status",
                            style: TextStyle(color: getStatusColor(status))),
                        trailing: Icon(isSelected ? Icons.expand_less : Icons.expand_more),
                        onTap: () {
                          setState(() {
                            selectedProductId = isSelected ? null : item['id_produitDetail'];
                          });

                          if (!isSelected) {
                            // Récupérer la position exacte de l'élément
                            _scrollToItem(item['id_produitDetail']);
                          }
                        },
                      ),
                      if (isSelected)
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Column(
                            children: [
                              const Divider(thickness: 2),
                              SizedBox(
                                height: historiques.length >= 3 ? 268 : historiques.length * 90.0,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: historiques.map((historique) {
                                      final dateT = DateTime.parse(historique['date']);
                                      return Card(
                                        color: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        margin: const EdgeInsets.symmetric(vertical: 5),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.blueAccent.withOpacity(0.1),
                                            child: const Icon(Icons.add_shopping_cart_outlined,
                                                color: Colors.blueAccent),
                                          ),
                                          title: Text(
                                            "${DateFormat('d MMMM y', 'fr').format(dateT)} : ${historique['qualite'].toStringAsFixed(2)} Kg",
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                            "   - Achat : ${historique['prix_achat']} Ar\n   - Vente : ${historique['prix_vente']} Ar",
                                            style: const TextStyle(color: Colors.black87),
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
            ),
          ),
        ]
        ),
      floatingActionButton:

      FloatingActionButton(

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Graph()),
            );
          },
        child: Icon(Icons.bar_chart), // Icône de graphique
        backgroundColor: Colors.blue, // Couleur du bouton
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}
