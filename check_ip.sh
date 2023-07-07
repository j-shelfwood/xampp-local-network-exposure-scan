#!/bin/bash

ip=$1
start=$(date +%s.%N)

# Check if port 80 is open using netcat with a timeout
if gtimeout 5 nc -v -z $ip 80 &> /dev/null; then
  echo "✅ Port 80 open on IP: $ip"

  # Check for Apache server signature in headers with a 5 second timeout
  headers=$(gtimeout 5 curl -I -s http://$ip)
  curl_exit_status=$?

  # Log headers and curl exit status if --verbose flag is provided
  if [ "$verbose" == "true" ]; then
    echo "🔍 Curl exit status: $curl_exit_status"
    echo "🔍 Response headers from IP $ip:"
    echo "$headers"
  fi

  # Check for a more generic server string
  if echo "$headers" | grep -q "Server: Apache"; then
    echo "✅ XAMPP (or other Apache server) possibly exposed on IP: $ip"
  else
    echo "⚠️ Web service running, but doesn't seem to be Apache (or XAMPP) on IP: $ip"
  fi
else
  nc_exit_status=$?
  echo "❌ No web service running on IP: $ip"
fi

end=$(date +%s.%N)
duration=$(echo "$end - $start" | bc)

echo "⏱️ Time taken for IP $ip: $duration seconds."
