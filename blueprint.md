
# Blueprint: Qrden - Gestión de Inventario con QR

## 1. Visión General del Proyecto

**Qrden** es una aplicación móvil moderna, diseñada para una gestión de inventario eficiente e intuitiva. El núcleo de la aplicación es el uso de códigos QR para simplificar drásticamente el proceso de añadir, modificar, eliminar y consultar productos.

Construida con Flutter y Firebase, Qrden ofrece una experiencia de usuario fluida, en tiempo real y multiplataforma (iOS y Android), con un diseño profesional y cuidado al detalle.

---

## 2. Plan para la Solicitud Actual (Rediseño y Mejora Funcional)

Esta sección describe los cambios que se implementarán en la versión actual, basados en la última solicitud del usuario.

**A. Renovación del Diseño Visual:**
- **Objetivo:** Modernizar la interfaz para que sea más elegante y sofisticada.
- **Paleta de Colores:** Se migrará del `Colors.deepPurple` a un azul pizarra (`#005f73`) como color semilla para generar una paleta más profesional.
- **Tipografía:** Se implementará una combinación de fuentes más refinada:
    - **Montserrat** para títulos y encabezados, aportando un estilo moderno y limpio.
    - **Lato** para el cuerpo de texto, garantizando una legibilidad óptima.
- **Estilo de Componentes:** Se ajustarán los estilos de tarjetas, botones y otros elementos para que armonicen con la nueva estética.

**B. Mejora de la Lógica de Gestión de Productos:**
- **Objetivo:** Hacer la gestión de productos más clara e intuitiva.
- **Botón "Eliminar":** El antiguo botón de "Archivar" se convertirá en un botón de "Eliminar" (icono de papelera), que **borrará permanentemente** el producto de la base de datos, previa confirmación del usuario.
- **Botón "Modificar":** Se añadirá un nuevo botón "Modificar" (icono de lápiz) en la pantalla de detalles. Este permitirá editar **toda la información de un producto existente**, incluyendo el ajuste de stock, reutilizando el formulario de creación de productos.

---

## 3. Características Principales (Actualizadas)

- **Autenticación Segura:**
  - Inicio de sesión con correo y contraseña (`Firebase Authentication`).
- **Gestión Completa de Inventario:**
  - **Añadir:** Escanea un QR para dar de alta un nuevo producto.
  - **Modificar:** Edita la información completa de un producto, incluido el stock, desde un formulario dedicado.
  - **Eliminar:** Escanea un QR o usa un botón en la pantalla de detalles para **eliminar permanentemente** un producto.
  - **Visualización:** Lista en tiempo real de todos los productos.
- **Escáner y Generador de QR:**
  - Escáner con `mobile_scanner` y generador con `qr_flutter`.
- **Detalles del Producto:**
  - Vista dedicada con toda la información del producto.
- **Perfil de Usuario:**
  - Pantalla para ver datos de la cuenta y cerrar sesión.

---

## 4. Arquitectura de la Aplicación

Qrden sigue una arquitectura limpia y por capas para garantizar la separación de responsabilidades, la mantenibilidad y la escalabilidad.

- **Gestión de Estado:** `provider` para el estado global (tema) y `StatefulWidget` para el estado local.
- **Flujo de Datos y Servicios:**
  - **Capa de Presentación (UI):** Widgets y pantallas.
  - **Capa de Servicio (`firestore_service.dart`):** Abstrae la lógica de acceso a datos de Firestore.
  - **Capa de Modelo de Datos (`product_model.dart`):** Define la estructura del objeto `Product`.
- **Navegación:** `MaterialPageRoute` y un `AuthGate` para gestionar las rutas según el estado de autenticación.

---

## 5. Diseño Visual y Tema (Theming - Actualizado)

El diseño de Qrden se centra en la claridad, la modernidad y una experiencia de usuario elegante.

- **Esquema de Color:**
  - Basado en **Material 3 (`useMaterial3: true`)**.
  - Utiliza `ColorScheme.fromSeed` con un color semilla **azul pizarra (`#005f73`)** para generar paletas armoniosas.
- **Tipografía:**
  - **Montserrat** para títulos y **Lato** para el cuerpo de texto, usando `google_fonts`.
  - Jerarquía de texto bien definida en el `TextTheme`.
- **Estilo de Componentes:**
  - Temas específicos para `AppBar`, `ElevatedButton`, `Card`, etc., garantizando una apariencia unificada.
- **Animaciones:**
  - `flutter_staggered_animations` y `animations` para enriquecer la experiencia de usuario.

---

## 6. Dependencias Clave

- **Firebase:** `firebase_core`, `firebase_auth`, `cloud_firestore`.
- **Estado y Utilidades:** `provider`, `intl`.
- **UI y Diseño:** `google_fonts`, `mobile_scanner`, `qr_flutter`.
- **Animaciones:** `flutter_staggered_animations`, `animations`.
