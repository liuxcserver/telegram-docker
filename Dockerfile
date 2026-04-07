# 使用 Debian Stable (Bookworm)
FROM debian:stable-slim

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    VNC_PASSWORD=123456 \
    RESOLUTION=1280x720

# 安装必要的软件
# 修正点：
# 1. 使用 tigervnc-standalone-server 替代 primeserver (兼容性问题)
# 2. 移除容易报错的特定 xcb 库，改用基础库
# 3. 增加 Telegram 必须的 Qt5 和 GStreamer 多媒体库
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # --- 桌面与 VNC ---
        xfce4 \
        xfce4-goodies \
        tigervnc-common \
        tigervnc-standalone-server \
        dbus-x11 \
        # --- Telegram 核心依赖 (Qt5 & Multimedia) ---
        libgtk-3-0 \
        libnotify4 \
        libnss3 \
        libxss1 \
        libasound2 \
        libxtst6 \
        libatspi2.0-0 \
        libsecret-1-0 \
        libxkbcommon0 \
        # Qt5 基础库 (Telegram 是 Qt 应用)
        libgl1 \
        libegl1 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-randr0 \
        libxcb-render-util0 \
        libxcb-xinerama0 \
        libxcb-xinput0 \
        libxcb-xfixes0 \
        # 多媒体支持 (防止视频/语音无法播放)
        gstreamer1.0-pulseaudio \
        gstreamer1.0-libav \
        # --- 工具与字体 ---
        curl \
        wget \
        unzip \
        python3 \
        python3-websockify \
        fonts-wqy-zenhei \
        fonts-wqy-microhei && \
    rm -rf /var/lib/apt/lists/*

# 下载并安装 noVNC
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC && \
    git clone --depth 1 https://github.com/novnc/websockify /opt/noVNC/utils/websockify

# 下载 Telegram Linux 官方版本
RUN curl -L -o /tmp/telegram.tar.xz https://telegram.org/dl/desktop/linux && \
    mkdir -p /opt/telegram && \
    tar -xf /tmp/telegram.tar.xz -C /opt/telegram --strip-components=1 && \
    rm /tmp/telegram.tar.xz

# 添加启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 配置 VNC 启动时的桌面环境
RUN mkdir -p /root/.vnc && \
    echo "startxfce4 &" > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# 暴露端口
EXPOSE 6080 5901

# 容器启动命令
CMD ["/start.sh"]