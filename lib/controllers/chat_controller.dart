import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatController extends GetxController {
  final supabase = Supabase.instance.client;

  Future<String> getOrCreateRoom(String productId, String sellerId) async {
    try {
      final myId = supabase.auth.currentUser!.id;

      final existingRoom = await supabase
          .from('chat_rooms')
          .select()
          .eq('buyer_id', myId)
          .eq('seller_id', sellerId)
          .maybeSingle();

      if (existingRoom != null) {
        await supabase
            .from('chat_rooms')
            .update({
              'last_product_id': productId,
              'last_message_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', existingRoom['id']);
        return existingRoom['id'];
      } else {
        final newRoom = await supabase
            .from('chat_rooms')
            .insert({
              'buyer_id': myId,
              'seller_id': sellerId,
              'last_product_id': productId,
              'last_message_at': DateTime.now().toUtc().toIso8601String(),
            })
            .select()
            .single();
        return newRoom['id'];
      }
    } catch (e) {
      debugPrint("GetOrCreateRoom Error: $e");
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getMessages(String roomId) {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: false);
  }

  Future<void> deleteMessage(dynamic messageId) async {
    try {
      await supabase.from('messages').delete().eq('id', messageId);
    } catch (e) {
      debugPrint("Delete Message Error: $e");
    }
  }

  Future<void> addReaction(dynamic messageId, String emoji) async {
    try {
      final int id = int.parse(messageId.toString());
      await supabase
          .from('messages')
          .update({
            'reactions': [emoji],
          })
          .eq('id', id);
    } catch (e) {
      debugPrint("Reaction Error: $e");
    }
  }

  Future<void> sendMessage(
    String roomId,
    String content, {
    dynamic replyId,
  }) async {
    if (content.trim().isEmpty) return;

    try {
      final myId = supabase.auth.currentUser!.id;

      final insertedMessage = await supabase
          .from('messages')
          .insert({
            'room_id': roomId,
            'sender_id': myId,
            'content': content.trim(),
            'reply_to': replyId,
            'is_read': false,
          })
          .select()
          .single();

      await supabase
          .from('chat_rooms')
          .update({'last_message_at': insertedMessage['created_at']})
          .eq('id', roomId);
    } catch (e) {
      debugPrint("Send Message Error: $e");
    }
  }
}
