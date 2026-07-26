#!/bin/sh
#opkg update
#opkg install -y kmod-nft-connlimit conntrack nftables

cat > /root/connlimit.nft <<'NFT_EOF'
table inet connlimit_table {
    chain prerouting_hook {
        type filter hook prerouting priority 150; policy accept;
        ip saddr 192.168.20.0/24 ip daddr != 192.168.20.1 udp dport 53 accept;
        ip saddr 192.168.20.0/24 ip daddr != 192.168.20.1 tcp dport {80,443} accept;
        ip saddr 192.168.20.0/24 ip daddr != 192.168.20.1 ct state new ct count over 500 counter drop;
    }
}
NFT_EOF

cat > /etc/init.d/connlimit <<'INIT_EOF'
#!/bin/sh /etc/rc.common
START=90

start() {
    nft delete table inet connlimit_table 2>/dev/null
    nft -f /root/connlimit.nft
    echo "✅ 规则加载：放行UDP53、TCP80/443，剩余流量单IP总连接上限500"
}

stop() {
    nft delete table inet connlimit_table 2>/dev/null
    echo "❌ 连接限制已移除"
}

restart() { stop; start; }
INIT_EOF

chmod +x /etc/init.d/connlimit
/etc/init.d/connlimit enable
/etc/init.d/connlimit start

echo "=========================="
echo "查看规则：nft list table inet connlimit_table"
echo "重启规则：/etc/init.d/connlimit restart"
echo "关闭限制：/etc/init.d/connlimit stop"
echo "监控循环命令："
echo 'while true; do clear;echo "【限制规则】";nft list table inet connlimit_table;echo -e "\n【各IP连接统计】";conntrack -L | awk '\''{src=$5; sub(/src=/,"",src);print src}'\'' | sort | uniq -c | sort -nr;sleep 2;done'
echo "Ctrl+C 退出监控"
