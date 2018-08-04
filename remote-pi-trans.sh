#!/bin/bash

ROUTER_IP=192.168.0.1 

MULTI_CAST_IP=224.1.1.1

BASE_VIDEO_PORT=5000
BASE_AUDIO_PORT=5001
REMOTE_VIDEO_PORT=5002
REMOTE_AUDIO_PORT=5003 

# Wait for network to come up before attempting to receive video/audio
while ! ping -c 1 -W 1 $ROUTER_IP; do
    sleep 1
done

# Once the network is up, then start the script
gst-launch-1.0 \
	v4l2src device=/dev/video0 ! queue ! video/x-h264, width=640, height=480, framerate=30/1 ! h264parse ! rtph264pay pt=96 ! udpsink host=$MULTI_CAST_IP port=$REMOTE_VIDEO_PORT auto-multicast=true \
	alsasrc device=hw:1 ! audio/x-raw, rate=32000, channels=2, format=S16LE ! audioconvert ! queue ! interleave ! audioresample ! audio/x-raw, rate=8000 ! mulawenc ! rtppcmupay ! application/x-rtp, payload=96 ! udpsink host=$MULTI_CAST_IP port=$REMOTE_AUDIO_PORT auto-multicast=true 

