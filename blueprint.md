
# Blueprint: Qrden - Gestión de Inventario con QR

## 1. Visión General del Proyecto

**Qrden** es una aplicación móvil moderna, diseñada para una gestión de inventario eficiente e intuitiva. El núcleo de la aplicación es el uso de códigos QR para simplificar drásticamente el proceso de añadir, modificar, eliminar y consultar productos.

Construida con Flutter y Firebase, Qrden ofrece una experiencia de usuario fluida, en tiempo real y multiplataforma (iOS y Android), con un diseño profesional y cuidado al detalle.

---

## 2. Características Principales

- **Autenticación Segura:**
  - Inicio de sesión de usuarios a través de correo electrónico y contraseña, gestionado por **Firebase Authentication**.
  - Persistencia de la sesión para una experiencia de usuario continua.

- **Gestión Completa de Inventario:**
  - **Añadir:** Escanea un código QR único para dar de alta un nuevo producto, rellenando sus detalles en un formulario modal.
  - **Modificar:** Escanea el QR de un producto existente para editar su información.
  - **Eliminar:** Escanea el QR de un producto para confirmar su eliminación del inventario.
  - **Visualización:** Una lista principal muestra en tiempo real todos los productos del inventario, con su nombre, categoría y stock.
  - **Búsqueda de Productos:**
    - Una barra de búsqueda fija y estilizada está integrada directamente en el `AppBar` como elemento principal, ofreciendo acceso inmediato a la funcionalidad de búsqueda.
    - Filtra la lista de productos por nombre en tiempo real a medida que el usuario escribe.
    - La búsqueda no distingue entre mayúsculas y minúsculas para una mayor comodidad.
    - Incluye un icono de búsqueda y un botón para limpiar el campo de texto fácilmente.
    - Se muestra un mensaje claro cuando la búsqueda no arroja resultados.


- **Escáner y Generador de QR:**
  - **Escáner Inteligente:** Utiliza la cámara del dispositivo (`mobile_scanner`) para detectar códigos QR. El modo de escaneo (Añadir, Modificar, Eliminar) se selecciona a través de un menú FAB expandible.
  - **Generador de QR:** Crea códigos QR únicos (`qr_flutter`) para identificar nuevos productos que aún no tienen uno.

- **Historial de Actividad (En Desarrollo):**
  - Se ha añadido un botón de "Historial" en la barra de navegación superior.
  - Se han creado los archivos base (`history_screen.dart`, `history_model.dart`) para la futura implementación de esta pantalla.

- **Detalles del Producto:**
  - Una vista dedicada muestra toda la información de un producto: nombre, categoría, stock, precio, fecha de ingreso, usuario que lo ingresó y número de estante.

- **Perfil de Usuario:**
  - Pantalla donde el usuario puede ver su nombre y correo electrónico.
  - Funcionalidad para cerrar sesión de forma segura.

- **Tema Dinámico y Moderno:**
  - **Inicio en Modo Claro por Defecto:** La aplicación se inicia siempre en modo claro para una experiencia de usuario consistente, independientemente de la configuración del sistema.
  - **Soporte para Modo Oscuro:** El usuario puede cambiar al modo oscuro en cualquier momento a través de un interruptor en la interfaz.
  - Paleta de colores profesional y consistente basada en Material 3.

---

## 3. Arquitectura de la Aplicación

Qrden sigue una arquitectura limpia y por capas para garantizar la separación de responsabilidades, la mantenibilidad y la escalabilidad.

- **Gestión de Estado:**
  - **`provider`:** Se utiliza para la gestión de estado a nivel de aplicación, principalmente para manejar el cambio de tema (claro/oscuro).
  - **`StatefulWidget` y `AnimationController`:** Para gestionar el estado local y efímero dentro de los widgets, como las animaciones del FAB.

