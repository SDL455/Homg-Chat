import '../../core/config/app_config.dart';
import 'chat_repository.dart';
import 'chat_repository_memory.dart';
import 'chat_repository_firebase.dart';

class ChatRepoFactory {
  static IChatRepository build() {
    return useFirebase ? ChatRepositoryFirebase() : ChatRepositoryMemory();
  }
}
