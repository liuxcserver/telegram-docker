#!/bin/bash
set -e

mkdir -p ~/.vnc
echo -e "${VNC_PASSWD}\n${VNC_PASSWD}" | vncpasswd ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

Xvfb ${DISPLAY} -screen 0 1280x720x16 &
sleep 1

openbox &

vncserver ${DISPLAY} -geometry 1280x720 -depth 16 &

${NO_VNC_HOME}/utils/novnc_proxy --vnc localhost:${VNC_PORT} --listen ${NO_VNC_PORT} &

telegram