- **Flujo de Datos y Servicios:**
  - **Capa de Presentación (UI):** Compuesta por todos los widgets y pantallas. Es responsable de mostrar los datos y capturar la interacción del usuario.
  - **Capa de Servicio (`firestore_service.dart`):** Actúa como un intermediario entre la UI y Firebase. Centraliza y abstrae toda la lógica de acceso a datos (lectura, escritura, actualización y eliminación en Firestore), ofreciendo una API limpia al resto de la aplicación.
  - **Capa de Modelo de Datos (`product_model.dart`, `history_model.dart`):** Define la estructura de los objetos de datos con una lógica de serialización/deserialización robusta (`fromFirestore`, `toFirestore`) para garantizar la coherencia de los datos entre la app y la base de datos.
  - **Logging:** Se utiliza `dart:developer` para un registro de errores estructurado y profesional, especialmente útil para depurar problemas en la capa de servicio.

- **Navegación:**
  - **`MaterialPageRoute`:** Para la navegación imperativa y estándar entre pantallas.
  - **`AuthWrapper`:** Un widget inteligente que actúa como un guardián de rutas, decidiendo qué pantalla mostrar (Login o Home) basándose en el estado de autenticación del usuario en tiempo real.

---

## 4. Diseño Visual y Tema (Theming)

El diseño de Qrden se centra en la claridad, la modernidad y una experiencia de usuario agradable.

- **Esquema de Color:**
  - Basado en **Material 3 (`useMaterial3: true`)**.
  - Utiliza `ColorScheme.fromSeed` con un color primario verde oscuro (`#2E7D32`) para generar paletas armoniosas y consistentes tanto para el modo claro como para el oscuro.
  - Se favorece `withAlpha` para un control moderno y predecible de la transparencia.

- **Tipografía:**
  - La fuente **Inter**, obtenida a través de `google_fonts`, se utiliza en toda la aplicación para una legibilidad excelente y una estética moderna.
  - La jerarquía de texto está bien definida en el `TextTheme` para títulos, subtítulos y cuerpo de texto.

- **Estilo de Componentes:**
  - Se definen temas específicos (`appBarTheme`, `elevatedButtonTheme`, `cardTheme`, etc.) para garantizar una apariencia visual unificada en todos los componentes de Material Design.
  - Los `Card` tienen una elevación sutil y bordes redondeados.
  - Los `InputDecoration` son limpios, con un fondo relleno y bordes redondeados.

- **Animaciones:**
  - Se utilizan `flutter_staggered_animations` para animar la aparición de las listas (FadeIn y Slide), haciendo la interfaz más dinámica.
  - Se emplean `animations` para transiciones suaves entre pantallas (FadeThroughTransition).

---

## 5. Dependencias Clave

- **`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`:** El stack de Firebase para backend, autenticación, base de datos NoSQL y almacenamiento de archivos.
- **`provider`:** Para una gestión de estado simple y eficaz.
- **`mobile_scanner`:** La librería principal para la funcionalidad de escaneo de códigos QR.
- **`qr_flutter`:** Para la generación de imágenes de códigos QR dentro de la app.
- **`google_fonts`:** Para cargar y utilizar fuentes personalizadas de manera sencilla.
- **`intl`:** Para el formateo de fechas y números.
- **`flutter_staggered_animations`, `animations`:** Para enriquecer la experiencia de usuario con animaciones elegantes.
- **`cupertino_icons`:** Iconografía de estilo iOS.

---

## 6. Control de Versiones

- **Repositorio Git:** El código fuente del proyecto está gestionado y versionado con Git.
- **Alojamiento Remoto:** El repositorio remoto está alojado en GitHub y es accesible en la siguiente URL:
  - **[https://github.com/GerardAstargo/QrdenApp](https://github.com/GerardAstargo/QrdenApp)**
- **Estado Actual:** El proyecto ha sido restaurado a la versión 5.4 y esta versión ha sido subida como la base del repositorio remoto.

