FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 安装依赖
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    tigervnc-common \
    novnc \
    python3-websockify \
    dbus-x11 \
    x11-xserver-utils \
    telegram-desktop \
    fonts-wqy-zenhei \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 创建 VNC 目录
RUN mkdir -p /root/.vnc

# 创建一个空的密码文件占位（权限设为 600 防止报错）
RUN touch /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# 配置 xstartup
RUN echo '#!/bin/bash\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
exec startxfce4' > /root/.vnc/xstartup
RUN chmod +x /root/.vnc/xstartup

# 复制启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5901 6080

CMD ["/start.sh"]