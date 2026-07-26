# 停止服务
/etc/init.d/connlimit stop 2>/dev/null
# 取消开机自启
/etc/init.d/connlimit disable 2>/dev/null
# 删除启动脚本
rm -f /etc/init.d/connlimit
# 删除规则文件
rm -f /root/connlimit.nft
# 删除内存中nft连接限制表
nft delete table inet connlimit_table 2>/dev/null

echo "✅ 所有连接限制配置、内存规则全部清除完成"
