# Trivia Ecuatoriana

Aplicación Flutter que presenta una trivia básica con categorías. El proyecto
sirve como ejemplo de cómo leer archivos JSON, dibujar animaciones sencillas y
navegar entre pantallas dentro de Flutter.

## Funcionalidades

- **Selección de categoría:** `CategoryScreen` muestra un tablero con las
  categorías disponibles y un botón para iniciar la trivia.
- **Ruleta al azar:** `CategoryRandomScreen` implementa una ruleta que toma las
  categorías desde `assets/data/categories.json` y muestra una animación de
  giro hasta detenerse en una opción aleatoria.
- **Preguntas de la trivia:** `PreguntasScreen` lee la pregunta y las opciones
  desde `assets/data/pregunta.json`. Al elegir la opción correcta se despliega
  una pequeña animación indicando el acierto.
- **Modelos de datos:** en `lib/models/question.dart` se encuentran las clases
  `Question` y `Option` encargadas de mapear la información proveniente de los
  archivos JSON.

## Estructura del código

- `lib/main.dart` inicializa la aplicación y define `CategoryScreen` como la
  pantalla principal.
- `lib/screen/` contiene las pantallas de la aplicación:
  - `category_screen.dart` muestra las categorías.
  - `category_random_screen.dart` dibuja y anima la ruleta.
  - `preguntas_screen.dart` gestiona la visualización de las preguntas y la
    lógica para marcar respuestas correctas.
- `assets/data/` almacena los archivos JSON que se leen en las pantallas.

Para ejecutar las pruebas integradas se utiliza `flutter test`, donde se incluye
un test de ejemplo en `test/widget_test.dart`.

## Configuración del entorno

La aplicación utiliza el paquete `flutter_dotenv` para cargar variables de
entorno desde un archivo `.env` ubicado en la raíz del proyecto. Un archivo
de ejemplo llamado `.env.example` se incluye en el repositorio. Copie este
archivo y renómbrelo como `.env` para definir la URL base de la API y la clave
secreta:

```bash
cp .env.example .env
```

Recuerde que el archivo `.env` no se encuentra bajo control de versiones.

## Recursos útiles

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Documentación oficial de Flutter](https://docs.flutter.dev/)
