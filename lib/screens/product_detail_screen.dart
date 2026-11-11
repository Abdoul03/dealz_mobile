import 'package:cached_network_image/cached_network_image.dart';
import 'package:dealz/_base/constant.dart';
import 'package:dealz/models/annonce_model.dart';
import 'package:dealz/screens/chat_detail_screen.dart';
import 'package:dealz/screens/vendor_profil_screen.dart';
import 'package:dealz/services/auth_service.dart';
import 'package:dealz/services/favori_service.dart';
import 'package:dealz/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ProductDetailScreen extends StatefulWidget {
  final AnnonceModel annonce;
  const ProductDetailScreen({super.key, required this.annonce});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _buying = false;
  bool _reserved = false;
  bool _isFavorite = false;
  bool _favoriteLoading = false;
  int _photoIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final ids = await FavoriService().getMesFavorisIds();
      if (mounted) setState(() => _isFavorite = ids.contains(widget.annonce.id));
    } catch (_) {
      // L'article reste consultable si le chargement des favoris échoue.
    }
  }

  Future<void> _toggleFavorite() async {
    if (_favoriteLoading) return;
    setState(() => _favoriteLoading = true);
    try {
      if (_isFavorite) {
        await FavoriService().retirer(widget.annonce.id);
      } else {
        await FavoriService().ajouter(widget.annonce.id);
      }
      if (!mounted) return;
      setState(() => _isFavorite = !_isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite
              ? 'Article ajouté aux favoris.'
              : 'Article retiré des favoris.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _favoriteLoading = false);
    }
  }

  Future<void> _acheter() async {
    final currentUserId = await AuthService().getCurrentUserId();
    if (currentUserId == widget.annonce.vendeur.id) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('C’est votre propre annonce.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _buying = true);
    try {
      await TransactionService().initierTransaction(
        annonceId: widget.annonce.id,
      );
      if (!mounted) return;
      setState(() => _reserved = true);
      final openChat = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Article réservé'),
          content: const Text(
            'Écrivez au vendeur pour convenir du rendez-vous. Le paiement se fait directement entre vous, hors Dealz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Plus tard'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Écrire au vendeur'),
            ),
          ],
        ),
      );
      if (openChat == true && mounted) await _contacterVendeur();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  Future<void> _contacterVendeur() async {
    final currentUserId = await AuthService().getCurrentUserId();
    if (widget.annonce.vendeur.id == currentUserId) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('C\'est votre propre annonce.')));
      return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          autreUserId: widget.annonce.vendeur.id,
          autreUserNom: widget.annonce.vendeur.nomComplet,
          annonceId: widget.annonce.id,
          annonceTitre: widget.annonce.titre,
          annonceImageUrl: widget.annonce.urlImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.annonce;
    final canReserve = a.statut == 'PUBLIEE' && !_reserved;
    final photos = <String>{
      if (a.urlImage != null && a.urlImage!.isNotEmpty) a.urlImage!,
      ...a.urlImages.where((url) => url.isNotEmpty),
    }.toList();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image principale
                Stack(
                  children: [
                    SizedBox(
                      height: 380,
                      width: double.infinity,
                      child: photos.isEmpty
                          ? Image.asset(
                              'assets/images/jordan-air-jordan.webp',
                              fit: BoxFit.cover,
                            )
                          : PageView.builder(
                              itemCount: photos.length,
                              onPageChanged: (index) =>
                                  setState(() => _photoIndex = index),
                              itemBuilder: (context, index) =>
                                  CachedNetworkImage(
                                imageUrl: photos[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Constant.backgroundColor,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  'assets/images/jordan-air-jordan.webp',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),
                    Container(
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black45, Colors.transparent],
                        ),
                      ),
                    ),
                    // Badge état
                    Positioned(
                      top: 100,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(a.etatLabel,
                            style: TextStyle(
                                color: Constant.primaireColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ),
                    ),
                    if (photos.length > 1)
                      Positioned(
                        bottom: 14,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            photos.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: index == _photoIndex ? 18 : 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: index == _photoIndex
                                    ? Colors.white
                                    : Colors.white60,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre + Prix
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(a.titre,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Text('${_formatPrix(a.prix)} FCFA',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Constant.primaireColor)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Localisation + catégorie
                      Row(
                        children: [
                          Icon(LucideIcons.map_pin,
                              size: 15, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(a.quartier ?? 'Lieu de rendez-vous à convenir',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Constant.primaireColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(a.categorie.nom,
                                style: TextStyle(
                                    color: Constant.primaireColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),

                      if ((a.marque != null && a.marque!.isNotEmpty) ||
                          (a.taille != null && a.taille!.isNotEmpty)) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (a.marque != null && a.marque!.isNotEmpty)
                              _detailTag('Marque', a.marque!),
                            if (a.taille != null && a.taille!.isNotEmpty)
                              _detailTag('Taille', a.taille!),
                          ],
                        ),
                      ],

                      const Divider(height: 32),

                      // Description
                      const Text('Description',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(a.description,
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.6)),

                      const Divider(height: 32),

                      // Profil vendeur
                      const Text('Vendeur',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VendorProfilScreen(
                              vendorId: a.vendeur.id,
                              vendorName: a.vendeur.nomComplet,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Constant.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    Constant.primaireColor.withValues(alpha: 0.1),
                                child: Icon(LucideIcons.user,
                                    color: Constant.primaireColor),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.vendeur.nomComplet,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    Row(
                                      children: [
                                        Icon(Icons.star,
                                            color: const Color(0xFFFFB100),
                                            size: 15),
                                        Text(
                                            ' ${a.vendeur.noteMoyenne.toStringAsFixed(1)}',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(LucideIcons.chevron_right,
                                  color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bouton retour
          Positioned(
            top: 48,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(LucideIcons.arrow_left, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          Positioned(
            top: 48,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                tooltip: _isFavorite
                    ? 'Retirer des favoris'
                    : 'Ajouter aux favoris',
                onPressed: _favoriteLoading ? null : _toggleFavorite,
                icon: _favoriteLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite
                            ? Constant.secondaryColor
                            : Constant.primaireColor,
                      ),
              ),
            ),
          ),

          // Barre d'action en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _contacterVendeur,
                      icon: const Icon(LucideIcons.message_circle),
                      label: const Text('Message'),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Constant.primaireColor),
                        foregroundColor: Constant.primaireColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _buying || !canReserve ? null : _acheter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constant.primaireColor,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _buying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              canReserve
                                  ? 'Réserver'
                                  : _reserved || a.statut == 'RESERVEE'
                                      ? 'Déjà réservé'
                                      : a.statut == 'VENDUE'
                                          ? 'Vendu'
                                          : 'Indisponible',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrix(double prix) {
    return prix
        .toStringAsFixed(0)
        .replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ');
  }

  Widget _detailTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Constant.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$label : $value', style: const TextStyle(fontSize: 13)),
    );
  }
}
