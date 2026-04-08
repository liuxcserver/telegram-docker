FROM debian:latest

# 设置非交互式环境，避免安装过程中的交互提示
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 优化后的安装命令
# 1. 使用 --fix-missing 处理网络波动
# 2. 使用 --no-install-recommends 减少依赖数量，提高成功率
RUN apt-get update && apt-get install -y --no-install-recommends --fix-missing \
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
    # 清理缓存，减小镜像体积
    && rm -rf /var/lib/apt/lists/*

# 创建 VNC 目录
RUN mkdir -p /root/.vnc

# 复制配置文件 (确保你的本地文件名和这里一致)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh

# 赋予脚本执行权限
RUN chmod +x /start.sh

# 暴露端口
EXPOSE 6080 5901

# 启动命令
CMD ["/start.sh"]
