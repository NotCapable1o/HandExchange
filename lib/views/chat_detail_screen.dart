import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';

class ChatDetailScreen extends StatefulWidget {
  final dynamic roomId;
  final String otherUserName;
  const ChatDetailScreen({
    super.key,
    required this.roomId,
    required this.otherUserName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with WidgetsBindingObserver {
  final supabase = Supabase.instance.client;
  final ChatController _chatController = Get.put(ChatController());
  final _msgController = TextEditingController();

  Map<String, dynamic>? replyingTo;
  dynamic tappedMsgId;

  late Stream<List<Map<String, dynamic>>> _messagesStream;

  RealtimeChannel? _typingChannel;
  bool _isOtherUserTyping = false;
  Timer? _hideTypingTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _setOnlineStatus(true);

    _messagesStream = _chatController.getMessages(widget.roomId);
    _markAsRead();
    _setupTypingListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setOnlineStatus(false);

    _hideTypingTimer?.cancel();
    _typingChannel?.unsubscribe();
    _msgController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setOnlineStatus(true);
    } else {
      _setOnlineStatus(false);
    }
  }

  void _setOnlineStatus(bool isOnline) async {
    final myId = supabase.auth.currentUser?.id;
    if (myId == null) return;
    try {
      await supabase
          .from('profiles')
          .update({'is_online': isOnline})
          .eq('id', myId);
    } catch (e) {
      debugPrint("Status update error: $e");
    }
  }

  void _setupTypingListener() {
    final myId = supabase.auth.currentUser!.id;

    _typingChannel = supabase.channel('room_${widget.roomId}');

    _typingChannel!
        .onBroadcast(
          event: 'typing',
          callback: (payload) {
            final senderId = payload['sender_id'];
            if (senderId != myId) {
              setState(() => _isOtherUserTyping = true);

              _hideTypingTimer?.cancel();
              _hideTypingTimer = Timer(const Duration(seconds: 2), () {
                if (mounted) setState(() => _isOtherUserTyping = false);
              });
            }
          },
        )
        .subscribe();
  }

  void _markAsRead() async {
    final myId = supabase.auth.currentUser!.id;
    try {
      await supabase
          .from('messages')
          .update({'is_read': true})
          .eq('room_id', widget.roomId)
          .eq('is_read', false)
          .neq('sender_id', myId);
    } catch (e) {
      debugPrint("Mark as read error: $e");
    }
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final replyId = replyingTo?['id'];
    setState(() => replyingTo = null);
    _msgController.clear();

    try {
      final insertedMessage = await supabase
          .from('messages')
          .insert({
            'room_id': widget.roomId,
            'sender_id': supabase.auth.currentUser!.id,
            'content': text,
            'reply_to': replyId,
            'is_read': false,
          })
          .select()
          .single();

      await supabase
          .from('chat_rooms')
          .update({'last_message_at': insertedMessage['created_at']})
          .eq('id', widget.roomId);
    } catch (e) {
      debugPrint("Chat Error: $e");
    }
  }

  void _showMessageOptions(Map<String, dynamic> msg, bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ["👍", "❤️", "😂", "😮", "😢", "🙏"].map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        _chatController.addReaction(msg['id'], emoji);
                        Navigator.pop(context);
                      },
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () {
                  setState(() => replyingTo = msg);
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: msg['content']));
                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Message copied!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),

              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    _chatController.deleteMessage(msg['id']);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final myId = supabase.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: StreamBuilder<List<Map<String, dynamic>>>(
          stream: supabase
              .from('chat_list_view')
              .stream(primaryKey: ['room_id'])
              .eq('room_id', widget.roomId),
          builder: (context, snapshot) {
            bool isOnline = false;
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final room = snapshot.data!.first;
              final iAmBuyer = room['buyer_id'] == myId;
              isOnline =
                  (iAmBuyer ? room['seller_online'] : room['buyer_online']) ??
                  false;
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isOnline)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.circle, color: Colors.green, size: 10),
                      SizedBox(width: 4),
                      Text(
                        "Online",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    "Offline",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => setState(() {}),
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _messagesStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());

                    final messages = snapshot.data!;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      bool hasUnread = messages.any(
                        (m) => m['sender_id'] != myId && m['is_read'] == false,
                      );
                      if (hasUnread) {
                        _markAsRead();
                      }
                    });

                    if (messages.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 300,
                            child: Center(child: Text("Say hi!")),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      reverse: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg['sender_id'] == myId;
                        final isRead = msg['is_read'] == true;
                        final msgTime = DateTime.parse(
                          msg['created_at'],
                        ).toLocal();
                        final isTapped = tappedMsgId == msg['id'];

                        return Dismissible(
                          key: Key(msg['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.blue.withOpacity(0.2),
                            child: const Icon(Icons.reply, color: Colors.blue),
                          ),
                          confirmDismiss: (direction) async {
                            setState(() => replyingTo = msg);
                            return false;
                          },
                          child: GestureDetector(
                            onLongPress: () => _showMessageOptions(msg, isMe),
                            onTap: () => setState(
                              () => tappedMsgId = isTapped ? null : msg['id'],
                            ),
                            child: Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 12,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Column(
                                          crossAxisAlignment: isMe
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            if (msg['reply_to'] != null)
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                margin: const EdgeInsets.only(
                                                  bottom: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Text(
                                                  "Replying...",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isMe
                                                    ? Colors.blueAccent
                                                    : Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              child: Wrap(
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.end,
                                                alignment: WrapAlignment.end,
                                                children: [
                                                  Text(
                                                    msg['content'],
                                                    style: TextStyle(
                                                      color: isMe
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    DateFormat(
                                                      'hh:mm a',
                                                    ).format(msgTime),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: isMe
                                                          ? Colors.white70
                                                          : Colors.black54,
                                                    ),
                                                  ),
                                                  if (isMe)
                                                    Icon(
                                                      isRead
                                                          ? Icons.done_all
                                                          : Icons.check,
                                                      color: isRead
                                                          ? Colors.amber
                                                          : Colors.grey,
                                                      size: 16,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (msg['reactions'] != null &&
                                            (msg['reactions'] as List)
                                                .isNotEmpty)
                                          Positioned(
                                            bottom: -10,
                                            left: isMe ? null : 10,
                                            right: isMe ? 10 : null,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                msg['reactions'][0],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (isTapped)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                          right: 4,
                                          left: 4,
                                        ),
                                        child: Text(
                                          isMe
                                              ? (isRead ? "Seen" : "Delivered")
                                              : "Received",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            if (_isOtherUserTyping)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    "Typing...",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyingTo != null)
            ListTile(
              tileColor: Colors.blue.withOpacity(0.1),
              leading: const Icon(Icons.reply, color: Colors.blue),
              title: Text(
                replyingTo!['content'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => replyingTo = null),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  onChanged: (text) {
                    if (text.isNotEmpty) {
                      _typingChannel?.sendBroadcastMessage(
                        event: 'typing',
                        payload: {'sender_id': supabase.auth.currentUser!.id},
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Message...",
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
