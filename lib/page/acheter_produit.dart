import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:untitled/controller/controller.dart';
import 'package:provider/provider.dart';

class AcheterProduit extends StatefulWidget {
   AcheterProduit(
      {super.key, required this.id, required this.nom, required this.lanja,required this.prix, required this.items});

  final int id;
  final String nom;
  final double lanja;
  final double prix;
  final List<Map<String, dynamic>>items;

  @override
  State<AcheterProduit> createState() => _AcheterProduitState();
}

class _AcheterProduitState extends State<AcheterProduit> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController qualite = TextEditingController();
  late TextEditingController _prixTotal = TextEditingController();
bool isChecked = false;
  DateTime? selectedDate;
  String? selectedDescription; // Stocke la description sélectionnée

  @override
  void initState() {
    super.initState();

    qualite = TextEditingController();
    _prixTotal = TextEditingController();
    if (widget.items.isNotEmpty) {
      selectedDescription; // Sélectionne le premier élément par défaut
    }
  }

  @override
  void dispose() {
    qualite.dispose();
    _prixTotal.dispose();

    super.dispose();
  }

  void _cancel() {
    Navigator.pop(context);
  }

  bool isLoading = false;

  Future<void> _submit(Controller globalState) async {
    if (_formKey.currentState!.validate()) {
      double quantite =
          double.tryParse(qualite.text.isNotEmpty ? qualite.text : "0.0") ??
              0.0;
      DateTime date_debut = DateTime.now();

      double prix_payer = double.tryParse(
              _prixTotal.text.isNotEmpty ? _prixTotal.text : "0.0") ??
          0.0;
      final find = widget.items.firstWhere(
            (item) => item['description'] == selectedDescription,
        orElse: () => {'stock': 0, 'prix_entrer': 0.0},
      );
      final id = find['id_produit'];
      final idB = widget.items.length > 1 ? id : widget.id;
      final vidinyB = widget.items.length > 1 ? vidiny : prix_payer;
      print("vidiny be 00000000 $vidinyB");
      if (quantite <= (widget.items.length > 1 ?  lanja : widget.lanja)) {
        // ✅ Fermer le clavier avant d'afficher le dialogue de confirmation
        FocusScope.of(context).requestFocus(FocusNode());

        // ✅ Affichage de la boîte de confirmation
        bool? confirmation = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Confirmation"),
              content: Text("Prix acheter : $prix_payer Ar/kg\n"
                  "Kilos : $quantite kg ~${(quantite * 1000)} gramme~"),
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
          int  id_ticket = await
          globalState.addTicket(reste: 0, montant: prix_payer, date: date_debut.toIso8601String(), paiement: "Cash");
     int  id_vente =   await globalState.addVente(
              qualite: quantite,
              prixTotal: prix_payer,
              date: date_debut.toIso8601String(),
              idProduit: idB, id_ticket: id_ticket);
     if( globalState.id_vente == 0 ){
      await globalState.ajouterId(id_v: id_vente);
     }


          final idF = widget.items.firstWhere(
                  (item) => item['description'] == selectedDescription,
              orElse: () => {} // Si aucun élément n'est trouvé, retourner un Map vide.
          );


          int? id = idF.isNotEmpty ? int.tryParse(idF['id_produitDetail'].toString()) : widget.id;  // S'assurer que 'id_produit' est bien converti en int
          double newStock = idF.isNotEmpty ? idF['stock'] - quantite : widget.lanja - quantite;
          print("fit avec success $newStock");
// Vérifier si 'id' est valide avant de l'utiliser
          if (id != null) {
            await globalState.updateProduitDetailsK(id: id, stock:newStock);
          } else {
            print('ID invalide, mise à jour annulée');
          }

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
                content: const Text("Enregistrement fait avec succès !"),
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
      } else {
        FocusScope.of(context).requestFocus(FocusNode());

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Tsia!"),
              content: Text("Tsy ampy ny tahinry"),
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

  void processAndInsertDevoirTransaction(Controller globalState) {}
  bool ops = true;
  double lanja = 0;
  double vidiny = 0;

  @override
  Widget build(BuildContext context) {
    // Récupération du GlobalState
    final globalState = Provider.of<Controller>(context, listen: false);

    // Pour afficher les informations
    String affichageLanja = widget.items.length > 1 ?  lanja.toStringAsFixed(1) : widget.lanja.toStringAsFixed(2);
    String affichageVidiny = widget.items.length > 1 ?  vidiny.toString(): widget.prix.toString() ;

    return SingleChildScrollView(
      child: AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Center(
          child: Column(
            children: [
              Text(
                "Hividy ${widget.nom}",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "Azo vidina ${(affichageLanja)} kg",
                style: TextStyle(color: Colors.green, fontSize: 13),
              ),
              Text(
                "$affichageVidiny Ar/Kg",
                style: TextStyle(color: Colors.blue, fontSize: 13),
              ),
            ],
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                  const Text(
                    'Hampiditra vola',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),

                if (widget.items.length > 1)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      value: selectedDescription,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.green.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        hintText: 'Sokajy',  // Texte du label
                        hintStyle: TextStyle(color: Colors.black), // Style du texte du label
                      ),
                      style: TextStyle(color: Colors.black), // Style du texte sélectionné
                      dropdownColor: Colors.white, // Fond du menu déroulant

                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDescription = newValue;
                          // Chercher l'élément sélectionné dans widget.items
                          final find = widget.items.firstWhere(
                                (item) => item['description'] == selectedDescription,
                            orElse: () => {'stock': 0, 'prix_entrer': 0.0},
                          );
                          // Imprimer pour vérifier que les valeurs sont bien récupérées
                          print("Trouvé: ${find['description']}, stock: ${find['stock']}, prix_entrer: ${find['prix_entrer']}");
                          // Mettre à jour lanja et vidiny
                          lanja = find['stock'];
                          vidiny = find['prix_entrer'];
                        });
                      },
                      items: widget.items.map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem<String>(
                          value: item['description'],
                          child: Text(
                            item['description'],
                            style: TextStyle(color: Colors.black), // Couleur du texte de la liste
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              if(isChecked)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _prixTotal,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: 'Andoha vola',
                      labelStyle: TextStyle(color: Colors.white),
                      suffixText: "Ariary",
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Hamarino ny vola";
                      }
                      if (isChecked) {
                        double prix = widget.items.length > 1 ?(double.tryParse(value ?? '0') ?? 0) / vidiny : (double.tryParse(value ?? '0') ?? 0) / widget.prix.toDouble();
                        qualite.text = prix.toString();
                      }

                    }),
              ),
              if(!isChecked)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: qualite,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    labelText: 'Hampiditra lanja',
                    labelStyle: TextStyle(color: Colors.white),
                    suffixText: "Kg",
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !isChecked, // Désactive le champ si isChecked est true

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Hamarino ny lanjaa";
                    }
                    if (!isChecked) {
                      double prix = widget.items.length > 1 ? (double.tryParse(value ?? '0') ?? 0) * vidiny : (double.tryParse(value ?? '0') ?? 0) * widget.prix.toDouble();
                      _prixTotal.text = prix.toString();
                    }
                  },
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
      ),
    );
  }
}
