#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 7+
#	Description: sspanel后端一键安装脚本
#	Version: 0.2.1
#	Author: 壕琛
#	Blog: http://mluoc.top/
#=================================================

sh_ver="0.2.1"
github="raw.githubusercontent.com/mlch911/ss-node-script/master/"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"



#开始菜单
start_menu(){
clear
echo && echo -e " sspanel后端 一键安装管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- 壕琛小站 | ss.mluoc.tk --
  
  第一次运行，请按照0->1->2->3的顺序执行脚本
  
 ${Green_font_prefix}0.${Font_color_suffix} 升级脚本
 ${Green_font_prefix}1.${Font_color_suffix} 安装依赖(只需执行一次，若重复执行会覆盖原有配置)
 ${Green_font_prefix}2.${Font_color_suffix} 服务器配置
 ${Green_font_prefix}3.${Font_color_suffix} 运行服务
 ${Green_font_prefix}4.${Font_color_suffix} 卸载脚本
 ${Green_font_prefix}5.${Font_color_suffix} 退出脚本
————————————————————————————————" && echo

	# check_status
	# if [[ ${kernel_status} == "noinstall" ]]; then
		# echo -e " 当前状态: ${Green_font_prefix}未安装${Font_color_suffix} 加速内核 ${Red_font_prefix}请先安装内核${Font_color_suffix}"
	# else
		# echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} ${_font_prefix}${kernel_status}${Font_color_suffix} 加速内核 , ${Green_font_prefix}${run_status}${Font_color_suffix}"	
	# fi
	
	
echo
read -p " 请输入数字 [0-8]:" num
case "$num" in
	0)
	Update_Shell
	;;
	1)
	Install_Shell
	;;
	2)
	ServerSetup_Shell
	;;
	3)
	Run_Shell
	;;
	4)
	Uninstall_Shell
	;;
	5)
	exit 1
	;;
	*)
	clear
	echo -e "${Error}:请输入正确数字 [0-8]"
	sleep 5s
	start_menu
	;;
esac
}

#更新脚本
Update_Shell(){
	echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
	sh_new_ver=$(wget --no-check-certificate -qO- "https://${github}/ss-node-script.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 检测最新版本失败 !" && sleep 2s && start_menu
	if [[ ${sh_new_ver} != ${sh_ver} ]]; then
		echo -e "发现新版本[ ${sh_new_ver} ]，是否更新？[Y/n]"
		read -p "(默认: y):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
			wget -N --no-check-certificate http://${github}/ss-node-script.sh && chmod +x ss-node-script.sh
			echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] ! 稍等片刻，马上运行 !"
			bash ss-node-script.sh
		else
			echo && echo "	已取消..." && echo
			start_menu
		fi
	else
		echo -e "当前已是最新版本[ ${sh_new_ver} ] !"
		sleep 2s
		start_menu
	fi
}

#安装依赖
Install_Shell(){
	if [[ "${release}" == "centos" ]]; then
		cd ~
		yum -y groupinstall "Development Tools"
		wget https://github.com/jedisct1/libsodium/releases/download/1.0.16/libsodium-1.0.16.tar.gz
		tar xf libsodium-1.0.16.tar.gz && cd libsodium-1.0.16
		./configure && make -j2 && make install
		echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
		ldconfig
		cd /root
		yum -y install python-setuptools
		easy_install pip
		git clone -b manyuser https://github.com/glzjin/shadowsocks.git
		cd shadowsocks
		pip install -r requirements.txt
		cp apiconfig.py userapiconfig.py
		cp config.json user-config.json
	fi
	
	echo -e "${Info}依赖安装成功！"
	sleep 5s
	start_menu
	
}

#服务器配置
ServerSetup_Shell(){
	cd /root/shadowsocks
	
	#设置node_id
	read -p " 请输入该节点的NODE_ID :" node_id
	sed -n "2c NODE_ID = ${node_id}" userapiconfig.py
	
	#设置API
	sed -n '15c API_INTERFACE = 'glzjinmod'  # glzjinmod, modwebapi' userapiconfig.py
	
	#设置服务器IP
	read -p ' 请输入sspanel服务器的IP(不输入则为127.0.0.1) :' mysql_host_input
	if  [ ${mysql_host_input} ] ;then
		mysql_host=${mysql_host_input}
	else
		mysql_host="127.0.0.1"
	fi
	sed -n "24c MYSQL_HOST = '${mysql_host}'" userapiconfig.py
	
	#设置mysql服务器端口
	read -p ' 请输入sspanel服务器的数据库端口号(不输入则为3306) :' mysql_port_input
	mysql_port="3306"
	if  [ ${mysql_port_input} ] ;then
		mysql_port=${mysql_port_input}
	fi
	sed -n "24c MYSQL_PORT = ${mysql_port}" userapiconfig.py
	
	#设置mysql服务器用户
	read -p ' 请输入sspanel服务器的数据库用户名(不输入则为sspanel) :' mysql_user_input
	mysql_user="sspanel"
	if  [ ${mysql_user_input} ] ;then
		mysql_user=${mysql_user_input}
	fi
	sed -n "24c MYSQL_USER = '${mysql_user}'" userapiconfig.py
	
	#设置mysql服务器密码
	read -p ' 请输入sspanel服务器的数据库密码(不输入则为sspanel) :' mysql_pass_input
	mysql_pass="sspanel"
	if  [ ${mysql_pass_input} ] ;then
		mysql_pass=${mysql_pass_input}
	fi
	sed -n "24c MYSQL_PASS = '${mysql_pass}'" userapiconfig.py
	
	#设置mysql服务器数据库
	read -p ' 请输入sspanel服务器的数据库名称(不输入则为sspanel) :' mysql_db_input
	mysql_db="sspanel"
	if  [ ${mysql_db_input} ] ;then
		mysql_db=${mysql_db_input}
	fi
	sed -n "24c MYSQL_DB = '${mysql_db}'" userapiconfig.py
	
	echo -e "${Info}服务器配置成功！"
	sleep 5s
	start_menu
}

