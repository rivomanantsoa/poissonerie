
import 'package:flutter/material.dart';
import 'package:untitled/controller/controller.dart';
import 'package:provider/provider.dart';

class Ticket extends StatefulWidget {
  Ticket(
      {super.key,});



  @override
  State<Ticket> createState() => _TicketState();
}

class _TicketState extends State<Ticket> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> produitsAvecNomQualiteDescription = [];
  late double sommePayer = 0;

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

      DateTime date_debut = DateTime.now();
     print(" les element quenous avons recuperer dans le adding : $produitsAvecNomQualiteDescription");
      double prix_payer = double.tryParse(
          _prixTotal.text.isNotEmpty ? _prixTotal.text : "0.0") ??
          0.0;

        // ✅ Fermer le clavier avant d'afficher le dialogue de confirmation
        FocusScope.of(context).requestFocus(FocusNode());

        // ✅ Affichage de la boîte de confirmation
        bool? confirmation = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Confirmation"),
              content: Text("Payement : $prix_payer Ar"),
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
          double reste = sommePayer > prix_payer ? (sommePayer - prix_payer) : 0;

          int  id_ticket = await
          globalState.addTicket(reste: reste, montant: prix_payer, date: date_debut.toIso8601String(), paiement: selectedDescription.toString());

          for(var vente in globalState.ventes){
            if(vente['id_ticket'] == 0){
              await globalState.updateVenteIdTicket(id: vente['id_vente'], idTicket: id_ticket);
              print("la vente toucher: $vente ave id_ticket = ${id_ticket}");
            }
          }
          for(var detailProd in globalState.produitsDetails){
            if(detailProd['statut'] == "achat"){
              await globalState.updateProduitDetailsStatut(id: detailProd['id_produitDetail'], status: 'paye');
              print("la produitdetail toucher: $detailProd ave id_ticket = ${detailProd['id_vente']}");
            }
          }
          await globalState.ajouterId(id_v: 0);
          await globalState.loadVentes();
          await globalState.loadProduitsDetails();
          await globalState.loadTickets();

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

  void processAndInsertDevoirTransaction(Controller globalState) {}
  bool ops = true;
  double lanja = 0;
  double vidiny = 0;

  @override
  Widget build(BuildContext context) {
    // Récupération du GlobalState
    final globalState = Provider.of<Controller>(context, listen: false);

// Étape 1 : Récupérer les ventes avec id_ticket == 0
    final ventesSansTicket = globalState.ventes.where(
            (vente) => vente['id_ticket'] == 0
    ).toList();

// Étape 2 : Créer une map des produitsDetails pour accès rapide par id_produitDetail
    final Map<int, dynamic> mapProduitsDetails = {
      for (var p in globalState.produitsDetails) p['id_produitDetail']: p
    };

// Étape 3 : Créer une map des produits pour accès rapide par id_produit
    final Map<int, dynamic> mapProduits = {
      for (var p in globalState.produits) p['id_produit']: p
    };

    List<Map<String, dynamic>> ventesLieesAchat = [];
    double sommeTotale = 0.0;

// Étape 4 : Parcourir les ventes filtrées
    for (var vente in ventesSansTicket) {
      final produitDetail = mapProduitsDetails[vente['id_produitDetail']];
      if (produitDetail == null) continue;

      final produit = mapProduits[produitDetail['id_produit']];
      if (produit == null) continue;

      ventesLieesAchat.add({
        'id_produit': produit['id_produit'],
        'nom': produit['nom'],
        'qualite': vente['qualite'],
        'description': produitDetail['description'],
        'prix_total': vente['prix_total'],
      });

      sommeTotale += vente['prix_total'] ?? 0.0;
    }





// Vérification des produits récupérés
    if (ventesLieesAchat.isNotEmpty) {
      for (var produit in ventesLieesAchat) {
        print("Nom: ${produit['nom']}, Qualité: ${produit['qualite']}, Description: ${produit['description']}, Prix total: ${produit['prix_total']}");
      }

      // Affichage de la somme totale
      print("Somme totale des produits achetés: $sommeTotale");
    } else {
      print("Aucun produit trouvé.");
    }




    return SingleChildScrollView(
      child: AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Column(
          children: [

            Text(
              "Ticket",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "Total à payer ${sommeTotale} Ariary",
              style: TextStyle(color: Colors.green, fontSize: 13),
            ),
            // Affichage dynamique des éléments de vente
            ...ventesLieesAchat.map((produit) {
              return Row(
                children: [
                  Icon(Icons.remove, color: Colors.white,),
                  Text(
                    produit['nom'] ?? "Produit inconnu",
                    // Afficher le nom du produit
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  SizedBox(width: 10,),
                  Text(
                    produit['description'],  // Afficher le nom du produit
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  SizedBox(width: 10,),
                  Text(
                    produit['qualite'].toString() + " Kg",  // Afficher le nom du produit
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),

                ],
              );
            }).toList(),
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: selectedDescription,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.green.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    hintText: 'Mode Payement',  // Texte du label
                    hintStyle: TextStyle(color: Colors.black), // Style du texte du label
                  ),
                  style: TextStyle(color: Colors.black), // Style du texte sélectionné
                  dropdownColor: Colors.white, // Fond du menu déroulant

                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDescription = newValue;
                      // Imprimer pour vérifier les nouvelles valeurs
                      print("Sélectionné: $selectedDescription, Lanja: $lanja, Vidiny: $vidiny");
                    });
                  },
                  items: ["Cash", "Mobile", "Cheque"].map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black), // Couleur du texte de la liste
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                      controller: _prixTotal,
                      style: TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Argent',
                        labelStyle: TextStyle(color: Colors.white),
                        suffixText: "Ariary",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Hamarino ny vola";
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
              setState(() {
                produitsAvecNomQualiteDescription = ventesLieesAchat;
                sommePayer = sommePayer;
              });
              _submit(globalState);
            },
            child: const Text('Handefa'),
          ),
        ],
      ),
    );
  }
}
