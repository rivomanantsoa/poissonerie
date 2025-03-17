import 'package:flutter/material.dart';

class AlphabetListScreen extends StatefulWidget {
  @override
  _AlphabetListScreenState createState() => _AlphabetListScreenState();
}

class _AlphabetListScreenState extends State<AlphabetListScreen> {
  late ScrollController _scrollController;
  late TextEditingController _searchController;

  // Exemple de produits (les noms commencent par A à Z pour la démo)
  List<Map<String, String>> _produits = [
    {'nom': 'Apple'},
    {'nom': 'Avocado'},
    {'nom': 'Banana'},
    {'nom': 'Broccoli'},
    {'nom': 'Carrot'},
    {'nom': 'Cherry'},
    {'nom': 'Date'},
    {'nom': 'Eggplant'},
    {'nom': 'Fig'},
    {'nom': 'Grapes'},
    {'nom': 'Honeydew'},
    {'nom': 'Iceberg Lettuce'},
    {'nom': 'Jackfruit'},
    {'nom': 'Kiwi'},
    {'nom': 'Lemon'},
    {'nom': 'Mango'},
    {'nom': 'Nectarine'},
    {'nom': 'Orange'},
    {'nom': 'Papaya'},
    {'nom': 'Pineapple'},
    {'nom': 'Quince'},
    {'nom': 'Raspberry'},
    {'nom': 'Strawberry'},
    {'nom': 'Tomato'},
    {'nom': 'Uva'},
    {'nom': 'Watermelon'},
    {'nom': 'Xigua'},
    {'nom': 'Yam'},
    {'nom': 'Zucchini'},
  ];

  // Stockage des produits par lettre initiale
  Map<String, List<Map<String, String>>> _groupedByLetter = {};
  List<String> _alphabet = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();

    _organizeProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _organizeProducts() {
    // Regrouper les produits par première lettre
    _groupedByLetter.clear();
    _produits.forEach((produit) {
      String firstLetter = produit['nom']![0].toUpperCase();
      if (!_groupedByLetter.containsKey(firstLetter)) {
        _groupedByLetter[firstLetter] = [];
      }
      _groupedByLetter[firstLetter]!.add(produit);
    });

    // Ajouter toutes les lettres de A à Z, même celles sans produits
    _alphabet = List.generate(26, (index) => String.fromCharCode(65 + index));
    _alphabet.forEach((letter) {
      if (!_groupedByLetter.containsKey(letter)) {
        _groupedByLetter[letter] = [];
      }
    });
  }

  void _scrollToLetter(String letter) {
    final sectionKey = GlobalKey();
    final context = sectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des Produits')),
      body: Row(
        children: [
          // Barre de l'alphabet
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _alphabet.length,
              itemBuilder: (context, index) {
                String letter = _alphabet[index];
                bool hasProducts = _groupedByLetter[letter]!.isNotEmpty;

                return GestureDetector(
                  onTap: hasProducts ? () => _scrollToLetter(letter) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 20,
                        color: hasProducts ? Colors.blue : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Liste des produits
          Expanded(
            child: ListView.builder(
              itemCount: _groupedByLetter.length,
              itemBuilder: (context, index) {
                String letter = _alphabet[index];
                List<Map<String, String>> produits = _groupedByLetter[letter]!;

                return Column(
                  key: ValueKey(letter), // Chaque section a une clé unique
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...produits.map((produit) => ListTile(
                      title: Text(produit['nom']!),
                    )),
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
