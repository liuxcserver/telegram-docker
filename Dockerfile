# 使用 Debian Stable 作为基础系统
FROM debian:stable-slim

# 设置环境变量，避免安装过程中的交互提示
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# 1. 安装所有必要的软件
# 包括：桌面环境(XFCE)、VNC服务、Wine、noVNC、以及下载工具 curl
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

# 2. 下载并安装 noVNC (用于在浏览器显示画面)
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC && \
    git clone --depth 1 https://github.com/novnc/websockify /opt/noVNC/utils/websockify

# 3. 下载 Telegram Windows 官方版本
# 我们使用 curl 下载最新的安装包，并用 unzip 解压
RUN curl -L -o /tmp/telegram.zip https://telegram.org/dl/desktop/win64_portable && \
    unzip /tmp/telegram.zip -d /opt/telegram && \
    rm /tmp/telegram.zip

# 4. 添加启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 5. 配置 VNC 密码
# 定义一个构建参数 VNC_PASSWORD，并设置默认值为 "123456"
ARG VNC_PASSWORD=123456

# 使用上面定义的参数来创建密码文件
RUN mkdir -p /root/.vnc && \
    echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# 6. 配置 VNC 启动时的桌面环境
RUN echo "startxfce4 &" > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# 7. 暴露端口
EXPOSE 6080 5901

# 8. 容器启动时运行的命令
CMD ["/start.sh"]