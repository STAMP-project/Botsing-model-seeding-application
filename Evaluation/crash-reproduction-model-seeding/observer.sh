pid=$1
Timeout=900 # 15 minutes (Vibes+ Botsing)
sleep "$Timeout"
kill "$pid"
