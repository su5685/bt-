#!/bin/sh
#opkg update
#opkg install -y kmod-nft-connlimit conntrack nftables

cat > /root/connlimit.nft <<'NFT_EOF'
table inet connlimit_table {
    chain prerouting_hook {
        type filter hook prerouting priority 150; policy accept;
        ip saddr 192.168.1.0/24 ip daddr != 192.168.1.1 ct state new ct count over 500 counter drop;
        ip saddr 192.168.10.0/24 ip daddr != 192.168.10.1 ct state new ct count over 500 counter drop;
    }
}
NFT_EOF

cat > /etc/init.d/connlimit <<'INIT_EOF'
#!/bin/sh /etc/rc.common
START=90

start() {
    nft delete table inet connlimit_table 2>/dev/null
    if nft -f /root/connlimit.nft; then
        echo "✅规则加载成功"
        echo "管控网段：192.168.1.0/24、192.168.10.0/24｜单IP总连接上限500"
    else
        echo "❌nft语法错误"
        nft delete table inet connlimit_table 2>/dev/null
    fi
}

stop() {
    nft delete table inet connlimit_table 2>/dev/null
    echo "❌连接限制已移除"
}
restart() { stop; start; }
INIT_EOF

chmod +x /etc/init.d/connlimit
/etc/init.d/connlimit enable
/etc/init.d/connlimit start

echo "=============================="
echo "查看规则：nft list table inet connlimit_table"
echo "重启规则：/etc/init.d/connlimit restart"
echo "关闭限制：/etc/init.d/connlimit stop"
