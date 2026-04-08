# 使用 Ubuntu 22.04 作为基础镜像
FROM ubuntu:22.04

# 设置非交互式安装环境
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    NO_VNC_PASSWD=123456

# 安装依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tar \
    wget \
    xvfb \
    x11vnc \
    dbus-x11 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libfontconfig1 \
    libasound2 \
    libatk1.0-0 \
    libgtk-3-0 \
    libnss3 \
    libxss1 \
    python3 \
    net-tools \
    supervisor && \
    rm -rf /var/lib/apt/lists/*

# 安装 noVNC (使用 wget 替代 git clone，更可靠)
# 2. 安装 noVNC (拆分为多行命令)
COPY noVNC-master.tar.gz /tmp/noVNC.tar.gz
RUN tar -xzf /tmp/noVNC.tar.gz -C /opt && mv /opt/noVNC-master /opt/noVNC
COPY websockify-master.tar.gz /tmp/websockify.tar.gz
RUN tar -xzf /tmp/websockify.tar.gz -C /opt && mv /opt/websockify-master /opt/noVNC/utils/websockify
RUN rm -rf /tmp/noVNC.tar.gz /tmp/websockify.tar.gz
RUN ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# 下载并安装 Telegram Desktop
RUN wget -O /tmp/Telegram.tar.xz  https://github.com/telegramdesktop/tdesktop/releases/download/v6.7.5/tsetup.6.7.5.tar.xz
RUN tar -xJf Telegram.tar.xz -C /opt
RUN rm -rf /tmp/Telegram.gz

# 创建用户
RUN useradd -m -s /bin/bash telegram && \
    echo "telegram ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# 设置工作目录
WORKDIR /home/telegram

# 复制启动脚本和配置文件
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 切换用户
USER telegram
ENV HOME=/home/telegram

# 暴露端口: VNC (5901) 和 noVNC Web (6901)
EXPOSE $VNC_PORT $NO_VNC_PORT

# 启动脚本
CMD ["/start.sh"]