# Guía de Configuración y Uso de Gemini API

## 📋 Resumen

Esta guía explica cómo está configurada la integración con Gemini API para el sistema de chat con IAs en LearnMate.

## 🔧 Configuración

### 1. API Key de Gemini

La API key está configurada en `lib/config/api_config.dart`:

```dart
static const String geminiApiKey = 'AIzaSyBv4_k52VxHNTrdkI24y3YlljHwAgEI5L4';
static const String geminiModel = 'gemini-pro';
```

**⚠️ IMPORTANTE**: Para producción, considera:
- Usar variables de entorno
- Almacenar la API key de forma segura (no en el código)
- Rotar la API key periódicamente
- Configurar restricciones de API en Google Cloud Console

### 2. Dependencias

El paquete `google_generative_ai` ya está agregado en `pubspec.yaml`:

```yaml
dependencies:
  google_generative_ai: ^0.2.2
```

## 📁 Estructura de Archivos

```
learn_mate/lib/
├── config/
│   └── api_config.dart          # Configuración de API key
├── models/
│   ├── tipo_ia.dart             # Modelo para tipos de IA
│   └── mensaje.dart             # Modelo para mensajes
└── services/
    ├── gemini_service.dart      # Servicio para interactuar con Gemini
    └── chat_service.dart        # Servicio que integra Gemini + Supabase
```

## 🚀 Uso Básico

### 1. Inicializar el Servicio de Chat

```dart
import 'package:learn_mate/services/chat_service.dart';

final chatService = ChatService();
```

### 2. Obtener Configuración de un Tipo de IA

```dart
// Obtener configuración de Kora (emocional)
final tipoIA = await chatService.obtenerTipoIA('emocional');

if (tipoIA != null) {
  print('Nombre: ${tipoIA.nombre}');
  print('Color: ${tipoIA.colorPrimario}');
  print('Prompt: ${tipoIA.promptBase}');
}
```

### 3. Obtener Historial de Mensajes

```dart
final mensajes = await chatService.obtenerMensajes(
  usuarioId: 'uuid-del-usuario',
  tipoIA: 'emocional',
  limite: 50, // Opcional: límite de mensajes
);

for (final mensaje in mensajes) {
  print('${mensaje.role}: ${mensaje.mensaje}');
}
```

### 4. Enviar un Mensaje y Obtener Respuesta

```dart
// Información del usuario (opcional pero recomendado)
final informacionUsuario = {
  'nombre': 'Juan',
  'apellido': 'Pérez',
  'carrera': 'Ingeniería de Sistemas',
  'semestre': 8,
};

// Enviar mensaje
final resultado = await chatService.enviarMensaje(
  usuarioId: 'uuid-del-usuario',
  tipoIA: 'emocional', // o 'academica'
  mensajeUsuario: 'Hola, ¿cómo estás?',
  informacionUsuario: informacionUsuario,
);

// El resultado contiene ambos mensajes
final mensajeUsuario = resultado['usuario'];
final mensajeIA = resultado['ia'];

print('Usuario: ${mensajeUsuario.mensaje}');
print('IA: ${mensajeIA.mensaje}');
```

### 5. Usar GeminiService Directamente

Si necesitas más control sobre la generación de respuestas:

```dart
import 'package:learn_mate/services/gemini_service.dart';

final geminiService = GeminiService();

// Configurar prompt base
final tipoIA = await chatService.obtenerTipoIA('emocional');
if (tipoIA != null) {
  geminiService.configurarPromptBase(tipoIA);
}

// Generar respuesta
final respuesta = await geminiService.generarRespuesta(
  tipoIA: 'emocional',
  mensajes: historialMensajes,
  mensajeUsuario: '¿Cómo puedo manejar el estrés?',
  informacionUsuario: informacionUsuario,
);

print(respuesta);
```

## 🎯 Tipos de IA Disponibles

