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

      print("📌 Variables à enregistrer :");
      print("nom: $nom, prix_unitaire: $prix_unitaire, statut: $statut, description: $description, prix_vente: $prixvente, stock: $stock");

      print("📌 Fermeture du clavier...");
      FocusScope.of(context).requestFocus(FocusNode());

      if (prix_unitaire > prixvente) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Ooops!"),
              content: Text("Mety ho maty antoka! \nNy nakana azy ${prix_unitaire.toString()} Ar \nandefasana azy ${prixvente.toString()} Ar"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
        return;
      }

      print("📌 Affichage boîte de confirmation...");
      final bool bob = await showConfirmationDialog(context, nom, description, prix_unitaire, prixvente, stock);
      if (!bob) {
        print("❌ L'utilisateur a annulé l'ajout.");
        return;
      }

      print("✅ Confirmation validée !");
      FocusScope.of(context).requestFocus(FocusNode());

      print("📌 Affichage du loader...");
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

      final idProduit = globalState.produits.firstWhere(
            (produit) => produit['nom'] == nom,
        orElse: () => {},
      );

      if (idProduit == null) {
        print("❌ Aucune correspondance trouvée pour le produit '$nom'");
      } else {
        print("✅ Produit trouvé: $idProduit");
      }

      final id = idProduit?['id_produit'];
      final produitNom = idProduit?['nom'] ?? 'Inconnu';

      print("🔎 ID Produit: $id, Nom Produit: $produitNom");
      print("🔎 Recherche avec - Nom: $nom, Description: $description");

      final test = globalState.produitsDetails.where((produitDetail) =>
      id != null && produitDetail['id_produit'].toString() == id.toString() &&
          produitNom == nom &&
          produitDetail['description'] == description
      ).toList();

      final test2 = globalState.produits.where((produitDetail) => produitDetail['nom'] == nom).toList();

      print("🔎 Produits existants (test2) : $test2");
      print("🔎 Détails du produit existant (test) : $test");

      if (test.isNotEmpty) {
        print("✅ Premier élément trouvé dans test : ${test.first}");
      } else {
        print("⚠️ Aucune correspondance trouvée dans test.");
      }

      if (test2.isNotEmpty) {
        print("✅ Premier élément trouvé dans test2 : ${test2.first}");
      } else {
        print("⚠️ Aucune correspondance trouvée dans test2.");
      }

      double sommeStock = globalState.produitsDetails
          .where((detailProduit) => detailProduit['id_produit'] == idProduit?['id_produit']
          && produitNom == nom && detailProduit['description'] == description)
          .fold(0, (somme, detailProduit) => somme + detailProduit['stock']);

      double sommeTotalStock = sommeStock + stock;

      try {
        if (test.isEmpty) {
          if (test2.isEmpty) {
            print("📌 Nouveau produit, insertion en cours...");
            int id = await globalState.addProduit(
              nom: nom,
              id_vente: 0,
            );
            print("✅ Produit ajouté avec ID : $id");

          int id_detail =  await globalState.addProduitDetail(
              prix_unitaire: prix_unitaire,
              prix_entrer: prixvente,
              status: statut,
              stock: stock,
              date_ajout: date_debut.toIso8601String(),
              date_fin: date_fin.toIso8601String(),
              description: description,
              id: id,
            );
            await globalState.addHistorique(prix_achat: prix_unitaire, prix_vente: prixvente, date: date_debut.toIso8601String(),
                qualite: stock, id: id, id_detail: id_detail);
            print("✅ Détail du produit ajouté avec succès.");

          } else {
            print("📌 Produit existant, ajout des détails...");
          int id_detail =  await globalState.addProduitDetail(
              prix_unitaire: prix_unitaire,
              prix_entrer: prixvente,
              status: statut,
              stock: stock,
              date_ajout: date_debut.toIso8601String(),
              date_fin: date_fin.toIso8601String(),
              description: description,
              id: test2.first['id_produit'],
            );
          await globalState.addHistorique(prix_achat: prix_unitaire, prix_vente: prixvente, date: date_debut.toIso8601String(),
              qualite: stock, id: id, id_detail: id_detail);
            print("✅ Détail du produit existant ajouté avec succès.");
          }
        } else {
          print("📌 Mise à jour d'un produit existant...");
          await globalState.updateProduitDetail(
            prix_unitaire: prix_unitaire,
            prix_entrer: prixvente,
            status: statut,
            stock: sommeTotalStock,
            date_ajout: date_debut.toIso8601String(),
            date_fin: date_fin.toIso8601String(),
            id: test.first['id_produitDetail'],
          );
          await globalState.addHistorique(prix_achat: prix_unitaire, prix_vente: prixvente, date: date_debut.toIso8601String(),
              qualite: stock, id: id, id_detail: test.first['id_produitDetail']);
          print("✅ Produit mis à jour avec succès.");
        }

        print("📌 Fermeture du loader...");
        Navigator.pop(context);

        print("✅ Succès : Produit ajouté !");
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Succès"),
              content: const Text("Le produit a été ajouté avec succès !"),
              actions: [
                TextButton(
                  onPressed: () {
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
        print("❌ Erreur lors de l'ajout du produit : $e");
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Erreur"),
              content: Text("Une erreur est survenue : $e"),
              actions: [
                TextButton(
                  onPressed: () {
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
                        if (value == null || value.trim().isEmpty) {
                          return "Hamarino ny anarana";
                        }

                        // Vérifie la présence de caractères spéciaux
                        final RegExp regex = RegExp(r"^[a-zA-ZÀ-ÿ\s]+$");
                        if (!regex.hasMatch(value.trim())) {
                          return "Tsy azo atao ny mampiditra mari-panavahana";
                        }

                        return null;
                      },
                      onChanged: (value) {
                        // Supprime les espaces avant et après en mettant à jour le contrôleur
                        _nom.text = value.trim();
                        _nom.selection = TextSelection.fromPosition(
                          TextPosition(offset: _nom.text.length),
                        );
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