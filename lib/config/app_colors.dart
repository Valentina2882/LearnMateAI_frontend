import 'package:flutter/material.dart';

/// Colores principales de la aplicación LearnMate
class AppColors {
  // Colores principales
  static const Color azulOscuro = Color(0xFF1E3A8A);
  static const Color celeste = Color(0xFF60A5FA);
  static const Color grisGrafito = Color(0xFF111827);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color verdeAzulado = Color(0xFF14B8A6);

  // Colores adicionales para diferentes contextos
  static const Color fondoClaro = Color(0xFFF5F5F5);
  static const Color grisClaro = Color(0xFF9CA3AF);
  static const Color grisMedio = Color(0xFF6B7280);
  
  // Colores por sección
  // HORARIO - MORADO
  static const Color horarioPrimary = Color(0xFF6366F1);
  static const Color horarioSecondary = Color(0xFF4F46E5);
  
  // EXAMENES - NARANJA
  static const Color examenesPrimary = Color(0xFFFF7043);
  static const Color examenesSecondary = Color(0xFFE64A19);
  
  // KORA AI - ROJO
  static const Color koraPrimary = Color(0xFFEF5350);
  static const Color koraSecondary = Color(0xFFE53935);
  
  // BIENESTAR - VERDE
  static const Color bienestarPrimary = Color(0xFF66BB6A);
  static const Color bienestarSecondary = Color(0xFF43A047);
  
  // PERFIL - CIAN
  static const Color perfilPrimary = Color(0xFF26C6DA);
  static const Color perfilSecondary = Color(0xFF00ACC1);
  
  // Colores para gradientes
  static const List<Color> gradientePrincipal = [
    azulOscuro,
    celeste,
    verdeAzulado,
  ];

  static const List<Color> gradienteSecundario = [
    azulOscuro,
    celeste,
  ];
  
  static const List<Color> gradienteHorario = [
    horarioPrimary,
    horarioSecondary,
  ];
  
  static const List<Color> gradienteExamenes = [
    examenesPrimary,
    examenesSecondary,
  ];
  
  static const List<Color> gradienteKora = [
    koraPrimary,
    koraSecondary,
  ];
  
  static const List<Color> gradienteBienestar = [
    bienestarPrimary,
    bienestarSecondary,
  ];
  
  static const List<Color> gradientePerfil = [
    perfilPrimary,
    perfilSecondary,
  ];

  // Color para texto sobre fondos oscuros
  static const Color textoClaro = blanco;
  
  // Color para texto sobre fondos claros
  static const Color textoOscuro = grisGrafito;
}

