import 'package:dealz/_base/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ChatDetailScreen extends StatelessWidget {
  final String userName;
  const ChatDetailScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    // Les suggestions demandées par le cahier des charges de REVINA
    final List<String> quickReplies = [
      "Disponible ?",
      "Négociable ?",
      "Faire une offre",
      "Où se voir ?",
    ];

    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        title: Text(
          userName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Zone des messages échangés (Fictive)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBubble(
                  context,
                  "Bonjour, je suis intéressé par votre veste.",
                  false,
                ),
                _buildBubble(
                  context,
                  "Bonjour ! Oui, elle est toujours disponible.",
                  true,
                ),
              ],
            ),
          ),

          // BARRE DES SUGGESTIONS (Messages préenregistrés du cahier des charges)
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: quickReplies.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ActionChip(
                    backgroundColor: Colors.grey[100],
                    side: BorderSide(color: Colors.grey[300]!),
                    label: Text(
                      quickReplies[index],
                      style: TextStyle(
                        color: Constant.primaireColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () {
                      // Action à déclencher pour envoyer directement le texte sélectionné
                    },
                  ),
                );
              },
            ),
          ),

          // Zone de saisie classique du message en bas
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Écrire un message...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Constant.primaireColor,
                    child: const Icon(
                      LucideIcons.send,
                      color: Colors.white,
                      size: 18,
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
}

// Helper pour les bulles de discussion
Widget _buildBubble(BuildContext context, String text, bool isMe) {
  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? Constant.primaireColor : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 0),
          bottomRight: Radius.circular(isMe ? 0 : 16),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black87,
          fontSize: 15,
        ),
      ),
    ),
  );
}
