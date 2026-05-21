import 'package:dealz/screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:dealz/_base/constant.dart';
import 'package:dealz/screens/product_card.dart';
import 'package:dealz/screens/product_detail_screen.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class VendorProfilScreen extends StatelessWidget {
  final String vendorName;

  const VendorProfilScreen({super.key, required this.vendorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Profil Vendeur",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(
              LucideIcons.ellipsis_vertical,
              color: Colors.black,
            ),
            onPressed: () {
              // Option pour signaler le profil si nécessaire (exigence cahier des charges)
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. EN-TÊTE DU PROFIL DU VENDEUR
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.grey[200],
                        child: Icon(
                          LucideIcons.user,
                          size: 36,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vendorName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.map_pin,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Hamdallaye, Bamako",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Membre depuis mai 2025",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Zone Évaluations et Avis
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFB100),
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "4.9",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Constant.primaireColor,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              "Note globale",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 25,
                          width: 1,
                          color: Colors.grey[200],
                        ),
                        const Column(
                          children: [
                            Text(
                              "18",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Avis reçus",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 25,
                          width: 1,
                          color: Colors.grey[200],
                        ),
                        const Column(
                          children: [
                            Icon(
                              LucideIcons.shield_check,
                              color: Colors.green,
                              size: 18,
                            ),
                            Text(
                              "Vérifié",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Bouton pour contacter directement
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatDetailScreen(userName: vendorName),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.message_square, size: 18),
                      label: const Text(
                        "Contacter le vendeur",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Constant.primaireColor,
                        side: BorderSide(color: Constant.primaireColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TITRE SECTION : OBJETS EN VENTE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 20.0,
                bottom: 10.0,
              ),
              child: Text(
                "Annonces de $vendorName",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // 2. GRILLE DES PRODUITS DU VENDEUR
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(),
                      ),
                    );
                  },
                  child:
                      const ProductCard(), // Réutilisation de votre carte produit
                ),
                childCount: 4, // Nombre d'articles fictifs de ce vendeur
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}
