FROM debian:latest

# 设置环境变量，避免安装过程中的交互式提示
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 安装所有必要依赖
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    tigervnc-common \
    novnc \
    python3-websockify \
    dbus-x11 \
    x11-xserver-utils \
    telegram-desktop \
    supervisor \
    fonts-wqy-zenhei \
    && rm -rf /var/lib/apt/lists/*

# 创建必要的目录
RUN mkdir -p /root/.vnc

# 复制配置文件
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh

# 赋予执行权限
RUN chmod +x /start.sh

# 暴露端口
EXPOSE 6080 5901

# 设置入口点
CMD ["/start.sh"]
