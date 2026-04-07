# 使用 Debian Stable 作为基础系统
FROM debian:stable-slim

# 设置环境变量
# 1. 系统基础设置
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    # 2. VNC 默认密码 (这里设置默认值)
    VNC_PASSWORD=123456 \
    # 3. 分辨率设置
    RESOLUTION=1280x720

# 1. 安装所有必要的软件
# 注意：这里不再包含 vncpasswd 的配置命令
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    tigervnc-common \
    wine64 \
    curl \
    unzip \
    git \
    python3-websockify \
    supervisor \
    fonts-wqy-zenhei \
    fonts-wqy-microhei && \
    rm -rf /var/lib/apt/lists/*

# 2. 下载并安装 noVNC
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC && \
    git clone --depth 1 https://github.com/novnc/websockify /opt/noVNC/utils/websockify

# 3. 下载 Telegram Windows 官方版本
RUN curl -L -o /tmp/telegram.zip https://telegram.org/dl/desktop/win64_portable && \
    unzip /tmp/telegram.zip -d /opt/telegram && \
    rm /tmp/telegram.zip

# 4. 添加启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 5. 配置 VNC 启动时的桌面环境 (xstartup)
# 这一步可以保留在 Dockerfile 中，因为它是静态的
RUN mkdir -p /root/.vnc && \
    echo "startxfce4 &" > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# 6. 暴露端口
EXPOSE 6080 5901

# 7. 容器启动时运行的命令
CMD ["/start.sh"]