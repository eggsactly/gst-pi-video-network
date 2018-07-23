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

gst-launch-1.0 -v udpsrc \
	multicast-group=$MULTI_CAST_IP auto-multicast=true port=$BASE_VIDEO_PORT caps = "application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H264, payload=(int)96" ! rtpjitterbuffer ! rtph264depay ! h264parse ! omxh264dec ! queue ! videoconvert ! queue ! fbdevsink sync=false \
	udpsrc multicast-group=$MULTI_CAST_IP port=$BASE_AUDIO_PORT ! application/x-rtp, media=audio, clock-rate=8000, encoding-name=PCMU ! rtpjitterbuffer ! rtppcmudepay ! queue ! mulawdec ! queue ! audioconvert ! autoaudiosink sync=false 

