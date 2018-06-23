screen_name="ssr"
screen -dmS $screen_name

cmd="python /root/shadowsocks/server.py";
screen -x -S $screen_name -p 0 -X stuff "$cmd"
screen -x -S $screen_name -p 0 -X stuff '\n'