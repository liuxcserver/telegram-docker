#!/bin/bash

# --- 1. 处理 VNC 密码逻辑 ---
# 如果环境变量 VNC_PASSWORD 存在则使用它，否则默认为 123456
PASS="${VNC_PASSWORD:-123456}"

echo "正在配置 VNC 密码..."

# 将密码写入 VNC 密码文件
echo "$PASS" | vncpasswd -f > /root/.vnc/passwd

# 确保权限正确 (仅所有者可读写)
chmod 600 /root/.vnc/passwd

echo "VNC 密码已设置为: $PASS"

# --- 2. 启动 Supervisor ---
# 执行 supervisord，它会接管后续的 VNC 和 Telegram 启动工作
echo "启动 Supervisor 守护进程..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
