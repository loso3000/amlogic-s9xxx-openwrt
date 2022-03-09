#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt for Amlogic S9xxx STB
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/coolsnowwolf/lede / Branch: master
#========================================================================================================================
git clone https://github.com/sirpdboy/sirpdboy-package ./package/diy
git clone https://github.com/sirpdboy/build.git ./package/build
rm -rf ./feeds/luci/themes/luci-theme-argon
rm -rf ./feeds/luci/applications/luci-theme-opentomcat
rm -rf ./feeds/luci/applications/luci-app-wrtbwmon

rm -rf ./package/build/miniupnpd
rm -rf ./package/lean/automount
rm -rf ./package/lean/autosamba
rm -rf ./feeds/luci/applications/luci-app-accesscontrol
rm -rf ./package/build/autocore
rm -rf ./package/lean/autocore
rm -rf ./package/lean/default-settings
# rm -rf ./feeds/luci/applications/luci-app-ramfree
rm -rf ./feeds/luci/applications/luci-app-arpbind
rm -rf ./feeds/luci/applications/luci-app-docker
rm -rf ./feeds/luci/applications/luci-app-dockerman

rm -rf ./package/build/samba4
rm -rf ./feeds/luci/applications/luci-app-samba4

echo '添加关机'
curl -fsSL  https://raw.githubusercontent.com/sirpdboy/other/master/patch/poweroff/poweroff.htm > ./feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_system/poweroff.htm 
curl -fsSL  https://raw.githubusercontent.com/sirpdboy/other/master/patch/poweroff/system.lua > ./feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/system.lua

sed -i 's/root::0:0:99999:7:::/root:$1$tzMxByg.$e0847wDvo3JGW4C3Qqbgb.:19052:0:99999:7:::/g' ./package/base-files/files/etc/shadow

sed -i "s/hostname='OpenWrt'/hostname='JituTiktok'/g" package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate


date1='JituTiktok R'`TZ=UTC-8 date +%Y.%m.%d -d +"12"hour`
echo "DISTRIB_REVISION='${date1}'" > ./package/base-files/files/etc/openwrt_release1
echo ${date1}  >> ./package/base-files/files/etc/banner
echo '---------------------------------' >> ./package/base-files/files/etc/banner

sed -i 's/KERNEL_PATCHVER:=5.4/KERNEL_PATCHVER:=5.10/g' ./target/linux/*/Makefile
sed -i 's/KERNEL_PATCHVER:=5.15/KERNEL_PATCHVER:=5.10/g' ./target/linux/*/Makefile

sed -i '/filter_/d' ./package/network/services/dnsmasq/files/dhcp.conf
sed -i 's/请输入用户名和密码。/欢迎使用~请输入登陆密码~/g' ./feeds/luci/modules/luci-base/po/zh-cn/base.po

#修正nat回流 
cat ./package/build/set/sysctl.conf >>  package/base-files/files/etc/sysctl.conf
#修正连接数 
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf
# 最大连接数
sed -i 's/65535/165535/g' ./package/kernel/linux/files/sysctl-nf-conntrack.conf

# Modify default theme（FROM uci-theme-bootstrap CHANGE TO luci-theme-material）
# sed -i 's/luci-theme-bootstrap/luci-theme-material/g' ./feeds/luci/collections/luci/Makefile
# 使用默认取消自动
sed -i "s/bootstrap/chuqitopd/g" feeds/luci/modules/luci-base/root/etc/config/luci
sed -i 's/bootstrap/chuqitopd/g' feeds/luci/collections/luci/Makefile
echo "修改默认主题"
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap

# ------------------------------- Main source started -------------------------------
#


rm -rf ./package/lean/ddns-scripts_aliyun
rm -rf ./package/lean/ddns-scripts_dnspod
svn co https://github.com/sirpdboy/build/trunk/ddns-scripts_aliyun package/lean/ddns-scripts_dnspod
svn co https://github.com/sirpdboy/build/trunk/ddns-scripts_dnspod package/lean/ddns-scripts_aliyun

curl -fsSL  https://raw.githubusercontent.com/loso3000/other/master/patch/default-settings/zzz-default-settingswifi > ./package/build/default-settings/files/zzz-default-settings
sed -i 's/opentopd/chuqitopd/g'    ./package/build/default-settings/files/zzz-default-settings

# Modify some code adaptation
sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' package/lean/luci-app-cpufreq/Makefile


# Passwall
svn co https://github.com/xiaorouji/openwrt-passwall/trunk package/pass2
#rm -rf package/passwall/shadowsocksr-libev
# svn co https://github.com/loso3000/openwrt-pswall/trunk/luci-app-passwall ./package/passwall/luci-app-passwall
svn co https://github.com/loso3000/openwrt-pswall/trunk/ ./package/passwall
sed -i 's,default n,default y,g' package/passwall/luci-app-passwall/Makefile
# svn co https://github.com/loso3000/openwrt-pswall/trunk/shadowsocksr-libev ./package/passwall/shadowsocksr-libev
rm -rf ./package/build/pass/luci-app-passwall
#
# Add luci-app-amlogic
# svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# Add p7zip
svn co https://github.com/hubutui/p7zip-lede/trunk package/p7zip
./scripts/feeds update -i
