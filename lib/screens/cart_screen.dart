import 'package:dealz/_base/constant.dart';
import 'package:dealz/models/transaction_model.dart';
import 'package:dealz/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _service = TransactionService();
  List<TransactionModel> _transactions = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _service.getMesAchats();
      setState(() => _transactions = list.where((t) => t.statut == 'EN_COURS' || t.statut == 'SEQUESTRE').toList());
    } catch (_) {}
    finally { setState(() => _loading = false); }
  }

  Future<void> _confirmer(TransactionModel t) async {
    try {
      await _service.confirmerTransaction(t.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Réception confirmée ! Le vendeur a été payé.'),
          backgroundColor: Colors.green, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _annuler(TransactionModel t) async {
    final confirm = await showDialog<bool>(context: context,
        builder: (_) => AlertDialog(
          title: const Text('Annuler la transaction ?'),
          content: const Text('Cette action est irréversible.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
            TextButton(onPressed: () => Navigator.pop(context, true),
                child: const Text('Oui, annuler', style: TextStyle(color: Colors.redAccent))),
          ],
        ));
    if (confirm != true) return;
    try {
      await _service.annulerTransaction(t.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction annulée.'),
          behavior: SnackBarBehavior.floating));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        title: const Text('Transactions en cours', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0, surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [IconButton(icon: const Icon(LucideIcons.refresh_cw, color: Colors.black54, size: 20), onPressed: _load)],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load, color: Constant.primaireColor,
              child: _transactions.isEmpty ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length,
                      itemBuilder: (_, i) => _buildCard(_transactions[i])),
            ),
    );
  }

  Widget _buildCard(TransactionModel t) {
    final isSequestre = t.statut == 'SEQUESTRE';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(t.annonceTitre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: isSequestre ? Colors.orange.shade50 : Constant.primaireColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(t.statutLabel,
                  style: TextStyle(color: isSequestre ? Colors.orange : Constant.primaireColor,
                      fontSize: 12, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Icon(LucideIcons.user, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text('Vendeur : ${t.vendeur.nomComplet}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          Icon(LucideIcons.circle_dollar_sign, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text('${t.montant.toStringAsFixed(0)} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          if (t.typePaiement != null) ...[
            const SizedBox(width: 8),
            Text('via ${t.typePaiement!.replaceAll('_', ' ')}',
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ],
        ]),
        if (t.modeRetrait != null) ...[
          const SizedBox(height: 4),
          Row(children: [
            Icon(LucideIcons.map_pin, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(t.modeRetrait!.replaceAll('_', ' '), style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ]),
        ],
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => _annuler(t),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Annuler'),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: isSequestre ? () => _confirmer(t) : null,
            style: ElevatedButton.styleFrom(backgroundColor: Constant.primaireColor, foregroundColor: Colors.white,
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                disabledBackgroundColor: Colors.grey[200]),
            child: const Text('Confirmer la réception', style: TextStyle(fontSize: 13)),
          )),
        ]),
      ]),
    );
  }

  Widget _buildEmpty() => ListView(children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6,
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.shopping_cart, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('Aucune transaction en cours.', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        const SizedBox(height: 20),
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Parcourir les annonces',
            style: TextStyle(color: Constant.primaireColor, fontWeight: FontWeight.bold))),
      ])))]);
}
