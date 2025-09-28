# Blueprint de la Aplicación

## Visión General

Esta es una aplicación Flutter llamada **Qrden** que proporciona autenticación de usuarios y una pantalla de inicio para gestionar un inventario de bodega mediante el escaneo de códigos QR. La aplicación utiliza Firebase para la autenticación y Cloud Firestore para la base de datos.

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

### Mejoras de Perfil
*   Se añadió una pantalla de perfil accesible desde un icono en la `AppBar`.
*   La pantalla de perfil muestra el correo del usuario y un botón para cerrar sesión.

### Corrección de Cierre de Sesión Persistente

*   **Problema:** La sesión del usuario no se borraba correctamente al reiniciar la aplicación después de cerrar sesión.
*   **Solución:** Se simplificó la función `_signOut` en `lib/profile_screen.dart`. Se eliminó la navegación manual y redundante (`Navigator.pushAndRemoveUntil`) para depender únicamente del `StreamBuilder` en `main.dart` como la única fuente de verdad para el estado de autenticación. Esto asegura que el estado se maneje de forma consistente y se eviten condiciones de carrera. Se añadió también un manejo de errores para diagnosticar problemas durante el cierre de sesión.

## Plan Actual

*   **Objetivo:** Cambiar la marca de la aplicación a "Qrden".
*   **Pasos:**
    1.  **Actualizar Logo:** Cambiar el logo en `lib/login_screen.dart` por el texto "Qrden".
    2.  **Actualizar Título de la App:** Cambiar el título en `lib/main.dart` a "Qrden".
    3.  **Actualizar AppBar:** Cambiar el título en la barra de navegación de `lib/home_screen.dart` a "Qrden".
