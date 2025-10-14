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
   - **Búsqueda Insensible a Mayúsculas/Minúsculas:** La lógica para encontrar un empleado por su email ha sido robustecida para que funcione correctamente sin importar si el usuario escribe su email con mayúsculas o minúsculas al iniciar sesión.
   - **Modelos de Datos:**
     - `Empleado`: Modela los datos del usuario. Incluye los campos `id`, `nombre`, `apellido`, `email`, `cargo`, `rut` y `telefono`.
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
     - **Diseño Fiel a la Imagen:** La pantalla ha sido rediseñada para ser una réplica visual de la maqueta proporcionada por el usuario, con fondos degradados y una estética moderna.
     - **Información Detallada:** Muestra la información completa del empleado obtenida de Firestore, incluyendo:
       - Nombre completo, cargo, y un avatar.
       - Una tarjeta de información con Email, RUT y Teléfono, cada uno con su icono correspondiente.
     - **Cierre de Sesión:** Contiene un botón estilizado en la parte inferior para cerrar la sesión de forma segura.

## Plan de Implementación (Historial de Cambios Recientes)

### Tarea Final: Resolución de Búsqueda y Rediseño Final del Perfil

1.  **Objetivo:** Solucionar el error persistente que impedía mostrar los datos del perfil y, una vez resuelto, implementar el diseño exacto solicitado por el usuario.

2.  **Paso 1: Diagnóstico y Corrección del Error de Búsqueda.**
    - **Problema:** Se identificó que la consulta a Firestore era sensible a mayúsculas y minúsculas, lo que causaba que no se encontrara el email del usuario si este iniciaba sesión con una capitalización diferente a la almacenada en la base de datos.
    - **Solución:** Se modificó `lib/services/firestore_service.dart`. La función `getEmployeeByEmail` ahora recupera todos los documentos de la colección `empleados` y realiza una comparación de emails en minúsculas en el lado del cliente, garantizando la coincidencia.

3.  **Paso 2: Restaurar Modelo de Datos Completo.**
    - Se restauró el archivo `lib/models/empleado_model.dart` para incluir todos los campos requeridos por el diseño (`nombre`, `apellido`, `cargo`, `rut`, `telefono`).

4.  **Paso 3: Implementar el Diseño Final de la Interfaz.**
    - Se reescribió `lib/profile_screen.dart` para replicar fielmente el diseño de la imagen proporcionada, utilizando todos los campos del modelo de datos restaurado.

5.  **Paso 4: Limpieza y Validación Final.**
    - Se corrigieron 3 advertencias de `flutter analyze` relacionadas con el uso de propiedades obsoletas (`deprecated_member_use`) para alinear el código con las últimas prácticas de Flutter.
    - Una ejecución final de `flutter analyze` confirmó que el proyecto está libre de errores y advertencias.

6.  **Resultado:** La aplicación es ahora completamente funcional. La pantalla de perfil muestra los datos correctos para cualquier usuario y tiene la apariencia visual solicitada. El proyecto se encuentra en un estado estable y completo.
