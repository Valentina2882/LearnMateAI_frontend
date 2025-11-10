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

  // Color para texto sobre fondos oscuros
  static const Color textoClaro = blanco;
  
  // Color para texto sobre fondos claros
  static const Color textoOscuro = grisGrafito;
}

