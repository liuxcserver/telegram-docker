#!/bin/bash

# --- 动态生成 VNC 密码 ---
mkdir -p /root/.vnc
printf "${VNC_PASSWORD}\n${VNC_PASSWORD}\n" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd

# --- 启动 VNC 服务 ---
# 增加 -SecurityTypes VncAuth 确保密码验证生效
vncserver :1 -geometry $RESOLUTION -depth 24 -SecurityTypes VncAuth

# --- 启动 noVNC ---
/opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080 --web /opt/noVNC &

# 等待桌面启动
sleep 5

# --- 启动 Telegram ---
# 设置环境变量以兼容容器环境
export QT_X11_NO_MITSHM=1
/opt/telegram/Telegram -- --no-sandbox &

# 保持容器运行
tail -f /dev/null