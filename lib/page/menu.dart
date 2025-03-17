import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Simuler une opération asynchrone comme le chargement des données
      await Future.delayed(Duration(seconds: 2));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 120.0),
              child: Row(
                children: [
                  Center(
                    child: Text(
                      "Acceuil",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 48.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.history, // Icône de la flèche
                        color: Colors.white, // Couleur de la flèche
                        size: 35.0, // Taille de la flèche
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Text(
              "Notification",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Center(
            child: const Text(
              "Add-Money",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Center(
            child: Text(
              "Membres",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Center(
            child: const Text(
              "Créer un membre",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ][_currentIndex],
      ),
      body: [
        const Center(child: Text("Cliquez sur 'Add' pour ouvrir le ppup1.")),
        const Center(child: Text("Cliquez sur 'Add' pour ouvrir le ppup2.")),
        const Center(child: Text("Cliquez sur 'Add' pour ouvrir le ppup3.")),
        const Center(child: Text("Cliquez sur 'Add' pour ouvrir le ppup4.")),
        const Center(child: Text("Cliquez sur 'Add' pour ouvrir le ppup5.")),
      ][_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black, // Couleur de la bordure
              width: 2.0, // Épaisseur de la bordure
            ),
            borderRadius: BorderRadius.circular(40), // Applique un border radius
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40), // Applique un border radius
            child: BottomNavigationBar(
              backgroundColor: Colors.blue,
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index == 2) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog()
                  );
                } else {
                  setCurrentIndex(index);
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.yellow,
              selectedFontSize: 11,
              unselectedFontSize: 10,

              unselectedItemColor: Colors.white,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Acceuil",
                ),

                BottomNavigationBarItem(
                  /*icon: Consumer<Controller>(
                    builder: (context, globalState, child) {
                      // Filtrer les personnes dont l'anniversaire est dans 2 jours
                      final upcomingBirthdays = globalState.personnes.where((personne) {
                        var date = DateTime.tryParse(personne['dob']);
                        return date != null &&
                            date.day == DateTime.now().add(Duration(days: 1)).day &&
                            date.month == DateTime.now().add(Duration(days: 1)).month
                            ||date != null &&
                                date.day == DateTime.now().day &&
                                date.month == DateTime.now().month ;
                      }).toList();

                      return badges.Badge(
                        showBadge: upcomingBirthdays.isNotEmpty,  // Afficher si des anniversaires sont à venir
                        badgeContent: Text(
                          '${upcomingBirthdays.length}',  // Affiche le nombre d'anniversaires
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        child: Icon(Icons.notifications),
                      );
                    },
                  ),*/

    icon: Icon(Icons.history),
    label: "Acceuil",
                ),

                BottomNavigationBarItem(
                  icon: Container(
                    width: 50, // Largeur personnalisée pour l'icône "add"
                    height: 40, // Hauteur personnalisée pour l'icône "add"
                    decoration: BoxDecoration(
                      color: Colors.white, // Couleur de fond
                      shape: BoxShape.circle, // Forme circulaire
                    ),
                    child: const Icon(
                      Icons.add_circle, // Icône principale
                      size: 37, // Taille augmentée
                      color: Colors.black, // Couleur de l'icône
                    ),
                  ),
                  label: "",
                  backgroundColor: Colors.blue, // Couleur si sélectionnée
                ),
                BottomNavigationBarItem(

                  icon: Icon(Icons.library_books),
                  label: "Acceuil",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_add),
                  label: "Ajouter",
                ),
              ],
            ),
          ),
        ),
      ),


    );
  }
}
