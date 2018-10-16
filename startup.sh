#!/bin/bash
nohup vncserver -kill :0 &
nohup rm -rfv /tmp/.X*-lock /tmp/.X11-unix &
nohup vncserver :0 -geometry $GEOMETRY &

/usr/sbin/sshd -D