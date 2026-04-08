FROM debian:latest

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV TERM=xterm

# --- 1. 更新软件源 ---
RUN apt-get update

# --- 2. 安装基础系统工具 (包含 wget 和 ca-certificates) ---
# 这是下载 Telegram 的前提
RUN apt-get install -y --no-install-recommends wget && echo "✅ wget installed"
RUN apt-get install -y --no-install-recommends ca-certificates && echo "✅ ca-certificates installed"
RUN apt-get install -y --no-install-recommends gnupg && echo "✅ gnupg installed"
RUN apt-get install -y --no-install-recommends fonts-wqy-zenhei && echo "✅ fonts installed"

# --- 3. 安装桌面环境 (XFCE4) ---
RUN apt-get install -y --no-install-recommends xfce4 && echo "✅ xfce4 installed"
RUN apt-get install -y --no-install-recommends xfce4-goodies && echo "✅ xfce4-goodies installed"

# --- 4. 安装 VNC 服务 ---
RUN apt-get install -y --no-install-recommends tigervnc-standalone-server && echo "✅ tigervnc installed"
RUN apt-get install -y --no-install-recommends tigervnc-common && echo "✅ tigervnc-common installed"

# --- 5. 安装 noVNC (网页版 VNC) ---
RUN apt-get install -y --no-install-recommends novnc && echo "✅ novnc installed"
RUN apt-get install -y --no-install-recommends python3-websockify && echo "✅ websockify installed"

# --- 6. 安装 Telegram 运行所需的精简核心库 ---
# 之前的长列表已精简，只保留必要的库，避免报错
RUN apt-get install -y --no-install-recommends libgtk-3-0 && echo "✅ libgtk-3-0 installed"
RUN apt-get install -y --no-install-recommends libx11-xcb1 && echo "✅ libx11-xcb1 installed"
RUN apt-get install -y --no-install-recommends libxtst6 && echo "✅ libxtst6 installed"
RUN apt-get install -y --no-install-recommends libnss3 && echo "✅ libnss3 installed"
RUN apt-get install -y --no-install-recommends libxss1 && echo "✅ libxss1 installed"
RUN apt-get install -y --no-install-recommends libasound2 && echo "✅ libasound2 installed"
RUN apt-get install -y --no-install-recommends libatk-bridge2.0-0 && echo "✅ libatk-bridge installed"
RUN apt-get install -y --no-install-recommends libatspi2.0-0 && echo "✅ libatspi installed"

# --- 7. 下载并安装 Telegram (官方版) ---
# 使用官方最新的 Linux 64位版本
RUN mkdir -p /opt/Telegram && \
    wget -q --show-progress --progress=bar:force:noscroll -O /tmp/telegram.tgz https://telegram.org/dl/desktop/linux && \
    tar --extract --file /tmp/telegram.tgz --strip-components=1 --directory /opt/Telegram && \
    ln -sf /opt/Telegram/Telegram /usr/local/bin/telegram-desktop && \
    rm /tmp/telegram.tgz && \
    echo "✅ Telegram Binary Downloaded"

# --- 8. 清理缓存 (最后一步) ---
# 释放空间
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "✅ Build Cache Cleaned"

# --- 9. 暴露端口 ---
EXPOSE 5901
EXPOSE 6080

# --- 10. 启动命令 (示例，具体取决于你的启动脚本) ---
# CMD ["bash"]
