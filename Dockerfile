FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV TELEGRAM_VERSION=latest

# 1. 更新源
RUN apt-get update

# 2. 安装桌面环境基础 (XFCE4)
RUN apt-get install -y --no-install-recommends xfce4 && echo "XFCE4 installed"

# 3. 安装桌面插件
RUN apt-get install -y --no-install-recommends xfce4-goodies && echo "XFCE4 Goodies installed"

# 4. 安装 VNC 核心组件
RUN apt-get install -y --no-install-recommends tigervnc-standalone-server tigervnc-common && echo "TigerVNC installed"

# 5. 安装 noVNC (Web端VNC)
RUN apt-get install -y --no-install-recommends novnc python3-websockify && echo "noVNC installed"

# 6. 安装系统工具 (dbus, x11 utils, fonts)
RUN apt-get install -y --no-install-recommends dbus-x11 x11-xserver-utils fonts-wqy-zenhei supervisor && echo "System tools installed"

# --- Telegram 部分开始：拆分依赖安装 ---

# 7. Telegram 依赖组 1：基础下载工具和证书 (必须优先安装)
RUN apt-get install -y --no-install-recommends curl ca-certificates wget xdg-utils lsb-release && echo "Telegram Base Tools installed"

# 8. Telegram 依赖组 2：核心图形库 (GTK/Qt 基础)
# 移除了已废弃的 libappindicator1
RUN apt-get install -y --no-install-recommends \
    libgtk-3-0 \
    libgdk-pixbuf2.0-0 \
    libpango-1.0-0 \
    libcairo2 \
    libx11-6 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    libnss3 \
    libasound2 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libglib2.0-0 \
    libnspr4 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    libappindicator3-1 && echo "Telegram Core Libs installed"

# 9. Telegram 依赖组 3：杂项 (如果上面成功了，这一步通常也是空的或很快)
RUN apt-get install -y --no-install-recommends fonts-liberation && echo "Telegram Fonts installed"

# 10. 下载并安装 Telegram (官方二进制版)
# 使用官方最新链接，不再依赖 apt 源
RUN curl -Lo /tmp/telegram.tgz "https://desktop.telegram.org/linux/desktop/latest?_ga=2.123456789.123456789.123456789-123456789.123456789" && \
    tar -xzf /tmp/telegram.tgz -C /opt && \
    rm /tmp/telegram.tgz && \
    ln -s /opt/Telegram/Telegram /usr/local/bin/telegram && \
    echo "Telegram installed successfully"

# 11. 清理缓存 (最后一步)
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
