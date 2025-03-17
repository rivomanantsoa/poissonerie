Container(
  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(0, 3)),
    ],
  ),
  child: ListTile(
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,  // Taille de l'image circulaire
          backgroundImage: NetworkImage(produit['image_url'] ?? 'url_de_defaut'), // Remplacer par l'URL de l'image du produit
        ),
        SizedBox(height: 8),
        Text(
          produit['nom'],  // Affichage du nom du produit
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    ),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(Icons.airplane_ticket, size: 14, color: Colors.grey),
            SizedBox(width: 5),
            Text(
              "${produit["stock"]} Kg",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Text(
          produit["stock"] == 0
              ? "Lafo daholo"
              : "Mbola misy amidy",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: produit["stock"] == 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    ),
    onTap: () {
      if (produit["stock"] != null && produit["stock"] > 0) {
        showDialog(
          context: context,
          builder: (context) => SingleChildScrollView(
            child: AcheterProduit(id: idRecherche),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Tatitra"),
            content: Text("Tsy misy $afficher intsony!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    },
  ),
);
