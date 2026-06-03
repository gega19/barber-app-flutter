import 'package:google_sign_in/google_sign_in.dart';
import '../constants/app_constants.dart';

/// Handles Google Sign-In and returns an ID token for backend verification.
class GoogleAuthService {
  GoogleSignIn? _googleSignIn;

  GoogleSignIn get _client {
    _googleSignIn ??= GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: AppConstants.googleWebClientId.isNotEmpty
          ? AppConstants.googleWebClientId
          : null,
    );
    return _googleSignIn!;
  }

  Future<String> getIdToken() async {
    if (AppConstants.googleWebClientId.isEmpty) {
      throw Exception(
        'Google Sign-In no está configurado. Define GOOGLE_WEB_CLIENT_ID.',
      );
    }

    final account = await _client.signIn();
    if (account == null) {
      throw Exception('Inicio de sesión con Google cancelado');
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'No se pudo obtener el token de Google. Verifica la configuración OAuth.',
      );
    }

    return idToken;
  }

  Future<void> signOut() async {
    await _client.signOut();
  }
}
