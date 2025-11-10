import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/complete_profile_screen.dart';

class ProfileHelper {
  // Verificar si el perfil está completo
  static bool isProfileCompleted(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    return user?.isProfileCompleted ?? false;
  }

  // Mostrar modal de completar perfil
  static Future<bool> showCompleteProfileModal(
    BuildContext context, {
    VoidCallback? onComplete,
  }) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompleteProfileScreen(
        isModal: true,
        onComplete: onComplete,
      ),
    );
    
    // Verificar si el perfil se completó después de cerrar el modal
    // El AuthProvider actualiza el usuario automáticamente
    return isProfileCompleted(context);
  }

  // Verificar y mostrar modal si es necesario
  static Future<bool> checkAndShowCompleteProfile(
    BuildContext context, {
    VoidCallback? onComplete,
  }) async {
    if (!isProfileCompleted(context)) {
      await showCompleteProfileModal(
        context,
        onComplete: onComplete,
      );
      
      // Verificar nuevamente después de completar
      // El perfil se actualiza automáticamente en el callback
      return isProfileCompleted(context);
    }
    return true;
  }
}

