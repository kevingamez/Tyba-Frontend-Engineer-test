

El proyecto está organizado siguiendo los principios de Arquitectura con tres capas principales:

1. **Capa de Datos**: Maneja fuentes de datos externas e implementación de repositorios
2. **Capa de Dominio**: Contiene entidades de negocio y casos de uso
3. **Capa de Presentación**: Gestiona componentes de UI y estado

## Características Principales

- Visualización de una lista de universidades
- Ver información detallada de cada universidad
- Capacidad para añadir/editar información del número de estudiantes
- Añadir imágenes a perfiles de universidades (desde cámara o galería)
- Abrir sitios web de universidades mediante URL launcher
- Almacenamiento local de información añadida por el usuario (imágenes y numero de estudiantes)

## Dependencias

La aplicación utiliza las siguientes dependencias:

- **http**: Para realizar peticiones API y obtener datos de universidades
- **image_picker**: Para seleccionar imágenes desde la cámara o galería
- **url_launcher**: Para abrir sitios web de universidades en un navegador
- **shared_preferences**: Para almacenar localmente detalles de las universidades

## Comenzando

### Requisitos previos

- Flutter SDK (versión 3.7.2 o superior)
- Dart SDK
- Android Studio / VS Code con extensión Flutter

### Instalación

1. Clonar el repositorio
   ```
   git clone https://github.com/tu-usuario/university-app.git
   ```

2. Navegar al directorio del proyecto
   ```
   cd Tyba-Frontend-Engineer-test
   ```

3. Instalar dependencias
   ```
   flutter pub get
   ```

4. Ejecutar la aplicación
   ```
   flutter run
   ```

## Detalles de Implementación del Proyecto

### Flujo de Datos

1. Los datos de las universidades se obtienen de una API remota
2. Los datos se analizan en entidades University
3. La información detallada se muestra en UniversityDetailPage
4. La información añadida por el usuario (recuentos de estudiantes e imágenes) se almacena localmente usando shared_preferences

### Almacenamiento Local

La aplicación implementa almacenamiento local para:
- Imágenes de universidades
- Información del recuento de estudiantes