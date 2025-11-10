# LearnMate Mobile App 📱

Aplicación móvil Flutter para el sistema de gestión académica LearnMate. Permite a los estudiantes universitarios gestionar sus materias, horarios, exámenes, bienestar emocional y chatear con inteligencias artificiales especializadas.

## 📋 Tabla de Contenidos

- [Descripción](#descripción)
- [Características Principales](#características-principales)
- [Tecnologías Utilizadas](#tecnologías-utilizadas)
- [Requisitos Previos](#requisitos-previos)
- [Instalación](#instalación)
- [Configuración](#configuración)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Arquitectura](#arquitectura)
- [Funcionalidades](#funcionalidades)
- [Screens](#screens)
- [Servicios](#servicios)
- [Providers](#providers)
- [Integración con Backend](#integración-con-backend)
- [Integración con Gemini AI](#integración-con-gemini-ai)
- [Integración con Supabase](#integración-con-supabase)
- [Ejecución](#ejecución)
- [Build y Despliegue](#build-y-despliegue)
- [Troubleshooting](#troubleshooting)

## 📖 Descripción

LearnMate es una aplicación móvil desarrollada en Flutter que ayuda a los estudiantes universitarios a:

- Gestionar sus materias y horarios académicos
- Registrar y hacer seguimiento de exámenes y evaluaciones
- Realizar cuestionarios de bienestar emocional (PHQ-9, GAD-7, ISI)
- Gestionar contactos de emergencia
- Chatear con inteligencias artificiales especializadas:
  - **Kora**: Asistente de bienestar emocional
  - **Kora Pro**: Asistente de rendimiento académico
- Visualizar estadísticas académicas y de bienestar

## ✨ Características Principales

### 🎓 Gestión Académica
- **Materias**: Crear, editar y eliminar materias
- **Horarios**: Gestionar horarios semestrales
- **Exámenes**: Registrar exámenes con notas y ponderaciones
- **Estadísticas**: Visualizar estadísticas académicas con gráficos

### 💚 Bienestar Estudiantil
- **Cuestionarios**: Realizar cuestionarios de salud mental (PHQ-9, GAD-7, ISI)
- **Resultados**: Ver historial de resultados de cuestionarios
- **Contactos de Emergencia**: Gestionar contactos de emergencia personales y nacionales
- **Estadísticas de Bienestar**: Visualizar tendencias de bienestar

### 🤖 Chat con Inteligencias Artificiales
- **Kora (Bienestar Emocional)**: Chat para apoyo emocional y gestión del estrés
- **Kora Pro (Rendimiento Académico)**: Chat para consejos académicos y hábitos de estudio
- **Historial Persistente**: Conversaciones guardadas en Supabase
- **Detección de Crisis**: Sistema de detección de crisis con respuestas de apoyo inmediato

### 👤 Gestión de Perfil
- Registro e inicio de sesión
- Perfil de usuario completo
- Configuración de sistema de calificación (5, 10, 100)
- Actualización de información personal

## 🛠 Tecnologías Utilizadas

### Framework
- **Flutter** (SDK ^3.9.2): Framework de desarrollo multiplataforma
- **Dart**: Lenguaje de programación

### Estado y Gestión de Datos
- **Provider** (^6.1.2): Gestión de estado reactiva
- **Shared Preferences** (^2.3.2): Almacenamiento local

### Backend y APIs
- **HTTP** (^1.5.0): Cliente HTTP para comunicación con backend
- **Supabase Flutter** (^2.10.3): Cliente de Supabase para chat y mensajería

### Inteligencia Artificial
- **Google Generative AI** (^0.4.7): Integración con Gemini AI

### UI y Visualización
- **FL Chart** (^0.69.0): Gráficos y visualización de datos
- **Material Design 3**: Diseño moderno y responsive
- **Cupertino Icons** (^1.0.8): Iconos iOS

### Utilidades
- **URL Launcher** (^6.2.5): Abrir URLs y contactos de emergencia

## 📦 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- **Flutter SDK** (3.9.2 o superior)
- **Dart SDK** (incluido con Flutter)
- **Android Studio** o **VS Code** con extensiones de Flutter
- **Android SDK** (para Android)
- **Xcode** (para iOS, solo en macOS)
- **Git**

### Verificar Instalación

```bash
flutter doctor
```

Este comando verificará que todo esté correctamente instalado.

## 🚀 Instalación

1. **Clonar el repositorio**

```bash
git clone <repository-url>
cd learn_mate
```

2. **Instalar dependencias**

```bash
flutter pub get
```

3. **Configurar la aplicación**

Edita el archivo `lib/config/api_config.dart` con tus credenciales (ver [Configuración](#configuración)).

4. **Ejecutar la aplicación**

```bash
flutter run
```

## ⚙️ Configuración

### Configuración del Backend

Edita el archivo `lib/config/api_config.dart`:

```dart
// Configuración para dispositivo físico
static const bool usePhysicalDevice = true;
static const String deviceIp = 'TU_IP_LOCAL'; // Tu IP local
static const int backendPort = 3000;

// Configuración para emulador Android
static const String emulatorIp = '10.0.2.2';
```

**Para dispositivo físico:**
1. Obtén tu IP local: `ipconfig` (Windows) o `ifconfig` (Mac/Linux)
2. Asegúrate de que tu dispositivo y PC estén en la misma red Wi-Fi
3. Cambia `deviceIp` con tu IP local

**Para emulador Android:**
- Usa `10.0.2.2` para acceder a `localhost` de tu máquina host
- Cambia `usePhysicalDevice` a `false`

### Configuración de Gemini AI

En `lib/config/api_config.dart`:

```dart
static const String geminiApiKey = 'TU_API_KEY_DE_GEMINI';
static const String geminiModel = 'gemini-2.0-flash';
```

**Obtener API Key de Gemini:**
1. Ve a [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Crea una nueva API key
3. Copia la clave y pégala en `geminiApiKey`

### Configuración de Supabase

En `lib/config/api_config.dart`:

```dart
static const String supabaseUrl = 'TU_SUPABASE_URL';
static const String supabaseAnonKey = 'TU_SUPABASE_ANON_KEY';
```

**Obtener Credenciales de Supabase:**
1. Ve a [Supabase Dashboard](https://app.supabase.com)
2. Selecciona tu proyecto
3. Ve a **Settings** > **API**
4. Copia la **URL** y la **anon key**

## 📁 Estructura del Proyecto

```
learn_mate/
├── lib/
│   ├── config/              # Configuración de la app
│   │   ├── api_config.dart  # URLs y API keys
│   │   └── app_colors.dart  # Colores de la app
│   ├── models/              # Modelos de datos
│   │   ├── user.dart
│   │   ├── materia.dart
│   │   ├── examen.dart
│   │   ├── horario.dart
│   │   ├── bienestar.dart
│   │   ├── mensaje.dart
│   │   ├── tipo_ia.dart
│   │   └── ...
│   ├── providers/           # Providers de estado
│   │   ├── auth_provider.dart
│   │   ├── examenes_provider.dart
│   │   ├── horarios_provider.dart
│   │   ├── bienestar_provider.dart
│   │   └── kora_ia_provider.dart
│   ├── screens/             # Pantallas de la app
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── examenes_screen.dart
│   │   ├── horarios_screen.dart
│   │   ├── bienestar_screen.dart
│   │   ├── kora_ia_screen.dart
│   │   └── ...
│   ├── services/            # Servicios de negocio
│   │   ├── auth_service.dart
│   │   ├── examenes_service.dart
│   │   ├── materias_service.dart
│   │   ├── horarios_service.dart
│   │   ├── bienestar_service.dart
│   │   ├── chat_service.dart
│   │   └── gemini_service.dart
│   ├── widgets/             # Widgets reutilizables
│   │   ├── examen_widgets.dart
│   │   └── carrera_search_dropdown.dart
│   ├── utils/               # Utilidades
│   │   └── profile_helper.dart
│   └── main.dart            # Punto de entrada
├── android/                 # Configuración Android
├── ios/                     # Configuración iOS
├── web/                     # Configuración Web
├── windows/                 # Configuración Windows
├── macos/                   # Configuración macOS
├── linux/                   # Configuración Linux
├── pubspec.yaml             # Dependencias
└── README.md
```

## 🏗 Arquitectura

### Patrón de Arquitectura

La aplicación utiliza el patrón **Provider** para la gestión de estado y una arquitectura en capas:

```
┌─────────────────────────────────────┐
│         Screens (UI)                │
│  (Pantallas y widgets de UI)        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Providers (Estado)             │
│  (Gestión de estado reactiva)       │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Services (Lógica)              │
│  (Comunicación con APIs)            │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Models (Datos)                 │
│  (Estructuras de datos)             │
└─────────────────────────────────────┘
```

### Flujo de Datos

1. **UI (Screens)**: Las pantallas muestran la UI y responden a interacciones del usuario
2. **Providers**: Los providers gestionan el estado y notifican cambios a la UI
3. **Services**: Los services manejan la lógica de negocio y comunicación con APIs
4. **Models**: Los models definen la estructura de datos

## 🎯 Funcionalidades

### Autenticación
- **Registro**: Crear nueva cuenta con email y contraseña
- **Login**: Iniciar sesión con credenciales
- **Perfil**: Ver y editar información del perfil
- **Completar Perfil**: Completar información académica (carrera, semestre, sistema de calificación)

### Gestión de Materias
- **Listar Materias**: Ver todas las materias del usuario
- **Crear Materia**: Agregar nueva materia con código, créditos, profesor, etc.
- **Editar Materia**: Modificar información de una materia
- **Eliminar Materia**: Eliminar una materia
- **Buscar Materias**: Buscar materias por nombre o código

### Gestión de Horarios
- **Listar Horarios**: Ver todos los horarios semestrales
- **Crear Horario**: Crear nuevo horario con fechas de inicio y fin
- **Editar Horario**: Modificar información de un horario
- **Eliminar Horario**: Eliminar un horario
- **Materias de Horario**: Ver y gestionar materias asociadas a un horario

### Gestión de Exámenes
- **Listar Exámenes**: Ver todos los exámenes con filtros
- **Crear Examen**: Registrar nuevo examen con tipo, fecha, nota, ponderación
- **Editar Examen**: Modificar información de un examen
- **Eliminar Examen**: Eliminar un examen
- **Filtros**: Filtrar por materia, estado, tipo, fechas
- **Estadísticas**: Ver estadísticas generales y por materia con gráficos

### Bienestar Estudiantil
- **Cuestionarios**: Realizar cuestionarios PHQ-9, GAD-7, ISI
- **Resultados**: Ver historial de resultados de cuestionarios
- **Estadísticas**: Visualizar estadísticas de bienestar
- **Contactos de Emergencia**: Gestionar contactos personales y ver contactos nacionales

### Chat con IAs
- **Kora (Bienestar Emocional)**: Chat para apoyo emocional
- **Kora Pro (Rendimiento Académico)**: Chat para consejos académicos
- **Historial**: Ver historial de conversaciones
- **Detección de Crisis**: Sistema automático de detección de crisis
- **Respuestas Personalizadas**: Respuestas contextualizadas según el usuario

## 📱 Screens

### Pantallas Principales

1. **LoginScreen**: Pantalla de inicio de sesión
2. **RegisterScreen**: Pantalla de registro
3. **HomeScreen**: Pantalla principal con navegación
4. **ExamenesScreen**: Lista de exámenes
5. **AddEditExamenScreen**: Crear/editar examen
6. **EstadisticasExamenesScreen**: Estadísticas de exámenes
7. **HorariosScreen**: Lista de horarios
8. **AddEditHorarioScreen**: Crear/editar horario
9. **BienestarScreen**: Pantalla de bienestar
10. **CuestionarioScreen**: Realizar cuestionario de bienestar
11. **ContactosEmergenciaScreen**: Gestionar contactos de emergencia
12. **KoraIAScreen**: Chat con Kora (bienestar emocional)
13. **ChatBienestarScreen**: Chat con Kora Pro (rendimiento académico)
14. **ProfileSettingsScreen**: Configuración de perfil
15. **CompleteProfileScreen**: Completar perfil

## 🔧 Servicios

### AuthService
- Maneja autenticación (login, registro)
- Gestión de tokens JWT
- Gestión de perfil de usuario
- Almacenamiento local de sesión

### ExamenesService
- CRUD de exámenes
- Obtención de estadísticas
- Filtrado de exámenes

### MateriasService
- CRUD de materias
- Búsqueda de materias

### HorariosService
- CRUD de horarios
- Gestión de horarios semestrales

### HorariosMateriasService
- Asociar materias con horarios
- Gestión de relaciones

### BienestarService
- Gestión de cuestionarios de bienestar
- Gestión de contactos de emergencia
- Obtención de estadísticas de bienestar

### ChatService
- Gestión de mensajes con IAs
- Integración con Supabase
- Historial de conversaciones

### GeminiService
- Integración con Google Gemini AI
- Generación de respuestas de IA
- Detección de crisis
- Configuración de prompts

## 🎨 Providers

### AuthProvider
- Estado de autenticación
- Información del usuario
- Gestión de sesión

### ExamenesProvider
- Lista de exámenes
- Filtros de exámenes
- Estadísticas

### HorariosProvider
- Lista de horarios
- Horario activo

### BienestarProvider
- Resultados de cuestionarios
- Contactos de emergencia
- Estadísticas de bienestar

### KoraIAProvider
- Tipos de IA disponibles
- Mensajes de chat
- Estado de conversación

## 🔌 Integración con Backend

### Configuración

La aplicación se comunica con el backend NestJS a través de HTTP. La URL base se configura en `lib/config/api_config.dart`.

### Autenticación

1. **Login/Register**: Se envía email y contraseña al backend
2. **Token JWT**: El backend retorna un token JWT
3. **Almacenamiento**: El token se guarda localmente usando SharedPreferences
4. **Headers**: El token se incluye en el header `Authorization: Bearer <token>` en cada request

### Endpoints Utilizados

- `POST /auth/login`: Iniciar sesión
- `POST /auth/register`: Registrar usuario
- `GET /auth/profile`: Obtener perfil
- `PATCH /auth/profile`: Actualizar perfil
- `GET /materias`: Obtener materias
- `POST /materias`: Crear materia
- `GET /examenes`: Obtener exámenes
- `POST /examenes`: Crear examen
- Y más...

## 🤖 Integración con Gemini AI

### Configuración

La aplicación utiliza Google Gemini AI para generar respuestas de las IAs. La API key se configura en `lib/config/api_config.dart`.

### Flujo de Chat

1. **Usuario envía mensaje**: El mensaje se guarda en Supabase
2. **Generación de respuesta**: Se llama a GeminiService con el historial de conversación
3. **Detección de crisis**: Se verifica si hay indicadores de crisis
4. **Respuesta de IA**: Gemini genera una respuesta contextualizada
5. **Guardado**: La respuesta se guarda en Supabase

### Tipos de IA

- **Kora (emocional)**: Prompt especializado en bienestar emocional
- **Kora Pro (académica)**: Prompt especializado en rendimiento académico

### Detección de Crisis

El sistema detecta automáticamente indicadores de crisis en los mensajes y responde con mensajes de apoyo y recursos de ayuda profesional.

## 🗄 Integración con Supabase

### Configuración

Supabase se utiliza para almacenar el historial de conversaciones con las IAs. Las credenciales se configuran en `lib/config/api_config.dart` y en `main.dart`.

### Tablas Utilizadas

- **mensajes**: Historial de mensajes de chat
- **tipos_ia**: Configuración de tipos de IA

### Inicialización

Supabase se inicializa en `main.dart` antes de ejecutar la aplicación.

## 🏃 Ejecución

### Desarrollo

```bash
# Ejecutar en modo desarrollo
flutter run

# Ejecutar en modo release
flutter run --release

# Ejecutar en dispositivo específico
flutter run -d <device-id>

# Ver dispositivos disponibles
flutter devices
```

### Hot Reload

Durante el desarrollo, puedes usar hot reload para ver cambios instantáneamente:
- Presiona `r` en la terminal para hot reload
- Presiona `R` para hot restart

### Debugging

```bash
# Ejecutar en modo debug
flutter run --debug

# Ver logs
flutter logs
```

## 📦 Build y Despliegue

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (para Google Play)
flutter build appbundle --release
```

### iOS

```bash
# Build para iOS (solo en macOS)
flutter build ios --release
```

### Web

```bash
# Build para web
flutter build web --release
```

### Windows

```bash
# Build para Windows
flutter build windows --release
```

### macOS

```bash
# Build para macOS (solo en macOS)
flutter build macos --release
```

### Linux

```bash
# Build para Linux
flutter build linux --release
```

## 🔍 Troubleshooting

### Problemas Comunes

#### 1. Error de conexión con el backend

**Problema**: No se puede conectar al backend

**Soluciones**:
- Verifica que el backend esté corriendo
- Verifica la URL en `api_config.dart`
- Para dispositivo físico, verifica que estés en la misma red Wi-Fi
- Para emulador Android, usa `10.0.2.2` en lugar de `localhost`

#### 2. Error de autenticación

**Problema**: Error 401 Unauthorized

**Soluciones**:
- Verifica que el token JWT sea válido
- Verifica que el backend esté configurado correctamente
- Intenta cerrar sesión y volver a iniciar sesión

#### 3. Error con Gemini AI

**Problema**: Error al generar respuestas de IA

**Soluciones**:
- Verifica que la API key de Gemini sea válida
- Verifica que tengas cuota disponible en Google Cloud
- Verifica la conexión a internet

#### 4. Error con Supabase

**Problema**: Error al conectar con Supabase

**Soluciones**:
- Verifica que las credenciales de Supabase sean correctas
- Verifica que Supabase esté inicializado en `main.dart`
- Verifica que las tablas existan en Supabase

#### 5. Dependencias no instaladas

**Problema**: Error al ejecutar `flutter run`

**Soluciones**:
```bash
flutter pub get
flutter clean
flutter pub get
```

#### 6. Problemas con el build

**Problema**: Error al compilar la aplicación

**Soluciones**:
```bash
flutter clean
flutter pub get
flutter run
```

### Logs y Debugging

Para ver logs detallados, los servicios incluyen logging con prefijos:
- `🔐 [AuthService]`: Logs de autenticación
- `📚 [ExamenesService]`: Logs de exámenes
- `🤖 [GeminiService]`: Logs de Gemini AI
- `💬 [ChatService]`: Logs de chat

## 📝 Notas Adicionales

### Seguridad

- **API Keys**: Nunca commitees API keys al repositorio. Usa variables de entorno o archivos de configuración locales.
- **Tokens JWT**: Los tokens se almacenan localmente usando SharedPreferences. Considera usar almacenamiento seguro para producción.
- **HTTPS**: En producción, asegúrate de usar HTTPS para todas las comunicaciones.

### Performance

- **Caching**: Considera implementar caching para datos que no cambian frecuentemente
- **Lazy Loading**: Las listas grandes deberían usar lazy loading
- **Image Optimization**: Optimiza las imágenes antes de incluirlas en la app

### Mejoras Futuras

- Implementar notificaciones push
- Agregar sincronización offline
- Mejorar la UI/UX
- Agregar más tipos de gráficos
- Implementar exportación de datos
- Agregar temas oscuros/claros

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es privado y está bajo licencia UNLICENSED.

## 📞 Soporte

Para soporte, contacta al equipo de desarrollo o abre un issue en el repositorio.

---

**Desarrollado por Valentina2882 con ❤️ para LearnMate**

# LearnMateAI_frontend
