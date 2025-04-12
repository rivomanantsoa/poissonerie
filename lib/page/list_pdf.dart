import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:untitled/page/principale.dart';
class ListPdf extends StatefulWidget {
  @override
  _ListPdfState createState() => _ListPdfState();
}

class _ListPdfState extends State<ListPdf> {
  List<File> pdfFiles = [];

  @override
  void initState() {
    super.initState();
    _loadPdfFiles();
  }

  // Charger les fichiers PDF
  Future<void> _loadPdfFiles() async {
    final directory = await getExternalStorageDirectory();
    final pdfDir = Directory('${directory!.path}/PDFs');

    if (await pdfDir.exists()) {
      setState(() {
        pdfFiles = pdfDir
            .listSync()
            .where((file) => file.path.endsWith('.pdf'))
            .map((file) => File(file.path))
            .toList()
          ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      });
    }
  }

  // Ouvrir un fichier PDF
  void _openPdf(File file) {
    OpenFile.open(file.path);
  }


  void _downloadPdf(BuildContext context, File file, String nom) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      _showMessage(context, "Permission refusée");
      return;
    }

    final downloadsDir = Directory('/storage/emulated/0/Download/MesRapports');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text("Téléchargement en cours...")),
          ],
        ),
      ),
    );

    try {
      final newFilePath = '${downloadsDir.path}/${file.path.split('/').last}';
      await file.copy(newFilePath);

      Navigator.of(context).pop(); // Ferme le loader

      // Montre une boîte de succès avec bouton "Ouvrir le dossier"
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Succès"),
          content: Text("Fichier téléchargé dans :\n$newFilePath"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Fermer"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Ouvre le dossier contenant le fichier
                OpenFile.open(downloadsDir.path);
              },
              child: Text("Ouvrir le dossier"),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      _showMessage(context, "Erreur lors du téléchargement : $e");
    }
  }




// Fonction pour afficher un message (Toast ou SnackBar)
  void _showMessage(BuildContext context, String message) async {
    try {
      await Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (_) {
      // Fallback si Fluttertoast ne fonctionne pas
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _deletePdf(File file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Supprimer le fichier ?"),
        content: Text("Es-tu sûr de vouloir supprimer ce fichier ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              file.deleteSync();
              Navigator.pop(ctx);
              _loadPdfFiles(); // Recharge la liste
            },
            child: Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.home,
            color: Colors.white,
            size: 40,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black.withOpacity(0.5),
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Principale()),
            );
          }, // ou Navigator.pop(context), selon ton besoin
        ),
        backgroundColor: Colors.red.shade600,
        title: Text(
          "Récapitulatif des ventes",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 35,shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black.withOpacity(0.5),
                offset: Offset(2.0, 2.0),
              ),
            ],),
            onPressed: _loadPdfFiles,
            tooltip: "Rafraîchir",
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Liste des rapports PDF",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: pdfFiles.isEmpty
                  ? Center(
                child: Text(
                  "Aucun PDF trouvé",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: pdfFiles.length,
                itemBuilder: (context, index) {
                  final file = pdfFiles[index];
                  final fileName = file.path.split('/').last;
                  final fileSize = (file.lengthSync() / 1024).toStringAsFixed(1); // en Ko
                  final fileDate = DateFormat('dd/MM/yyyy HH:mm').format(file.lastModifiedSync());
                  final nom = fileName.split('_').first;
                  return Card(
                    elevation: 3,
                    color: Colors.red.shade600,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      leading: IconButton(
                        icon: Icon(Icons.remove_red_eye, color: Colors.white, size: 30, shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(2.0, 2.0),
                          ),
                        ],),
                        onPressed: () => _openPdf(file),
                        tooltip: "Voir",
                      ),
                      title: Text(
                        fileName,
                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.yellowAccent),
                      ),
                      subtitle: Text(
                        "Taille: $fileSize Ko\nModifié: $fileDate ",
                        style: TextStyle(fontSize: 12, color : Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          IconButton(
                            icon: Icon(Icons.download, color: Colors.yellowAccent, size: 35, shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(2.0, 2.0),
                              ),
                            ],),
                            onPressed: () => _downloadPdf(context, pdfFiles[index], nom ),
                          ),

                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.lightGreenAccent.shade400, size: 35, shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(2.0, 2.0),
                              ),
                            ], ),
                            onPressed: () => _deletePdf(file),
                            tooltip: "Supprimer",
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
