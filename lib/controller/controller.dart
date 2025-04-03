import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Controller extends ChangeNotifier {
  late Database _db;

  // Initialiser la base de données
  Future<void> initDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'poissonnerie.db');

    _db = await openDatabase(
      path,
      version: 4, // Mise à jour de la version en cas de modification
      onCreate: (db, version) async {
        // Table Produit
        await db.execute('''
          CREATE TABLE Produit (
            id_produit INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT NOT NULL,
            id_vente INTEGER NOT NULL,
            FOREIGN KEY (id_vente) REFERENCES Vente (id_vente) ON DELETE CASCADE  
          )
        ''');
        await db.execute('''
          CREATE TABLE ProduitDetail (
            id_produitDetail INTEGER PRIMARY KEY AUTOINCREMENT,
            prix_unitaire REAL NOT NULL,
            prix_entrer REAL NOT NULL,
            statut TEXT NOT NULL,
            stock REAL DEFAULT 0,
            date_ajout TEXT NOT NULL,
            date_fin TEXT NOT NULL,
            description TEXT NOT NULL,
            id_produit INTEGER NOT NULL,
            FOREIGN KEY (id_produit) REFERENCES Produit (id_produit) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE Historique (
            id_historique INTEGER PRIMARY KEY AUTOINCREMENT,
            qualite REAL,
            prix_achat REAL,
            prix_vente REAL,
            date TEXT NOT NULL,
            id_produitDetail INTEGER NOT NULL,
            id_produit INTEGER NOT NULL,
            FOREIGN KEY (id_produitDetail) REFERENCES ProduitDetail (id_produitDetail) ON DELETE CASCADE,
           
            FOREIGN KEY (id_produit) REFERENCES Produit (id_produit) ON DELETE CASCADE
            
          )
        ''');
        // Table ticket
        await db.execute('''
          CREATE TABLE Ticket (
            id_ticket INTEGER PRIMARY KEY AUTOINCREMENT,
            date_heure DATETIME DEFAULT CURRENT_TIMESTAMP,
            montant_total REAL NOT NULL,
            reste_a_payer REAL DEFAULT 0,
            mode_paiement TEXT            
        )
        ''');
        // Table Vente
        await db.execute('''
          CREATE TABLE Vente (
            id_vente INTEGER PRIMARY KEY AUTOINCREMENT,
            qualite REAL,
            prix_total REAL,
            date TEXT NOT NULL,
            id_produit INTEGER NOT NULL,
            id_ticket INTEGER NOT NULL,
            FOREIGN KEY (id_produit) REFERENCES Produit (id_produit) ON DELETE CASCADE,
            FOREIGN KEY (id_ticket) REFERENCES Ticket (id_ticket) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE Rapport (
            id_rapport INTEGER PRIMARY KEY AUTOINCREMENT,
            nom text,
            date TEXT NOT NULL
           )
        ''');
      },
    );

    await loadProduits();
    await loadProduitsDetails();
    await loadVentes();
    await loadTickets();
  }

  // Listes des données
  List<Map<String, dynamic>> produits = [];
  List<Map<String, dynamic>> produitsDetails = [];
  List<Map<String, dynamic>> ventes = [];
  List<Map<String, dynamic>> rapports = [];
  List<Map<String, dynamic>> historiques = [];
  List<Map<String, dynamic>> ticktes = [];
  late int id_vente = 0;
  // 🔹 CRUD : Produit

  // Ajouter un produit
  Future<int> addProduit({
    required String nom,
    required int id_vente,

  }) async {
  int id =  await _db.insert('Produit', {
      'nom': nom,
       'id_vente': id_vente,
    });

    print("ID du produit inséré : ");
    await loadProduits(); // Recharger les produits après l'ajout
    // Retourner l'ID de l'insertion
    return id;
  }
  Future<int> ajouterId({required int id_v}) async {
    id_vente = id_v;
    notifyListeners(); // Notifie les widgets écoutant ce changement
    return id_v;
  }

  Future<void> loadId() async {
    rapports = await _db.query('Rapport');
    print("📌 Produits chargés : $required");
    notifyListeners();
  }



  Future<int> addProduit_Vente({
    required int id_vente,
    required int id_produit,

  }) async {
    int id =  await _db.insert('Produit', {
      'id_vente': id_vente,
      'id_produit' : id_produit,
    });

    print("ID du produit inséré : ");
    await loadProduits(); // Recharger les produits après l'ajout
    await loadVentes();
    // Retourner l'ID de l'insertion
    return id;
  }


  Future<void> addRapport({
    required String nom,
    required String date,

  }) async {
     await _db.insert('Rapport', {
      'nom': nom,
       'date' : date,
    });

    print("ID du produit inséré : ");
    await loadProduits(); // Recharger les produits après l'ajout
    // Retourner l'ID de l'insertion

  }

  Future<void> loadRapport() async {
    rapports = await _db.query('Rapport');
    print("📌 Produits chargés : $required");
    notifyListeners();
  }


  /* porduit ************************/


  // Lire tous les produits
  Future<void> loadProduits() async {
    produits = await _db.query('Produit');
    print("📌 Produits chargés : $produits");
    notifyListeners();
  }

  // Modifier un produit
  Future<void> updateProduit({
    required int id,
    required String nom,
  }) async {
    await _db.update(
      'Produit',
      {
        'nom': nom,
              },
      where: 'id_produit = ?',
      whereArgs: [id],
    );
    await loadProduits();
  }
  Future<void> updateProduitK({
    required int id,
    required double stock,

  }) async {
    await _db.update(
      'Produit',
      {

        'stockTotal': stock,

      },
      where: 'id_produit = ?',
      whereArgs: [id],
    );
    await loadProduits();
  }

  // Supprimer un produit
  Future<void> deleteProduit(int id) async {
    await _db.delete('Produit', where: 'id_produit = ?', whereArgs: [id]);
    await _db.delete(
      'Vente',
      where: 'id_produit = ?',
      whereArgs: [id],
    );
    await loadProduits();
    await loadProduitsDetails();
    await loadVentes();
  }
  Future<int> addProduitDetail({
    required double prix_unitaire,
    required double prix_entrer,
    required String status,
    required double stock,
    required String date_ajout,
    required String date_fin,
    required String description,
    required int id,
  }) async {
   int idt = await _db.insert('ProduitDetail', {
      'prix_unitaire' : prix_unitaire,
      'prix_entrer' : prix_entrer,
      'statut' : status,
      'stock': stock,
      'date_ajout' : date_ajout,
      'date_fin' : date_fin,
     'description' : description,
     'id_produit' : id,
    });
    print("dans contrroler les produits sont: $idt");
    await loadProduitsDetails();
return idt;
  }
  Future<void> updateProduitDetailsK({
    required int id,
    required double stock,

  }) async {
    await _db.update(
      'ProduitDetail',
      {
        'stock': stock,
      },
      where: 'id_produitDetail = ?',
      whereArgs: [id],
    );
    await loadProduitsDetails();
  }

  Future<void> updateProduitDetail({
    required int id,
    required double prix_unitaire,
    required double prix_entrer,
    required String status,
    required double stock,
    required String date_ajout,
    required String date_fin,

  }) async {
    await _db.update('ProduitDetail', {
      'prix_unitaire' : prix_unitaire,
      'prix_entrer' : prix_entrer,
      'statut' : status,
      'stock': stock,
      'date_ajout' : date_ajout,
      'date_fin' : date_fin,

    },
      where: 'id_produitDetail = ?',
      whereArgs: [id],
    );
    print("dans contrroler les produits sont: $produitsDetails");
    await loadProduitsDetails();
  }
  Future<void> deleteProduitDetail(int id) async {
    await _db.delete('ProduitDetail', where: 'id_produitDetail = ?', whereArgs: [id]);

    await loadProduits();
    await loadProduitsDetails();
    await loadVentes();
  }

  Future<void> loadProduitsDetails() async {
    produitsDetails = await _db.query('ProduitDetail');
    print("📌 Produits chargés : $produitsDetails");
    notifyListeners();
  }




  /* Crud : Tickets */

  Future<void> loadTickets() async {
    ticktes = await _db.query('Ticket');
    print("📌 Produits chargés : $ticktes");
    notifyListeners();
  }

  Future<int> addTicket({
    required double reste,
    required double montant,
    required String date,
    required String paiement,
  }) async {
    int idt = await _db.insert('Ticket', {
      'montant_total' : montant,
      'reste_a_payer' : reste,
      'mode_paiement': paiement,
      'date_heure' : date,

    });
    print("dans contrroler les produits sont: $idt");
    await loadTickets();
    return idt;
  }



  // Crud : historique

  Future<int> addHistorique({
    required double prix_achat,
    required double prix_vente,
    required String date,
    required double qualite,
    required int id,
    required int id_detail,
  }) async {
    int idt = await _db.insert('Historique', {
      'prix_achat' : prix_achat,
      'prix_vente' : prix_vente,
      'qualite': qualite,
      'date' : date,
      'id_produit' : id,
      'id_produitDetail': id_detail,
    });
    print("dans contrroler les produits sont: $idt");
    await loadHistoriques();
    return id;
  }
  Future<void> loadHistoriques() async {
    historiques = await _db.query('Historique');
    print("📌 Produits chargés : $historiques");
    notifyListeners();
  }

  // 🔹 CRUD : Vente

  // Ajouter une vente
  Future<int> addVente({
    required double qualite,
    required double prixTotal,
    required String date,
    required int idProduit,
    required int id_ticket,
  }) async {
  int id =  await _db.insert('Vente', {
      'qualite': qualite,
      'prix_total': prixTotal,
      'date': date,
      'id_produit': idProduit,
      'id_ticket': id_ticket,
    });
  await id_vente;
    await loadVentes();
    return id;
  }

  // Lire toutes les ventes
  Future<void> loadVentes() async {
    ventes = await _db.query('Vente');
    print("📌 Ventes chargées : $ventes");
    await id_vente;
    notifyListeners();
  }

  // Modifier une vente
  Future<void> updateVente({
    required int id,
    required double qualite,
    required double prixTotal,
    required String date,
    required int idProduit,
  }) async {
    await _db.update(
      'Vente',
      {
        'qualite': qualite,
        'prix_total': prixTotal,
        'date': date,
        'id_produit': idProduit,
      },
      where: 'id_vente = ?',
      whereArgs: [id],
    );
    await loadVentes();
  }

  // Supprimer une vente
  Future<void> deleteVente(int id) async {
    await _db.delete('Vente', where: 'id_vente = ?', whereArgs: [id]);
    await loadVentes();
  }
}
