#!/bin/bash

check_ip() {
  ip=$1
  start=$(date +%s.%N)

  # Check if port 80 is open using netcat with a timeout
  if gtimeout 5 nc -v -z $ip 80 &> /dev/null; then
    echo "✅ Checking XAMPP exposure on IP: $ip"

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
      ip_statuses+=("$ip|✅ XAMPP (or other Apache server)")
    else
      echo "⚠️ Web service running, but doesn't seem to be Apache (or XAMPP) on IP: $ip"
      ip_statuses+=("$ip|⚠️ Web service running, but not XAMPP (or other Apache server)")
    fi
  else
    nc_exit_status=$?
    echo "❌ No web service running on IP: $ip"
    ip_statuses+=("$ip|❌ No web service running")
  fi

  end=$(date +%s.%N)
  duration=$(echo "$end - $start" | bc)

  echo "⏱️ Time taken for IP $ip: $duration seconds."
}

export -f check_ip

echo "🔎 Starting XAMPP Exposure Scan..."

# Check if --test flag is used
if [ "$1" == "--test" ]; then
  verbose="true"
  check_ip "20.230.1.213"
  exit 0
fi

# Check if --verbose flag is used with --test
if [ "$1" == "--test" ] && [ "$2" == "--verbose" ]; then
  verbose="true"
  check_ip "20.230.1.213"
  exit 0
fi

# Check if --verbose flag is used
if [ "$1" == "--verbose" ]; then
  verbose="true"
fi

# Get ARP output
arp_output=$(arp -a)

# Count total IPs
total_ips=$(echo "$arp_output" | awk -F'[()]' '{print $2}' | wc -l)
echo "🌐 Total IP addresses: $total_ips"
processed_ips=0

# Array to store IP addresses and their statuses
declare -a ip_statuses

# Extract IPs and check each
for ip in $(echo "$arp_output" | awk -F'[()]' '{print $2}'); do
  check_ip $ip
  processed_ips=$((processed_ips + 1))

  # Calculate progress
  progress=$((100*processed_ips/total_ips))

  # Print progress
  printf "🚀 Progress: [%-50s] %d%%, processed: %d/%d\r" $(printf "%${progress}s" | tr ' ' '#') $progress $processed_ips $total_ips
done

echo -e "\n✨ Finished XAMPP Exposure Scan\n"

# Display overview table with clickable links
echo "Overview:"
echo "---------------------------"
echo "IP Address       | Status"
echo "---------------------------"
for ip_status in "${ip_statuses[@]}"; do
  ip=$(echo "$ip_status" | cut -d '|' -f 1)
  status=$(echo "$ip_status" | cut -d '|' -f 2)
  echo "$ip | $status"
done
echo "---------------------------"
echo ""
echo "Click on the IP Address to open the link in your default browser."
echo ""

# Process IP addresses and create clickable links
for ip_status in "${ip_statuses[@]}"; do
  ip=$(echo "$ip_status" | cut -d '|' -f 1)
  status=$(echo "$ip_status" | cut -d '|' -f 2)

  if [[ "$status" == *"XAMPP"* ]]; then
    echo "🌐 Click here to open http://$ip/ in your default browser: xdg-open http://$ip/"
  elif [[ "$status" == *"Web service running"* ]]; then
    echo "🌐 Click here to open http://$ip/ in your default browser: xdg-open http://$ip/"
  fi
done
