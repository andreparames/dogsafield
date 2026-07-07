import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> submit(String message) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await Supabase.instance.client.from('feedback').insert({
      'user_id': user.id,
      'message': message,
    });
  }
}

final feedbackProvider = NotifierProvider<FeedbackNotifier, void>(
  FeedbackNotifier.new,
);
