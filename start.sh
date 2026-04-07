#!/bin/bash

# --- 动态生成 VNC 密码文件 ---
if [ -z "$VNC_PASSWORD" ]; then
    echo "VNC_PASSWORD is not set. Using default or empty."
fi
mkdir -p /root/.vnc
printf "${VNC_PASSWORD}\n${VNC_PASSWORD}\n" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd
# ---------------------------

# 启动 VNC 服务
vncserver :1 -geometry $RESOLUTION -depth 24

# 启动 noVNC，将网页的 6080 端口映射到 VNC 的 5901 端口
/opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080 --web /opt/noVNC &

# 等待几秒让桌面环境完全启动
sleep 5

# 启动 Telegram (Linux 版本)
# 直接运行二进制文件，--no-sandbox 是为了在容器中避免沙盒报错
/opt/telegram/Telegram -- --no-sandbox &

# 保持容器运行
tail -f /dev/null