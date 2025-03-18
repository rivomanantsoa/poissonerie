import 'package:flutter/material.dart';
import 'package:untitled/controller/controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ListTousVente extends StatefulWidget {
  const ListTousVente({super.key});

  @override
  State<ListTousVente> createState() => _ListTousVenteState();
}

class _ListTousVenteState extends State<ListTousVente> {
  late Controller globalState;
  late Future<void> _loadDataFuture = _initializeData();
  String? _selectedDate;
  String? _selectedYear;
  bool _datesArrondies = false;

  @override
  void initState() {
    super.initState();
    globalState = Provider.of<Controller>(context, listen: false);
    _loadDataFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    await globalState.loadVentes();
    setState(() {});
  }

  Map<String, Map<String, List<Map<String, dynamic>>>> groupVentesByYear(List ventes) {
    Map<String, Map<String, List<Map<String, dynamic>>>> ventesGrouped = {};

    for (var vente in ventes) {
      DateTime date = DateTime.parse(vente['date']);
      String year = DateFormat('yyyy').format(date);
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      if (!ventesGrouped.containsKey(year)) {
        ventesGrouped[year] = {};
      }
      if (!ventesGrouped[year]!.containsKey(formattedDate)) {
        ventesGrouped[year]![formattedDate] = [];
      }

      ventesGrouped[year]![formattedDate]!.add(vente);
    }

    // Trier les dates du plus proche au plus loin (ordre décroissant)
    var sortedVentesGrouped = Map.fromEntries(
      ventesGrouped.entries.map((entry) {
        var sortedDates = Map.fromEntries(
          entry.value.entries.toList()
            ..sort((a, b) => DateTime.parse(b.key).compareTo(DateTime.parse(a.key))),
        );
        return MapEntry(entry.key, sortedDates);
      }),
    );

    return sortedVentesGrouped;
  }


  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<Controller>(context);

    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 10),
      child: Column(
        children: [
          Text(
            "📅 Tahirin-tsoratra",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: _loadDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var ventesGrouped = groupVentesByYear(globalState.ventes);
                if (ventesGrouped.isEmpty) {
                  return Center(child: Text("Aucune vente trouvée", style: TextStyle(color: Colors.blue.shade900)));
                }

                return Row(
                  children: [
                    // 📆 COLONNE ANNÉES & DATES
                    Container(
                      width: _selectedYear == null ? 80 : _selectedDate == null ? 150 : 60,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView(
                        children: ventesGrouped.keys.map((year) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedYear = _selectedYear == year ? null : year;
                                    _selectedDate = null;
                                    _datesArrondies = _selectedDate != null;
                                  });
                                },
                                child: Container(
                                  width: 80,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: _selectedYear == year ? Colors.blue.shade300 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    year,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              if (_selectedYear == year)
                                Column(
                                  children: ventesGrouped[year]!.keys.map((date) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedDate = _selectedDate == date ? null : date;
                                            _datesArrondies = _selectedDate != null;
                                          });
                                        },
                                        child: Container(
                                          width: _datesArrondies ? 80 : 150,
                                          height: _datesArrondies ? 60 : 40,
                                          padding: EdgeInsets.only(left: 5),
                                          decoration: BoxDecoration(
                                            color: _selectedDate == date ? Colors.cyan.shade300 : Colors.transparent,
                                            borderRadius: _datesArrondies
                                                ? BorderRadius.circular(50)
                                                : BorderRadius.circular(10),
                                            border: Border.all(color: Colors.white),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            _datesArrondies
                                                ? DateFormat('d/MM').format(DateTime.parse(date))
                                                : DateFormat('EEEE d MMM', 'fr_FR').format(DateTime.parse(date)),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    // 🛒 COLONNE DES VENTES
                    SizedBox(width: 6),
                    Expanded(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade900, width: 2),
                        ),
                        child: _selectedDate != null
                            ? Column(

                          key: ValueKey(_selectedDate),
                          crossAxisAlignment : CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0, left: 10),
                              child: Text(
                                " - Totalin'ny lafo : ${ventesGrouped[_selectedYear!]![_selectedDate!]!.fold<double>
                                  (0, (total, vente) => total + ((vente['qualite'] ?? 0) as double)).toStringAsFixed(2)} Kg \n - Vidiny : ${ventesGrouped[_selectedYear!]![_selectedDate!]!.fold<double>
                                  (0, (total, vente) => total + ((vente['prix_total'] ?? 0) as double)).toStringAsFixed(2)} Ariary",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                key: ValueKey(_selectedDate),
                                padding: EdgeInsets.all(10),
                                itemCount: ventesGrouped[_selectedYear!]![_selectedDate!]!.length,
                                itemBuilder: (context, index) {
                                  final vente = ventesGrouped[_selectedYear!]![_selectedDate!]![index];
                                  final dateT = DateTime.parse(vente['date']);
                                  final nomProduit = globalState.produits.firstWhere(
                                        (produit) => produit['id_produit'] == vente['id_produit'],
                                    orElse: () => {},
                                  );
                                  final nomProduitDetail = globalState.produitsDetails.firstWhere(
                                        (produit) => produit['id_produitDetail'] == vente['id_produit'],
                                    orElse: () => {},
                                  );
                                  return Card(
                                    color: Colors.cyan.shade200,
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  ". ${nomProduit['nom'] ?? 'Produit inconnu'}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(width: 1),
                                              Expanded(
                                                child: Text(
                                                  " (${nomProduitDetail['description'] ?? 'Produit inconnu'})",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text("📦 Quantité : ${vente['qualite']} Kg"),
                                          Text("💰 Prix : ${vente['prix_total']} Ar"),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              DateFormat('HH:mm').format(dateT),
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                            : Center(child: Text("Hijery ireo raki-tsoratra", style: TextStyle(color: Colors.blue.shade900))),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
