import 'package:dealz/screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:dealz/_base/constant.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  // Liste fictive des discussions en cours
  final List<Map<String, dynamic>> chatList = [
    {
      "name": "Modibo Diarra",
      "lastMessage": "Est-ce que le prix est négociable ?",
      "time": "14:32",
      "unreadCount": 2,
      "productImage": "https://via.placeholder.com/50",
      "isOnline": true,
    },
    {
      "name": "Fatoumata Coulibaly",
      "lastMessage": "D'accord, on se donne rendez-vous à l'ACI 2000.",
      "time": "Hier",
      "unreadCount": 0,
      "productImage": "https://via.placeholder.com/50",
      "isOnline": false,
    },
    {
      "name": "Mamadou Touré",
      "lastMessage": "L'objet est toujours disponible ?",
      "time": "15 Mai",
      "unreadCount": 0,
      "productImage": "https://via.placeholder.com/50",
      "isOnline": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.check_check, color: Colors.black54),
            onPressed: () {
              // Tout marquer comme lu
            },
          ),
        ],
      ),
      body: chatList.isEmpty
          ? _buildEmptyMessages()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                final chat = chatList[index];
                return _buildChatTile(chat);
              },
            ),
    );
  }

  // Widget d'une ligne de discussion (Conversation)
  Widget _buildChatTile(Map<String, dynamic> chat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          // Naviguer vers les détails de la conversation (ChatDetailScreen)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(userName: chat['name']),
            ),
          );
        },
        // Avatar utilisateur avec badge en ligne/hors ligne
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey[200],
              child: Icon(LucideIcons.user, color: Colors.grey[400]),
            ),
            if (chat['isOnline'])
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        // Nom et aperçu du dernier message
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              chat['name'],
              style: TextStyle(
                fontWeight: chat['unreadCount'] > 0
                    ? FontWeight.bold
                    : FontWeight.w600,
                fontSize: 15,
              ),
            ),
            Text(
              chat['time'],
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  chat['lastMessage'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: chat['unreadCount'] > 0
                        ? Colors.black87
                        : Colors.grey[600],
                    fontSize: 13,
                    fontWeight: chat['unreadCount'] > 0
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Petite vignette du produit concerné par la discussion à droite
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  chat['productImage'],
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[100],
                    child: const Icon(
                      LucideIcons.package,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Badge de messages non lus si nécessaire
        trailing: chat['unreadCount'] > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Constant.primaireColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  chat['unreadCount'].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : const Icon(
                LucideIcons.chevron_right,
                size: 16,
                color: Colors.grey,
              ),
      ),
    );
  }

  // Écran si aucune discussion
  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.message_square, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            "Aucune discussion pour le moment",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
