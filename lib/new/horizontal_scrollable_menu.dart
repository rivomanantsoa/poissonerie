import 'package:flutter/material.dart';

class HorizontalScrollableMenu extends StatefulWidget {
  @override
  _HorizontalScrollableMenuState createState() =>
      _HorizontalScrollableMenuState();
}

class _HorizontalScrollableMenuState extends State<HorizontalScrollableMenu> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  // Groupes de fruits de mer
  final List<String> groups = ['Poisson', 'Crustacés', 'Mollusques'];

  // Données pour chaque groupe
  final Map<String, List<String>> fruitsDeMer = {
    'Poisson': ['Saumon', 'Thon', 'Sardine'],
    'Crustacés': ['Crabe', 'Crevette', 'Homard'],
    'Mollusques': ['Huître', 'Moule', 'Calmar'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menu Horizontal Défilable")),
      body: Column(
        children: [
          // Conteneur avec les flèches de défilement
          Stack(
            children: [
              // Menu défilable horizontal avec PageView
              Container(
                height: 70,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: groups.length,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index; // Mettre à jour l'index du groupe sélectionné
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 65),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedIndex == index
                              ? Colors.blue.shade700
                              : Colors.blue.shade400, // Changer la couleur selon la sélection
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: Text(groups[index], style: TextStyle(fontSize: 16)),
                      ),
                    );
                  },
                ),
              ),
              // Flèche gauche
              Positioned(
                left: 5,
                top: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_left, color: Colors.black, size: 35),
                  onPressed: () {
                    if (_selectedIndex > 0) {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
              // Flèche droite
              Positioned(
                right: 5,
                top: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_right, color: Colors.black, size: 35,),
                  onPressed: () {
                    if (_selectedIndex < groups.length - 1) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Affichage des fruits de mer du groupe sélectionné
          Expanded(
            child: ListView.builder(
              itemCount: fruitsDeMer[groups[_selectedIndex]]?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(fruitsDeMer[groups[_selectedIndex]]![index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
void main() {
  runApp(MaterialApp(
    home: HorizontalScrollableMenu(),
  ));
}
