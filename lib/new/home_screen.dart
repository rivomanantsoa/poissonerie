import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌄 Background image (mer ou port)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg_poissonnerie.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 60),

              // 🐟 Titre
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.set_meal, size: 40, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'POISSONNERIE CLUB',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ☀️ Score de la journée
              Container(
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Colors.yellow, Colors.orange],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.7),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Text(
                  '2 450 Ar\nVentes du jour',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 📅 Défi du jour
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.flag, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Défi du jour : 3kg vendus',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 🎯 Niveau
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.teal[800],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'NIVEAU 5 - Marchand local',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),

              const Spacer(),

              // ⬇️ Menu en bas
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    MenuIcon(
                      icon: Icons.inventory_2,
                      label: 'Produits',
                    ),
                    MenuIcon(
                      icon: Icons.bar_chart,
                      label: 'Rapport',
                    ),
                    MenuIcon(
                      icon: Icons.people,
                      label: 'Clients',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const MenuIcon({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blueAccent,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}