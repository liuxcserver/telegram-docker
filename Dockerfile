FROM ubuntu:22.04

# 设置环境变量 (关键修复点)
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    VNC_PASSWD=123456 \
    NO_VNC_HOME=/opt/noVNC \
    TELEGRAM_HOME=/opt/Telegram

# 安装依赖并配置应用 (关键修复点在 Telegram 下载命令)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    ca-certificates \
    xvfb \
    tigervnc-standalone-server \
    tigervnc-xorg-extension \
    openbox \
    libx11-xcb1 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-sync1 \
    libxcb-xfixes0 \
    libxcb-shape0 \
    libxkbcommon-x11-0 \
    libgl1-mesa-glx \
    libpulse0 \
    libasound2 \
    && \
    # --- 修复 Telegram 安装 ---
    # 1. 创建目录
    mkdir -p ${TELEGRAM_HOME} \
    # 2. 使用正确的直接下载链接 (linux_x64) 并解压
    && wget -qO- https://telegram.org/dl/desktop/linux_x64 | tar -xJ -C ${TELEGRAM_HOME} --strip-components=1 \
    # 3. 创建软链接
    && ln -sf ${TELEGRAM_HOME}/Telegram /usr/bin/telegram \
    \
    # --- 配置 noVNC ---
    && git clone --depth 1 https://github.com/novnc/noVNC.git ${NO_VNC_HOME} \
    && git clone --depth 1 https://github.com/novnc/websockify.git ${NO_VNC_HOME}/utils/websockify \
    && ln -s ${NO_VNC_HOME}/vnc.html ${NO_VNC_HOME}/index.html \
    \
    # --- 清理 ---
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 6901
CMD ["/start.sh"]