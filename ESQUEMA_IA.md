# Esquema de Base de Datos para Sistema de Chat con IAs

## Resumen

Este documento describe el esquema de base de datos para el sistema de chat con inteligencias artificiales en LearnMate. El sistema soporta dos tipos de IAs: **Kora** (bienestar emocional) y **Kora Pro** (rendimiento académico).

## Tablas Creadas

### 1. `tipos_ia` - Configuración de IAs

Esta tabla almacena la configuración de cada tipo de IA disponible en la aplicación.

**Campos:**
- `id` (uuid, PK): Identificador único
- `codigo` (text, UNIQUE): Código único del tipo de IA ('emocional' o 'academica')
- `nombre` (text): Nombre de la IA (ej: 'Kora', 'Kora Pro')
- `descripcion` (text): Descripción de la IA
- `avatar_url` (text): URL del avatar de la IA (opcional)
- `color_primario` (varchar(7)): Color primario en formato HEX (ej: '#6366F1')
- `color_secundario` (varchar(7)): Color secundario en formato HEX
- `prompt_base` (text): Prompt base o instrucciones del sistema para la IA
- `activo` (boolean): Indica si la IA está activa
- `orden` (integer): Orden de visualización
- `fecha_creacion` (timestamp): Fecha de creación
- `fecha_actualizacion` (timestamp): Fecha de última actualización

**Índices:**
- `idx_tipos_ia_codigo`: Para búsquedas rápidas por código
- `idx_tipos_ia_activo`: Para filtrar IAs activas

**Constraints:**
- `check_codigo_ia`: Valida que el código sea 'emocional' o 'academica'
- `tipos_ia_codigo_key`: Garantiza unicidad del código

### 2. `mensajes` - Historial de Chat

Esta tabla almacena todos los mensajes del chat entre usuarios e IAs.

**Campos:**
- `id` (uuid, PK): Identificador único
- `usuario_id` (uuid, FK): Referencia al usuario (tabla `usuarios`)
- `tipo_ia` (text): Tipo de IA ('emocional' o 'academica')
- `role` (text): Rol del mensaje ('user' o 'ia')
- `mensaje` (text): Contenido del mensaje
- `metadata` (jsonb): Campos adicionales en formato JSON (opcional)
  - Ejemplos: `tokens_usados`, `modelo_ia`, `version`, `temperatura`, etc.
- `created_at` (timestamp): Fecha y hora de creación
- `updated_at` (timestamp): Fecha y hora de última actualización

**Índices:**
- `idx_mensajes_usuario`: Para búsquedas por usuario
- `idx_mensajes_tipo_ia`: Para búsquedas por tipo de IA
- `idx_mensajes_usuario_tipo`: Compuesto (usuario_id, tipo_ia) para consultas frecuentes
- `idx_mensajes_created_at`: Para ordenar por fecha (descendente)
- `idx_mensajes_usuario_tipo_fecha`: Compuesto (usuario_id, tipo_ia, created_at) para consultas optimizadas

**Constraints:**
- `check_tipo_ia`: Valida que el tipo de IA sea 'emocional' o 'academica'
- `check_role`: Valida que el rol sea 'user' o 'ia'
- `mensajes_usuarioid_fkey`: Foreign key a `usuarios` con cascade delete

**Trigger:**
- `update_mensajes_updated_at`: Actualiza automáticamente `updated_at` cuando se modifica un mensaje

## Datos Iniciales

El esquema incluye scripts para insertar la configuración inicial de las dos IAs:

1. **Kora** (emocional):
   - Código: 'emocional'
   - Colores: Primario '#6366F1' (índigo), Secundario '#8B5CF6' (púrpura)
   - Prompt base: Enfoque en bienestar emocional, empatía y apoyo

2. **Kora Pro** (académica):
   - Código: 'academica'
   - Colores: Primario '#10B981' (verde), Secundario '#059669' (verde oscuro)
   - Prompt base: Enfoque en rendimiento académico, productividad y planificación

## Modificaciones a Tablas Existentes

