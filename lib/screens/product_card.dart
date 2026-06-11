import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ProductCard extends StatelessWidget {
  final String titre;
  final double prix;
  final String? localisation;
  final String? imageUrl;

  const ProductCard({
    super.key,
    this.titre = 'Article',
    this.prix = 0,
    this.localisation,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image de l'article
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: _buildImage(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatPrix(prix)} FCFA',
                  style: const TextStyle(
                    color: Color(0xFF2D6A4F),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (localisation != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.map_pin,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          localisation!,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        // Téléchargée une seule fois puis enregistrée localement
        placeholder: (context, url) => Container(
          color: Colors.grey[100],
          child: Center(
            child: Icon(LucideIcons.image,
                color: Colors.grey[300], size: 32),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[100],
          child: Center(
            child: Icon(LucideIcons.image_off,
                color: Colors.grey[300], size: 32),
          ),
        ),
      );
    }
    // Fallback asset local
    return Image.asset(
      'assets/images/jordan-air-jordan.webp',
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }

  String _formatPrix(double prix) {
    if (prix >= 1000) {
      final parts = prix.toStringAsFixed(0).split('');
      final buffer = StringBuffer();
      for (int i = 0; i < parts.length; i++) {
        if (i > 0 && (parts.length - i) % 3 == 0) buffer.write(' ');
        buffer.write(parts[i]);
      }
      return buffer.toString();
    }
    return prix.toStringAsFixed(0);
  }
}
