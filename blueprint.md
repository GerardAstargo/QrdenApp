# Blueprint de la Aplicación de Inventario con QR

## Visión General

Esta es una aplicación móvil desarrollada en Flutter para la gestión de inventario. Permite a los empleados autenticados registrar, visualizar y gestionar productos mediante el escaneo de códigos QR. La aplicación se integra con Firebase para la autenticación de usuarios y el almacenamiento de datos en Firestore.

## Características y Diseño Implementados

### 1. **Estructura y Navegación (go_router)**
   - **Enrutamiento Declarativo:** Se utiliza `go_router` para una navegación robusta y basada en URLs.
   - **Rutas Definidas:** `/`, `/login`, `/home`, `/scanner`, `/generator`, `/product/:name`, `/history`, `/profile`.
   - **Navegación con BottomNavigationBar:** Un `ScaffoldWithNavBar` gestiona la navegación principal entre las pantallas Home, Scanner, Generator, History y Profile.

### 2. **Autenticación (Firebase Auth)**
   - **Inicio y Cierre de Sesión:** Autenticación con email/contraseña y gestión de sesión mediante un `AuthWrapper` que redirige automáticamente.

### 3. **Base de Datos (Firestore)**
   - **Servicio Firestore (`firestore_service.dart`):** Clase que centraliza todas las interacciones con la base de datos.
   - **Colecciones:** `empleados`, `producto`, `categoria`, `registro`.
   - **Modelos de Datos:**
     - `Empleado`: Modela los datos del usuario. Incluye los campos `id`, `nombre`, `email`, `cargo`, `rut` y `telefono`.
     - `Product`: Modela los productos del inventario.
     - `HistoryEntry`: Modela las entradas del historial de movimientos.

### 4. **Diseño y Experiencia de Usuario (Material 3)**
   - **Tema Moderno:** La aplicación utiliza Material Design 3 (`useMaterial3: true`).
   - **Tema Oscuro/Claro:** Implementado con un `ThemeProvider` y un interruptor accesible desde la pantalla principal.
   - **Fuentes Personalizadas (`google_fonts`):** Se utiliza `google_fonts` para mejorar la tipografía.
   - **Feedback al Usuario:** Indicadores de carga y mensajes de error claros.

### 5. **Funcionalidades Clave por Pantalla**
   - **HomeScreen:** Muestra una lista en tiempo real de los productos del inventario.
   - **ScannerScreen / QRGeneratorScreen:** Gestionan el escaneo y la creación de códigos QR.
   - **HistoryScreen:** Muestra el historial de movimientos de inventario.
   - **ProfileScreen:**
     - **Diseño Fiel a la Imagen:** La pantalla ha sido rediseñada para ser una réplica visual de la maqueta proporcionada por el usuario.
     - **Información Detallada:** Muestra la información completa del empleado obtenida de Firestore, incluyendo:
       - Nombre y Cargo.
       - Una tarjeta de información con Email, RUT y Teléfono, cada uno con su icono correspondiente.
     - **Cierre de Sesión:** Contiene un botón estilizado en la parte inferior para cerrar la sesión de forma segura.

## Plan de Implementación (Historial de Cambios Recientes)

### Tarea Actual: Rediseño de la Pantalla de Perfil y Ampliación del Modelo de Datos

1.  **Objetivo:** Replicar el diseño de la pantalla de perfil proporcionado en una imagen por el usuario, que incluía más campos de datos.

2.  **Paso 1: Actualizar Modelo de Datos.**
    - Se modificó `lib/models/empleado_model.dart`.
    - Se añadieron a la clase `Empleado` los campos `cargo`, `rut` y `telefono` para que coincidiera con los datos requeridos por el nuevo diseño.

3.  **Paso 2: Rediseñar la Interfaz de Usuario (UI).**
    - Se reescribió por completo el archivo `lib/profile_screen.dart`.
    - Se implementó la estructura visual de la imagen, incluyendo:
        - Encabezado con avatar circular, nombre y cargo.
        - Tarjeta de información detallada con iconos para Email, RUT y Teléfono.
        - Botón de cierre de sesión rojo en la parte inferior de la pantalla.

4.  **Paso 3: Corrección de Errores y Refinamiento.**
    - Se solucionó un error crítico en `lib/services/firestore_service.dart`, actualizando la llamada al constructor del modelo de `Empleado.fromFirestore` a `Empleado.fromMap` para reflejar la refactorización del modelo.
    - Se eliminaron advertencias de variables no utilizadas para limpiar el código.

5.  **Resultado:** La pantalla de perfil es ahora funcional y visualmente idéntica al diseño solicitado. El modelo de datos ha sido ampliado para soportar la nueva información, y el código ha sido validado con `flutter analyze` para garantizar que no hay errores.
