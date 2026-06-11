import 'package:cached_network_image/cached_network_image.dart';
import 'package:dealz/_base/constant.dart';
import 'package:dealz/models/annonce_model.dart';
import 'package:dealz/screens/chat_detail_screen.dart';
import 'package:dealz/screens/product_detail_screen.dart';
import 'package:dealz/services/annonce_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class VendorProfilScreen extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  const VendorProfilScreen({super.key, required this.vendorId, required this.vendorName});
  @override
  State<VendorProfilScreen> createState() => _VendorProfilScreenState();
}

class _VendorProfilScreenState extends State<VendorProfilScreen> {
  List<AnnonceModel> _annonces = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await AnnonceService().getAnnoncesByVendeur(widget.vendorId);
      setState(() => _annonces = list);
    } catch (_) {}
    finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        title: const Text('Profil Vendeur', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        surfaceTintColor: Colors.transparent, backgroundColor: Colors.white, elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Container(
          color: Colors.white, padding: const EdgeInsets.all(20),
          child: Column(children: [
            Row(children: [
              CircleAvatar(radius: 36, backgroundColor: Colors.grey[200],
                  child: Icon(LucideIcons.user, size: 36, color: Colors.grey[400])),
              const SizedBox(width: 20),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.vendorName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (_annonces.isNotEmpty && _annonces.first.vendeur.noteMoyenne > 0)
                  Row(children: [
                    const Icon(Icons.star, color: Color(0xFFFFB100), size: 16),
                    Text(' ${_annonces.first.vendeur.noteMoyenne.toStringAsFixed(1)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ]),
              ])),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 44,
              child: OutlinedButton.icon(
                onPressed: _annonces.isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ChatDetailScreen(
                        autreUserId: widget.vendorId, autreUserNom: widget.vendorName,
                        annonceId: _annonces.first.id, annonceTitre: _annonces.first.titre))),
                icon: const Icon(LucideIcons.message_square, size: 18),
                label: const Text('Contacter le vendeur', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(foregroundColor: Constant.primaireColor,
                    side: BorderSide(color: Constant.primaireColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ]),
        )),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text('Annonces de ${widget.vendorName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        )),
        if (_loading) const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())))
        else if (_annonces.isEmpty) const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32),
            child: Text('Aucune annonce disponible.', style: TextStyle(color: Colors.grey)))))
        else SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.78),
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final a = _annonces[i];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(annonce: a))),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: a.urlImage != null
                            ? CachedNetworkImage(imageUrl: a.urlImage!, fit: BoxFit.cover, width: double.infinity,
                                placeholder: (c, u) => Container(color: Colors.grey[100]),
                                errorWidget: (c, u, e) => Container(color: Colors.grey[100],
                                    child: Icon(LucideIcons.image, color: Colors.grey[300])))
                            : Container(color: Colors.grey[100], child: Icon(LucideIcons.image, color: Colors.grey[300])),
                      )),
                      Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('${a.prix.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(color: Color(0xFF2D6A4F), fontWeight: FontWeight.bold, fontSize: 15)),
                      ])),
                    ]),
                  ),
                );
              },
              childCount: _annonces.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ]),
    );
  }
}