**No se requieren modificaciones** a las tablas existentes. El esquema es completamente nuevo y no afecta las tablas actuales.

## Consultas Comunes

### Obtener todos los mensajes de un usuario para un tipo de IA
```sql
SELECT * FROM mensajes
WHERE usuario_id = 'uuid-del-usuario'
  AND tipo_ia = 'emocional'
ORDER BY created_at ASC;
```

### Obtener la configuración de una IA
```sql
SELECT * FROM tipos_ia
WHERE codigo = 'emocional' AND activo = true;
```

### Obtener el último mensaje de cada tipo de IA para un usuario
```sql
SELECT DISTINCT ON (tipo_ia)
  tipo_ia,
  mensaje,
  created_at
FROM mensajes
WHERE usuario_id = 'uuid-del-usuario'
ORDER BY tipo_ia, created_at DESC;
```

### Contar mensajes por tipo de IA
```sql
SELECT tipo_ia, COUNT(*) as total_mensajes
FROM mensajes
WHERE usuario_id = 'uuid-del-usuario'
GROUP BY tipo_ia;
```

## Seguridad (RLS - Row Level Security)

**Recomendación:** Implementar políticas RLS en Supabase para garantizar que:
1. Los usuarios solo puedan ver sus propios mensajes
2. Los usuarios solo puedan crear mensajes para su propio `usuario_id`
3. Los usuarios no puedan modificar mensajes de IAs (solo sus propios mensajes)

Ejemplo de políticas RLS (ejecutar en Supabase SQL Editor):
```sql
-- Habilitar RLS en la tabla mensajes
ALTER TABLE public.mensajes ENABLE ROW LEVEL SECURITY;

-- Política para SELECT: Usuarios solo pueden ver sus propios mensajes
CREATE POLICY "Usuarios pueden ver sus propios mensajes"
ON public.mensajes FOR SELECT
USING (auth.uid() = usuario_id);

-- Política para INSERT: Usuarios solo pueden crear mensajes para sí mismos
CREATE POLICY "Usuarios pueden crear sus propios mensajes"
ON public.mensajes FOR INSERT
WITH CHECK (auth.uid() = usuario_id);

-- Política para UPDATE: Usuarios solo pueden actualizar sus propios mensajes de usuario
CREATE POLICY "Usuarios pueden actualizar sus propios mensajes de usuario"
ON public.mensajes FOR UPDATE
USING (auth.uid() = usuario_id AND role = 'user');

-- Política para DELETE: Usuarios solo pueden eliminar sus propios mensajes
CREATE POLICY "Usuarios pueden eliminar sus propios mensajes"
ON public.mensajes FOR DELETE
USING (auth.uid() = usuario_id);
```

## Notas de Implementación

1. **UUID vs BigInt**: Se utiliza UUID para `id` en lugar de BigInt para mantener consistencia con el resto de las tablas y facilitar la distribución.

2. **Metadata JSONB**: El campo `metadata` permite almacenar información adicional sin modificar el esquema (ej: tokens usados, modelo de IA, versión, etc.).

3. **Índices Compuestos**: Los índices compuestos optimizan las consultas más frecuentes (obtener mensajes por usuario y tipo de IA ordenados por fecha).

4. **Cascade Delete**: Al eliminar un usuario, se eliminan automáticamente todos sus mensajes.

5. **Triggers**: El trigger automático actualiza `updated_at` cuando se modifica un mensaje.

6. **Extensibilidad**: El esquema está diseñado para ser fácilmente expandible:
   - Agregar nuevos tipos de IA solo requiere insertar en `tipos_ia`
   - El campo `metadata` permite agregar información sin cambios al esquema
   - Los índices están optimizados para consultas comunes

## Próximos Pasos

1. Ejecutar los scripts SQL en Supabase
2. Configurar RLS (Row Level Security) si es necesario
3. Crear modelos en Flutter (`TipoIA`, `Mensaje`)
4. Crear servicios en Flutter (`chat_service.dart`, `ia_service.dart`)
5. Integrar con la API de Gemini
6. Crear la interfaz de usuario del chat

