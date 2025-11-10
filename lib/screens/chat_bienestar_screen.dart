import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bienestar_provider.dart';
import '../providers/auth_provider.dart';
import '../models/bienestar.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

class ChatBienestarScreen extends StatefulWidget {
  const ChatBienestarScreen({super.key});

  @override
  State<ChatBienestarScreen> createState() => _ChatBienestarScreenState();
}

class _ChatBienestarScreenState extends State<ChatBienestarScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Inicializar el provider y cargar mensajes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inicializarChat();
    });
  }

  Future<void> _inicializarChat() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bienestarProvider = Provider.of<BienestarProvider>(context, listen: false);

    final user = authProvider.user;
    if (user != null) {
      // Inicializar el provider con el usuario
      await bienestarProvider.inicializar(user);
    }
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

  Future<void> _enviarMensaje() async {
    final texto = _messageController.text.trim();
    if (texto.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bienestarProvider = Provider.of<BienestarProvider>(context, listen: false);
    
    await bienestarProvider.enviarMensajeChat(texto, usuario: authProvider.user);
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
                child: Consumer<BienestarProvider>(
                  builder: (context, bienestarProvider, child) {
                    final mensajes = bienestarProvider.mensajesChat;
                    
                    // Scroll al final cuando hay nuevos mensajes
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: mensajes.length,
                      itemBuilder: (context, index) {
                        final mensaje = mensajes[index];
                        return _buildMensajeBurbuja(mensaje);
                      },
                    );
                  },
                ),
              ),
              _buildInputArea(context),
              _buildBotonEmergencia(context),
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
              color: Colors.pink.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.pink,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistente de Bienestar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Siempre aquí para ti',
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
            onSelected: (value) {
              if (value == 'limpiar') {
                final bienestarProvider = Provider.of<BienestarProvider>(
                  context,
                  listen: false,
                );
                bienestarProvider.limpiarChat();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'limpiar',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
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

  /// Construir texto con formato markdown básico (negritas, listas, etc.)
  Widget _buildTextoConFormato(String texto) {
    // Normalizar el texto: eliminar espacios extra y unir líneas rotas
    texto = _normalizarTexto(texto);
    
    // Si no hay markdown, retornar texto simple
    if (!texto.contains('**') && !texto.contains('•') && !texto.trim().startsWith('-') && !texto.trim().startsWith('*')) {
      return Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.4,
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

    return RichText(
      text: TextSpan(children: spans.isEmpty ? [TextSpan(text: texto, style: defaultStyle)] : spans),
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

  Widget _buildMensajeBurbuja(MensajeChat mensaje) {
    final isUsuario = mensaje.esUsuario;

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
                color: Colors.pink.withOpacity(0.3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.pink,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUsuario
                    ? Colors.pink.withOpacity(0.3)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUsuario ? 20 : 4),
                  bottomRight: Radius.circular(isUsuario ? 4 : 20),
                ),
                border: Border.all(
                  color: isUsuario
                      ? Colors.pink.withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: _buildTextoConFormato(mensaje.texto),
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
                      hintText: 'Escribe tu mensaje...',
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
                colors: [Colors.pink, Colors.purple],
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

  Widget _buildBotonEmergencia(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        border: Border(
          top: BorderSide(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            final confirmacion = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.grey[900],
                title: const Text(
                  'Llamar a Emergencias',
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  '¿Estás seguro de que deseas llamar al 911?',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Llamar'),
                  ),
                ],
              ),
            );

            if (confirmacion == true) {
              const url = 'tel:911';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No se pudo realizar la llamada'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          icon: const Icon(Icons.emergency_rounded),
          label: const Text(
            'EMERGENCIA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

