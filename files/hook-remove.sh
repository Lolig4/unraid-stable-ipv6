SERVICE="disable" /usr/local/emhttp/plugins/stable-ipv6/scripts/apply 2>/dev/null
PID=$(cat /var/run/stable-ipv6.pid 2>/dev/null)
[[ -n $PID ]] && kill "$PID" 2>/dev/null
[[ -r /var/run/stable-ipv6.addr ]] && read -r OLD_IF OLD_ADDR < /var/run/stable-ipv6.addr
[[ -n $OLD_ADDR ]] && ip -6 addr del "$OLD_ADDR/64" dev "$OLD_IF" 2>/dev/null
rm -f /var/run/stable-ipv6.pid /var/run/stable-ipv6.addr
rm -rf /usr/local/emhttp/plugins/stable-ipv6 /boot/config/plugins/stable-ipv6
echo "stable-ipv6 has been removed"
