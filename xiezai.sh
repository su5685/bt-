/etc/init.d/connlimit stop 2>/dev/null
rm -f /etc/init.d/connlimit
rm -f /root/connlimit.nft
nft delete table inet connlimit_table 2>/dev/null
echo "全部清理完毕，不存在任何连接限制规则"
