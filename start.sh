#!/bin/bash

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