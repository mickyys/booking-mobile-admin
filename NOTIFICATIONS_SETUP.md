# Configuración de Notificaciones Push - Flutter Mobile

## ✅ Implementación Completada

Las notificaciones push han sido implementadas en la aplicación Flutter siguiendo la arquitectura Clean Architecture.

### 📁 Archivos Creados

```
lib/features/notification/
├── data/
│   ├── datasources/
│   │   ├── notification_remote_data_source.dart (interfaz)
│   │   └── notification_remote_data_source_impl.dart (implementación)
│   ├── repositories/
│   │   └── notification_repository_impl.dart
│   └── models/
│       └── device_token_model.dart
├── domain/
│   ├── repositories/
│   │   └── notification_repository.dart
│   └── usecases/
│       └── register_device_usecase.dart
└── presentation/
    └── notification_manager.dart
```

### 🔧 Configuración Requerida

#### 1. Instalar Dependencias

```bash
cd booking-mobile-admin
flutter pub get
```

#### 2. Configurar Firebase

**Opción A: Usando FlutterFire CLI (Recomendado)**

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Ejecutar configuración
flutterfire configure --project=reservaloya-2a59c
```

Esto generará automáticamente:
- `lib/core/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

**Opción B: Configuración Manual**

1. **Android:**
   - Descargar `google-services.json` desde Firebase Console
   - Colocar en: `android/app/google-services.json`
   - ✅ Ya configurado en `android/app/build.gradle.kts`: `id("com.google.gms.google-services")`

2. **iOS:**
   - Descargar `GoogleService-Info.plist` desde Firebase Console
   - Colocar en: `ios/Runner/GoogleService-Info.plist`
   - ✅ Ya configurado en `ios/Runner/Info.plist`: `UIBackgroundModes` con `remote-notification`

#### 3. Habilitar Firebase Cloud Messaging

1. Ir a Firebase Console → Project Settings → Cloud Messaging
2. Habilitar FCM para iOS y Android
3. Para iOS:
   - Subir certificado APNs (Authentication Key)
   - Habilitar "Push Notifications" en Signing & Capabilities

#### 4. Configurar Permisos

**iOS** (`ios/Runner/Info.plist`):
- ✅ Ya configurado: `UIBackgroundModes` con `remote-notification`

**Android** (`android/app/src/main/AndroidManifest.xml`):
- ✅ Ya configurados los permisos:
  - `INTERNET`
  - `POST_NOTIFICATIONS` (Android 13+)
  - `RECEIVE_BOOT_COMPLETED`
  - `VIBRATE`
  - `WAKE_LOCK`

### 🚀 Cómo Funciona

#### Registro Automático

El dispositivo se registra automáticamente después del login exitoso:

1. Usuario inicia sesión (email/password o social)
2. `AuthBloc` obtiene token FCM
3. Registra dispositivo en backend: `POST /api/users/devices`
4. Backend asocia token al centro deportivo del usuario

#### Recepción de Notificaciones

- **Foreground:** Muestra notificación local con `flutter_local_notifications`
- **Background:** Manejado por `firebaseMessagingBackgroundHandler`
- **Tap en notificación:** Navega a `/dashboard?booking_id={id}`

#### Tipos de Notificaciones

El backend envía notificaciones en los siguientes casos:

1. **Nueva Reserva** - Cuando un cliente reserva una cancha
2. **Pago Confirmado** - Cuando se confirma el pago (Fintoc/MercadoPago)
3. **Reserva Cancelada** - Cuando se cancela una reserva

### 📱 Estructura del Payload

```json
{
  "notification": {
    "title": "Nueva Reserva",
    "body": "Se ha realizado una nueva reserva en Centro Deportivo..."
  },
  "data": {
    "booking_id": "65f1234567890abcdef12345",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

### 🧪 Pruebas

#### Enviar Notificación de Prueba

1. **Desde Firebase Console:**
   - Ir a Cloud Messaging → New Notification
   - Completar título y mensaje
   - Enviar a todo el app o a un token específico

2. **Desde Backend (ya implementado):**
   - Crear una reserva de prueba
   - El backend automáticamente notifica a los admins

#### Verificar Registro

```bash
# En MongoDB, colección user_devices
db.user_devices.find().pretty()
```

### 🔍 Debugging

Habilitar logs detallados:

```dart
// El NotificationManager ya incluye logs con print
// Buscar en consola:
// - [NotificationManager]
// - [FCM Token]
// - [Foreground Message]
// - [Background Message]
// - [Navigation]
```

### ⚠️ Consideraciones

1. **iOS Simulator:** No soporta notificaciones push. Usar dispositivo físico.
2. **Android Emulator:** Funciona pero requiere Google Play Services.
3. **Tokens:** Se regeneran periódicamente. El backend maneja actualizaciones.
4. **Permisos Android 13+:** Se solicitan automáticamente en el primer login.

### 📚 Referencias

- [Firebase Messaging Flutter](https://firebase.flutter.dev/docs/messaging/overview/)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Backend: notification_service.go](../booking-sport/internal/infra/notification_service.go)

### ✅ Checklist Final

- [ ] Ejecutar `flutter pub get`
- [ ] Configurar Firebase con `flutterfire configure`
- [ ] Agregar `google-services.json` (Android)
- [ ] Agregar `GoogleService-Info.plist` (iOS)
- [ ] Habilitar Push Notifications en Firebase Console
- [ ] Subir certificado APNs para iOS (si es necesario)
- [ ] Probar en dispositivo físico
- [ ] Verificar registro en MongoDB
- [ ] Probar flujo completo de reserva

---

**Nota:** La configuración de Firebase ya está pre-configurada con el proyecto `reservaloya-2a59c`. Solo es necesario ejecutar `flutterfire configure` o agregar manualmente los archivos de configuración.
