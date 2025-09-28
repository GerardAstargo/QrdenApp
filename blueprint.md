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
*   **Solución:** Se simplificó la función `_signOut` en `lib/profile_screen.dart` para depender únicamente del `StreamBuilder` en `main.dart` para manejar el estado de autenticación de forma reactiva.

## Plan Actual

*   **Objetivo:** Sincronizar la aplicación con la estructura real de la base de datos de Firestore.
*   **Pasos:**
    1.  **Ajustar el Modelo de Datos (`product_model.dart`):**
        *   Actualizar el constructor `fromFirestore` para mapear los campos de la base de datos (`nombreproducto`, `stock`, `categoria`) a los campos del modelo de la aplicación (`name`, `quantity`, `description`).
    2.  **Ajustar el Servicio de Base de Datos (`firestore_service.dart`):**
        *   Cambiar el nombre de la colección de `products` a `producto`.
        *   Actualizar las funciones `addProduct` y `updateProductQuantity` para que escriban en la base de datos usando los nombres de campo correctos (`nombreproducto`, `stock`, etc.).
