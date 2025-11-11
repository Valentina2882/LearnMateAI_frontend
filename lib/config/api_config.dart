import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
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
