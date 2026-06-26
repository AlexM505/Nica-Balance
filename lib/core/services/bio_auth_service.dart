import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

class BioAuthService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Verifica si el dispositivo cuenta con hardware biométrico y está configurado
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  /// Dispara el flujo de autenticación nativa
  static Future<bool> authenticate() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: 'Autentícate para acceder a tus finanzas',
        biometricOnly: true,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Seguridad Biométrica',
            signInHint: 'Usa tu huella digital o reconocimiento facial',
            cancelButton: 'Cancelar',
          ),
        ],
      );
    } on PlatformException catch (e) {
      debugPrint("Error de autenticación biométrica: ${e.code} - ${e.message}");
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Método utilitario por si tu UI necesita saber qué tipo de sensor se está usando
  static Future<String> getBiometricTypeLabel() async {
    try {
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      
      if (availableBiometrics.contains(BiometricType.face)) {
        return "Face ID";
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return "Huella Digital";
      }
      return "Biometría";
    } catch (_) {
      return "Biometría";
    }
  }
}