import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre et bouton de rafraîchissement
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Liste des PDFs",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadPdfFiles,
                  ),
                ],
              ),
            ),

            Divider(color: Colors.white70), // Ligne de séparation stylisée

            // Liste des PDF
            Expanded(
              child: pdfFiles.isEmpty
                  ? Center(
                child: Text(
                  "Aucun PDF trouvé",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemCount: pdfFiles.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white.withOpacity(0.85), // Effet semi-transparent
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                      title: Text(
                        pdfFiles[index].path.split('/').last,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () => _openPdf(pdfFiles[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
