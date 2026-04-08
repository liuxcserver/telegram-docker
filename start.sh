#!/bin/bash
set -e

# 设置 VNC 密码
# 如果环境变量 NO_VNC_PASSWD 被设置，则使用它，否则使用 Dockerfile 中的默认值
PASSWD_FILE="$HOME/.vnc/passwd"
if [ -n "$NO_VNC_PASSWD" ]; then
    echo "Setting VNC password from environment variable."
    mkdir -p $HOME/.vnc
    x11vnc -storepasswd "$NO_VNC_PASSWD" "$PASSWD_FILE" << EOF
y
EOF
elif [ ! -f "$PASSWD_FILE" ]; then
    echo "Setting default VNC password (123456). You can override it via NO_VNC_PASSWD env variable."
    mkdir -p $HOME/.vnc
    x11vnc -storepasswd "123456" "$PASSWD_FILE" << EOF
y
EOF
fi

# 启动虚拟显示
Xvfb $DISPLAY -screen 0 1280x800x24 &
sleep 2

# 启动 VNC Server (使用 x11vnc 作为轻量级替代)
x11vnc -display $DISPLAY -rfbport $VNC_PORT -rfbauth $PASSWD_FILE -forever -shared &

# 启动 noVNC Web Server
/opt/noVNC/utils/launch.sh --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT &

# 启动 D-Bus (Telegram 可能需要)
# dbus-launch --exit-with-session /bin/true &
# export $(cat /proc/$(pgrep dbus-daemon)/environ | tr '\0' '\n' | grep DBUS_SESSION_BUS_ADDRESS)

# 等待 Telegram 配置目录就绪
mkdir -p $HOME/.local/share/TelegramDesktop

# 启动 Telegram Desktop
# 使用 --no-sandbox 通常在容器中是必要的，除非你以特权模式运行
echo "Starting Telegram Desktop..."
/opt/telegram/Telegram --startintray -- $DISPLAY &

# 保持容器运行
wait