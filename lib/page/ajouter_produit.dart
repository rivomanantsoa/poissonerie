import 'package:untitled/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:provider/provider.dart';

class AjouterProduit extends StatefulWidget {
  const AjouterProduit({super.key,});



  @override
  State<AjouterProduit> createState() => _AjouterProduitState();
}

class _AjouterProduitState extends State<AjouterProduit> {
  final _formKey = GlobalKey<FormState>();
  int _step = 1; // Étape actuelle
  late TextEditingController _fond = TextEditingController();
  late TextEditingController _nom = TextEditingController();
  late TextEditingController _commentaire = TextEditingController();
  late TextEditingController _prixUnitaire = TextEditingController();
  late TextEditingController _taux = TextEditingController();
  late TextEditingController _prixvente = TextEditingController();

  String? selectedType;
  DateTime? selectedDate;


  @override
  void initState() {
    super.initState();
    _fond = TextEditingController();
    _nom = TextEditingController();
    _commentaire = TextEditingController();
    _prixUnitaire = TextEditingController();
    _taux = TextEditingController();
    _prixvente = TextEditingController();
  }

  @override
  void dispose() {
    _fond.dispose();
    _nom.dispose();
    _commentaire.dispose();
    _prixUnitaire.dispose();
    _taux.dispose();
    _prixvente.dispose();
    super.dispose();
  }

  void _cancel() {
    Navigator.pop(context);
  }
  bool isLoading = false;
  Future<bool> showConfirmationDialog(BuildContext context, String nom, String description, double prixUnitaire, double prixVente, double stock) async {
    bool? confirmation = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: Text(
            "Nom : $nom \n"
                "Catégorie : $description \n"
                "Prix d'achat : $prixUnitaire Ar/kg\n"
                "Prix de vente : $prixVente Ar/kg\n"
                "Stock disponible : $stock kg",
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("Annuler cliqué");
                Navigator.pop(context, false);
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                print("Confirmer cliqué");
                Navigator.pop(context, true);
              },
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );
    return confirmation ?? false;
  }

  Future<void> _submit(Controller globalState) async {
    if (_formKey.currentState!.validate()) {
      String? nom = _nom.text[0].toUpperCase() + _nom.text.substring(1).toLowerCase();
      double prix_unitaire = double.tryParse(_prixUnitaire.text.isNotEmpty ? _prixUnitaire.text : "0.0") ?? 0.0;
      DateTime date_debut = DateTime.now();
      DateTime date_fin = selectedDate ?? DateTime.now();
      String? statut = "En cours";
      String description = selectedType!;
      double prixvente = double.tryParse(_prixvente.text.isNotEmpty ? _prixvente.text : "0.0") ?? 0.0;
      double stock = double.tryParse(_taux.text.isNotEmpty ? _taux.text : "0.0") ?? 0.0;
    print("le variable que ous allons enregistrer sont: nom:$nom, prix_unitite:$prix_unitaire,"
        " status: $statut, description: $description , prix de vente: $prixvente enfin , stock: $stock");
      // ✅ Fermer le clavier avant d'afficher le dialogue de confirmation
      //FocusScope.of(context).requestFocus(FocusNode());
print("fermeture de la clavier");
      // ✅ Affichage de la boîte de confirmation

      final bool bob = await showConfirmationDialog(context, nom, description, prix_unitaire, prixvente, stock);
      if (!bob) {
        return;
      }

      print("Valeur de confirmation après la boîte de dialogue : ");

      //if (!context.mounted) return;

      // ✅ Fermer le clavier avant d'afficher le loader
      FocusScope.of(context).requestFocus(FocusNode());

      // ✅ Affichage du loader AVANT l'insertion
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Ajout en cours..."),
              ],
            ),
          );
        },
      );

      try {
        print("tafiditr ATO VE O");
        int id =  await globalState.addProduitDetail(prix_unitaire: prix_unitaire,
          prix_entrer: prixvente, status: statut, stock: stock,
          date_ajout: date_debut.toIso8601String(),date_fin: date_fin.toIso8601String(),);

        await globalState.addProduit(
          nom: nom,
          description: description,
          stock: stock, id_produitDetail: id,

        );

        // ✅ Fermer le loader après succès
        Navigator.pop(context);

        // ✅ Fermer le clavier avant d'afficher le message de succès
        FocusScope.of(context).requestFocus(FocusNode());

        // ✅ Affichage du message de succès
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Succès"),
              content: const Text("Le produit a été ajouté avec succès !"),
              actions: [
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    Navigator.pop(context);
                    Navigator.pop(context, false);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } catch (e) {
        // ✅ Fermer le loader en cas d'erreur
        Navigator.pop(context);

        print("Erreur lors de l'ajout du produit : $e");

        // ✅ Fermer le clavier avant d'afficher le message d'erreur
        FocusScope.of(context).requestFocus(FocusNode());

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Erreur"),
              content: Text("Une erreur est survenue : $e"),
              actions: [
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }




  void processAndInsertDevoirTransaction(Controller globalState) {

  }
  bool ops = true;
  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context, listen: false);

    return SingleChildScrollView(
      child: AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Center(
          child: Text(
            "Mampiditra Vokatra",
            style: TextStyle(color: Colors.white),
          ),
        ),
        content: Form(
          key: _formKey,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0), // Animation depuis la droite
                  end: Offset(0.0, 0.0),
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey<int>(_step), // Clé pour déclencher l'animation
              mainAxisSize: MainAxisSize.min,
              children: [
                // Étape 1
                if (_step == 1) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _nom,
                      style: TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '...Ananarana...',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Hamarino ny anarana";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      style: TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      value: selectedType,
                      hint: const Text("...Sokajy...", style: TextStyle(color: Colors.white)),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedType = newValue;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty ? "Misafidina sokajy" : null,
                      items: <String>['Madinika', 'Antoniny', 'Vaventy', 'Vaventy Be']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: Colors.green)),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                // Étape 2
                if (_step == 2) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _prixUnitaire,
                      style: TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '...Nakana ny kilao...',
                        labelStyle: TextStyle(color: Colors.white),
                        suffixText: "Ariary",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty ? "Hamarino ny volanao" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _prixvente,
                      style: TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '...Hivarotana ny kilao...',
                        labelStyle: TextStyle(color: Colors.white),
                        suffixText: "Ariary",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty ? "Hamarino ny volanao" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _taux,
                      style: TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '...Lanja Amidy...',
                        labelStyle: TextStyle(color: Colors.white),
                        suffixText: "Kg",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty ? "Hamarino ny lanjaa" : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          // Étape 1 : Bouton "Suivant"
          if (_step == 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text(
                    'Hanafoana',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _step = 2; // Passer à l'étape 2 avec animation
                      });
                    }
                  },
                  child: const Text('Manaraka'),
                ),
              ],
            ),

          // Étape 2 : Bouton "Annuler" et "Soumettre"
          if (_step == 2) ...[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hanafoana',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus(); // Masquer le clavier
                _submit(globalState);
              },
              child: const Text('Handefa'),
            ),
          ],
        ],
      ),
    );
  }
}