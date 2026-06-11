import 'package:cached_network_image/cached_network_image.dart';
import 'package:dealz/_base/constant.dart';
import 'package:dealz/models/annonce_model.dart';
import 'package:dealz/screens/chat_detail_screen.dart';
import 'package:dealz/screens/vendor_profil_screen.dart';
import 'package:dealz/services/auth_service.dart';
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

  static const _paymentOptions = [
    {'value': 'ORANGE_MONEY', 'label': 'Orange Money'},
    {'value': 'MOOV_MONEY', 'label': 'Moov Money'},
    {'value': 'ESPECES', 'label': 'Espèces'},
    {'value': 'CARTE_BANCAIRE', 'label': 'Carte bancaire'},
  ];

  static const _retraitOptions = [
    'MAIN_PROPRE',
    'POINT_RELAIS',
    'DOMICILE',
  ];

  Future<void> _acheter() async {
    String? selectedPayment;
    String selectedRetrait = 'MAIN_PROPRE';

    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              const Text('Finaliser l\'achat',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                '${widget.annonce.titre} — ${_formatPrix(widget.annonce.prix)} FCFA',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 20),
              const Text('Mode de paiement',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _paymentOptions.map((opt) {
                  final sel = selectedPayment == opt['value'];
                  return ChoiceChip(
                    label: Text(opt['label']!),
                    selected: sel,
                    selectedColor: Constant.primaireColor,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : Colors.black87),
                    onSelected: (_) =>
                        setSheet(() => selectedPayment = opt['value']),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Mode de remise',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _retraitOptions.map((opt) {
                  final sel = selectedRetrait == opt;
                  return ChoiceChip(
                    label: Text(opt.replaceAll('_', ' ')),
                    selected: sel,
                    selectedColor: Constant.primaireColor,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : Colors.black87),
                    onSelected: (_) =>
                        setSheet(() => selectedRetrait = opt),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedPayment == null
                      ? null
                      : () => Navigator.pop(ctx, {
                            'payment': selectedPayment,
                            'retrait': selectedRetrait
                          }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constant.primaireColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Confirmer',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null || result['payment'] == null) return;

    setState(() => _buying = true);
    try {
      await TransactionService().initierTransaction(
        annonceId: widget.annonce.id,
        typePaiement: result['payment']!,
        modeRetrait: result['retrait'],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            'Transaction initiée ! Les fonds sont en séquestre.'),
        backgroundColor: Constant.primaireColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.annonce;
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
                      child: a.urlImage != null
                          ? CachedNetworkImage(
                              imageUrl: a.urlImage!,
                              fit: BoxFit.cover,
                              placeholder: (ctx, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                      child: CircularProgressIndicator())),
                              errorWidget: (ctx, url, err) => Image.asset(
                                  'assets/images/jordan-air-jordan.webp',
                                  fit: BoxFit.cover),
                            )
                          : Image.asset(
                              'assets/images/jordan-air-jordan.webp',
                              fit: BoxFit.cover),
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
                          Text(a.pointRetrait ?? 'Localisation non précisée',
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
                      onPressed: _buying ? null : _acheter,
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
                          : const Text('Acheter',
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
}
