pid=$1
Timeout=900 # 15 minutes
sleep "$Timeout"
kill "$pid"
