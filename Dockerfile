FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 1. 更新源
RUN apt-get update

# --- 基础环境 (之前的步骤) ---
RUN apt-get install -y --no-install-recommends xfce4 && echo "XFCE4 installed"
RUN apt-get install -y --no-install-recommends xfce4-goodies && echo "XFCE4 Goodies installed"
RUN apt-get install -y --no-install-recommends tigervnc-standalone-server tigervnc-common && echo "TigerVNC installed"
RUN apt-get install -y --no-install-recommends novnc python3-websockify && echo "noVNC installed"
RUN apt-get install -y --no-install-recommends dbus-x11 x11-xserver-utils supervisor fonts-wqy-zenhei && echo "Utils & Fonts installed"

# --- Telegram 核心下载 ---
# (先下载好 Telegram，避免后面依赖没装完导致无法测试)
RUN cd /tmp && \
    wget -q https://telegram.org/dl/desktop/linux && \
    tar -xJf linux -C /opt && \
    ln -s /opt/Telegram/Telegram /usr/local/bin/telegram-desktop && \
    echo "Telegram Binary Downloaded"

# --- 开始逐一排查依赖库 (拆分成一行一个) ---

# 第一组：GTK 和基础图形库
RUN apt-get install -y --no-install-recommends libgtk-3-0 && echo "libgtk-3-0 OK"
RUN apt-get install -y --no-install-recommends libgdk-pixbuf2.0-0 && echo "libgdk-pixbuf2.0-0 OK"
RUN apt-get install -y --no-install-recommends libpango-1.0-0 && echo "libpango-1.0-0 OK"
RUN apt-get install -y --no-install-recommends libcairo2 && echo "libcairo2 OK"
RUN apt-get install -y --no-install-recommends libpangocairo-1.0-0 && echo "libpangocairo-1.0-0 OK"

# 第二组：X11 核心库
RUN apt-get install -y --no-install-recommends libx11-6 && echo "libx11-6 OK"
RUN apt-get install -y --no-install-recommends libx11-xcb1 && echo "libx11-xcb1 OK"
RUN apt-get install -y --no-install-recommends libxcb1 && echo "libxcb1 OK"

# 第三组：X11 扩展库 (容易冲突的部分)
RUN apt-get install -y --no-install-recommends libxcomposite1 && echo "libxcomposite1 OK"
RUN apt-get install -y --no-install-recommends libxcursor1 && echo "libxcursor1 OK"
RUN apt-get install -y --no-install-recommends libxdamage1 && echo "libxdamage1 OK"
RUN apt-get install -y --no-install-recommends libxext6 && echo "libxext6 OK"
RUN apt-get install -y --no-install-recommends libxfixes3 && echo "libxfixes3 OK"
RUN apt-get install -y --no-install-recommends libxi6 && echo "libxi6 OK"
RUN apt-get install -y --no-install-recommends libxrandr2 && echo "libxrandr2 OK"
RUN apt-get install -y --no-install-recommends libxrender1 && echo "libxrender1 OK"
RUN apt-get install -y --no-install-recommends libxss1 && echo "libxss1 OK"
RUN apt-get install -y --no-install-recommends libxtst6 && echo "libxtst6 OK"

# 第四组：其他系统库
RUN apt-get install -y --no-install-recommends libasound2 && echo "libasound2 OK"
RUN apt-get install -y --no-install-recommends libatk1.0-0 && echo "libatk1.0-0 OK"
RUN apt-get install -y --no-install-recommends libcups2 && echo "libcups2 OK"
RUN apt-get install -y --no-install-recommends libdbus-1-3 && echo "libdbus-1-3 OK"
RUN apt-get install -y --no-install-recommends libexpat1 && echo "libexpat1 OK"
RUN apt-get install -y --no-install-recommends libfontconfig1 && echo "libfontconfig1 OK"
RUN apt-get install -y --no-install-recommends libgcc1 && echo "libgcc1 OK"
RUN apt-get install -y --no-install-recommends libgconf-2-4 && echo "libgconf-2-4 OK"
RUN apt-get install -y --no-install-recommends libglib2.0-0 && echo "libglib2.0-0 OK"
RUN apt-get install -y --no-install-recommends libnspr4 && echo "libnspr4 OK"
RUN apt-get install -y --no-install-recommends libnss3 && echo "libnss3 OK"
RUN apt-get install -y --no-install-recommends libstdc++6 && echo "libstdc++6 OK"

# 第五组：状态栏图标库 (Debian 12 中这个包经常出问题)
RUN apt-get install -y --no-install-recommends libappindicator3-1 && echo "libappindicator3-1 OK"

# --- 最终清理 ---
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
