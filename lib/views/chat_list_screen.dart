import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';
import '../controllers/auth_controller.dart';
import 'chat_detail_screen.dart';

import 'login_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final supabase = Supabase.instance.client;
  final AuthController authController = Get.find<AuthController>();
  String searchQuery = "";

  late Stream<List<Map<String, dynamic>>> _chatListStream;

  @override
  void initState() {
    super.initState();

    if (authController.isLoggedIn.value) {
      _initStream();
    }
  }

  void _initStream() {
    _chatListStream = supabase
        .from('chat_list_view')
        .stream(primaryKey: ['room_id']);
  }

  Future<void> _deleteConversation(String roomId) async {
    try {
      await supabase.from('chat_rooms').delete().eq('id', roomId);
      if (mounted) {
        setState(() {
          _initStream();
        });
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  DateTime _parseForSorting(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return DateTime.now();
    try {
      String normalized = timeStr.replaceAll(' ', 'T');
      if (!normalized.endsWith('Z') && !normalized.contains('+')) {
        int tIndex = normalized.indexOf('T');
        if (tIndex != -1 && !normalized.substring(tIndex).contains('-')) {
          normalized += 'Z';
        } else if (tIndex == -1) {
          normalized += 'Z';
        }
      }
      return DateTime.parse(normalized);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        theme.textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black87);
    final myId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chats",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        bottom: authController.isLoggedIn.value
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    onChanged: (val) =>
                        setState(() => searchQuery = val.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: "Search name...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: Obx(() {
          if (!authController.isLoggedIn.value) {
            return _buildLoginRequiredState(context, textColor);
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() => _initStream()),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatListStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.network(
                              'https://raw.githubusercontent.com/NotCapable1o/lottie/main/Chat/emptyInbox.json',
                              height: 200,
                              width: 200,
                              repeat: true,
                              frameRate: FrameRate.max,
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              "No conversations found.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                var rooms = snapshot.data!.where((r) {
                  final name =
                      (r['buyer_id'] == myId
                          ? r['seller_name']
                          : r['buyer_name']) ??
                      "";
                  if (searchQuery.isEmpty) return true;
                  return name.toString().toLowerCase().contains(searchQuery);
                }).toList();

                rooms.sort((a, b) {
                  DateTime timeA = _parseForSorting(
                    a['last_message_at']?.toString(),
                  );
                  DateTime timeB = _parseForSorting(
                    b['last_message_at']?.toString(),
                  );
                  return timeB.compareTo(timeA);
                });

                if (rooms.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 300,
                        child: Center(
                          child: Text("No matching conversations found."),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: rooms.length,
                  itemExtent: 76.0,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final bool iAmBuyer = room['buyer_id'] == myId;
                    final String name =
                        (iAmBuyer ? room['seller_name'] : room['buyer_name']) ??
                        "User";
                    final String? avatar = iAmBuyer
                        ? room['seller_avatar']
                        : room['buyer_avatar'];
                    final bool isOnline =
                        (iAmBuyer
                            ? room['seller_online']
                            : room['buyer_online']) ??
                        false;
                    final int unread = room['unread_count'] ?? 0;

                    return ListTile(
                      onTap: () => Get.to(
                        () => ChatDetailScreen(
                          roomId: room['room_id'],
                          otherUserName: name,
                        ),
                      ),
                      onLongPress: () =>
                          _showDeleteConfirm(room['room_id'], name),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blueAccent,
                            backgroundImage:
                                (avatar != null && avatar.isNotEmpty)
                                ? NetworkImage(avatar)
                                : null,
                            child: (avatar == null || avatar.isEmpty)
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          if (isOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: unread > 0
                              ? FontWeight.w900
                              : FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        room['last_message_snippet'] ?? "No messages",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: unread > 0
                              ? Colors.lightBlueAccent
                              : Colors.grey,
                          fontWeight: unread > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: unread > 0
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "$unread",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoginRequiredState(BuildContext context, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://raw.githubusercontent.com/NotCapable1o/lottie/main/Chat/chatLocked.json',
            height: 200,
            width: 200,
            repeat: true,
            frameRate: FrameRate.max,
          ),
          const SizedBox(height: 24),
          Text(
            "Chat is Locked",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Please login to see your conversations",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const LoginScreen()),
            icon: const Icon(Icons.login, color: Colors.greenAccent),
            label: const Text(
              "Login / Register",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(String id, String name) {
    Get.defaultDialog(
      title: "Delete Chat?",
      middleText: "Remove all messages with $name?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _deleteConversation(id);
        Get.back();
      },
    );
  }
}
