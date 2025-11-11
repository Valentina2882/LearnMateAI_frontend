import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // ============================================
  // CONFIGURACIÓN DE URL DEL BACKEND
  // ============================================
  // Las configuraciones se cargan desde el archivo .env
  // Para desarrollo local:
  // - Android Emulator: 'http://10.0.2.2:3000'
  // - iOS Simulator: 'http://localhost:3000'
  // - Flutter Web: 'http://localhost:3000'
  // - Dispositivo físico: 'http://TU_IP_LOCAL:3000'
  
  // IP para emuladores Android (valor fijo, no necesita .env)
  static const String emulatorIp = '10.0.2.2';
  
  // Obtener configuración desde .env o valores por defecto
  static bool get usePhysicalDevice {
    return dotenv.get('USE_PHYSICAL_DEVICE', fallback: 'true').toLowerCase() == 'true';
  }
  
  static String get deviceIp {
    return dotenv.get('BACKEND_IP', fallback: '10.162.35.200');
  }
  
  static int get backendPort {
    return int.tryParse(dotenv.get('BACKEND_PORT', fallback: '3000')) ?? 3000;
  }
  
  static String get baseUrl {
    // Detectar plataforma y usar la URL apropiada
    if (kIsWeb) {
      // Flutter Web - localhost funciona
      return 'http://localhost:$backendPort';
    } else if (Platform.isAndroid) {
      // Android: usar IP de dispositivo físico o emulador según configuración
      if (usePhysicalDevice) {
        return 'http://$deviceIp:$backendPort';
      } else {
        // Android Emulator necesita usar 10.0.2.2 para acceder a localhost de la máquina host
        return 'http://$emulatorIp:$backendPort';
      }
    } else if (Platform.isIOS) {
      // iOS Simulator - localhost funciona
      // Para dispositivo físico iOS, también usar IP local
      if (usePhysicalDevice) {
        return 'http://$deviceIp:$backendPort';
      } else {
        return 'http://localhost:$backendPort';
      }
    } else {
      // Windows/Linux/Mac desktop - localhost funciona
      return 'http://localhost:$backendPort';
    }
  }

  // ============================================
  // CONFIGURACIÓN DE GEMINI API
  // ============================================
  // Las configuraciones se cargan desde el archivo .env
  
  static String get geminiApiKey {
    return dotenv.get('GEMINI_API_KEY', fallback: '');
  }
  
  static String get geminiModel {
    return dotenv.get('GEMINI_MODEL', fallback: 'gemini-2.0-flash');
  }

  // ============================================
  // CONFIGURACIÓN DE SUPABASE
  // ============================================
  // Las configuraciones se cargan desde el archivo .env
  // Puedes encontrarlas en: https://app.supabase.com/project/_/settings/api
  
  static String get supabaseUrl {
    return dotenv.get('SUPABASE_URL', fallback: '');
  }
  
  static String get supabaseAnonKey {
    return dotenv.get('SUPABASE_KEY', fallback: '');
  }
}
