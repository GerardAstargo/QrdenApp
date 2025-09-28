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

### Sincronización con Base de Datos Existente

*   **Problema:** La aplicación y la base de datos de Firestore tenían estructuras de datos diferentes (nombres de colección y campos).
*   **Solución:**
    1.  Se actualizó `product_model.dart` para mapear los nombres de campo de Firestore (`nombreproducto`, `stock`, `categoria`) a los del modelo de la app (`name`, `quantity`, `description`).
    2.  Se actualizó `firestore_service.dart` para apuntar a la colección `producto` y usar los nombres de campo correctos al escribir datos.

### Vista de Detalles del Producto

*   Se creó una pantalla de detalles para mostrar toda la información de un producto (`product_detail_screen.dart`).
*   Se habilitó la navegación desde la lista de productos a la pantalla de detalles.
*   Se añadió el campo `precio` al modelo y al formulario de creación.
*   Se corrigió un error de importación en `home_screen.dart`.
*   Se restauró el diseño original de los botones de acción a petición del usuario.

### Generador de Códigos QR

*   Se añadió el paquete `qr_flutter`.
*   Se creó una pantalla (`qr_generator_screen.dart`) que permite al usuario introducir texto y generar un QR.
*   Se integró el acceso a esta pantalla desde un nuevo botón en la pantalla principal.
*   Se corrigió un error de importación recurrente en `home_screen.dart`.

## Plan Actual

*   **Objetivo:** Mejorar la modificación de productos y la generación de códigos QR.
*   **Pasos:**
    1.  **Modificación Completa de Productos:**
        *   Crear una nueva pantalla `lib/edit_product_screen.dart` que contenga un formulario para editar todos los detalles de un producto.
        *   Actualizar `lib/firestore_service.dart` con un método `updateProduct` que guarde todos los datos de un producto.
        *   Modificar `lib/scanner_screen.dart` para que, en el modo `update`, navegue a la nueva pantalla de edición con los datos precargados.
    2.  **Generación de Códigos QR Aleatorios:**
        *   Modificar `lib/qr_generator_screen.dart` para que genere automáticamente un código numérico aleatorio.
        *   Eliminar el campo de texto manual y añadir un botón para generar un nuevo código si se desea.
