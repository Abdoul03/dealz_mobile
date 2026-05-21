import 'package:flutter/material.dart';
import 'package:dealz/_base/constant.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Liste fictive d'articles dans le panier
  List<Map<String, dynamic>> cartItems = [
    {
      "title": "Veste en jean Zara",
      "price": 10000,
      "location": "Hamdallaye",
      "image": "https://via.placeholder.com/100",
    },
    {
      "title": "Chaussures Nike Air",
      "price": 25000,
      "location": "ACI 2000",
      "image": "https://via.placeholder.com/100",
    },
  ];

  double get subtotal => cartItems.fold(0, (sum, item) => sum + item['price']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Mon Panier",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(item, index);
                    },
                  ),
                ),
                _buildSummarySection(),
              ],
            ),
    );
  }

  // Widget pour un article individuel (Sécurisé contre les Overflows d'images)
  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ), // Ombre plus douce et pro que withAlpha(128)
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Correction de l'overflow : Conteneur de taille fixe pour l'image
          SizedBox(
            width: 80,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item['image'],
                fit: BoxFit.cover,
                // Gestion de l'erreur réseau / HandshakeException vue sur votre capture
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[100],
                    child: Icon(
                      LucideIcons.package,
                      color: Colors.grey[400],
                      size: 30,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Infos produits bien enveloppées dans un Expanded pour éviter les coupures de texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${item['price']} FCFA",
                  style: TextStyle(
                    color: Constant.primaireColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      LucideIcons.map_pin,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['location'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bouton Supprimer
          IconButton(
            icon: const Icon(LucideIcons.trash_2, color: Colors.redAccent),
            onPressed: () {
              setState(() {
                cartItems.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  // Section du récapitulatif en bas
  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        // Assure que le bouton ne colle pas au bas de l'iPhone 17
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Sous-total",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Text(
                  "$subtotal FCFA",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Frais de service",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Text(
                  "500 FCFA",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  "${subtotal + 500} FCFA",
                  style: TextStyle(
                    color: Constant.primaireColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Logique de paiement (ex: Séquestre Orange Money / Moov Money)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constant.primaireColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Confirmer la commande",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Écran si le panier est vide
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.shopping_cart, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            "Votre panier est vide",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Continuer mes achats",
              style: TextStyle(
                color: Constant.primaireColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
