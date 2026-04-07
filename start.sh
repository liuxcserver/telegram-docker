#!/bin/bash

# --- 动态生成 VNC 密码文件 ---
# 检查环境变量 VNC_PASSWORD 是否设置
if [ -z "$VNC_PASSWORD" ]; then
  echo "VNC_PASSWORD is not set. Using default or empty."
fi

# 创建目录并生成密码文件
# 注意：vncpasswd 需要密码输入两次，所以用 printf
mkdir -p /root/.vnc
printf "${VNC_PASSWORD}\n${VNC_PASSWORD}\n" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd
# ---------------------------

# 启动 VNC 服务
vncserver :1 -geometry 1280x720 -depth 24

# 启动 noVNC，将网页的 6080 端口映射到 VNC 的 5901 端口
/opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080 --web /opt/noVNC &

# 等待几秒让桌面环境完全启动
sleep 5

# 启动 Telegram
# 使用 wine64 运行我们之前解压好的 Telegram.exe
# & 符号让它后台运行，不会阻塞脚本
wine64 /opt/telegram/Telegram.exe &

# 保持容器运行
# tail -f /dev/null 会让脚本无限期运行，防止容器退出
tail -f /dev/null