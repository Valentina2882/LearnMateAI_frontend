Estoy trabajando en una app Flutter llamada LearnMate, que tiene dos inteligencias artificiales llamadas Kora (bienestar emocional) y Kora Pro (rendimiento académico).

Ambas van a usar la misma base de datos Supabase, y necesito que los mensajes y el tipo de IA estén correctamente identificados.

Quiero que configures Supabase y Flutter para esto:

Crear o actualizar las tablas necesarias en Supabase:

users → datos básicos del usuario (id, nombre, email, etc.)

messages → historial de chat con los siguientes campos:

Campo	Tipo	Descripción
id	bigint (PK)	autoincrement
user_id	uuid	referencia al usuario
ia_type	text	valores posibles: emocional o academica
role	text	puede ser user o ia
message	text	contenido del mensaje
created_at	timestamp	valor automático

Crear un modelo Message en Flutter con los campos mencionados.

Crear un servicio supabase_service.dart con funciones:

saveMessage(String userId, String iaType, String role, String message)

Future<List<Message>> getMessages(String userId, String iaType)

Asegúrate de que cada vez que se envía o recibe un mensaje del chat, se guarde correctamente con su ia_type.

Objetivo:
Tener la base de datos Supabase lista para soportar múltiples IAs (emocional y académica) y un servicio en Flutter que lea y guarde mensajes de forma separada por tipo de IA.

Es importante que el código sea claro, organizado en carpetas (models, services, screens) y fácil de expandir luego.

