# Blueprint de la Aplicación de Inventario con QR

## Visión General

Esta es una aplicación móvil desarrollada en Flutter para la gestión de inventario. Permite a los empleados autenticados registrar, visualizar y gestionar productos mediante el escaneo de códigos QR. La aplicación se integra con Firebase para la autenticación de usuarios y el almacenamiento de datos en Firestore.

## Características y Diseño Implementados

### 1. **Estructura y Navegación (go_router)**
   - **Enrutamiento Declarativo:** Se utiliza `go_router` para una navegación robusta y basada en URLs.
   - **Rutas Definidas:**
     - `/`: `AuthWrapper` - Decide si mostrar el login o la home.
     - `/login`: `LoginScreen` - Pantalla de inicio de sesión.
     - `/home`: `HomeScreen` - Pantalla principal con la lista de productos.
     - `/scanner`: `ScannerScreen` - Escáner de códigos QR.
     - `/generator`: `QRGeneratorScreen` - Generador de QR para nuevos productos.
     - `/product/:name`: `ProductDetailScreen` - Detalles de un producto específico.
     - `/history`: `HistoryScreen` - Historial de entradas y salidas de productos.
     - `/profile`: `ProfileScreen` - Pantalla de perfil del empleado.
   - **Navegación con BottomNavigationBar:** Se ha implementado un `ScaffoldWithNavBar` que gestiona la navegación principal entre las pantallas Home, Scanner, Generator, History y Profile.

### 2. **Autenticación (Firebase Auth)**
   - **Inicio de Sesión:** Los usuarios (empleados) se autentican con su email y contraseña a través de Firebase Auth.
   - **Gestión de Sesión:** Un `AuthWrapper` (`StreamBuilder` sobre `authStateChanges()`) gestiona el estado de la sesión y redirige automáticamente al usuario a la pantalla de login o a la home.
   - **Cierre de Sesión:** Funcionalidad para cerrar la sesión del usuario de forma segura.

### 3. **Base de Datos (Firestore)**
   - **Servicio Firestore (`firestore_service.dart`):** Una clase centraliza todas las interacciones con la base de datos Firestore, facilitando el mantenimiento.
   - **Colecciones:**
     - `empleados`: Almacena los datos de los empleados (nombre, email).
     - `producto`: Inventario principal de productos.
     - `categoria`: Lista de categorías de productos.
     - `registro`: Historial de movimientos de inventario.
   - **Modelos de Datos:** Se utilizan clases (`Empleado`, `Product`, `HistoryEntry`) para estructurar los datos obtenidos de Firestore, promoviendo la seguridad de tipos.

### 4. **Diseño y Experiencia de Usuario (Material 3)**
   - **Tema Moderno:** La aplicación utiliza Material Design 3 (`useMaterial3: true`).
   - **Tema Oscuro/Claro:** Implementado con un `ThemeProvider` (`ChangeNotifier`) y un interruptor en la pantalla de perfil, permitiendo al usuario elegir su preferencia.
   - **Componentes Estilizados:** Uso de `Card`, `ElevatedButton`, `Icon`, etc., con una estética consistente.
   - **Fuentes Personalizadas (`google_fonts`):** Se utiliza `google_fonts` para mejorar la tipografía y el atractivo visual de la aplicación.
   - **Feedback al Usuario:** Uso de `CircularProgressIndicator` durante las cargas y mensajes claros en caso de errores.

### 5. **Funcionalidades Clave por Pantalla**
   - **HomeScreen:** Muestra una lista en tiempo real de los productos del inventario.
   - **ProfileScreen:**
     - Muestra el nombre y el email del empleado que ha iniciado sesión, obtenidos de la colección `empleados` en Firestore.
     - Permite al usuario activar o desactivar el modo oscuro.
     - Contiene el botón para cerrar la sesión de forma segura y corregida.

## Plan de Implementación (Historial de Cambios Recientes)

### Tarea Actual: Corrección del Bug de Navegación al Cerrar Sesión

1.  **Identificación del Problema:** Se detectó un conflicto de navegación. Al cerrar sesión, el código forzaba una redirección manual a `LoginScreen`, mientras que el `AuthWrapper` (el listener de autenticación) también intentaba hacer lo mismo, resultando en un error (`Looking up a deactivated widget's ancestor is unsafe`).

2.  **Análisis y Depuración (Fallida):** Los intentos iniciales de corrección se vieron frustrados por suposiciones incorrectas sobre la estructura del código (nombres de archivo y clases erróneos como `qrden`, `DatabaseService`, `employee.dart`), lo que introdujo múltiples errores de compilación.

3.  **Investigación y Solución:**
    - Se inspeccionó la estructura real del proyecto listando los archivos en el directorio `lib`.
    - Se identificaron los nombres correctos: `empleado_model.dart`, `firestore_service.dart` y la clase `FirestoreService`.
    - Se identificó el método correcto `getEmployeeByEmail` en lugar del supuesto `getEmployee`.

4.  **Implementación de la Solución Definitiva:**
    - Se modificó la función `_signOut` en `lib/profile_screen.dart` para que **únicamente** llame a `FirebaseAuth.instance.signOut()`.
    - Se eliminó por completo la lógica de navegación manual (`Navigator.of(context).pushAndRemoveUntil(...)`) del método `_signOut`.
    - La responsabilidad de la redirección recae ahora, de forma única y correcta, en el widget `AuthWrapper` que ya estaba implementado en `main.dart`, solucionando el conflicto y el bug.
    - Se corrigieron todas las importaciones y llamadas a clases/métodos en `lib/profile_screen.dart` para usar los nombres correctos, restaurando la funcionalidad de mostrar los datos del perfil.
