abstract class IAuthRepository {
  Future<String?> currentUserId();
  Future<void> register(String email, String password, String name);
  Future<void> login(String email, String password);
  Future<void> logout();
}
