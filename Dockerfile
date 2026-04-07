# 使用 Debian Stable 作为基础系统
FROM debian:stable-slim

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    VNC_PASSWORD=123456 \
    RESOLUTION=1280x720

# 安装必要的软件
# 关键修复：使用 tigervnc 的 websockify 替代旧的 python3-websockify
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        xfce4 \
        xfce4-goodies \
        tigervnc-standalone-server \
        wine64 \
        curl \
        unzip \
        fonts-wqy-zenhei \
        fonts-wqy-microhei && \
    # 关键修复：手动下载 noVNC (官方推荐方式，避免 git clone 失败)
    curl -L -o /tmp/novnc.zip https://github.com/novnc/noVNC/archive/refs/heads/master.zip && \
    unzip /tmp/novnc.zip -d /opt/ && \
    mv /opt/noVNC-master /opt/noVNC && \
    rm /tmp/novnc.zip && \
    # 下载辅助工具
    curl -L -o /tmp/websockify.zip https://github.com/novnc/websockify/archive/refs/heads/master.zip && \
    unzip /tmp/websockify.zip -d /opt/noVNC/utils/ && \
    mv /opt/noVNC/utils/websockify-master /opt/noVNC/utils/websockify && \
    rm -rf /tmp/* && \
    # 清理缓存
    rm -rf /var/lib/apt/lists/*

# 创建 VNC 目录和启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh && \
    mkdir -p /root/.vnc && \
    echo "startxfce4 &" > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

EXPOSE 6080 5901

CMD ["/start.sh"]