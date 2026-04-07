FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    VNC_PASSWD=123456 \
    NO_VNC_HOME=/opt/noVNC

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl git ca-certificates \
    xvfb tigervnc-standalone-server tigervnc-xorg-extension \
    openbox libx11-xcb1 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
    libxcb-randr0 libxcb-render-util0 libxcb-sync1 libxcb-xfixes0 libxcb-shape0 \
    libxkbcommon-x11-0 libgl1-mesa-glx libpulse0 libasound2 \
    && wget -O- https://telegram.org/dl/desktop/linux | tar -xJ -C /opt/ \
    && ln -s /opt/Telegram/Telegram /usr/bin/telegram \
    && git clone https://github.com/novnc/noVNC.git ${NO_VNC_HOME} \
    && git clone https://github.com/novnc/websockify.git ${NO_VNC_HOME}/utils/websockify \
    && ln -s ${NO_VNC_HOME}/vnc.html ${NO_VNC_HOME}/index.html \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 6901
CMD ["/start.sh"]