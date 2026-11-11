import 'package:dealz/_base/constant.dart';
import 'package:dealz/models/transaction_model.dart';
import 'package:dealz/screens/chat_detail_screen.dart';
import 'package:dealz/services/auth_service.dart';
import 'package:dealz/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class CartScreen extends StatefulWidget {
  final int initialTab;

  const CartScreen({super.key, this.initialTab = 0});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _service = TransactionService();
  List<TransactionModel> _transactions = [];
  String? _currentUserId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.getMesAchats(),
        _service.getMesVentes(),
        AuthService().getCurrentUserId(),
      ]);
      final achats = results[0] as List<TransactionModel>;
      final ventes = results[1] as List<TransactionModel>;
      final currentUserId = results[2] as String?;
      final byId = <String, TransactionModel>{
        for (final transaction in [...achats, ...ventes])
          transaction.id: transaction,
      };
      final transactions = byId.values.toList()
        ..sort((a, b) =>
            (b.dateTransaction ?? DateTime(0))
                .compareTo(a.dateTransaction ?? DateTime(0)));

      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _currentUserId = currentUserId;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<TransactionModel> get _active => _transactions
      .where((t) =>
          t.statut == 'EN_COURS' || t.statut == 'CONFIRMATION_PARTIELLE')
      .toList();

  List<TransactionModel> get _history => _transactions
      .where((t) =>
          t.statut == 'CONFIRMEE' ||
          t.statut == 'ANNULEE' ||
          t.statut == 'SEQUESTRE')
      .toList();

  Future<void> _confirmHandover(TransactionModel transaction) async {
    try {
      final updated = await _service.confirmerTransaction(transaction.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updated.statut == 'CONFIRMEE'
              ? 'La vente est confirmée par les deux personnes.'
              : 'Confirmation enregistrée. En attente de l’autre personne.'),
          backgroundColor: Constant.primaireColor,
        ),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _cancel(TransactionModel transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation ?'),
        content: const Text('L’article sera remis en ligne.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuer la réservation'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.annulerTransaction(transaction.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation annulée. L’article est de nouveau en ligne.')),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab == 1 ? 1 : 0,
      child: Scaffold(
        backgroundColor: Constant.backgroundColor,
        appBar: AppBar(
          title: const Text('Mes achats et ventes'),
          actions: [
            IconButton(
              onPressed: _load,
              tooltip: 'Actualiser',
              icon: const Icon(LucideIcons.refresh_cw),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Réservations'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : TabBarView(
                    children: [
                      _buildList(_active, 'Aucune réservation en cours.'),
                      _buildList(
                        _history,
                        'Vos achats et ventes terminés apparaîtront ici.',
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildList(List<TransactionModel> transactions, String emptyMessage) {
    if (transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 220),
            const Icon(LucideIcons.shopping_bag, size: 54, color: Colors.black26),
            const SizedBox(height: 14),
            Center(child: Text(emptyMessage)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _transactionCard(
          transactions[index],
          isActive: transactions[index].statut == 'EN_COURS' ||
              transactions[index].statut == 'CONFIRMATION_PARTIELLE',
        ),
      ),
    );
  }

  Widget _transactionCard(
    TransactionModel transaction, {
    required bool isActive,
  }) {
    final isSeller = _currentUserId == transaction.vendeur.id;
    final hasConfirmed = isSeller
        ? transaction.vendeurConfirmeRemise
        : transaction.acheteurConfirmeRemise;
    final interlocuteur = isSeller
        ? transaction.acheteur.nomComplet
        : transaction.vendeur.nomComplet;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    transaction.annonceTitre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                _statusBadge(transaction.statutLabel),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${isSeller ? 'Acheteur' : 'Vendeur'} : $interlocuteur',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              '${transaction.montant.toStringAsFixed(0)} FCFA',
              style: TextStyle(
                color: Constant.primaireColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Remise en main propre · paiement direct entre utilisateurs',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (isActive) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          autreUserId: isSeller
                              ? transaction.acheteur.id
                              : transaction.vendeur.id,
                          autreUserNom: interlocuteur,
                          annonceId: transaction.annonceId,
                          annonceTitre: transaction.annonceTitre,
                          annonceImageUrl: transaction.annonceImageUrl,
                        ),
                      ),
                    ),
                    icon: const Icon(LucideIcons.message_circle, size: 17),
                    label: const Text('Écrire'),
                  ),
                  OutlinedButton(
                    onPressed: () => _cancel(transaction),
                    child: const Text('Annuler la réservation'),
                  ),
                  FilledButton(
                    onPressed: hasConfirmed
                        ? null
                        : () => _confirmHandover(transaction),
                    child: Text(
                      hasConfirmed ? 'Remise confirmée' : 'Confirmer la remise',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String label) => DecoratedBox(
        decoration: BoxDecoration(
          color: Constant.primaireColor.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Text(
            label,
            style: TextStyle(
              color: Constant.primaireColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Impossible de charger vos réservations.'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
}
