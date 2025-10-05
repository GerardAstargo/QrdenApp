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

### Gestión de Inventario (Funcionalidad Principal)

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

### Mejoras de Perfil y Sincronización

*   **Pantalla de Perfil:** Se añadió una pantalla de perfil accesible desde un icono en la `AppBar` que muestra el correo del usuario y un botón para cerrar sesión.
*   **Cierre de Sesión Persistente:** Se solucionó un problema donde la sesión del usuario no se borraba correctamente al reiniciar la aplicación después de cerrar sesión.
*   **Sincronización con Base de Datos:** Se adaptó el modelo de datos y los servicios para que coincidieran con una estructura de base de datos de Firestore preexistente.

### Vista de Detalles y Generador QR

*   **Pantalla de Detalles:** Se creó una vista detallada para cada producto, accesible desde la lista principal.
*   **Generador de Códigos QR:** Se implementó una pantalla (`qr_generator_screen.dart`) que permite generar códigos QR a partir de un texto aleatorio, facilitando la creación de nuevos identificadores de productos.

### Trazabilidad y Ubicación de Productos

*   **Ingresado por (Creación):**
    *   Se añadió un campo de texto obligatorio **"Ingresado por"** en el formulario de creación de productos (`lib/scanner_screen.dart`).
*   **Ingresado por (Solo Lectura en Edición):**
    *   El campo **"Ingresado por"** se configuró como de solo lectura en la pantalla de edición (`lib/edit_product_screen.dart`) para preservar el registro original.
*   **Ubicación del Producto (Número de Estante):**
    *   Se añadió el campo `numeroEstante` al modelo `Product` (`lib/product_model.dart`).
    *   Se incluyó un nuevo campo de texto **"Número de Estante"** en los formularios de creación (`lib/scanner_screen.dart`) y edición (`lib/edit_product_screen.dart`) para registrar y actualizar la ubicación física del producto.

## Plan Actual

*   **Objetivo:** Completado.
*   **Descripción:** Se han implementado con éxito las mejoras solicitadas para la trazabilidad de quién ingresa el producto y la ubicación física del mismo mediante el número de estante.
