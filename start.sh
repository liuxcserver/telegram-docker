#!/bin/bash

# --- 密码配置逻辑 ---

# 1. 定义密码变量
# 语法解释：${变量名:-默认值}
# 如果环境变量 VNC_PASSWORD 存在且不为空，则使用它；否则使用 "123456"
PASS="${VNC_PASSWORD:-123456}"

echo "正在配置 VNC 密码..."

# 2. 将密码写入 VNC 密码文件
# vncpasswd -f 从标准输入读取并加密
echo "$PASS" | vncpasswd -f > /root/.vnc/passwd

# 3. 确保权限正确
chmod 600 /root/.vnc/passwd

echo "VNC 密码已设置。"

# --- 启动服务逻辑 ---

# 启动 dbus
dbus-daemon --system --fork

# 清理锁文件
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

# 启动 VNC Server
# -rfbauth 指定使用刚才生成的密码文件
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no -rfbauth /root/.vnc/passwd

# 等待 VNC 启动
sleep 2

# 启动 noVNC 代理
websockify -D --web=/usr/share/novnc/ 6080 localhost:5901

# 保持容器运行
tail -f /dev/null