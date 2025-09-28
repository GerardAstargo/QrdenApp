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

## Plan Actual

*   **Objetivo:** Crear una vista de detalle para mostrar toda la información de un producto y permitir el ingreso del precio.
*   **Pasos:**
    1.  **Actualizar `product_model.dart`:** Añadir los campos `precio` (double) y `fechaingreso` (Timestamp) al modelo de datos.
    2.  **Actualizar `scanner_screen.dart`:** Añadir un campo de texto para `precio` en el diálogo de creación de producto.
    3.  **Actualizar `firestore_service.dart`:** Modificar la función `addProduct` para que acepte y guarde el nuevo campo `precio`.
    4.  **Crear `product_detail_screen.dart`:** Diseñar una nueva pantalla que reciba un objeto `Product` y muestre todos sus detalles.
    5.  **Actualizar `home_screen.dart`:** Hacer que los elementos de la lista de productos sean interactivos. Al tocar un producto, se navegará a la pantalla de detalles, pasándole la información del producto seleccionado.
