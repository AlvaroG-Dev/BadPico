# BadPico 🚀

**BadPico** es una herramienta de automatización de inyección HID (Human Interface Device) diseñada para Raspberry Pi Pico. Permite generar scripts de CircuitPython que ejecutan Reverse Shells en sistemas Linux y Windows de forma automatizada y discreta.

## ✨ Características
- **Multi-Plataforma:** Soporte para Linux (Bash/Python) y Windows (PowerShell Hidden).
- **Multi-Idioma:** Soporte para teclados en Español (ES) e Inglés (US).
- **Configuración Dinámica:** Permite definir IP y Puerto personalizados en cada ejecución.
- **Auto-Listener:** Opción para abrir automáticamente un receptor Netcat en una ventana independiente.
- **Comprobación de Dependencias:** Verifica automáticamente que el sistema tenga las herramientas necesarias.

## 🛠️ Requisitos
- **En la Raspberry Pi Pico:**
  - [CircuitPython](https://circuitpython.org/) instalado.
  - Librería `adafruit_hid` en la carpeta `/lib`.
  - Archivos de layout de teclado (ej. `keyboard_layout_win_es.py`) en la carpeta `/lib/adafruit_hid/`.
- **En el equipo atacante (RPi 4 / Linux):**
  - `bash`, `python3`, `netcat`, `xterm`.

# 🚀 Instalación y Uso

## 1. Clona el repositorio

```bash
git clone https://github.com/TU_USUARIO/BadPico.git
cd BadPico
```

## 2. Dale permisos de ejecución

```bash
chmod +x badpico.sh
```

## 3. Ejecuta la herramienta

```bash
./badpico.sh
```

Sigue las instrucciones en pantalla para configurar la IP, el puerto, el sistema operativo objetivo y el idioma del teclado.

## 4. Generación del hardware

El script creará un archivo llamado `code.py`.

Conecta tu Raspberry Pi Pico a tu PC manteniendo pulsado el botón **BOOTSEL**.

Aparecerá una unidad llamada **RPI-RP2**.

Copia el archivo `code.py` generado a la unidad raíz de tu Raspberry Pi Pico.

Asegúrate de tener la carpeta `lib` con las librerías de `adafruit_hid` necesarias.

---

# 🛠️ Estructura de Librerías en la Pico

Para que el script funcione, tu Raspberry Pi Pico debe verse así:

```
CIRCUITPY (Unidad flash)
├── lib/
│   └── adafruit_hid/
│       ├── __init__.py
│       ├── keyboard.py
│       ├── keycode.py
│       ├── keyboard_layout_us.py
│       └── keyboard_layout_win_es.py  <-- Importante para teclados españoles
└── code.py                            <-- El archivo generado por BadPico
```

---

# ⚠️ Descargo de Responsabilidad (Disclaimer)

Este proyecto ha sido creado únicamente con fines educativos y de auditoría ética. El uso de esta herramienta contra objetivos sin autorización previa es ilegal. El desarrollador no se hace responsable del mal uso de esta herramienta ni de los daños que pueda causar. Úsalo bajo tu propia responsabilidad.

---

Creado con por [Alvaro]
