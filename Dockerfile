# 使用 Ubuntu 22.04 作为基础镜像
FROM ubuntu:22.04

# 设置非交互式安装环境
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    # Telegram 安装包下载地址
    TELEGRAM_URL=https://telegram.org/dl/desktop/linux \
    # noVNC 默认密码
    NO_VNC_PASSWD=123456

# 安装依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    tar \
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

# 安装 TigerVNC Server
# RUN wget -qO- https://twds.dl.sourceforge.net/project/tigervnc/stable/1.16.2/tigervnc-1.16.2.x86_64.tar.gz?viasf=1 | tar xz --strip-components=1 -C /usr/local

# 安装 noVNC (使用 wget 替代 git clone，更可靠)
RUN cd /tmp && \
    wget -O noVNC.tar.gz https://github.com/novnc/noVNC/archive/refs/heads/master.tar.gz && \
    tar -xzf noVNC.tar.gz && \
    mv noVNC-master /opt/noVNC && \
    rm noVNC.tar.gz

# 下载并安装 Telegram Desktop
RUN cd /tmp && \
    wget -O telegram.tar.xz $TELEGRAM_URL && \
    tar -xf telegram.tar.xz && \
    mv Telegram/ /opt/telegram && \
    rm telegram.tar.xz && \
    rm -rf Telegram

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