#!/bin/bash
set -e

# 创建 VNC 密码
mkdir -p ~/.vnc
echo -e "${VNC_PASSWD}\n${VNC_PASSWD}" | vncpasswd ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# 启动虚拟桌面
Xvfb ${DISPLAY} -screen 0 1280x720x16 &
sleep 1

# 窗口管理器
openbox &

# VNC
vncserver ${DISPLAY} -geometry 1280x720 -depth 16 &

# noVNC
${NO_VNC_HOME}/utils/novnc_proxy --vnc localhost:${VNC_PORT} --listen ${NO_VNC_PORT} &

# 启动 Telegram
telegram