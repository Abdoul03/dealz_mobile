import 'package:dealz/_base/constant.dart';
import 'package:dealz/screens/product_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Liste fictive des catégories pour le filtre
  final List<String> categories = [
    "Tout",
    "Vêtements",
    "Électronique",
    "Maison",
    "Livres",
  ];
  int selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.backgroundColor, // Fond gris très clair
      body: CustomScrollView(
        slivers: [
          // 1. Barre d'application avec recherche
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            backgroundColor: Constant.primaireColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Rechercher...",
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: Constant.primaireColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),
          ),

          // 2. Section des Catégories
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedCategoryIndex == index;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: ChoiceChip(
                      label: Text(categories[index]),
                      selected: isSelected,
                      selectedColor: Constant.primaireColor,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (selected) {
                        setState(() => selectedCategoryIndex = index);
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Grille de Produits
          SliverPadding(
            padding: EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75, // Ajuste la hauteur des cartes
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => ProductCard(),
                childCount: 10, // Nombre d'articles à afficher
              ),
            ),
          ),
        ],
      ),

      // Bouton Flottant pour Vendre
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Constant.secondaryColor, // Ambre pour l'action
        icon: Icon(Icons.add_a_photo, color: Colors.white),
        label: Text(
          "Vendre",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