#运行服务
Run_Shell(){
	cd /root/shadowsocks
	read -p " ${Info} 建议执行python server.py进行测试后再运行服务\n是否运行服务 :(y/n)" input
	if [ input == "y" ] ;then
		./run.sh
	else
		start_menu
	fi
	
	read -p " ${Info} sspanel后端运行成功！\n是否退出脚本 :(y/n)" input
	if [ input == "y" ] ;then
		exit 1
	fi
	sleep 5s
	start_menu
}

#############系统检测组件#############

#检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
}

#检查Linux版本
check_version(){
	if [[ -s /etc/redhat-release ]]; then
		version=`grep -oE  "[0-9.]+" /etc/redhat-release | cut -d . -f 1`
	else
		version=`grep -oE  "[0-9.]+" /etc/issue | cut -d . -f 1`
	fi
	bit=`uname -m`
	if [[ ${bit} = "x86_64" ]]; then
		bit="x64"
	else
		bit="x32"
	fi
}

#检查安装bbr的系统要求
# check_sys_bbr(){
	# check_version
	# if [[ "${release}" == "centos" ]]; then
		# if [[ ${version} -ge "6" ]]; then
			# installbbr
		# else
			# echo -e "${Error} BBR内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		# fi
	# elif [[ "${release}" == "debian" ]]; then
		# if [[ ${version} -ge "8" ]]; then
			# installbbr
		# else
			# echo -e "${Error} BBR内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		# fi
	# elif [[ "${release}" == "ubuntu" ]]; then
		# if [[ ${version} -ge "14" ]]; then
			# installbbr
		# else
			# echo -e "${Error} BBR内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		# fi
	# else
		# echo -e "${Error} BBR内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	# fi
# }

#检查安装Lotsever的系统要求
# check_sys_Lotsever(){
	# check_version
	# if [[ "${release}" == "centos" ]]; then
		# if [[ ${version} == "6" ]]; then
			# kernel_version="2.6.32-504"
			# installlot
		# elif [[ ${version} == "7" ]]; then
			# yum -y install net-tools
			# kernel_version="3.10.0-327"
			# installlot
		# else
			# echo -e "${Error} Lotsever不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		# fi
	# elif [[ "${release}" == "debian" ]]; then
		# if [[ ${version} -ge "7" ]]; then
			# if [[ ${bit} == "x64" ]]; then
				# kernel_version="3.16.0-4"
				# installlot
			# elif [[ ${bit} == "x32" ]]; then
				# kernel_version="3.2.0-4"
				# installlot
			# fi
		# else
			# echo -e "${Error} Lotsever不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		# fi
	# elif [[ "${release}" == "ubuntu" ]]; then
		# if [[ ${version} -ge "12" ]]; then
			# if [[ ${bit} == "x64" ]]; then
				# kernel_version="4.4.0-47"
				# installlot
			# elif [[ ${bit} == "x32" ]]; then
				# kernel_version="3.13.0-29"
				# installlot
			# fi
		# else
			# echo -e "${Error} Lotsever不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		# fi
	# else
		# echo -e "${Error} Lotsever不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	# fi
# }

# check_status(){
	# kernel_version=`uname -r | awk -F "-" '{print $1}'`
	# if [[ ${kernel_version} = "4.11.8" ]]; then
		# kernel_status="BBR"
	# elif [[ ${kernel_version} = "3.10.0" || ${kernel_version} = "3.16.0" || ${kernel_version} = "3.2.0" || ${kernel_version} = "4.4.0" || ${kernel_version} = "3.13.0"  || ${kernel_version} = "2.6.32" ]]; then
		# kernel_status="Lotserver"
	# else 
		# kernel_status="noinstall"
	# fi
	# if [[ ${kernel_status} == "Lotserver" ]]; then
		# if [[ -e /appex/bin/serverSpeeder.sh ]]; then
			# run_status=`bash /appex/bin/serverSpeeder.sh status | grep "ServerSpeeder" | awk  '{print $3}'`
			# if [[ ${run_status} = "running!" ]]; then
				# run_status="启动成功"
			# else 
				# run_status="启动失败"
			# fi
		# else 
			# run_status="未安装加速模块"
		# fi
	# elif [[ ${kernel_status} == "BBR" ]]; then
		# run_status=`grep "net.ipv4.tcp_congestion_control" /etc/sysctl.conf | awk -F "=" '{print $2}'`
		# if [[ ${run_status} == "bbr" ]]; then
			# run_status=`lsmod | grep "bbr" | awk '{print $1}'`
			# if [[ ${run_status} == "tcp_bbr" ]]; then
				# run_status="BBR启动成功"
			# else 
				# run_status="BBR启动失败"
			# fi
		# elif [[ ${run_status} == "tsunami" ]]; then
			# run_status=`lsmod | grep "tsunami" | awk '{print $1}'`
			# if [[ ${run_status} == "tcp_tsunami" ]]; then
				# run_status="BBR魔改版启动成功"
			# else 
				# run_status="BBR魔改版启动失败"
			# fi
		# else 
			# run_status="未安装加速模块"
		# fi
	# fi
# }

#############系统检测组件#############

check_sys
check_version
[[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
start_menu
