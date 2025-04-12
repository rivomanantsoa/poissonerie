import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:untitled/controller/controller.dart';
import 'package:untitled/page/ajouter_produit.dart';
import 'package:untitled/page/principale.dart';

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
  late PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final globalState = Provider.of<Controller>(context, listen: false);
    final produitsDetails = globalState.produitsDetails;
    final produits = globalState.produits;
    await globalState.loadHistoriques();

    // Filtrage par groupe
    filteredProduitsDetails = produitsDetails.where((item) {
      final produit = produits.firstWhere(
            (p) => p['id_produit'] == item['id_produit'],
        orElse: () => {},
      );
      return produit['genre'] == selectedGroup;
    }).toList();
    print("les detail de produit dans produit sont: $filteredProduitsDetails");


    setState(() {});
  }


  void filterProduits(String query, List<Map<String, dynamic>> produitsDetails, List<Map<String, dynamic>> produits) {
    filteredProduitsDetails = produitsDetails.where((item) {
      final produit = produits.firstWhere(
            (p) => p['id_produit'] == item['id_produit'],
        orElse: () => {},
      );
      final matchNom = produit['nom'].toString().toLowerCase().contains(query.toLowerCase());
      final matchGroupe = produit['groupe'] == selectedGroup;
      return matchNom && matchGroupe;
    }).toList();

    filteredProduitsDetails.sort((a, b) {
      final nomA = produits.firstWhere((p) => p['id_produit'] == a['id_produit'], orElse: () => {})['nom'] ?? '';
      final nomB = produits.firstWhere((p) => p['id_produit'] == b['id_produit'], orElse: () => {})['nom'] ?? '';
      return nomA.compareTo(nomB);
    });

    setState(() {});
  }


  Color getStatusColor(String status) {
    switch (status) {
      case "Disponible":
        return Colors.blueAccent;
      case "Bientôt épuisé":
        return Colors.yellowAccent;
      case "Rupture":
        return Colors.redAccent.shade700;
      default:
        return Colors.grey;
    }
  }

  /* void _scrollToItem(int index) {
    _scrollController.animateTo(
      index * 150.0, // estimation hauteur élément
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }*/
  String selectedGroup = 'Poissons';

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);
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
        title: Text(
          "Gestion de Stock",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black.withOpacity(0.5),
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.orange.shade600,
        centerTitle: true,
        actions: [
          IconButton(
            icon:  Icon(Icons.add, color: Colors.white, weight: 45, size: 35, shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black.withOpacity(0.5),
                offset: Offset(2.0, 2.0),
              ),
            ],),
            onPressed: () async {
              await showDialog(context: context, builder: (context) => const AjouterProduit());
              await _loadData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Poissons', 'Crustacés', 'Mollusques'].map((group) {
                final isSelected = selectedGroup == group;
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      selectedGroup = group;

                    }

                    );
                    await _loadData();
                  },
                  child: Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange.shade600 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade600),
                    ),
                    child: Text(
                      group,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.orange.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ),
                );
              }).toList(),
            ),
          ),
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
              onChanged: (value) => filterProduits(value, globalState.produitsDetails, globalState.produits),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10.0),
              itemCount: filteredProduitsDetails.length,
              itemBuilder: (context, index) {
                final item = filteredProduitsDetails[index];
                final produit = globalState.produits.firstWhere(
                      (p) => p['id_produit'] == item['id_produit'],
                  orElse: () => {'nom': 'Produit inconnu'},
                );
                final produitDetail = globalState.produitsDetails.firstWhere(
                      (p) => p['id_produit'] == item['id_produit'] &&
                      p['id_produitDetail'] == item['id_produitDetail'],
                );
                print("les zavatra ao am produit detail: $produitDetail");

                final status = item['stock'] == 0
                    ? "Rupture"
                    : item['stock'] <= 3
                    ? "Bientôt épuisé"
                    : "Disponible";

                bool isSelected = selectedProductId == item['id_produitDetail'];
                //globalState.loadHistoriques();
                final historiques = globalState.historiques
                    .where((h) =>
                h['id_produit'] == produitDetail['id_produit'] &&
                    h['id_produitDetail'] == item['id_produitDetail'])
                    .toList();

                print("les historique dan notre histoire sont : $historiques");

                return Card(
                  color: Colors.orange.shade600,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: getStatusColor(status).withOpacity(0.2),
                          child: Icon(Icons.fiber_manual_record, color: getStatusColor(status)),
                        ),
                        title: Text(
                          "${produit['nom']} ${item['description']} : ${item['stock'].toStringAsFixed(2)} Kg",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        subtitle: Text("Statut: $status", style: TextStyle(color: getStatusColor(status))),
                        trailing: Icon(isSelected ? Icons.expand_less : Icons.expand_more , color: Colors.white),
                        onTap: () {
                          setState(() {
                            selectedProductId = isSelected ? null : item['id_produitDetail'];
                          });
                          //if (!isSelected) _scrollToItem(index);
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
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        margin: const EdgeInsets.symmetric(vertical: 5),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.blueAccent.withOpacity(0.1),
                                            child: const Icon(Icons.add_shopping_cart_outlined, color: Colors.blueAccent),
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
        ],
      ),
    );
  }
}
