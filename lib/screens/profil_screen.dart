import 'package:flutter/material.dart';
import 'package:dealz/_base/constant.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Mon Profil",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        surfaceTintColor: Colors.transparent,
        backgroundColor: Constant.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, color: Colors.black),
            onPressed: () {
              // Ouvrir les paramètres
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER : INFOS UTILISATEUR
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        child: Icon(
                          LucideIcons.user,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        // Une fois l'image connectée :
                        // backgroundImage: NetworkImage("https://via.placeholder.com/150"),
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Constant.primaireColor,
                        child: const Icon(
                          LucideIcons.camera,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Fatoumata Keita",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.map_pin,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Hamdallaye ACI 2000, Bamako",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Note et Évaluations (Exigence clé du cahier des charges pour la confiance)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star,
                          color: Color(0xFFFFB100),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "4.9 (18 avis)",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. BANDEAU DE STATISTIQUES RAPIDES
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem("12", "Annonces"),
                  _buildStatDivider(),
                  _buildStatItem("45", "Achats"),
                  _buildStatDivider(),
                  _buildStatItem("32", "Ventes"),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. LISTE DES OPTIONS / HISTORIQUE
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: LucideIcons.package,
                    title: "Mes objets en vente",
                    subtitle: "Gérer ou modifier vos annonces",
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                    icon: LucideIcons.history,
                    title: "Historique des transactions",
                    subtitle: "Achats et ventes terminés",
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                    icon: LucideIcons.heart,
                    title: "Mes favoris",
                    subtitle: "Articles sauvegardés",
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                    icon: LucideIcons.store,
                    title: "Devenir Commerçant Pro",
                    subtitle: "Boutique dédiée à 5 000 FCFA / mois",
                    iconColor: Constant.secondaryColor,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. BOUTON DÉCONNEXION ÉPURÉ
            TextButton.icon(
              onPressed: () {
                // Logique de déconnexion
              },
              icon: const Icon(
                LucideIcons.log_out,
                color: Colors.redAccent,
                size: 18,
              ),
              label: const Text(
                "Se déconnecter",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget Helper pour créer les blocs de statistiques
  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Constant.primaireColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 30, width: 1, color: Colors.grey[200]);
  }

  // Widget Helper pour les lignes du menu
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Constant.primaireColor).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? Constant.primaireColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: const Icon(
        LucideIcons.chevron_right,
        size: 18,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 70,
      ), // Aligné avec le début du texte pour faire propre
      child: Divider(height: 1, color: Colors.grey[100]),
    );
  }
}
