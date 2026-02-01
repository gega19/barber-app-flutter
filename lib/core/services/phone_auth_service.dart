import 'package:firebase_auth/firebase_auth.dart';
import 'package:barber_app/core/utils/logger.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Envía el código SMS al número proporcionado.
  ///
  /// [phoneNumber] debe estar en formato E.164 (ej: +584141234567).
  /// [codeSent] callback cuando el SMS ha sido enviado. Retorna verificationId y resendToken.
  /// [verificationCompleted] callback para autoverificación (Android).
  /// [verificationFailed] callback para errores.
  /// [codeAutoRetrievalTimeout] callback para timeout de autoverificación.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(PhoneAuthCredential credential) verificationCompleted,
    required Function(FirebaseAuthException e) verificationFailed,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    try {
      appLogger.d('Iniciando verificación de teléfono para: $phoneNumber');
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) {
          appLogger.i('Verificación automática completada');
          verificationCompleted(credential);
        },
        verificationFailed: (e) {
          appLogger.e(
            'Error en verificación de teléfono: ${e.code} - ${e.message}',
          );
          verificationFailed(e);
        },
        codeSent: (verificationId, resendToken) {
          appLogger.i('Código SMS enviado. ID: $verificationId');
          codeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          appLogger.d('Timeout de autoverificación. ID: $verificationId');
          codeAutoRetrievalTimeout(verificationId);
        },
      );
    } catch (e) {
      appLogger.e('Excepción no controlada en verifyPhoneNumber: $e');
      rethrow;
    }
  }

  /// Verifica el código SMS ingresado por el usuario y retorna una credencial.
  ///
  /// Con esta credencial se puede hacer signIn (verifyCodeAndSignIn) o linkear a una cuenta existente.
  PhoneAuthCredential getCredential({
    required String verificationId,
    required String smsCode,
  }) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  /// Inicia sesión con el código SMS.
  Future<UserCredential> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      appLogger.i('Login telefónico exitoso: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      appLogger.e(
        'Error al iniciar sesión con credencial: ${e.code} - ${e.message}',
      );
      rethrow;
    }
  }
}
