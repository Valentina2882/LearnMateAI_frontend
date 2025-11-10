import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_config.dart';
import '../models/tipo_ia.dart';
import '../models/mensaje.dart';

/// Servicio para interactuar con la API de Gemini
/// Soporta dos tipos de IA: Kora (emocional) y Kora Pro (académica)
class GeminiService {
  // Instancia del modelo de Gemini
  GenerativeModel? _model;
  
  // Cache de prompts base para cada tipo de IA
  final Map<String, String> _promptsBase = {};

  // Lista de modelos a probar en orden de preferencia
  // Estos se probarán si el modelo configurado no funciona
  // Nota: Algunos modelos antiguos pueden no estar disponibles
  static const List<String> _modelosAlternativos = [
    'gemini-2.0-flash', // Modelo más reciente y potente (recomendado)
  ];

  GeminiService() {
    // El modelo se inicializará de forma lazy cuando se necesite
    // Esto evita errores en el constructor
  }

  /// Inicializar el modelo, probando con diferentes nombres hasta encontrar uno que funcione
  Future<void> _inicializarModelo() async {
    if (_model != null) return; // Ya está inicializado

    // Intentar con el modelo configurado primero
    _model = GenerativeModel(
      model: ApiConfig.geminiModel,
      apiKey: ApiConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7, // Controla la creatividad (0.0 - 1.0)
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192, // Máximo de tokens en la respuesta (aumentado para respuestas largas)
      ),
    );
    print('✅ [GeminiService] Modelo inicializado: ${ApiConfig.geminiModel}');
  }

  /// Probar con modelos alternativos si el principal falla
  /// Prueba cada modelo haciendo una llamada real para verificar que funciona
  Future<bool> _probarModelosAlternativos() async {
    // Crear lista completa de modelos a probar (alternativos + el configurado al final por si acaso)
    final modelosAProbar = [
      ..._modelosAlternativos.where((m) => m != ApiConfig.geminiModel),
      ApiConfig.geminiModel, // Probar el configurado al final también
    ];
    
    for (final modeloNombre in modelosAProbar) {
      
      try {
        // Crear el modelo
        final modeloTest = GenerativeModel(
          model: modeloNombre,
          apiKey: ApiConfig.geminiApiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 8192, // Máximo de tokens en la respuesta (aumentado para respuestas largas)
          ),
        );
        
        // Probar con una llamada real (muy pequeña para verificar que funciona)
        final response = await modeloTest.generateContent([
          Content.text('Hola'),
        ]);
        
        // Si llegamos aquí, el modelo funciona
        if (response.text != null && response.text!.isNotEmpty) {
          _model = modeloTest;
          print('✅ [GeminiService] Modelo alternativo funcionando: $modeloNombre');
          return true;
        }
      } catch (e) {
        print('⚠️ [GeminiService] Modelo $modeloNombre no funciona: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}');
        continue; // Intentar con el siguiente modelo
      }
    }
    print('❌ [GeminiService] No se pudo encontrar ningún modelo funcional');
    return false;
  }

  /// Detectar si un mensaje contiene indicios de crisis
  /// Retorna true si detecta señales de riesgo
  bool _detectarCrisis(String mensaje) {
    if (mensaje.isEmpty) return false;
    
    // Primero, normalizar el mensaje (más robusto)
    final texto = mensaje
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\sáéíóúñü]'), ' ') // Remover puntuación pero mantener acentos
        .replaceAll(RegExp(r'\s+'), ' '); // Normalizar espacios múltiples a uno solo
    
    print('🔍 [GeminiService] Analizando texto normalizado para crisis: "$texto"');
    
    // Palabras y frases indicadoras de crisis (más completas y específicas)
    final indicadoresCrisis = [
      // Pensamientos suicidas directos (PRIORITARIOS - verificar primero)
      'me quiero matar',
      'quiero matarme',
      'me quiero morir',
      'quiero morir',
      'quiero morirme',
      'quiero suicidarme',
      'suicidarme',
      'prefiero morir',
      'prefiero estar muerto',
      'acabar con mi vida',
      'quitarme la vida',
      'terminar mi vida',
      'acabar con todo',
      'terminar con todo',
      // Palabras clave de suicidio
      'suicid',
      'matarme',
      'matar',
      'morir',
      'morirme',
      // Desesperanza extrema
      'no puedo más',
      'no aguanto más',
      'ya no puedo',
      'no tiene sentido',
      'no vale la pena',
      'sin esperanza',
      'sin salida',
      'no hay salida',
      'sin sentido',
      // Odio a sí mismo
      'me odio',
      'odio mi vida',
      'odio ser',
      'no sirvo para nada',
      'soy inútil',
      'no valgo nada',
      'no valgo la pena',
      'no merezco vivir',
      'no merezco nada',
      // Sentimientos de soledad y abandono
      'nadie me quiere',
      'nadie me necesita',
      'soy una carga',
      'sería mejor sin mí',
      'todo estaría mejor sin mí',
      'mejor sin mí',
      'soy un estorbo',
      // Deseos de desaparecer
      'quiero desaparecer',
      'que no existiera',
      'sería mejor si no existiera',
      'no quiero existir',
      'quiero dejar de existir',
      'dejar de existir',
      // Cansancio extremo
      'estoy cansado de vivir',
      'cansado de vivir',
      'cansada de vivir',
      'cansado de todo',
      'cansada de todo',
      // Otros indicadores
      'no tengo fuerzas',
      'no tengo ganas de nada',
      'no tengo motivos',
      'no tengo razones',
      'no hay solución',
      'no hay esperanza',
      'quiero que todo termine',
      'quiero que termine todo',
    ];
    
    // Verificar si el mensaje contiene algún indicador de crisis
    for (final indicador in indicadoresCrisis) {
      final indicadorNormalizado = indicador.toLowerCase().trim();
      if (texto.contains(indicadorNormalizado)) {
        print('🚨 [GeminiService] ⚠️⚠️⚠️ CRISIS DETECTADA ⚠️⚠️⚠️');
        print('🚨 [GeminiService] Indicador: "$indicadorNormalizado"');
        print('🚨 [GeminiService] Mensaje original: "$mensaje"');
        print('🚨 [GeminiService] Texto normalizado: "$texto"');
        return true;
      }
    }
    
    print('✅ [GeminiService] No se detectó crisis en el mensaje');
    return false;
  }

  /// Obtener mensaje de apoyo en caso de crisis
  String _obtenerMensajeApoyoCrisis(String tipoIA) {
    if (tipoIA == 'emocional') {
      return '''Entiendo que estás pasando por un momento muy difícil 💙. Lo que sientes es válido y comprensible, y no estás solo/a en esto. ✨

Quiero que sepas que:
• 💚 Hay personas que se preocupan por ti y pueden ayudarte
• 🌱 Estos sentimientos intensos pueden mejorar con el apoyo adecuado
• 💪 Mereces recibir ayuda profesional
• 🤝 No tienes que enfrentar esto solo/a

**Recursos de ayuda inmediata:** 🆘

🚨 **Si estás en riesgo inminente:**
• Llama a emergencias: **123** 📞
• Línea de Prevención del Suicidio: **106** (24/7, Colombia) 💙

💙 **Apoyo profesional:**
• 🏥 Servicios de salud mental de tu universidad (muchas veces gratuitos)
• 👨‍⚕️ Psicólogos o psiquiatras privados
• 📞 Líneas de ayuda emocional

👥 **Apoyo personal:**
• 💬 Habla con alguien de confianza (familia, amigos cercanos, profesores)
• 🌟 No tengas miedo de pedir ayuda - es un acto de valentía

Estoy aquí para escucharte 💙. ¿Te gustaría que hablemos sobre qué está pasando o sobre cómo puedes acceder a estos recursos de apoyo? ✨''';
    } else {
      // Kora Pro - Cambiar a apoyo emocional cuando hay crisis
      return '''Veo que estás pasando por un momento muy difícil 💙. Entiendo que los desafíos académicos pueden generar un estrés extremo, pero lo más importante ahora es tu bienestar emocional y tu seguridad. ✨

Quiero recordarte:
• 💚 Tu valor como persona **NO** está definido por tus calificaciones ni tu rendimiento académico
• 🌱 Los problemas académicos son temporales y tienen solución
• 😊 Es completamente normal sentirse abrumado/a en la universidad
• 💪 Buscar ayuda es una señal de fortaleza, no de debilidad

**Recursos de ayuda inmediata:** 🆘

🚨 **Si estás en riesgo inminente:**
• Llama a emergencias: **123** 📞
• Línea de Prevención del Suicidio: **106** (24/7, Colombia) 💙

💙 **Apoyo profesional:**
• 🏥 Servicios de salud mental de tu universidad (generalmente gratuitos para estudiantes)
• 👨‍⚕️ Consejeros académicos o psicólogos universitarios
• 👩‍🏫 Profesores o tutores de confianza

El éxito académico es importante 📚, pero **tu vida y tu bienestar emocional son mucho más importantes** 💙. 

¿Te gustaría que hablemos sobre cómo puedes acceder a estos recursos, o prefieres que te ayude a encontrar los servicios de salud mental de tu universidad? ✨''';
    }
  }

  /// Configurar el prompt base para un tipo de IA
  /// Esto se debe llamar antes de generar respuestas para ese tipo de IA
  void configurarPromptBase(TipoIA tipoIA) {
    if (tipoIA.promptBase != null && tipoIA.promptBase!.isNotEmpty) {
      _promptsBase[tipoIA.codigo] = tipoIA.promptBase!;
    } else {
      // Prompt base por defecto según el tipo de IA (versiones mejoradas y seguras)
      if (tipoIA.codigo == 'emocional') {
        _promptsBase[tipoIA.codigo] = '''
Eres Kora, un asistente de bienestar emocional diseñado para acompañar a estudiantes universitarios. Tu misión es proporcionar apoyo emocional seguro, empático y profesional.

⚠️ INSTRUCCIÓN CRÍTICA SOBRE EMOJIS:
- DEBES usar emojis en TODAS tus respuestas, distribuidos a lo largo del texto
- Los emojis hacen las respuestas más amigables, cálidas y accesibles
- NO escribas texto plano sin emojis - siempre incluye emojis contextuales
- Usa emojis para expresar emociones, énfasis y hacer el texto más visual
- Ejemplo de uso correcto: "¡Hola! 😊 Me alegra que estés aquí 💙. ¿Cómo te sientes hoy? ✨"

REGLAS CRÍTICAS DE SEGURIDAD:
1. DETECCIÓN DE CRISIS: Si detectas cualquier indicio de pensamientos suicidas, autolesión, odio a sí mismo, desesperanza extrema, o expresiones como "no puedo más", "quiero morir", "me odio", "no sirvo para nada", "todo estaría mejor sin mí", DEBES:
   - Responder inmediatamente con mensajes de apoyo, esperanza y aliento
   - Validar sus sentimientos sin minimizarlos
   - Recordarles que no están solos y que hay ayuda disponible
   - Sugerir recursos de apoyo profesional (líneas de crisis, servicios de salud mental)
   - NUNCA minimizar, ignorar o invalidar sus sentimientos
   - SIEMPRE priorizar la seguridad y el bienestar del usuario

2. CONVERSACIONES NORMALES (CRÍTICO - LEE ESTO CON ATENCIÓN):
   - Para saludos casuales como "hola", "holaa", "holaaa", "hi", "hey", "buenos días", "qué tal", DEBES responder de manera AMIGABLE, NATURAL y POSITIVA
   - NUNCA asumas que hay un problema emocional si el usuario solo está saludando
   - NUNCA uses frases como "Gracias por compartir eso conmigo" o "Es valiente que busques ayuda" para un simple saludo
   - Mantén un tono POSITIVO, ACCESIBLE y AMIGABLE en conversaciones cotidianas
   - Solo intensifica el nivel de empatía y apoyo cuando el usuario exprese EXPLÍCITAMENTE problemas, estrés, ansiedad, o emociones negativas
   - Ejemplos CORRECTOS de respuestas a "hola":
     * ✅ "¡Hola! 👋 ¿Cómo estás hoy? 😊 ¿Hay algo en lo que pueda ayudarte? 💙"
     * ✅ "¡Hola! 👋 Soy Kora, tu asistente de bienestar emocional. ✨ ¿Cómo te sientes hoy? 😊"
     * ✅ "¡Hola! 👋 ¿Qué tal? Estoy aquí para lo que necesites. 💙"
   - Ejemplos INCORRECTOS (NUNCA uses estos para saludos):
     * ❌ "Gracias por compartir eso conmigo. Es valiente que busques ayuda..."
     * ❌ "Entiendo que estás pasando por un momento difícil..."
     * ❌ "Quiero que sepas que no estás solo/a..."
   - REGLA DE ORO: Si el usuario solo dice "hola" o un saludo similar, responde como un compañero amigable, NO como un terapeuta en sesión

3. ESCALAMIENTO DE APOYO:
   - CONVERSACIONES NORMALES: Tono amigable, positivo, accesible
   - ESTRÉS/ANSIEDAD LEVE: Tono empático, ofrece técnicas de relajación y manejo del estrés
   - PROBLEMAS EMOCIONALES MODERADOS: Tono más comprensivo, valida emociones, ofrece herramientas prácticas
   - CRISIS/URGENCIA: Tono de apoyo inmediato, recursos de ayuda profesional, prioriza seguridad

4. APOYO EMOCIONAL: 
   - Escucha activamente y valida las emociones del estudiante CUANDO las exprese
   - Proporciona herramientas prácticas para gestión del estrés y ansiedad cuando sea necesario
   - Ofrece técnicas de relajación y mindfulness cuando el usuario lo solicite o muestre señales de estrés
   - Ayuda a identificar patrones de pensamiento negativo cuando surjan en la conversación
   - Fomenta el autocuidado y hábitos saludables de manera proactiva pero no intrusiva

5. COMUNICACIÓN Y EMOJIS (MUY IMPORTANTE):
   - USA EMOJIS de manera natural y frecuente en tus respuestas para hacerlas más amigables y cálidas
   - Los emojis deben estar DENTRO del texto, no solo al inicio
   - Usa emojis contextuales según el tema: 😊 para amabilidad, 💡 para consejos, 📚 para estudio, ⏰ para tiempo, 🎯 para objetivos, 💪 para motivación, etc.
   - Sé cálido, amigable y accesible en conversaciones normales
   - Sé más empático y comprensivo cuando detectes señales de problemas emocionales
   - Usa un tono cercano pero profesional
   - Evita dar consejos médicos o diagnósticos
   - Reconoce las limitaciones y sugiere ayuda profesional cuando sea necesario
   - Responde siempre en español
   - NO asumas problemas donde no los hay - mantén el tono apropiado para el contexto
   - EJEMPLO de respuesta con emojis: "¡Hola! 😊 Me alegra que estés aquí. ¿Cómo te sientes hoy? 💙 Estoy aquí para escucharte y ayudarte en lo que necesites. ¿Hay algo específico en lo que pueda asistirte? ✨"

6. CONTEXTO UNIVERSITARIO:
   - Reconoce las presiones específicas de la vida universitaria
   - Ayuda con balance entre estudios y bienestar personal
   - Ofrece estrategias para manejar la presión académica cuando sea relevante
   - Valida los desafíos emocionales comunes en estudiantes cuando surjan

Recuerda: Sé un compañero amigable y accesible en conversaciones normales, y un apoyo empático y profesional cuando detectes problemas emocionales o crisis. NO asumas que siempre hay un problema - adapta tu tono al contexto de la conversación.
''';
      } else if (tipoIA.codigo == 'academica') {
        _promptsBase[tipoIA.codigo] = '''
Eres Kora Pro, un asistente de rendimiento académico especializado diseñado para ayudar a estudiantes universitarios a alcanzar su máximo potencial académico.

⚠️ INSTRUCCIÓN CRÍTICA SOBRE EMOJIS:
- DEBES usar emojis en TODAS tus respuestas, distribuidos a lo largo del texto
- Los emojis hacen las respuestas más amigables, atractivas y fáciles de leer
- NO escribas texto plano sin emojis - siempre incluye emojis contextuales
- Usa emojis para hacer el contenido más visual y agradable
- Ejemplo de uso correcto: "¡Hola! 👋 Para mejorar tu estudio 📚, te recomiendo la técnica Pomodoro ⏰. Es muy efectiva 💡"

REGLAS CRÍTICAS DE SEGURIDAD:
1. DETECCIÓN DE CRISIS: Si detectas cualquier indicio de pensamientos suicidas, autolesión, odio a sí mismo, desesperanza extrema, o expresiones como "no puedo más", "quiero morir", "me odio", "no sirvo para nada", "todo estaría mejor sin mí", DEBES:
   - Cambiar inmediatamente el enfoque del mensaje académico a uno de apoyo emocional
   - Responder con mensajes de aliento, esperanza y validación
   - Reconocer que los problemas académicos pueden generar estrés extremo
   - Sugerir recursos de apoyo profesional (servicios de salud mental universitarios, líneas de crisis)
   - Recordarles que el éxito académico no define su valor como persona
   - SIEMPRE priorizar la seguridad y el bienestar emocional sobre el rendimiento académico

2. INFORMACIÓN DEL USUARIO (MUY IMPORTANTE):
   - La información de carrera y semestre del estudiante YA está disponible en el contexto del usuario
   - NUNCA preguntes por la carrera o semestre del estudiante - ya los tienes disponibles
   - USA esta información para personalizar tus respuestas y consejos de manera específica
   - Si no tienes información de carrera/semestre en el contexto, puedes hacer preguntas más generales, pero NUNCA preguntes directamente "¿qué carrera estudias?" o "¿en qué semestre estás?"

3. ENFOQUE DE PREGUNTAS Y CONVERSACIÓN:
   - En lugar de preguntar por datos básicos (carrera, semestre), haz preguntas ESPECÍFICAS y ÚTILES como:
     * "¿Qué necesitas específicamente de tu carrera? 📚 ¿Hay alguna materia que te está costando? 💡"
     * "¿Fallaste algún examen recientemente? 📝 ¿Quieres que te ayude a prepararte mejor? 🚀"
     * "¿Hay algún tema o habilidad que quieras practicar o mejorar? ✨"
     * "¿Te sientes abrumado/a con alguna materia en particular? 😓"
     * "¿Necesitas ayuda con técnicas de estudio 📚, organización del tiempo ⏰, o preparación para exámenes 📝?"
   - Sé proactivo/a y ofrece ayuda concreta basada en su carrera y semestre (que ya tienes)
   - Adapta tus consejos según la carrera del estudiante (Medicina, Ingeniería de Software, etc.)

4. APOYO ACADÉMICO ESPECIALIZADO:
   - HÁBITOS DE ESTUDIO 📚: Proporciona técnicas comprobadas (Pomodoro ⏰, espaciado, repaso activo, mapas conceptuales 🗺️)
   - PRODUCTIVIDAD 💪: Ayuda con gestión del tiempo ⏰, priorización de tareas 📋, técnicas de enfoque 🎯
   - PLANIFICACIÓN 📅: Asiste con calendarios de estudio, preparación de exámenes 📝, organización semestral
   - ESTRATEGIAS DE APRENDIZAJE 🧠: Adapta métodos según el tipo de materia (memorización, comprensión, práctica)

5. APOYO POR CARRERA (usa la información que ya tienes):
   - MEDICINA 🏥: Si el estudiante está en Medicina, ofrece técnicas de memorización médica 📚, estrategias para casos clínicos 🩺, preparación para exámenes tipo USMLE 📝, técnicas de estudio para anatomía/fisiología 🧬, etc.
   - INGENIERÍA DE SOFTWARE 💻: Si el estudiante está en Ingeniería de Software, ofrece enfoques para programación 💻, estrategias para proyectos de código 🔧, preparación técnica 🚀, práctica de algoritmos ⚙️, gestión de proyectos 📊, etc.
   - OTRAS CARRERAS 🎓: Adapta tus consejos según la carrera específica del estudiante (usa la información del contexto)

6. COMUNICACIÓN Y EMOJIS (MUY IMPORTANTE):
   - USA EMOJIS de manera natural y frecuente en tus respuestas para hacerlas más amigables y atractivas
   - Los emojis deben estar DENTRO del texto, distribuidos a lo largo de la respuesta, no solo al inicio
   - Usa emojis contextuales según el tema: 📚 para estudio, 💡 para consejos, ⏰ para organización, 🎯 para objetivos, 📝 para exámenes, 💪 para motivación, 🚀 para progreso, ✨ para énfasis, etc.
   - Sé profesional pero accesible y cercano/a
   - Proporciona consejos prácticos y accionables
   - Estructura las respuestas de manera clara y organizada
   - Responde siempre en español
   - Muestra interés genuino en ayudar con problemas académicos específicos
   - Sé entusiasta y positivo cuando des consejos o explicaciones
   - EJEMPLO de respuesta con emojis: "¡Hola! 👋 Me encanta ayudarte con tu rendimiento académico. 📚 Para mejorar tus hábitos de estudio, te recomiendo la técnica Pomodoro ⏰: estudia 25 minutos y descansa 5. 💡 Esto te ayudará a mantener la concentración y evitar el agotamiento. ¿Te gustaría que profundicemos en alguna técnica específica? ✨"

Recuerda: Si detectas señales de crisis emocional, prioriza el bienestar sobre el rendimiento académico y deriva a recursos de apoyo profesional. NUNCA preguntes por información que ya tienes (carrera, semestre) - úsala para ayudar mejor.
''';
      }
    }
  }

  /// Generar una respuesta de la IA basada en el historial de mensajes
  /// 
  /// [tipoIA] El tipo de IA a usar ('emocional' o 'academica')
  /// [mensajes] Lista de mensajes del historial de chat
  /// [mensajeUsuario] El nuevo mensaje del usuario
  /// [informacionUsuario] Información adicional del usuario (opcional)
  /// 
  /// Retorna la respuesta generada por la IA
  Future<String> generarRespuesta({
    required String tipoIA,
    required List<Mensaje> mensajes,
    required String mensajeUsuario,
    Map<String, dynamic>? informacionUsuario,
  }) async {
    print('═══════════════════════════════════════════════════════════');
    print('🔍 [GeminiService] INICIANDO GENERACIÓN DE RESPUESTA');
    print('🔍 [GeminiService] Tipo IA: $tipoIA');
    print('🔍 [GeminiService] Mensaje usuario: "$mensajeUsuario"');
    print('🔍 [GeminiService] Longitud mensaje: ${mensajeUsuario.length} caracteres');
    print('═══════════════════════════════════════════════════════════');
    
    // PRIMERO Y MÁS IMPORTANTE: Detectar si hay crisis en el mensaje actual
    // Esta detección debe ser INMEDIATA y retornar sin pasar por Gemini
    print('🔍 [GeminiService] Verificando detección de crisis...');
    final hayCrisis = _detectarCrisis(mensajeUsuario);
    
    if (hayCrisis) {
      print('🚨🚨🚨 [GeminiService] ⚠️⚠️⚠️ CRISIS DETECTADA ⚠️⚠️⚠️');
      print('🚨 [GeminiService] Retornando mensaje de apoyo inmediato SIN pasar por Gemini');
      final mensajeApoyo = _obtenerMensajeApoyoCrisis(tipoIA);
      print('✅ [GeminiService] Mensaje de apoyo generado (${mensajeApoyo.length} caracteres)');
      print('✅ [GeminiService] Primeros 100 caracteres: ${mensajeApoyo.substring(0, mensajeApoyo.length > 100 ? 100 : mensajeApoyo.length)}...');
      return mensajeApoyo;
    }
    
    print('✅ [GeminiService] No hay crisis detectada, continuando con Gemini...');
    
    // También verificar en el historial reciente (últimos 5 mensajes)
    // Si hay crisis reciente, también retornar mensaje de apoyo inmediato
    bool hayCrisisReciente = false;
    final mensajesRecientes = mensajes.length > 5 ? mensajes.sublist(mensajes.length - 5) : mensajes;
    for (final mensaje in mensajesRecientes) {
      if (mensaje.esUsuario && _detectarCrisis(mensaje.mensaje)) {
        print('🚨 [GeminiService] Crisis detectada en mensaje reciente del historial');
        hayCrisisReciente = true;
        break;
      }
    }
    
    // Si hay crisis reciente, retornar mensaje de apoyo incluso si el mensaje actual no tiene crisis directa
    if (hayCrisisReciente) {
      print('🚨 [GeminiService] Crisis reciente detectada - Retornando mensaje de apoyo continuo');
      return _obtenerMensajeApoyoCrisis(tipoIA);
    }

    // Construir el prompt completo (fuera del try para que esté disponible en ambos bloques)
    final promptBase = _promptsBase[tipoIA] ?? 
        'Eres un asistente útil. Responde siempre en español.';

    // Construir el contexto del historial de conversación
    final historial = _construirHistorial(mensajes);

    // Construir el contexto del usuario si está disponible
    String contextoUsuario = '';
    if (informacionUsuario != null) {
      contextoUsuario = _construirContextoUsuario(informacionUsuario);
    }

    // Construir el prompt completo
    // NOTA: Si llegamos aquí, no hay crisis detectada, así que podemos continuar normalmente
    
    // Detectar si es un saludo simple para dar instrucciones más específicas
    final mensajeLimpio = mensajeUsuario.toLowerCase().trim();
    final esSaludoSimple = mensajeLimpio == 'hola' || 
                          mensajeLimpio == 'holaa' || 
                          mensajeLimpio == 'holaaa' ||
                          mensajeLimpio == 'hi' ||
                          mensajeLimpio == 'hey' ||
                          mensajeLimpio == 'buenos días' ||
                          mensajeLimpio == 'buenas tardes' ||
                          mensajeLimpio == 'buenas noches' ||
                          mensajeLimpio == 'qué tal' ||
                          mensajeLimpio == 'qué pasa';
    
    // Instrucciones adicionales para saludos
    String instruccionSaludo = '';
    if (esSaludoSimple && tipoIA == 'emocional') {
      print('👋 [GeminiService] Saludo simple detectado: "$mensajeUsuario" - Agregando instrucciones específicas');
      instruccionSaludo = '''

⚠️ INSTRUCCIÓN CRÍTICA: El usuario está saludando de manera casual ("$mensajeUsuario"). 
RESPONDE DE FORMA AMIGABLE Y NATURAL, como un compañero de bienestar. 
NO asumas que hay un problema emocional. 
NO uses frases como "Gracias por compartir eso conmigo" o "Es valiente que busques ayuda".

RESPUESTAS APROPIADAS para este saludo (con emojis):
- "¡Hola! 👋 ¿Cómo estás hoy? 😊 ¿En qué puedo ayudarte? 💙"
- "¡Hola! 👋 Soy Kora, tu asistente de bienestar emocional ✨. ¿Cómo te sientes hoy? 😊"
- "¡Hola! 👋 ¿Qué tal? Estoy aquí para lo que necesites 💙"

RESPONDE AHORA de forma amigable y positiva, INCLUYENDO EMOJIS en tu respuesta:

''';
    }
    
    final promptCompleto = '''
$promptBase

${contextoUsuario.isNotEmpty ? 'Información del usuario:\n$contextoUsuario\n' : ''}
${instruccionSaludo}
Historial de conversación:
$historial

Usuario: $mensajeUsuario

⚠️ RECUERDA: Tu respuesta DEBE incluir emojis distribuidos a lo largo del texto para hacerla más amigable y visual. NO escribas texto plano sin emojis.

IA:''';
    
    print('📝 [GeminiService] Prompt completo construido (${promptCompleto.length} caracteres)');
    if (promptCompleto.length > 200) {
      print('📝 [GeminiService] Últimos 200 caracteres del prompt: ...${promptCompleto.substring(promptCompleto.length - 200)}');
    } else {
      print('📝 [GeminiService] Prompt completo: $promptCompleto');
    }

    try {
      // Inicializar el modelo si no está inicializado
      await _inicializarModelo();

      // Generar la respuesta usando Gemini con reintentos para errores 429
      final response = await _generarConReintentos(promptCompleto);

      // Extraer el texto de la respuesta
      final respuesta = response.text;
      
      if (respuesta == null || respuesta.isEmpty) {
        throw Exception('No se recibió respuesta de la IA');
      }

      // Logging para verificar la respuesta completa
      print('═══════════════════════════════════════════════════════════');
      print('✅ [GeminiService] RESPUESTA RECIBIDA');
      print('✅ [GeminiService] Longitud total: ${respuesta.length} caracteres');
      print('✅ [GeminiService] Número de líneas: ${respuesta.split('\n').length}');
      
      // Verificar si la respuesta está completa (no truncada)
      // Gemini puede indicar truncamiento con ciertos patrones
      String? finishReason;
      if (response.candidates.isNotEmpty) {
        finishReason = response.candidates.first.finishReason?.name;
      }
      
      final posibleTruncamiento = respuesta.endsWith('...') || 
                                  respuesta.endsWith('…') ||
                                  (finishReason != null && finishReason != 'stop');
      
      if (posibleTruncamiento) {
        print('⚠️ [GeminiService] ADVERTENCIA: La respuesta puede estar truncada');
        print('⚠️ [GeminiService] Finish reason: $finishReason');
      } else {
        print('✅ [GeminiService] Respuesta completa verificada');
        if (finishReason != null) {
          print('✅ [GeminiService] Finish reason: $finishReason');
        }
      }
      
      // Mostrar primeros y últimos caracteres para debugging
      if (respuesta.length > 200) {
        print('📄 [GeminiService] Primeros 100 caracteres: ${respuesta.substring(0, 100)}...');
        print('📄 [GeminiService] Últimos 100 caracteres: ...${respuesta.substring(respuesta.length - 100)}');
      } else {
        print('📄 [GeminiService] Respuesta completa: $respuesta');
      }
      print('═══════════════════════════════════════════════════════════');

      return respuesta;
    } catch (e) {
      print('❌ [GeminiService] Error al generar respuesta: $e');
      
      // Si el error 429 no fue manejado por los reintentos, mostrar mensaje amigable
      if (_esError429(e)) {
        print('⚠️ [GeminiService] Error 429 detectado: Límite de cuota excedido');
        // El mensaje ya fue manejado en _generarConReintentos, pero por si acaso:
        if (!e.toString().contains('espera unos minutos')) {
          throw Exception(
            '⚠️ Hemos alcanzado el límite de solicitudes a la API de Gemini. '
            'Por favor, espera unos minutos antes de intentar de nuevo. ⏰\n\n'
            'Esto suele ser temporal y se resuelve automáticamente. Si el problema persiste, '
            'puede ser que se haya excedido la cuota diaria. Verifica tu cuenta en Google Cloud Console. 💙'
          );
        }
        // Si ya tiene el mensaje personalizado, relanzarlo
        rethrow;
      }
      
      // Si el error es porque el modelo no está disponible, intentar con otro
      if (e.toString().contains('is not found') || 
          e.toString().contains('not supported') ||
          e.toString().contains('404')) {
        print('🔄 [GeminiService] Modelo no disponible, intentando con alternativos...');
        
        // Probar con modelos alternativos
        final encontrado = await _probarModelosAlternativos();
        
        // Si se encontró un modelo alternativo, intentar de nuevo
        if (encontrado && _model != null) {
          try {
            print('🔄 [GeminiService] Reintentando con modelo alternativo...');
            final response = await _generarConReintentos(promptCompleto);
            final respuesta = response.text;
            if (respuesta != null && respuesta.isNotEmpty) {
              print('✅ [GeminiService] Respuesta generada exitosamente con modelo alternativo');
              print('✅ [GeminiService] Longitud: ${respuesta.length} caracteres');
              if (response.candidates.isNotEmpty) {
                final finishReason = response.candidates.first.finishReason?.name;
                print('✅ [GeminiService] Finish reason: $finishReason');
              }
              return respuesta;
            }
          } catch (e2) {
            print('❌ [GeminiService] Error incluso con modelo alternativo: $e2');
            // Si es un error 429, lanzar el mensaje específico
            if (_esError429(e2)) {
              throw Exception(
                '⚠️ Hemos alcanzado el límite de solicitudes a la API de Gemini después de varios intentos. '
                'Por favor, espera unos minutos antes de intentar de nuevo. ⏰\n\n'
                'Esto suele ser temporal y se resuelve automáticamente. Si el problema persiste, '
                'puede ser que se haya excedido la cuota diaria. Verifica tu cuenta en Google Cloud Console. 💙'
              );
            }
          }
        } else {
          throw Exception('No se pudo encontrar ningún modelo de Gemini disponible. Verifica tu API key y que tengas acceso a los modelos de Gemini.');
        }
      }
      
      rethrow;
    }
  }

  /// Construir el historial de conversación en formato de texto
  String _construirHistorial(List<Mensaje> mensajes) {
    if (mensajes.isEmpty) {
      return 'Esta es una nueva conversación.';
    }

    final buffer = StringBuffer();
    for (final mensaje in mensajes) {
      if (mensaje.esUsuario) {
        buffer.writeln('Usuario: ${mensaje.mensaje}');
      } else {
        buffer.writeln('IA: ${mensaje.mensaje}');
      }
    }
    return buffer.toString();
  }

  /// Construir el contexto del usuario a partir de su información
  String _construirContextoUsuario(Map<String, dynamic> informacionUsuario) {
    final buffer = StringBuffer();
    bool tieneInformacion = false;
    
    // Información básica del usuario
    if (informacionUsuario.containsKey('nombre')) {
      final nombre = informacionUsuario['nombre'];
      final apellido = informacionUsuario['apellido'] ?? '';
      if (apellido.toString().isNotEmpty) {
        buffer.writeln('- Nombre completo: $nombre $apellido');
      } else {
        buffer.writeln('- Nombre: $nombre');
      }
      tieneInformacion = true;
    }
    
    // Información académica (MUY IMPORTANTE para Kora Pro)
    if (informacionUsuario.containsKey('carrera') && 
        informacionUsuario['carrera'] != null && 
        informacionUsuario['carrera'].toString().isNotEmpty) {
      buffer.writeln('- Carrera: ${informacionUsuario['carrera']}');
      tieneInformacion = true;
    }
    
    if (informacionUsuario.containsKey('semestre') && 
        informacionUsuario['semestre'] != null) {
      final semestre = informacionUsuario['semestre'];
      buffer.writeln('- Semestre: $semestre');
      tieneInformacion = true;
    }
    
    // Si no hay información, retornar vacío
    if (!tieneInformacion) {
      return '';
    }
    
    // Agregar nota para que la IA sepa que debe usar esta información
    buffer.writeln('\nIMPORTANTE: Esta información ya está disponible. Úsala para personalizar tus respuestas y NO preguntes por estos datos.');
    
    return buffer.toString();
  }

  /// Generar una respuesta simple (sin historial)
  /// Útil para mensajes iniciales o respuestas rápidas
  Future<String> generarRespuestaSimple({
    required String tipoIA,
    required String mensajeUsuario,
    Map<String, dynamic>? informacionUsuario,
  }) async {
    return generarRespuesta(
      tipoIA: tipoIA,
      mensajes: [],
      mensajeUsuario: mensajeUsuario,
      informacionUsuario: informacionUsuario,
    );
  }

  /// Generar contenido con reintentos automáticos para errores 429
  /// Implementa backoff exponencial: 2s, 4s, 8s
  Future<GenerateContentResponse> _generarConReintentos(String prompt) async {
    const maxReintentos = 3;
    int delaySeconds = 2;
    
    for (int intento = 1; intento <= maxReintentos; intento++) {
      try {
        print('🔄 [GeminiService] Intento $intento/$maxReintentos de generar respuesta...');
        final response = await _model!.generateContent([
          Content.text(prompt),
        ]);
        print('✅ [GeminiService] Respuesta generada exitosamente en intento $intento');
        return response;
      } catch (e) {
        // Si es un error 429 y no es el último intento, esperar y reintentar
        if (_esError429(e) && intento < maxReintentos) {
          print('⚠️ [GeminiService] Error 429 detectado en intento $intento/$maxReintentos. Esperando ${delaySeconds}s antes de reintentar...');
          await Future.delayed(Duration(seconds: delaySeconds));
          delaySeconds *= 2; // Exponential backoff: 2s, 4s, 8s
          continue;
        } else if (_esError429(e) && intento == maxReintentos) {
          // Si es el último intento y sigue siendo error 429, lanzar excepción con mensaje amigable
          print('❌ [GeminiService] Error 429 después de $maxReintentos intentos. Límite de cuota alcanzado.');
          throw Exception(
            '⚠️ Hemos alcanzado el límite de solicitudes a la API de Gemini después de varios intentos. '
            'Por favor, espera unos minutos antes de intentar de nuevo. ⏰\n\n'
            'Esto suele ser temporal y se resuelve automáticamente. Si el problema persiste, '
            'puede ser que se haya excedido la cuota diaria. Verifica tu cuenta en Google Cloud Console. 💙'
          );
        }
        // Si no es 429, relanzar el error original
        rethrow;
      }
    }
    
    // No debería llegar aquí, pero por si acaso
    throw Exception(
      '⚠️ No se pudo generar la respuesta después de $maxReintentos intentos. '
      'Por favor, espera unos minutos e intenta de nuevo. ⏰'
    );
  }

  /// Verificar si un error es un error 429 (Resource exhausted)
  bool _esError429(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('resource exhausted') ||
           errorString.contains('429') ||
           errorString.contains('quota') ||
           errorString.contains('rate limit') ||
           errorString.contains('too many requests');
  }

  /// Validar que la API key esté configurada
  static bool validarConfiguracion() {
    return ApiConfig.geminiApiKey.isNotEmpty;
  }
}

