FROM ubuntu:22.04

# --- 关键修复：设置非交互式安装模式 ---
# 这行代码必须放在最前面，确保 apt-get 不会弹出键盘布局选择等交互界面
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 1. 安装桌面环境、VNC服务器、Telegram及其他必要工具
# 我们显式安装 locales 并生成语言环境，防止 Telegram 启动报错
RUN apt-get update && \
    apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    tigervnc-common \
    telegram-desktop \
    supervisor \
    curl \
    wget \
    locales \
    && rm -rf /var/lib/apt/lists/*

# 2. 创建VNC配置目录
RUN mkdir -p /root/.vnc

# 3. 创建VNC启动脚本 (xstartup)
# 这个脚本会在VNC会话启动时运行，用于启动XFCE桌面
COPY <<EOF /root/.vnc/xstartup
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF
RUN chmod +x /root/.vnc/xstartup

# 4. 创建VNC密码设置脚本
# 该脚本会检查环境变量VNC_PASSWORD，如果存在则使用它，否则使用默认密码123456
COPY <<'EOF' /set_vnc_password.sh
#!/bin/bash
# 优先使用环境变量指定的密码，如果没有则使用默认密码
VNC_PASS="${VNC_PASSWORD:-123456}"

# 使用非交互方式设置VNC密码
echo "$VNC_PASS" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd
echo "VNC password has been set."
EOF
RUN chmod +x /set_vnc_password.sh

# 5. 创建Supervisor配置文件
# Supervisor用于在容器内同时管理VNC和Telegram等多个进程
COPY <<EOF /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true

# 启动VNC服务器
[program:vnc]
command=/bin/bash -c "/set_vnc_password.sh && vncserver :1 -geometry 1920x1080 -depth 24 -SecurityTypes None"
autorestart=true
stderr_logfile=/var/log/vnc.err.log
stdout_logfile=/var/log/vnc.out.log

# 启动Telegram
[program:telegram]
command=/usr/bin/telegram-desktop
autorestart=true
stderr_logfile=/var/log/telegram.err.log
stdout_logfile=/var/log/telegram.out.log
environment=HOME="/root",USER="root"
EOF

# 6. 暴露VNC服务端口
EXPOSE 5901

# 7. 设置容器启动命令
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]