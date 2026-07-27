cat > /root/connlimit.nft <<'NFT'
table inet connlimit {
        chain forward_hook {
                type filter hook forward priority -1000; policy accept;
                ip saddr 192.168.1.0/24 ip daddr != 192.168.1.1 ct state new ct count over 500 counter drop;
                ip saddr 192.168.10.0/24 ip daddr != 192.168.10.1 ct state new ct count over 500 counter drop;
        }
}
NFT



table inet connlimit {
        chain pre_hook {
                type filter hook prerouting priority -250; policy accept;
                ip saddr 192.168.1.0/24 ip daddr != 192.168.1.1 ct state new ct count over 500 counter drop;
                ip saddr 192.168.10.0/24 ip daddr != 192.168.10.1 ct state new ct count over 500 counter drop;
        }
}

cat > /root/connlimit.nft <<'NFT'
table inet connlimit {
        chain pre_hook {
                type filter hook prerouting priority -250; policy accept;

                # UDP新建速率抑制
                ip saddr 192.168.1.0/24 udp ct state new limit rate 100/sec burst 20 counter accept
                ip saddr 192.168.1.0/24 udp ct state new counter drop

                ip saddr 192.168.20.0/24 udp ct state new limit rate 100/sec burst 20 counter accept
                ip saddr 192.168.20.0/24 udp ct state new counter drop

                # 总连接限制，仅排除网关IP
                ip saddr 192.168.1.0/24 ip daddr != 192.168.1.1 ct state new ct count over 500 counter drop;
                ip saddr 192.168.10.0/24 ip daddr != 192.168.10.1 ct state new ct count over 500 counter drop;
        }
}
NFT





opkg install  kmod-nft-connlimit conntrack nftables

sleep 5 && nft delete table inet connlimit 2>/dev/null && sleep 1 && nft -f /root/connlimit.nft
查看服务 nft list tables inet
# 查看所有forward钩子
nft -e list ruleset | grep -E "hook forward"
# 查看完整规则
nft list table inet connlimit

# 手动加载规则
nft delete table inet connlimit 2>/dev/null && nft -f /root/connlimit.nft

# 临时清除规则
nft delete table inet connlimit 2>/dev/null

# 查看规则与丢弃数据包统计
nft list table inet connlimit

# 查看内网设备连接数，定位触发限流设备
conntrack -L | awk '{src=$5; sub(/src=/,"",src);print src}' | sort | uniq -c | sort -nr
