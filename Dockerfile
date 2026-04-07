FROM debian:13.4

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    VNC_PASSWD=123456 \
    NO_VNC_HOME=/opt/noVNC

# 修复 apt 源 + 安装依赖（最稳定）
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl git xvfb tigervnc-standalone-server tigervnc-xorg-extension \
    openbox libx11-xcb1 libxcb1 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
    libxcb-randr0 libxcb-render-util0 libxcb-sync1 libxcb-xfixes0 libxcb-shape0 \
    libxkbcommon-x11-0 libgl1-mesa-glx libpulse0 \
    && wget -O- https://telegram.org/dl/desktop/linux | tar -xJ -C /opt/ \
    && ln -s /opt/Telegram/Telegram /usr/bin/telegram \
    # 修复 noVNC 安装方式
    && wget https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz -O /tmp/novnc.tar.gz \
    && tar zxf /tmp/novnc.tar.gz -C /opt/ \
    && mv /opt/noVNC-1.4.0 ${NO_VNC_HOME} \
    && wget https://github.com/novnc/websockify/archive/refs/tags/v0.11.0.tar.gz -O /tmp/websockify.tar.gz \
    && tar zxf /tmp/websockify.tar.gz -C /tmp/ \
    && mv /tmp/websockify-0.11.0 ${NO_VNC_HOME}/utils/websockify \
    && ln -s ${NO_VNC_HOME}/vnc.html ${NO_VNC_HOME}/index.html \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 6901
CMD ["/start.sh"]