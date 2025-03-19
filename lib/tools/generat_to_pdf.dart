import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled/controller/controller.dart';
import 'package:intl/intl.dart';
Future<void> generateAndSavePDF(List<Map<String, dynamic>> ventesDuJour, Controller globalState) async {
  final pdf = pw.Document();

  // Date du rapport
  final dateRapport = DateTime.now();
  final dateFormat = "${dateRapport.day}/${dateRapport.month}/${dateRapport.year}";

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // En-tête
            pw.Center(
              child: pw.Text(
                "Rapport de Vente - $dateFormat",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ),
            pw.Divider(),
            pw.SizedBox(height: 10),

            // Résumé des ventes
            pw.Text(
              "Résumé des ventes :",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              "Total vendu : ${ventesDuJour.fold<double>(0, (total, vente) => total + ((vente['qualite'] ?? 0) as double)).toStringAsFixed(2)} Kg\n"
                  "Montant total : ${ventesDuJour.fold<double>(0, (total, vente) => total + ((vente['prix_total'] ?? 0) as double)).toStringAsFixed(2)} Ariary",
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 10),

            // Tableau des ventes
            pw.Table.fromTextArray(
              headers: ["Produit", "Description", "Poids (Kg)", "Prix (Ar)", "Heure"],
              data: ventesDuJour.map((vente) {
                final produit = globalState.produits.firstWhere(
                      (p) => p['id_produit'] == vente['id_produit'],
                  orElse: () => {},
                );

                final produitDetail = globalState.produitsDetails.firstWhere(
                      (p) => p['id_produit'] == vente['id_produit'],
                  orElse: () => {},
                );

                final nomProduit = produit?['nom'] ?? "Inconnu";
                final descriptionProduit = produitDetail?['description'] ?? "Non spécifiée";
                final heureVente = vente['date'] != null
                    ? DateFormat('HH:mm').format(DateTime.parse(vente['date']).toLocal())
                    : "Heure inconnue";
                final qualite = (vente['qualite']).toStringAsFixed(2);
                return [
                  nomProduit,
                  descriptionProduit,
                  qualite,
                  vente['prix_total'].toString(),
                  heureVente
                ];
              }).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: pw.TextStyle(fontSize: 12),
            ),

            pw.SizedBox(height: 20),

            // Pied de page
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Signature : _____________________",
                style: pw.TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    ),
  );

  // Vérification et enregistrement du PDF
  if (await Permission.storage.request().isGranted) {
    final Directory? directory = await getExternalStorageDirectory();
    final path = "${directory!.path}/PDFs";

    final directoryFolder = Directory(path);
    if (!await directoryFolder.exists()) {
      await directoryFolder.create(recursive: true);
    }

    DateTime now = DateTime.now();
    String formattedDate = DateFormat("ddMMMMyyyy_HH:mm", "fr_FR").format(now);
    final filePath = "$path/Ventes_$formattedDate.pdf" ;
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print("PDF enregistré : $filePath");
  } else {
    print("Permission refusée pour enregistrer le PDF");
  }
}
