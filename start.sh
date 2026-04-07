#!/bin/bash

# --- 1. 配置 VNC 密码 ---
# 创建 VNC 配置目录
mkdir -p ~/.vnc

# 设置 VNC 访问密码 (使用我们在 Dockerfile 中定义的变量)
echo "${VNC_PASSWD}" | vncpasswd -f > ~/.vnc/passwd

# 设置权限 (VNC 要求密码文件权限必须为 600)
chmod 600 ~/.vnc/passwd

# --- 2. 启动 VNC Server ---
# 启动 Xvfb (虚拟显示核心) 和 VNC Server
# -geometry: 设置分辨率
# -depth: 设置色深
# :${VNC_PORT:1}: 表示显示端口 (例如 5901 -> :1)
vncserver :1 -geometry 1920x1080 -depth 24 -SecurityTypes VncAuth

# --- 3. 启动 noVNC (Web 界面) ---
# 在后台启动 websockify，将 Web 流量转发到 VNC 端口
# --web /opt/noVNC: 指定网页文件路径
# ${NO_VNC_PORT}: Web 访问端口 (例如 6901)
# localhost:${VNC_PORT}: 目标 VNC 地址 (例如 localhost:5901)
${NO_VNC_HOME}/utils/novnc_proxy --web ${NO_VNC_HOME} ${NO_VNC_PORT} localhost:${VNC_PORT} &

# --- 4. 启动 Telegram ---
# 启动 Telegram 并使其在后台运行
# 注意：Telegram 可能会输出大量日志，这里将其重定向到 /dev/null 以保持控制台清洁
# 如果你需要调试 Telegram，可以去掉 "> /dev/null 2>&1"
telegram &

# --- 5. 保持容器运行 ---
# 为了防止容器在启动后立即退出，我们需要一个前台进程
# 这里使用 tail -f 来监控日志文件，或者简单地让脚本挂起
# 但更好的做法是让主应用 (Telegram) 在前台运行，或者使用 sleep infinity
# 由于 Telegram 已经在后台运行 (&)，我们使用 tail -f 来保持容器存活
tail -f /dev/null