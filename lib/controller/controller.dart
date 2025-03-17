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
            description TEXT NOT NULL,
            stockTotal REAL DEFAULT 0,
            id_produitDetail INTEGER NOT NULL,
            FOREIGN KEY (id_produitDetail) REFERENCES ProduitDetail (id_produitDetail) ON DELETE CASCADE
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
            date_fin TEXT NOT NULL
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
            FOREIGN KEY (id_produit) REFERENCES Produit (id_produit) ON DELETE CASCADE
          )
        ''');
      },
    );

    await loadProduits();
    await loadProduitsDetails();
    await loadVentes();
  }

  // Listes des données
  List<Map<String, dynamic>> produits = [];
  List<Map<String, dynamic>> produitsDetails = [];
  List<Map<String, dynamic>> ventes = [];

  // 🔹 CRUD : Produit

  // Ajouter un produit
  Future<void> addProduit({
    required String nom,
    required String description,
    required double stock,
    required int id_produitDetail,
  }) async {
    await _db.insert('Produit', {
      'nom': nom,
      'description': description,
      'stockTotal': stock,
      'id_produitDetail': id_produitDetail,
    });

    print("ID du produit inséré : ");
    await loadProduits(); // Recharger les produits après l'ajout
    // Retourner l'ID de l'insertion
  }



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
    required String description,
    required double stock,

  }) async {
    await _db.update(
      'Produit',
      {
        'nom': nom,
        'description': description,
        'stockTotal': stock,
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
  }) async {
   int id = await _db.insert('ProduitDetail', {
      'prix_unitaire' : prix_unitaire,
      'prix_entrer' : prix_entrer,
      'statut' : status,
      'stock': stock,
      'date_ajout' : date_ajout,
      'date_fin' : date_fin,
    });
    print("dans contrroler les produits sont: $id");
    await loadProduitsDetails();
return id;
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


  // 🔹 CRUD : Vente

  // Ajouter une vente
  Future<void> addVente({
    required double qualite,
    required double prixTotal,
    required String date,
    required int idProduit,
  }) async {
    await _db.insert('Vente', {
      'qualite': qualite,
      'prix_total': prixTotal,
      'date': date,
      'id_produit': idProduit,
    });
    await loadVentes();
  }

  // Lire toutes les ventes
  Future<void> loadVentes() async {
    ventes = await _db.query('Vente');
    print("📌 Ventes chargées : $ventes");
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
