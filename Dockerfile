FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV TERM=xterm

# --- 1. 更新源 ---
RUN apt-get update

# --- 2. 安装桌面环境基础 (XFCE4) ---
RUN apt-get install -y --no-install-recommends xfce4 && echo "✅ XFCE4 installed"

# --- 3. 安装桌面插件 ---
RUN apt-get install -y --no-install-recommends xfce4-goodies && echo "✅ XFCE4 Goodies installed"

# --- 4. 安装 VNC 核心组件 ---
RUN apt-get install -y --no-install-recommends tigervnc-standalone-server tigervnc-common && echo "✅ TigerVNC installed"

# --- 5. 安装 noVNC (Web端VNC) ---
RUN apt-get install -y --no-install-recommends novnc python3-websockify && echo "✅ noVNC installed"

# --- 6. 安装基础工具和字体 (包含 wget!) ---
RUN apt-get install -y --no-install-recommends \
    dbus-x11 \
    x11-xserver-utils \
    supervisor \
    fonts-wqy-zenhei \
    wget \
    ca-certificates \
    && echo "✅ Base tools installed"

# --- 7. 安装 Telegram (修复版：使用 GitHub 直链) ---
# 注意：这里使用了 GitHub 的官方发布链接，避免官网跳转链接导致的问题
RUN mkdir -p /opt/Telegram && \
    wget -q --show-progress --progress=bar:force:noscroll -O /tmp/telegram.tgz https://github.com/telegramdesktop/tdesktop/releases/download/v5.10.2/telegram-5.10.2-linux-x64.tar.xz && \
    tar --extract --file /tmp/telegram.tgz --strip-components=1 -C /opt/Telegram && \
    ln -sf /opt/Telegram/Telegram /usr/local/bin/telegram-desktop && \
    rm /tmp/telegram.tgz && \
    echo "✅ Telegram Binary Downloaded"

# --- 8. 安装 Zenity (用于弹窗测试) ---
RUN apt-get install -y --no-install-recommends zenity && echo "✅ Zenity installed"

# --- 9. 复制启动脚本 (文件名改回 start.sh) ---
COPY start.sh /start.sh
RUN chmod +x /start.sh

# --- 10. 暴露端口 ---
EXPOSE 5901 6080

# --- 11. 启动命令 ---
CMD ["/start.sh"]
