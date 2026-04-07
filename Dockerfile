# 使用 Debian Stable 作为基础系统
FROM debian:stable-slim

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    VNC_PASSWORD=123456 \
    RESOLUTION=1280x720

# 安装必要的软件
# 修正点1: 修复了换行符 \ 缺失导致的语法错误
# 修正点2: 移除了有问题的 standalone-server，改用 tigervnc-primeserver 或直接安装主包
# 修正点3: 移除了可能不存在的旧版 XCB 库 (如 icccm4)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # --- 桌面与VNC环境 ---
        xfce4 \
        xfce4-goodies \
        tigervnc-common \
        tigervnc-primeserver \
        # --- Telegram 依赖库 (修复了库名) ---
        libgtk-3-0 \
        libnotify4 \
        libgconf-2-4 \
        libnss3 \
        libxss1 \
        libasound2 \
        libxtst6 \
        libatspi2.0-0 \
        libsecret-1-0 \
        libxkbcommon0 \
        # --- XCB 核心库 (使用通用名称) ---
        libxcb-util1 \
        libxcb-randr0 \
        libxcb-cursor0 \
        libxcb-xinerama0 \
        libxcb-xfixes0 \
        # --- 其他工具 ---
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

# 容器启动时运行的命令
CMD ["/start.sh"]