FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV TERM=xterm

# --- 1. 更新源 ---
RUN apt-get update

# --- 2. 安装基础工具 (必须先安装 wget 和 ca-certificates) ---
RUN apt-get install -y --no-install-recommends wget ca-certificates && echo "✅ Base tools installed"

# --- 3. 安装桌面环境 ---
RUN apt-get install -y --no-install-recommends xfce4 && echo "✅ XFCE4 installed"
RUN apt-get install -y --no-install-recommends xfce4-goodies && echo "✅ XFCE4 Goodies installed"

# --- 4. 安装 VNC ---
RUN apt-get install -y --no-install-recommends tigervnc-standalone-server tigervnc-common && echo "✅ TigerVNC installed"
RUN apt-get install -y --no-install-recommends novnc python3-websockify && echo "✅ noVNC installed"

# --- 5. 安装其他工具 ---
RUN apt-get install -y --no-install-recommends dbus-x11 x11-xserver-utils supervisor fonts-wqy-zenhei && echo "✅ Utils & Fonts installed"

# --- 6. 安装 Telegram 核心依赖 (精简版) ---
RUN apt-get install -y --no-install-recommends libgtk-3-0 libx11-xcb1 libxcb-util1 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-shape0 libxcb-shm0 libxcb-sync1 libxcb-xfixes0 libxcb-xinerama0 libxkbcommon-x11-0 libsecret-1-0 && echo "✅ Telegram Dependencies Installed"

# --- 7. 下载并安装 Telegram (修复了下载链接问题) ---
# 第一步：从 API 获取真实的下载链接
# 第二步：使用真实链接下载
# 第三步：解压并清理
RUN mkdir -p /opt/Telegram && \
    REAL_URL=$(wget -qO- https://telegram.org/dl/desktop/linux | grep -o 'https://[^"]*x64.tar.xz' | head -n 1) && \
    if [ -z "$REAL_URL" ]; then echo "❌ Failed to get download URL"; exit 1; fi && \
    echo "Downloading from: $REAL_URL" && \
    wget -q --show-progress --progress=bar:force -O /tmp/telegram.tar.xz "$REAL_URL" && \
    tar -xf /tmp/telegram.tar.xz -C /opt/Telegram --strip-components=1 && \
    rm /tmp/telegram.tar.xz && \
    ln -sf /opt/Telegram/Telegram /usr/local/bin/telegram-desktop && \
    echo "✅ Telegram Binary Downloaded & Installed"

# --- 8. 清理缓存 ---
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# --- 9. 配置启动脚本 ---
COPY start-vnc.sh /start-vnc.sh
RUN chmod +x /start-vnc.sh

CMD ["/start-vnc.sh"]
