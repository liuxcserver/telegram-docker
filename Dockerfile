FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
# 指定 Telegram 版本 (latest 代表最新稳定版)
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

# 6. 安装系统工具
RUN apt-get install -y --no-install-recommends dbus-x11 x11-xserver-utils && echo "System utils installed"

# 7. 安装字体 (中文支持)
RUN apt-get install -y --no-install-recommends fonts-wqy-zenhei && echo "Fonts installed"

# 8. 安装 Supervisor (进程管理)
RUN apt-get install -y --no-install-recommends supervisor && echo "Supervisor installed"

# 9. 安装 Telegram (使用官方二进制包，解决 apt 源失效问题)
# 依赖库：需要安装一些基础库来运行 telegram
RUN apt-get install -y --no-install-recommends curl gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget && echo "Telegram Dependencies installed"

# 下载并解压 Telegram
RUN cd /tmp && \
    wget https://updates.tdesktop.com/tlinux/tsetup.$TELEGRAM_VERSION.tar.xz -O tsetup.tar.xz && \
    tar -xf tsetup.tar.xz -C /opt && \
    rm tsetup.tar.xz && \
    ln -s /opt/Telegram/Telegram /usr/bin/telegram-desktop && \
    echo "Telegram installed successfully"

# 10. 清理缓存 (最后一步)
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 复制配置文件 (你需要确保这两个文件存在)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 6080 5901

CMD ["/start.sh"]
