import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // ============================================
  // CONFIGURACIÓN DE URL DEL BACKEND
  // ============================================
  // Para desarrollo local:
  // - Android Emulator: 'http://10.0.2.2:3000'
  // - iOS Simulator: 'http://localhost:3000'
  // - Flutter Web: 'http://localhost:3000'
  // - Dispositivo físico: 'http://TU_IP_LOCAL:3000'
  //
  // IMPORTANTE: Para usar en dispositivo físico:
  // 1. Obtén tu IP local ejecutando: ipconfig (Windows) o ifconfig (Mac/Linux)
  // 2. Busca la IP de tu adaptador Wi-Fi/Ethernet (ej: 192.168.1.100)
  // 3. Asegúrate de que tu celular y PC estén en la misma red Wi-Fi
  // 4. Cambia usePhysicalDevice a true y configura deviceIp con tu IP
  
  // Cambia esto a true cuando uses un dispositivo físico
  static const bool usePhysicalDevice = true;
  
  // IP de tu máquina para dispositivos físicos
  // Obtén tu IP con: ipconfig (Windows) o ifconfig (Mac/Linux)
  // Busca la IP de tu adaptador Wi-Fi (generalmente 192.168.x.x)
  static const String deviceIp = '192.168.80.20'; // Cambia esto por tu IP local
  
  // IP para emuladores Android
  static const String emulatorIp = '10.0.2.2';
  
  // Puerto del backend
  static const int backendPort = 3000;
  
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
  // IMPORTANTE: Para producción, considera usar variables de entorno
  // o almacenar la API key de forma segura (no en el código)
  
  static const String geminiApiKey = 'AIzaSyBv4_k52VxHNTrdkI24y3YlljHwAgEI5L4';
  
  // Modelo de Gemini a usar
  // El servicio probará automáticamente con modelos alternativos si este no funciona
  // IMPORTANTE: Algunos modelos antiguos pueden no estar disponibles en v1
  // Modelos recomendados (orden de preferencia):
  // - gemini-2.0-flash: Modelo más reciente y potente (recomendado)
  // - gemini-1.5-flash-latest: Última versión de flash (rápido y económico)
  // - gemini-1.5-pro-latest: Última versión de pro (más potente)
  // - gemini-1.5-flash: Versión estándar de flash
  // - gemini-1.5-pro: Versión estándar de pro
  static const String geminiModel = 'gemini-2.0-flash';

  // ============================================
  // CONFIGURACIÓN DE SUPABASE
  // ============================================
  // IMPORTANTE: Reemplaza estas URLs con tus credenciales de Supabase
  // Puedes encontrarlas en: https://app.supabase.com/project/_/settings/api
  
  // TODO: Reemplaza con tu URL de Supabase
  static const String supabaseUrl = 'https://mhfsljxpccyedteobmbb.supabase.co'; // Ejemplo: 'https://xxxxx.supabase.co'
  
  // TODO: Reemplaza con tu anon key de Supabase
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1oZnNsanhwY2N5ZWR0ZW9ibWJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3NzYyOTYsImV4cCI6MjA3NTM1MjI5Nn0.N7-ziu_E9JOumetGTwnbIexCrm78kHQ7K-IiTYBzToU'; // Ejemplo: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
}
