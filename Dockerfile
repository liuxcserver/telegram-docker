FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 1. 更新源 (必须成功)
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

# 9. 安装 Telegram (这个包最大，最容易出问题)
RUN apt-get install -y --no-install-recommends telegram-desktop && echo "Telegram installed"

# 10. 清理缓存 (最后一步)
RUN rm -rf /var/lib/apt/lists/*

# 复制配置文件 (保持不变)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 6080 5901

CMD ["/start.sh"]
