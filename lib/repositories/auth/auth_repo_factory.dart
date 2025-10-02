import '../../core/config/app_config.dart';
import 'auth_repository.dart';
import 'auth_repository_memory.dart';
import 'auth_repository_firebase.dart';

class AuthRepoFactory {
  static IAuthRepository build() {
    return useFirebase ? AuthRepositoryFirebase() : AuthRepositoryMemory();
  }
}
