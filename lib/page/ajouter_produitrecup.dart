
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

      // ✅ Fermer le clavier avant d'afficher le dialogue de confirmation
      FocusScope.of(context).requestFocus(FocusNode());

      // ✅ Affichage de la boîte de confirmation
      bool? confirmation = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Confirmation"),
            content: Text(
                "Nom : $nom \n"
                    "Catégorie : $description \n"
                    "Prix d'achat : $prix_unitaire Ar/kg\n"
                    "Prix de vente : $prixvente Ar/kg\n"
                    "Stock disponible : $stock kg"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Confirmer"),
              ),
            ],
          );
        },
      );

      // ✅ Fermer le clavier après la fermeture de la boîte de confirmation
      FocusScope.of(context).requestFocus(FocusNode());

      if (confirmation == null || !confirmation) {
        return;
      }

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

    // Récupération du GlobalState
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _nom,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    labelText: '...Ananarana...',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Hamarino ny anarana";
                    }

                    // Supprimer les espaces et mettre en minuscule
                    String trimmedValue = value.trim().toLowerCase();

                    // Vérifier la présence de caractères spéciaux ou chiffres
                    final specialCharPattern = RegExp(r'[!@#\$%^&*(),.?":{}|<>0-9]');
                    if (specialCharPattern.hasMatch(trimmedValue)) {
                      return "Anarana tsy izy : tsy azo atao ny manao anarana toa io";
                    }

                    return null;
                  },
                  onChanged: (value) {
                    // Met automatiquement la valeur en minuscule dans le champ texte
                    _nom.value = TextEditingValue(
                      text: value.toLowerCase(),
                      selection: _nom.selection,
                    );
                  },
                ),
              ),


              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                    style: TextStyle(color: Colors.red),
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),

                    ),

                    value: selectedType,
                    hint: const Text("...Sokajy...", style: TextStyle(color: Colors.white)),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedType = newValue;
                        if (true) {
                          ops = false;
                        }
                      });
                    },
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? "Misafidina sokajy"
                        : null,
                    items: <String>['Madinika', 'Antoniny', 'Vaventy', 'Vaventy Be']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()
                ),
              ),
              if(1 == 0)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DateTimeFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '...Date fin...',
                    ),
                    onChanged: (DateTime? value) {
                      setState(() {
                        selectedDate = value;
                      });
                    },
                    validator: (value) =>
                    value == null ? "Veuillez sélectionner une datee" : null,
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _prixUnitaire,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: '...Nakana ny kilao...',
                      labelStyle: TextStyle(color: Colors.white),
                      suffixText: "Ariary",
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Hamarino ny volanao";
                      }
                    }
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _prixvente,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: '...Hivarotana ny kilao...',
                      labelStyle: TextStyle(color: Colors.white),
                      suffixText: "Ariary",
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Hamarino ny volanao";
                      }
                    }
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _taux,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: '...Lanja Amidy...',
                      labelStyle: TextStyle(color: Colors.white),
                      suffixText: "Kg",
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Hamarino ny lanjaa";
                      }
                    }
                ),
              ),
            ],
          ),
        ),
        actions: [

          ElevatedButton(
            onPressed: _cancel,
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
      ),);
  }
}
