import 'package:flutter/material.dart';

class Stock extends StatefulWidget {
  const Stock({super.key});

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  List<Map<String, dynamic>> stockList = [
    {"name": "Saumon", "quantity": 15, "unit": "kg", "status": "Disponible"},
    {"name": "Crevettes", "quantity": 0, "unit": "kg", "status": "Rupture"},
    {"name": "Tilapia", "quantity": 5, "unit": "kg", "status": "Bientôt épuisé"},
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case "Disponible":
        return Colors.green;
      case "Bientôt épuisé":
        return Colors.orange;
      case "Rupture":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion de Stock"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Naviguer vers la page d'ajout de produit
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: stockList.length,
          itemBuilder: (context, index) {
            var item = stockList[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: getStatusColor(item['status']),
                  radius: 8,
                ),
                title: Text("${item['name']} - ${item['quantity']} ${item['unit']}",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Statut: ${item['status']}",
                    style: TextStyle(color: getStatusColor(item['status']))),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Afficher les détails du produit
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
