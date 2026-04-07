#!/bin/bash

# --- 1. 强化版密码配置 (防止命令不存在导致崩溃) ---
echo "🔒 正在配置 VNC 密码..."
mkdir -p /root/.vnc

# 检查 vncpasswd 命令是否存在
if ! command -v vncpasswd &> /dev/null; then
    echo "❌ 错误: vncpasswd 未找到! 软件安装可能失败了。"
    echo "请检查 Dockerfile 是否正确安装了 tigervnc-standalone-server"
    exit 1
fi

# 检查密码变量
if [ -z "$VNC_PASSWORD" ]; then
    echo "⚠️ 警告: VNC_PASSWORD 为空，将使用无密码模式 (不安全)"
    > /root/.vnc/passwd # 创建空文件
else
    # 使用 printf 自动输入两次密码
    printf "${VNC_PASSWORD}\n${VNC_PASSWORD}\n" | vncpasswd -f > /root/.vnc/passwd
fi

chmod 600 /root/.vnc/passwd

# --- 2. 启动 VNC Server ---
echo "🖥️ 启动 VNC 服务..."
# 杀死旧的进程
vncserver -kill :1 2>/dev/null || true
# 启动新的
vncserver :1 -geometry $RESOLUTION -depth 24 -localhost no

# --- 3. 启动 noVNC (网页端) ---
echo "🌐 启动 noVNC..."
# 后台运行，日志重定向到控制台
/opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080 --web /opt/noVNC &

# --- 4. 启动 Telegram (Wine) ---
echo "🤖 启动 Telegram..."
# 检查 Wine 命令
if ! command -v wine64 &> /dev/null; then
    echo "❌ 错误: wine64 未找到! 软件安装可能失败了。"
    echo "请检查 Dockerfile 是否正确安装了 wine64"
    # 保持容器运行以便查看错误
    tail -f /dev/null
    exit 1
fi

# 启动 Telegram
wine64 /opt/telegram/Telegram.exe &

# --- 5. 保持容器运行 ---
echo "✅ 启动完成! 访问 http://localhost:6080/vnc.html"
tail -f /dev/null