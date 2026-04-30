# 🖼️ Configuración de Imágenes para Notificaciones Push

## ✅ Configuración Actualizada

Las notificaciones push ahora incluyen el logo de ReservaloYA configurado para cada plataforma.

---

## 📱 Tipos de Imágenes en Notificaciones

### 1. **Ícono Pequeño (Small Icon) - Android**
- **Archivo:** `android/app/src/main/res/drawable/notification_icon.xml`
- **Formato:** Vector XML (blanco con fondo transparente)
- **Tamaño:** 24x24 dp
- **Uso:** Ícono principal en la barra de estado y notificación colapsada

**Requisitos Android:**
- Debe ser **blanco** (#FFFFFF)
- Fondo **transparente**
- Sin colores ni detalles complejos
- Solo la silueta del logo

### 2. **Ícono Grande (Large Icon) - Android**
- **URL:** `https://reservaloya.cl/logo/android-chrome-192x192.png`
- **Formato:** PNG
- **Tamaño:** 192x192 px (recomendado)
- **Uso:** Se muestra cuando la notificación se expande

### 3. **Imagen Rich - iOS**
- **URL:** `https://reservaloya.cl/logo/android-chrome-192x192.png`
- **Formato:** PNG o JPEG
- **Tamaño:** 400x400 px (mínimo)
- **Uso:** Imagen grande en notificaciones iOS (requiere configuración adicional)

### 4. **Ícono Web**
- **Archivo:** `/logo/favicon-32x32.png`
- **Formato:** PNG
- **Tamaño:** 32x32 px
- **Uso:** Notificaciones en navegadores web

---

## 🔧 Configuración en el Backend

### Archivo: `booking-sport/internal/infra/notification_service.go`

```go
message := &messaging.MulticastMessage{
    Notification: &messaging.Notification{
        Title: title,
        Body:  body,
        Image: "https://reservaloya.cl/logo/android-chrome-192x192.png",
    },
    Android: &messaging.AndroidConfig{
        Notification: &messaging.AndroidNotification{
            Icon:  "notification_icon",  // Referencia al drawable XML
            Color: "#2C3345",            // Color primario
        },
    },
    APNS: &messaging.APNSConfig{
        Payload: &messaging.APNSPayload{
            Aps: &messaging.Aps{
                Sound:        "default",
                MutableContent: true,  // Para rich notifications
            },
        },
    },
}
```

---

## 📊 Cómo se Verán las Notificaciones

### Android

**Notificación Colapsada:**
```
┌────────────────────────────────────┐
│ 🔔 ReservaloYA                    │
│    Nueva Reserva                  │
│    Se ha realizado una nueva...   │
│    [Ícono blanco pequeño]         │
└────────────────────────────────────┘
```

**Notificación Expandida:**
```
┌────────────────────────────────────┐
│ 🔔 ReservaloYA                    │
│    Nueva Reserva                  │
│    Se ha realizado una nueva...   │
│                                   │
│    [Logo 192x192 a color]         │
│                                   │
│    [Botón de acción]              │
└────────────────────────────────────┘
```

### iOS

**Notificación Estándar:**
```
┌────────────────────────────────────┐
│ ReservaloYA           [Logo 192]  │
│ Nueva Reserva                     │
│ Se ha realizado una nueva...      │
└────────────────────────────────────┘
```

---

## ⚠️ Consideraciones Importantes

### Android

1. **Ícono Pequeño (notification_icon.xml):**
   - ✅ Debe ser vector XML blanco
   - ✅ Sin colores
   - ✅ Fondo transparente
   - ❌ No usar PNG a color

2. **Color de Acento:**
   - Configurado en `#2C3345` (color primario de la app)
   - Tinta el ícono de notificación en algunos dispositivos

3. **Imagen Grande:**
   - Debe estar en URL pública accesible
   - Se descarga automáticamente cuando se expande la notificación
   - Opcional pero recomendado

### iOS

1. **Rich Notifications:**
   - Requiere `MutableContent: true`
   - Para mostrar imagen grande, se necesita un Notification Service Extension
   - Sin extensión, solo se muestra el ícono de la app

2. **Ícono de App:**
   - iOS usa automáticamente el ícono de la aplicación
   - No se puede personalizar por notificación

3. **Imagen:**
   - La propiedad `Image` en el payload requiere configuración adicional
   - Se recomienda implementar UNSE (User Notification Service Extension)

---

## 🎨 Optimización de Imágenes

### Logo Actual
- **Archivo:** `logo-reservaloya.png` (1712x608 px, 251KB)
- **Problema:** Muy grande para notificaciones
- **Solución:** Usar `android-chrome-192x192.png` (39KB)

### Recomendaciones

1. **Crear versión específica para notificaciones:**
   - Tamaño: 192x192 px o 256x256 px
   - Formato: PNG con transparencia
   - Peso: < 50KB
   - Relación de aspecto: 1:1 (cuadrado)

2. **Ubicación:**
   - Subir a: `booking-sport-ui/public/logo/notification-icon.png`
   - URL: `https://reservaloya.cl/logo/notification-icon.png`

3. **Actualizar backend:**
   ```go
   Image: "https://reservaloya.cl/logo/notification-icon.png",
   ```

---

## 🧪 Pruebas

### Verificar Ícono Android

1. **Build de la app:**
   ```bash
   flutter build apk --debug
   ```

2. **Enviar notificación de prueba:**
   - Firebase Console → Cloud Messaging → New Notification
   - Enviar a dispositivo específico

3. **Verificar:**
   - Ícono en barra de estado: blanco, pequeño
   - Ícono en notificación: logo a color 192x192
   - Color de acento: #2C3345

### Verificar en Diferentes Android Versions

- **Android 5-7:** Solo ícono pequeño
- **Android 8+:** Ícono pequeño + imagen grande
- **Android 10+:** Notificaciones más ricas

---

## 📁 Archivos Modificados

### Backend
- ✅ `booking-sport/internal/infra/notification_service.go`
  - Agregado `Icon: "notification_icon"`
  - Agregado `Color: "#2C3345"`
  - Agregado `Image: "https://reservaloya.cl/logo/android-chrome-192x192.png"`
  - Agregado `MutableContent: true` para iOS

### Flutter Mobile
- ✅ `booking-mobile-admin/android/app/src/main/res/drawable/notification_icon.xml`
  - Ícono vectorial blanco para notificaciones

### Web (ya existentes)
- `booking-sport-ui/public/logo/android-chrome-192x192.png`
- `booking-sport-ui/public/logo/favicon-32x32.png`

---

## 🔗 URLs de Imágenes Usadas

| Plataforma | Tipo | URL | Tamaño |
|------------|------|-----|--------|
| Android | Small Icon | `notification_icon` (local) | 24x24 dp |
| Android | Large Icon | `https://reservaloya.cl/logo/android-chrome-192x192.png` | 192x192 px |
| iOS | Rich Image | `https://reservaloya.cl/logo/android-chrome-192x192.png` | 192x192 px |
| Web | Icon | `/logo/favicon-32x32.png` | 32x32 px |
| Web | Image | `/logo/android-chrome-192x192.png` | 192x192 px |

---

## ✅ Checklist

- [x] Backend actualizado con configuración de imágenes
- [x] Ícono notification_icon.xml creado
- [x] URLs de imágenes configuradas
- [x] Color de acento configurado (#2C3345)
- [x] MutableContent habilitado para iOS
- [ ] Pruebas en dispositivo Android
- [ ] Pruebas en dispositivo iOS
- [ ] Verificar que las imágenes sean accesibles desde internet
- [ ] Opcional: Crear versión optimizada del logo (192x192, cuadrado)

---

**Nota:** Para que las imágenes se muestren correctamente, el dominio `reservaloya.cl` debe ser accesible públicamente y las URLs deben responder con los headers CORS apropiados.
