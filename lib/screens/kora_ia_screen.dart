import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kora_ia_provider.dart';
import '../providers/auth_provider.dart';
import '../models/kora_ia.dart';
import '../utils/profile_helper.dart';
import 'dart:ui';

class KoraIAScreen extends StatefulWidget {
  const KoraIAScreen({super.key});

  @override
  State<KoraIAScreen> createState() => _KoraIAScreenState();
}

class _KoraIAScreenState extends State<KoraIAScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _ultimoNumeroMensajes = 0;
  bool _showScrollToBottomButton = false;

  @override
  void initState() {
    super.initState();
    // Inicializar el provider y cargar mensajes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inicializarChat();
    });
    
    // Listener para detectar cuando el usuario hace scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollController.addListener(_onScroll);
      }
    });
  }
  
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    try {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      if (maxScroll.isNaN || currentScroll.isNaN || maxScroll.isInfinite || currentScroll.isInfinite) {
        return;
      }
      
      // Mostrar el botón solo si NO está cerca del final (más de 100 píxeles del final)
      final isNearBottom = (maxScroll - currentScroll) <= 100;
      
      if (mounted && _showScrollToBottomButton != !isNearBottom) {
        setState(() {
          _showScrollToBottomButton = !isNearBottom;
        });
      }
    } catch (e) {
      print('⚠️ [KoraIAScreen] Error en _onScroll: $e');
    }
  }
  

  Future<void> _inicializarChat() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final koraIAProvider = Provider.of<KoraIAProvider>(
      context,
      listen: false,
    );

    final user = authProvider.user;
    if (user != null) {
      // Inicializar el provider con el usuario
      await koraIAProvider.inicializar(user);
    } else {
      // Si no hay usuario, cargar mensaje inicial
      final isCompleted = authProvider.user?.isProfileCompleted ?? false;
      koraIAProvider.recargarMensajeInicial(isCompleted);
    }
    
    // Actualizar el contador de mensajes después de inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _ultimoNumeroMensajes = koraIAProvider.mensajesChat.length;
      }
    });
  }

  void _checkProfileStatus() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final koraIAProvider = Provider.of<KoraIAProvider>(
      context,
      listen: false,
    );
    final isCompleted = authProvider.user?.isProfileCompleted ?? false;
    koraIAProvider.recargarMensajeInicial(isCompleted);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  Widget _buildScrollToBottomButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _scrollToBottom,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Future<void> _enviarMensaje() async {
    final texto = _messageController.text.trim();
    if (texto.isEmpty) return;

    final textoLower = texto.toLowerCase();
    
    // Detectar si el usuario quiere completar el perfil
    if (textoLower.contains('perfil') || textoLower.contains('completar') || 
        textoLower.contains('sí') || textoLower.contains('si') || 
        textoLower.contains('ok') || textoLower.contains('vale')) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isCompleted = authProvider.user?.isProfileCompleted ?? false;
      
      if (!isCompleted) {
        // Mostrar el modal de completar perfil
        ProfileHelper.checkAndShowCompleteProfile(
          context,
          onComplete: () {
            _checkProfileStatus();
          },
        );
        _messageController.clear();
        return;
      }
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final koraIAProvider = Provider.of<KoraIAProvider>(
      context,
      listen: false,
    );
    
    // Enviar mensaje con información del usuario
    await koraIAProvider.enviarMensajeChat(
      texto,
      usuario: authProvider.user,
    );
    _messageController.clear();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
              Colors.grey[900]!,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Consumer<KoraIAProvider>(
                  builder: (context, koraIAProvider, child) {
                    try {
                    // Mostrar indicador de carga si está cargando mensajes
                      final isLoading = koraIAProvider.isLoading;
                      final mensajes = koraIAProvider.mensajesChat;
                      
                      if (isLoading && mensajes.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                        ),
                      );
                    }

                      // Detectar nuevos mensajes y hacer scroll automático solo cuando hay nuevos
                      if (mensajes.length > _ultimoNumeroMensajes) {
                        _ultimoNumeroMensajes = mensajes.length;
                        // Hacer scroll solo si el usuario está cerca del final (no forzar si está leyendo arriba)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            final maxScroll = _scrollController.position.maxScrollExtent;
                            final currentScroll = _scrollController.position.pixels;
                            // Solo hacer scroll automático si está cerca del final (dentro de 200 píxeles)
                            if ((maxScroll - currentScroll) <= 200) {
                      _scrollToBottom();
                              // Actualizar estado del botón después del scroll
                              _onScroll();
                            }
                          }
                    });
                      }

                    return Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: mensajes.length,
                          itemBuilder: (context, index) {
                            final mensaje = mensajes[index];
                            return _buildMensajeBurbuja(mensaje);
                          },
                        ),
                        // Indicador de carga cuando se está enviando un mensaje
                        if (isLoading && mensajes.isNotEmpty)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.black.withOpacity(0.3),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Kora Pro está escribiendo...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Botón para ir al final de la conversación (aparece cuando bajes)
                        if (_showScrollToBottomButton && mensajes.isNotEmpty)
                          Positioned(
                            bottom: isLoading ? 50 : 20,
                            right: 12,
                            child: _buildScrollToBottomButton(),
                          ),
                      ],
                    );
                    } catch (e) {
                      print('❌ [KoraIAScreen] Error en Consumer builder: $e');
                      return const Center(
                        child: Text(
                          'Error al cargar los mensajes',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  },
                ),
              ),
              _buildInputArea(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kora AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tu asistente de carrera',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF1A2634),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            elevation: 8,
            onSelected: (value) async {
              if (value == 'limpiar') {
                final koraIAProvider = Provider.of<KoraIAProvider>(
                  context,
                  listen: false,
                );
                await koraIAProvider.limpiarChat();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'limpiar',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Limpiar chat',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMensajeBurbuja(MensajeKoraIA mensaje) {
    final isUsuario = mensaje.esUsuario;
    final tipoMensaje = mensaje.tipoMensaje;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUsuario) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              crossAxisAlignment: isUsuario
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUsuario && tipoMensaje != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tipoMensaje.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tipoMensaje.icono,
                          size: 12,
                          color: tipoMensaje.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tipoMensaje.nombre,
                          style: TextStyle(
                            color: tipoMensaje.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isUsuario
                        ? LinearGradient(
                            colors: [
                              Colors.purple.withOpacity(0.4),
                              Colors.deepPurple.withOpacity(0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isUsuario
                        ? null
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUsuario ? 20 : 4),
                      bottomRight: Radius.circular(isUsuario ? 4 : 20),
                    ),
                    border: Border.all(
                      color: isUsuario
                          ? Colors.purple.withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: !isUsuario
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header decorativo con emoji contextual
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.purple, Colors.deepPurple],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                  ),
                  child: Text(
                                    _obtenerEmojiContextual(mensaje.texto),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.purple.withOpacity(0.5),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                    ),
                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTextoConFormato(mensaje.texto),
                          ],
                        )
                      : _buildTextoConFormato(mensaje.texto),
                ),
              ],
            ),
          ),
          if (isUsuario) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.blue,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Pregunta sobre tu carrera, estudios, organización...',
                      hintStyle: TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _enviarMensaje(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _enviarMensaje,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construir texto con formato markdown básico (negritas, listas, etc.)
  Widget _buildTextoConFormato(String texto) {
    // Normalizar el texto: eliminar espacios extra y unir líneas rotas
    texto = _normalizarTexto(texto);
    
    // Si no hay markdown, retornar texto simple
    if (!texto.contains('**') && !texto.contains('•') && !texto.trim().startsWith('-') && !texto.trim().startsWith('*')) {
      return SizedBox(
        width: double.infinity,
        child: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
          textAlign: TextAlign.start,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      );
    }

    final List<TextSpan> spans = [];
    final lineas = texto.split('\n');
    final defaultStyle = const TextStyle(color: Colors.white, fontSize: 15, height: 1.4);
    final boldStyle = const TextStyle(
      color: Colors.white,
      fontSize: 15,
      height: 1.4,
      fontWeight: FontWeight.bold,
    );
    
    for (int i = 0; i < lineas.length; i++) {
      final linea = lineas[i];
      
      // Línea vacía
      if (linea.trim().isEmpty) {
        if (i < lineas.length - 1) {
          spans.add(const TextSpan(text: '\n'));
        }
        continue;
      }

      // Detectar listas (•, -, o * al inicio de la línea después de espacios)
      final trimmedLine = linea.trim();
      // Verificar si es un marcador de lista
      // Es lista si empieza con •, -, o * (pero no ** que es negrita)
      final esLista = trimmedLine.startsWith('•') || 
                      (trimmedLine.startsWith('-') && trimmedLine.length > 1 && trimmedLine[1] == ' ') ||
                      (trimmedLine.startsWith('*') && 
                       trimmedLine.length > 1 && 
                       trimmedLine[1] == ' ' && 
                       !trimmedLine.startsWith('**'));
      
      if (esLista) {
        // Obtener la indentación original
        final indentStart = linea.indexOf(trimmedLine[0]);
        final indent = indentStart > 0 ? linea.substring(0, indentStart) : '';
        // Remover el marcador de lista (*, -, o •)
        final contenido = trimmedLine.substring(1).trim();
        
        // Procesar negritas dentro del contenido de la lista
        final contenidoSpans = _procesarNegritasEnTexto(contenido, defaultStyle, boldStyle);
        spans.add(TextSpan(text: '$indent• ', style: defaultStyle));
        spans.addAll(contenidoSpans);
        if (i < lineas.length - 1) {
          spans.add(const TextSpan(text: '\n'));
        }
        continue;
      }

      // Procesar línea normal con negritas
      final lineaSpans = _procesarNegritasEnTexto(linea, defaultStyle, boldStyle);
      spans.addAll(lineaSpans);
      
      if (i < lineas.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return SizedBox(
      width: double.infinity,
      child: RichText(
        text: TextSpan(children: spans.isEmpty ? [TextSpan(text: texto, style: defaultStyle)] : spans),
        textAlign: TextAlign.start,
        softWrap: true,
        overflow: TextOverflow.visible,
      ),
    );
  }
  
  /// Normalizar texto: unir líneas rotas y limpiar espacios
  String _normalizarTexto(String texto) {
    // Dividir en líneas
    final lineas = texto.split('\n');
    final lineasNormalizadas = <String>[];
    
    for (int i = 0; i < lineas.length; i++) {
      final linea = lineas[i];
      final trimmedLine = linea.trim();
      
      // Si la línea está vacía, mantenerla
      if (trimmedLine.isEmpty) {
        lineasNormalizadas.add('');
        continue;
      }
      
      // Verificar si la línea anterior necesita continuación
      if (lineasNormalizadas.isNotEmpty && lineasNormalizadas.last.isNotEmpty) {
        final lineaAnterior = lineasNormalizadas.last.trim();
        
        // Verificar si es un marcador de lista
        final esMarcadorLista = trimmedLine.startsWith('•') || 
                                trimmedLine.startsWith('-') ||
                                (trimmedLine.startsWith('*') && trimmedLine.length > 1 && trimmedLine[1] == ' ');
        
        // Si la línea anterior no termina en puntuación final y esta no es marcador de lista,
        // unir las líneas (esto maneja casos como "¿Cuá" seguido de "objetivo principal")
        if (!lineaAnterior.endsWith('.') &&
            !lineaAnterior.endsWith('?') &&
            !lineaAnterior.endsWith('!') &&
            !esMarcadorLista &&
            !trimmedLine.startsWith('**')) {
          // Unir con la línea anterior
          lineasNormalizadas[lineasNormalizadas.length - 1] += ' $trimmedLine';
          continue;
        }
      }
      
      lineasNormalizadas.add(linea);
    }
    
    return lineasNormalizadas.join('\n');
  }
  
  /// Procesar negritas (**texto**) en un texto y retornar una lista de TextSpan
  List<TextSpan> _procesarNegritasEnTexto(
    String texto,
    TextStyle defaultStyle,
    TextStyle boldStyle,
  ) {
    final List<TextSpan> spans = [];
    final boldRegex = RegExp(r'\*\*(.+?)\*\*');
    int lastIndex = 0;
    
    for (final match in boldRegex.allMatches(texto)) {
      // Texto antes de la negrita
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: texto.substring(lastIndex, match.start),
          style: defaultStyle,
        ));
      }
      
      // Texto en negrita
      spans.add(TextSpan(
        text: match.group(1) ?? '',
        style: boldStyle,
      ));
      
      lastIndex = match.end;
    }
    
    // Texto restante después de la última negrita
    if (lastIndex < texto.length) {
      spans.add(TextSpan(
        text: texto.substring(lastIndex),
        style: defaultStyle,
      ));
    }
    
    // Si no se encontraron negritas, retornar el texto completo
    if (spans.isEmpty) {
      spans.add(TextSpan(text: texto, style: defaultStyle));
    }
    
    return spans;
  }

  /// Obtener emoji contextual basado en el contenido del mensaje
  String _obtenerEmojiContextual(String texto) {
    final textoLower = texto.toLowerCase();
    
    // Emojis para diferentes temas académicos
    if (textoLower.contains('algoritmo') || textoLower.contains('código') || textoLower.contains('programación')) {
      return '💻';
    } else if (textoLower.contains('matemática') || textoLower.contains('cálculo') || textoLower.contains('ecuación')) {
      return '📐';
    } else if (textoLower.contains('estudio') || textoLower.contains('aprender') || textoLower.contains('técnica')) {
      return '📚';
    } else if (textoLower.contains('organización') || textoLower.contains('tiempo') || textoLower.contains('horario')) {
      return '⏰';
    } else if (textoLower.contains('motivación') || textoLower.contains('ánimo') || textoLower.contains('inspiración')) {
      return '🚀';
    } else if (textoLower.contains('examen') || textoLower.contains('prueba') || textoLower.contains('evaluación')) {
      return '📝';
    } else if (textoLower.contains('consejo') || textoLower.contains('recomendación') || textoLower.contains('sugerencia')) {
      return '💡';
    } else if (textoLower.contains('carrera') || textoLower.contains('profesional') || textoLower.contains('futuro')) {
      return '🎓';
    } else if (textoLower.contains('lista') || textoLower.contains('paso') || textoLower.contains('punto')) {
      return '📋';
    } else if (textoLower.contains('explicación') || textoLower.contains('concepto') || textoLower.contains('definición')) {
      return '🔍';
    } else {
      return '✨'; // Emoji por defecto
    }
  }
}

