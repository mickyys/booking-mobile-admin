# 🔧 Configuración de API para Desarrollo

## ⚠️ Error de Conexión

El error `Failed host lookup: 'dev.api.reservaloya.cl'` indica que el emulador/dispositivo no puede resolver el dominio.

---

## 🛠️ Soluciones

### Opción 1: Usar API Local (Recomendado para Desarrollo)

Ejecutar la app apuntando al backend local:

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8080/api
```

**Para dispositivo físico:**
```bash
flutter run --dart-define=API_URL=http://TU_IP_LOCAL:8080/api
```

**IPs comunes:**
- Emulador Android: `10.0.2.2` o `localhost`
- Dispositivo físico: `192.168.x.x` (tu IP local)
- iOS Simulator: `localhost`

---

### Opción 2: Usar API de Producción

Si el backend está desplegado y accesible:

```bash
flutter run --dart-define=API_URL=https://dev.api.reservaloya.cl/api
```

**Requisitos:**
- ✅ El dominio debe ser accesible desde internet
- ✅ El emulador/dispositivo debe tener conexión a internet
- ✅ Verificar DNS: `ping dev.api.reservaloya.cl`

---

### Opción 3: Configurar en main.dart

Modificar `lib/main.dart` para usar configuración por defecto:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuración manual si es necesario
  const apiUrl = 'http://10.0.2.2:8080/api';
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await di.init();
  // ...
}
```

---

## 📱 Comandos de Ejecución

### Desarrollo Local (Backend en localhost)

```bash
# Emulador Android
flutter run --dart-define=API_URL=http://10.0.2.2:8080/api

# iOS Simulator
flutter run --dart-define=API_URL=http://localhost:8080/api

# Dispositivo físico (reemplaza con tu IP)
flutter run --dart-define=API_URL=http://192.168.1.100:8080/api
```

### Producción

```bash
flutter run --dart-define=API_URL=https://dev.api.reservaloya.cl/api
```

---

## 🔍 Debugging de Conexión

### Verificar Backend Local

```bash
# Verificar que el backend esté corriendo
curl http://localhost:8080/api/sport-centers

# Ver logs del backend
tail -f booking-sport/app.log
```

### Verificar desde el Emulador

```bash
# Desde ADB shell
adb shell ping 10.0.2.2

# Verificar DNS
adb shell nslookup dev.api.reservaloya.cl
```

### Verificar Logs de la App

Buscar en logs:
```
🌐 DIO: uri: http://10.0.2.2:8080/api/...
[Notification] Registering device for notifications...
[AuthBloc] Device registered successfully
```

---

## ⚙️ Configuración Actual

**Archivo:** `lib/core/config/app_config.dart`

```dart
static const String apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8080/api', // Cambiar según necesidad
);
```

**Valores por defecto:**
- Desarrollo: `http://10.0.2.2:8080/api`
- Producción: `https://dev.api.reservaloya.cl/api`

---

## ✅ Checklist para Producción

- [ ] Backend desplegado y accesible
- [ ] Dominio resuelve correctamente
- [ ] SSL/TLS configurado (HTTPS)
- [ ] CORS configurado para permitir requests móviles
- [ ] Auth0 configurado con audiencia correcta
- [ ] Firebase configurado correctamente
- [ ] Probar en dispositivo físico con conexión real

---

## 🚨 Errores Comunes

### 1. `Failed host lookup`
- **Causa:** Dominio no resuelve
- **Solución:** Verificar DNS o usar IP directa

### 2. `Connection refused`
- **Causa:** Backend no está corriendo
- **Solución:** Iniciar backend en puerto correcto

### 3. `Network unreachable`
- **Causa:** Sin conexión a internet
- **Solución:** Verificar conexión del emulador/dispositivo

### 4. `CORS error`
- **Causa:** Backend no permite origen móvil
- **Solución:** Configurar CORS en backend

---

## 📝 Notas

1. **Emulador Android:**
   - `localhost` o `127.0.0.1` = localhost del emulador
   - `10.0.2.2` = localhost de tu máquina

2. **iOS Simulator:**
   - `localhost` = localhost de tu máquina

3. **Dispositivo Físico:**
   - Usar IP local de tu máquina (ej: `192.168.1.x`)
   - Ambos deben estar en la misma red WiFi

---

**Recomendación:** Usar `http://10.0.2.2:8080/api` para desarrollo local y cambiar a producción solo para testing final.
