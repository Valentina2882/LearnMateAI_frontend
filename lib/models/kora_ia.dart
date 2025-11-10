import 'package:flutter/material.dart';

// Modelo para mensajes del chat de Kora IA
class MensajeKoraIA {
  final String id;
  final String texto;
  final bool esUsuario;
  final DateTime fecha;
  final TipoMensaje? tipoMensaje; // Para categorizar el tipo de mensaje

  MensajeKoraIA({
    required this.id,
    required this.texto,
    required this.esUsuario,
    required this.fecha,
    this.tipoMensaje,
  });
}

enum TipoMensaje {
  academico,
  motivacional,
  consejo,
  informacion,
  general,
}

extension TipoMensajeExtension on TipoMensaje {
  String get nombre {
    switch (this) {
      case TipoMensaje.academico:
        return 'Académico';
      case TipoMensaje.motivacional:
        return 'Motivacional';
      case TipoMensaje.consejo:
        return 'Consejo';
      case TipoMensaje.informacion:
        return 'Información';
      case TipoMensaje.general:
        return 'General';
    }
  }

  IconData get icono {
    switch (this) {
      case TipoMensaje.academico:
        return Icons.school_rounded;
      case TipoMensaje.motivacional:
        return Icons.emoji_events_rounded;
      case TipoMensaje.consejo:
        return Icons.lightbulb_rounded;
      case TipoMensaje.informacion:
        return Icons.info_rounded;
      case TipoMensaje.general:
        return Icons.chat_bubble_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TipoMensaje.academico:
        return Colors.blue;
      case TipoMensaje.motivacional:
        return Colors.orange;
      case TipoMensaje.consejo:
        return Colors.yellow;
      case TipoMensaje.informacion:
        return Colors.cyan;
      case TipoMensaje.general:
        return Colors.grey;
    }
  }
}