### Kora (emocional)
- **Código**: `'emocional'`
- **Propósito**: Bienestar emocional, gestión del estrés, ansiedad, motivación
- **Estilo**: Empático, comprensivo, cálido
- **Colores**: Índigo (#6366F1) y Púrpura (#8B5CF6)

### Kora Pro (académica)
- **Código**: `'academica'`
- **Propósito**: Rendimiento académico, hábitos de estudio, productividad
- **Estilo**: Profesional, práctico, estructurado
- **Colores**: Verde (#10B981) y Verde Oscuro (#059669)
- **Carreras soportadas**: Medicina, Ingeniería de Software

## 📊 Modelo de Datos

### TipoIA
```dart
class TipoIA {
  final String id;
  final String codigo;        // 'emocional' o 'academica'
  final String nombre;        // 'Kora' o 'Kora Pro'
  final String? descripcion;
  final String? avatarUrl;
  final String colorPrimario;
  final String colorSecundario;
  final String? promptBase;
  final bool activo;
  final int orden;
  // ...
}
```

### Mensaje
```dart
class Mensaje {
  final String id;
  final String usuarioId;
  final String tipoIA;        // 'emocional' o 'academica'
  final String role;          // 'user' o 'ia'
  final String mensaje;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  // ...
}
```

## 🔐 Seguridad

### Restricciones de API Key (Recomendado)

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto
3. Ve a "APIs & Services" > "Credentials"
4. Edita tu API key
5. Configura restricciones:
   - **Application restrictions**: Restringir por app (Android/iOS)
   - **API restrictions**: Permitir solo "Generative Language API"

### Variables de Entorno (Para Producción)

En lugar de hardcodear la API key, considera usar:

```dart
// lib/config/api_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

static String get geminiApiKey {
  return dotenv.env['GEMINI_API_KEY'] ?? '';
}
```

Y crear un archivo `.env`:
```
GEMINI_API_KEY=AIzaSyBv4_k52VxHNTrdkI24y3YlljHwAgEI5L4
```

## 🐛 Manejo de Errores

El servicio maneja errores automáticamente:

```dart
try {
  final resultado = await chatService.enviarMensaje(
    usuarioId: usuarioId,
    tipoIA: 'emocional',
    mensajeUsuario: 'Hola',
  );
} catch (e) {
  print('Error: $e');
  // El servicio ya tiene respuestas de fallback
}
```

## 📝 Ejemplo Completo

```dart
import 'package:learn_mate/services/chat_service.dart';
import 'package:learn_mate/models/user.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<Mensaje> _mensajes = [];
  bool _isLoading = false;

  List<Mensaje> get mensajes => _mensajes;
  bool get isLoading => _isLoading;

  Future<void> cargarMensajes(String usuarioId, String tipoIA) async {
    try {
      _isLoading = true;
      notifyListeners();

      _mensajes = await _chatService.obtenerMensajes(
        usuarioId: usuarioId,
        tipoIA: tipoIA,
      );
    } catch (e) {
      print('Error al cargar mensajes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> enviarMensaje({
    required String usuarioId,
    required String tipoIA,
    required String mensaje,
    User? usuario,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Preparar información del usuario
      Map<String, dynamic>? informacionUsuario;
      if (usuario != null) {
        informacionUsuario = {
          'nombre': usuario.nombre,
          'apellido': usuario.apellido,
          'carrera': usuario.carrera,
          'semestre': usuario.semestre,
        };
      }

      // Enviar mensaje
      final resultado = await _chatService.enviarMensaje(
        usuarioId: usuarioId,
        tipoIA: tipoIA,
        mensajeUsuario: mensaje,
        informacionUsuario: informacionUsuario,
      );

      // Agregar mensajes a la lista
      _mensajes.add(resultado['usuario']!);
      _mensajes.add(resultado['ia']!);
    } catch (e) {
      print('Error al enviar mensaje: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## 🔄 Próximos Pasos

1. ✅ Configuración de API key completada
2. ✅ Modelos de datos creados
3. ✅ Servicios implementados
4. ⏳ Crear Provider para el estado del chat
5. ⏳ Crear interfaz de usuario del chat
6. ⏳ Integrar con las pantallas existentes

## 📚 Referencias

- [Google Generative AI SDK](https://pub.dev/packages/google_generative_ai)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)

