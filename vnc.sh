#!/bin/bash
vncserver -kill :0
vncserver :0 -geometry $GEOMETRY
