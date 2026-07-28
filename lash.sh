cat > /root/connlimit.nft <<'NFT'
table inet connlimit {
        chain forward_hook {
                type filter hook forward priority -1000; policy accept;
                ip saddr 192.168.1.0/24 ip daddr != 192.168.1.1 ct state new ct count over 500 counter drop;
                ip saddr 192.168.10.0/24 ip daddr != 192.168.10.1 ct state new ct count over 500 counter drop;
        }
}
NFT



# 必备插件
# kmod-nft-connlimit conntrack nftables

# 开机启动(放本地启动脚本的exit 0前面)
# sleep 5 && nft delete table inet connlimit 2>/dev/null && sleep 2 && nft -f /root/connlimit.nft

# 手动加载规则
# nft delete table inet connlimit 2>/dev/null && sleep 2 && nft -f /root/connlimit.nft

# 临时清除规则
# nft delete table inet connlimit 2>/dev/null

# 查看规则与丢弃数据包统计
# nft list table inet connlimit

# 查看服务connlimit
# nft list tables inet

# 查看所有forward钩子
# nft -e list ruleset | grep -E "hook forward"
