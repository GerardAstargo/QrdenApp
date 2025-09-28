# Blueprint de la Aplicación

## Visión General

Esta es una aplicación Flutter que proporciona autenticación de usuarios y una pantalla de inicio para gestionar un inventario de bodega mediante el escaneo de códigos QR. La aplicación utiliza Firebase para la autenticación y Cloud Firestore para la base de datos.

## Diseño y Características

### Versión Inicial

*   **Autenticación:**
    *   Pantalla de inicio de sesión con correo electrónico y contraseña.
    *   Validación de formulario para correo electrónico y contraseña.
    *   Manejo de errores para credenciales incorrectas.
*   **Pantalla de Inicio:**
    *   Pantalla de inicio simple que se muestra después de iniciar sesión.
    *   Botón para cerrar sesión.
*   **Navegación:**
    *   Navegación básica entre la pantalla de inicio de sesión y la pantalla de inicio.

### Cambios de Gestión de Inventario

*   **Integración de Firebase:** Autenticación con Firebase Auth y base de datos en tiempo real con Cloud Firestore.
*   **Escaneo de Códigos QR:** Se usa `mobile_scanner` para añadir, eliminar o modificar productos mediante la cámara.
*   **Arquitectura Limpia:**
    *   `firestore_service.dart`: Lógica de base de datos.
    *   `product_model.dart`: Modelo de datos para productos.
    *   `home_screen.dart`: Vista principal con acciones y lista de inventario.
    *   `scanner_screen.dart`: Pantalla para el escaneo de códigos QR.
*   **Interfaz Funcional:**
    *   La pantalla de inicio presenta los botones de **Añadir, Eliminar y Modificar**.
    *   Muestra una lista en tiempo real del inventario de la bodega.

## Plan Actual

*   **Objetivo:** Añadir una pantalla de perfil de usuario y la funcionalidad para cerrar sesión.
*   **Pasos:**
    1.  Crear un nuevo archivo `lib/profile_screen.dart`.
    2.  Esta pantalla mostrará el correo electrónico del usuario actual y un botón para "Cerrar Sesión".
    3.  Añadir un `IconButton` con un icono de perfil en la `AppBar` de `lib/home_screen.dart`.
    4.  Al presionar el icono, se navegará a la nueva `ProfileScreen`.
    5.  Implementar la lógica para cerrar sesión usando `FirebaseAuth.instance.signOut()` en `ProfileScreen`.

