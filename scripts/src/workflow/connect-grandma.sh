#!/usr/bin/env bash

screenshare() {
    scrcpy --render-driver=opengles2 --stay-awake --legacy-paste --video-bit-rate 2M --max-fps 15 --max-size 960
}

port=$(ssh -p 8022 -o ProxyCommand='cloudflared access ssh --hostname grandma.usagi.io' u0_a346@grandma.usagi.io 'nmap -T4 localhost -p 30000-65535 | awk "/\/tcp open/" | cut -d/ -f1')

if [ -z "$port" ]; then
    echo "Error: No open port found."
    exit 1
fi

echo 'Forwarding ADB to localhost:5555'


( sleep 15 && adb connect localhost:5555 && screenshare ) &

ssh -p 8022 -N -L 5555:localhost:$port -o ProxyCommand='cloudflared access ssh --hostname grandma.usagi.io' u0_a346@grandma.usagi.io
