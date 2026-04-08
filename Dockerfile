FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV TERM=xterm

# 1. 更新源
RUN apt-get update

# 2. 安装基础工具 (wget 和证书必须先装好，否则无法下载)
RUN apt-get install -y wget && echo "✅ wget installed"
RUN apt-get install -y ca-certificates && echo "✅ ca-certificates installed"
RUN apt-get install -y gnupg && echo "✅ gnupg installed"

# 3. 安装 XFCE4 桌面核心
RUN apt-get install -y xfce4 && echo "✅ xfce4 installed"

# 4. 安装 XFCE4 插件
RUN apt-get install -y xfce4-goodies && echo "✅ xfce4-goodies installed"

# 5. 安装 VNC 服务器
RUN apt-get install -y tigervnc-standalone-server && echo "✅ tigervnc installed"
RUN apt-get install -y tigervnc-common && echo "✅ tigervnc-common installed"

# 6. 安装 noVNC (网页端)
RUN apt-get install -y novnc && echo "✅ novnc installed"
RUN apt-get install -y python3-websockify && echo "✅ websockify installed"

# 7. 安装其他依赖工具
RUN apt-get install -y dbus-x11 && echo "✅ dbus-x11 installed"
RUN apt-get install -y x11-xserver-utils && echo "✅ x11-xserver-utils installed"
RUN apt-get install -y supervisor && echo "✅ supervisor installed"
RUN apt-get install -y fonts-wqy-zenhei && echo "✅ fonts installed"

# 8. 安装 Telegram (修复版：增加 Header 防止 403 报错)
RUN mkdir -p /opt/Telegram
RUN wget -q --show-progress --progress=bar:force:noscroll --header="Accept: application/octet-stream" -O /tmp/telegram.tgz https://github.com/telegramdesktop/tdesktop/releases/download/v5.10.2/telegram-5.10.2-linux-x64.tar.xz
RUN tar --extract --file /tmp/telegram.tgz --strip-components=1 -C /opt/Telegram
RUN ln -sf /opt/Telegram/Telegram /usr/local/bin/telegram-desktop
RUN rm /tmp/telegram.tgz
RUN echo "✅ Telegram Binary Downloaded"

# 9. 创建启动脚本 start.sh
RUN echo '#!/bin/bash' > /start.sh
RUN echo 'rm -f /tmp/.X1-lock /tmp/.X11-unix/X1' >> /start.sh
RUN echo 'export DISPLAY=:1' >> /start.sh
RUN echo 'mkdir -p ~/.vnc' >> /start.sh
RUN echo 'x11vnc -storepasswd 123456 ~/.vnc/passwd' >> /start.sh
RUN echo 'chmod 600 ~/.vnc/passwd' >> /start.sh
RUN echo 'supervisord -c /etc/supervisor/supervisord.conf' >> /start.sh
RUN echo 'tail -f /dev/null' >> /start.sh
RUN chmod +x /start.sh

# 10. 复制 Supervisor 配置文件 (如果本地没有，下面这段会创建默认的)
RUN mkdir -p /etc/supervisor/conf.d
RUN echo '[supervisord]' > /etc/supervisor/supervisord.conf
RUN echo 'nodaemon=true' >> /etc/supervisor/supervisord.conf
RUN echo 'user=root' >> /etc/supervisor/supervisord.conf
RUN echo '' >> /etc/supervisor/supervisord.conf
RUN echo '[program:xfce]' >> /etc/supervisor/supervisord.conf
RUN echo 'command=startxfce4' >> /etc/supervisor/supervisord.conf
RUN echo 'autostart=true' >> /etc/supervisor/supervisord.conf
RUN echo 'autorestart=true' >> /etc/supervisor/supervisord.conf
RUN echo 'stderr_logfile=/var/log/xfce.err.log' >> /etc/supervisor/supervisord.conf
RUN echo 'stdout_logfile=/var/log/xfce.out.log' >> /etc/supervisor/supervisord.conf
RUN echo '' >> /etc/supervisor/supervisord.conf
RUN echo '[program:vnc]' >> /etc/supervisor/supervisord.conf
RUN echo 'command=x11vnc -display :1 -rfbport 5900 -rfbauth ~/.vnc/passwd -forever -shared' >> /etc/supervisor/supervisord.conf
RUN echo 'autostart=true' >> /etc/supervisor/supervisord.conf
RUN echo 'autorestart=true' >> /etc/supervisor/supervisord.conf
RUN echo 'stderr_logfile=/var/log/vnc.err.log' >> /etc/supervisor/supervisord.conf
RUN echo 'stdout_logfile=/var/log/vnc.out.log' >> /etc/supervisor/supervisord.conf
RUN echo '' >> /etc/supervisor/supervisord.conf
RUN echo '[program:novnc]' >> /etc/supervisor/supervisord.conf
RUN echo 'command=websockify --web=/usr/share/novnc/ 6080 localhost:5900' >> /etc/supervisor/supervisord.conf
RUN echo 'autostart=true' >> /etc/supervisor/supervisord.conf
RUN echo 'autorestart=true' >> /etc/supervisor/supervisord.conf
RUN echo 'stderr_logfile=/var/log/novnc.err.log' >> /etc/supervisor/supervisord.conf
RUN echo 'stdout_logfile=/var/log/novnc.out.log' >> /etc/supervisor/supervisord.conf

# 11. 暴露端口
EXPOSE 5900
EXPOSE 6080

# 12. 启动命令
CMD ["/start.sh"]
