#!/bin/bash
vncserver -kill :0
rm -rfv /tmp/.X*-lock /tmp/.X11-unix
vncserver :0 -geometry $GEOMETRY
