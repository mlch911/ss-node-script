#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 7+
#	Description: sspanel���һ����װ�ű�
#	Version: 0.4.6
#	Author: ���
#	Blog: http://mluoc.top/
#=================================================

sh_ver="0.4.6"
github="raw.githubusercontent.com/mlch911/ss-node-script/master/"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[��Ϣ]${Font_color_suffix}"
Error="${Red_font_prefix}[����]${Font_color_suffix}"
Tip="${Green_font_prefix}[ע��]${Font_color_suffix}"



#��ʼ�˵�
start_menu(){
clear
sh_new_ver=$(wget --no-check-certificate -qO- "https://${github}/ss-node-script.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
if [[ ${sh_new_ver} != ${sh_ver} ]]; then
	echo "${Red_font_prefix} �����°汾�������Զ����¡�����${Font_color_suffix}"
	Update_Shell
fi
echo && echo -e " sspanel��� һ����װ����ű� ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- ���Сվ | cc.mluoc.tk --

  ��һ�����У��밴��0->1->2->3->4��˳��ִ�нű�

 ${Green_font_prefix}0.${Font_color_suffix} �����ű�
 ${Green_font_prefix}1.${Font_color_suffix} ��װ����(ֻ��ִ��һ�Σ����ظ�ִ�лḲ��ԭ������)
 ${Green_font_prefix}2.${Font_color_suffix} ����������
 ${Green_font_prefix}3.${Font_color_suffix} ���Է�����
 ${Green_font_prefix}4.${Font_color_suffix} ���з���
 ${Green_font_prefix}5.${Font_color_suffix} ���ŷ���ǽ
 ${Green_font_prefix}6.${Font_color_suffix} bug�޸�
 ${Green_font_prefix}7.${Font_color_suffix} ��װsupervisor�ػ�����
 ${Green_font_prefix}8.${Font_color_suffix} �˳��ű�
����������������������������������������������������������������" && echo

	# check_status
	# if [[ ${kernel_status} == "noinstall" ]]; then
	# 	echo -e " ��ǰ״̬: ${Green_font_prefix}δ��װ${Font_color_suffix} �����ں� ${Red_font_prefix}���Ȱ�װ�ں�${Font_color_suffix}"
	# else
	# 	echo -e " ��ǰ״̬: ${Green_font_prefix}�Ѱ�װ${Font_color_suffix} ${_font_prefix}${kernel_status}${Font_color_suffix} �����ں� , ${Green_font_prefix}${run_status}${Font_color_suffix}"
	# fi


echo
read -p " ���������� [0-8]:" num
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
	TestServer_Shell
	;;
	4)
	Run_Shell
	;;
	5)
	Firewalld_Shell
	;;
	6)
	Bug_fix
	;;
	7)
	Supervisor_Shell
	;;
	8)
	exit 1
	;;
	*)
	clear
	echo -e "${Error}:��������ȷ���� [0-8]"
	sleep 5s
	start_menu
	;;
esac
}

#���½ű�
Update_Shell(){
	echo -e "��ǰ�汾Ϊ [ ${sh_ver} ]����ʼ������°汾..."
	sh_new_ver=$(wget --no-check-certificate -qO- "https://${github}/ss-node-script.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} ������°汾ʧ�� !" && sleep 2s && start_menu
	if [[ ${sh_new_ver} != ${sh_ver} ]]; then
		echo -e "�����°汾[ ${sh_new_ver} ]���Ƿ���£�[Y/n]"
		read -p "(Ĭ��: y):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
			wget -N --no-check-certificate http://${github}/ss-node-script.sh && chmod +x ss-node-script.sh
			echo -e "�ű��Ѹ���Ϊ���°汾[ ${sh_new_ver} ] ! �Ե�Ƭ�̣��������� !"
			bash ss-node-script.sh
		else
			echo && echo "	��ȡ��..." && echo
			start_menu
		fi
	else
		echo -e "��ǰ�������°汾[ ${sh_new_ver} ] !"
		sleep 2s
		start_menu
	fi
}

#��װ����
Install_Shell(){
	if [[ "${release}" == "centos" ]]; then
		# cd ~ || read -p "${Error}������װʧ�ܣ�����������������档" x
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

	echo -e "${Info}������װ������
	������ش�����ʾrequests�޷���װ�������нű�������requests"
	sleep 5s
	start_menu

}

#����������
ServerSetup_Shell(){
	cd /root/shadowsocks

	#����node_id
	read -p " ������ýڵ��NODE_ID :" node_id
	sed -i "2c NODE_ID = ${node_id}" userapiconfig.py

	#����API
	sed -i "15c API_INTERFACE = 'glzjinmod'  # glzjinmod, modwebapi" userapiconfig.py

	#���÷�����IP
	read -p ' ������sspanel��������IP(��������Ϊ127.0.0.1) :' mysql_host_input
	if  [ ${mysql_host_input} ] ;then
		mysql_host=${mysql_host_input}
	else
		mysql_host="127.0.0.1"
	fi
	sed -i "24c MYSQL_HOST = '${mysql_host}'" userapiconfig.py

	#����mysql�������˿�
	read -p ' ������sspanel�����������ݿ�˿ں�(��������Ϊ3306) :' mysql_port_input
	mysql_port="3306"
	if  [ ${mysql_port_input} ] ;then
		mysql_port=${mysql_port_input}
	fi
	sed -i "25c MYSQL_PORT = ${mysql_port}" userapiconfig.py

	#����mysql�������û�
	read -p ' ������sspanel�����������ݿ��û���(��������Ϊsspanel) :' mysql_user_input
	mysql_user="sspanel"
	if  [ ${mysql_user_input} ] ;then
		mysql_user=${mysql_user_input}
	fi
	sed -i "26c MYSQL_USER = '${mysql_user}'" userapiconfig.py

	#����mysql����������
	read -p ' ������sspanel�����������ݿ�����(��������Ϊsspanel) :' mysql_pass_input
	mysql_pass="sspanel"
	if  [ ${mysql_pass_input} ] ;then
		mysql_pass=${mysql_pass_input}
	fi
	sed -i "27c MYSQL_PASS = '${mysql_pass}'" userapiconfig.py

	#����mysql���������ݿ�
	read -p ' ������sspanel�����������ݿ�����(��������Ϊsspanel) :' mysql_db_input
	mysql_db="sspanel"
	if  [ ${mysql_db_input} ] ;then
		mysql_db=${mysql_db_input}
	fi
	sed -i "28c MYSQL_DB = '${mysql_db}'" userapiconfig.py

	echo -e "${Info}������������ɣ�"
	sleep 5s
	start_menu
}

TestServer_Shell(){
	cd /root/shadowsocks
	echo -e "${Info} ��Ctrl+Cֹͣ���У�"
	python server.py
	echo -e " ${Info} ������������ɣ�"
	read -p "�Ƿ��˳��ű� :(y/n)" run_input_b
	if [ ${run_input_b} == "y" ] ;then
		exit 1
	fi
	sleep 2s
	start_menu
}

#���з���
Run_Shell(){
	cd /root/shadowsocks
	echo -e " ${Info} ����ִ��python server.py���в��Ժ������з���"
	read -p "�Ƿ����з��� :(y/n)" run_input_a
	if [ ${run_input_a} == "y" ] ;then
		/root/shadowsocks/run.sh
		echo -e " ${Info} sspanel������гɹ���"
		read -p "�Ƿ��˳��ű� :(y/n)" run_input_b
		if [ ${run_input_b} == "y" ] ;then
			exit 1
		fi
		sleep 2s
		start_menu
	else
		start_menu
	fi
}

#���ŷ���ǽ
Firewalld_Shell(){
	clear
	echo -e " ��ѡ�����ǽ���� :
	${Green_font_prefix}1.${Font_color_suffix} firewalld
	${Green_font_prefix}2.${Font_color_suffix} iptables
	����������������������������������������������������������������"
	read -p "���������� :" num
	if [ ${num} == "1" ] ;then
		echo -e " firewalld :
		${Green_font_prefix}1.${Font_color_suffix} ���˿�
		${Green_font_prefix}2.${Font_color_suffix} �˿ڶ�
		����������������������������������������������������������������"
		read -p "���������� :" num
		if [ ${num} == "1" ] ;then
			read -p " ���ŷ���ǽ�˿�Ϊ :" port_a
			firewall-cmd --permanent --zone=public --add-port=${port_a}/tcp
			firewall-cmd --permanent --zone=public --add-port=${port_a}/udp
			firewall-cmd --reload
		elif [ ${num} == "2" ] ;then
			read -p " ���ŷ���ǽ�˿ڴ� :" port_b
			read -p " ���ŷ���ǽ�˿ڵ� :" port_c
			firewall-cmd --permanent --zone=public --add-port=${port_b}-${port_c}/tcp
			firewall-cmd --permanent --zone=public --add-port=${port_b}-${port_c}/udp
			firewall-cmd --reload
		fi
	elif [ ${num} == "2" ] ;then
		echo -e " iptables :
		${Green_font_prefix}1.${Font_color_suffix} ���˿�
		${Green_font_prefix}2.${Font_color_suffix} �˿ڶ�
		����������������������������������������������������������������"
		read -p "���������� :" num
		if [ ${num} == "1" ] ;then
			read -p " ���ŷ���ǽ�˿�Ϊ :" port_a
			iptables -A INPUT -p tcp --dport ${port_a} -j ACCEPT
			iptables -A INPUT -p udp --dport ${port_a} -j ACCEPT
			service iptables save
			service iptables restart
		elif [ ${num} == "2" ] ;then
			read -p " ���ŷ���ǽ�˿ڴ� :" port_b
			read -p " ���ŷ���ǽ�˿ڵ� :" port_c
			iptables -A INPUT -p tcp --dport ${port_b}:${port_c} -j ACCEPT
			iptables -A INPUT -p udp --dport ${port_b}:${port_c} -j ACCEPT
			service iptables save
			service iptables restart
		fi
	fi
	echo -e " ${Info} ���ŷ���ǽ������ɣ�"
	read -p "�Ƿ��˳��ű� :(y/n)" firewalld_input
	if [ ${firewalld_input} == "y" ] ;then
		exit 1
	fi
	sleep 2s
	start_menu

}

# ����requests
Bug_fix(){
	clear
	echo -e " ��ѡ��Bug���� :
	${Green_font_prefix}1.${Font_color_suffix} ����requests
	${Green_font_prefix}2.${Font_color_suffix} gitʧ��
	����������������������������������������������������������������"
	read -p "���������� :" num
	if [ ${num} == "1" ] ;then
		echo -e " ${Info} ǿ�Ƹ���requests���"
		read -p "�Ƿ���� :(y/n)" run_input_a
		if [ ${run_input_a} == "y" ] ;then
			mkdir /usr/lib/python2.7/dist-packages/ && cd /usr/lib/python2.7/dist-packages/
			echo "/usr/lib/python2.7/dist-packages/">>mypack.pth
			git clone git://github.com/requests/requests.git
			cd requests
			python setup.py install
			echo -e " ${Info} requests������ɣ�"
			read -p "�Ƿ��˳��ű� :(y/n)" firewalld_input
			if [ ${firewalld_input} == "y" ] ;then
				exit 1
			fi
			sleep 2s
			start_menu
		else
			start_menu
		fi
	elif [ ${num} == "2" ] ;then
		yum update -y nss curl libcurl
		echo -e " ${Info} nss������ɣ�"
		read -p "�Ƿ��˳��ű� :(y/n)" firewalld_input
			if [ ${firewalld_input} == "y" ] ;then
				exit 1
			fi
			sleep 2s
			start_menu
	fi
	sleep 2s
	start_menu
}

Supervisor_Shell(){
	if [[ "${release}" == "centos" ]]; then
		clear
		echo -e " ��ѡ�� :
		${Green_font_prefix}1.${Font_color_suffix} ��װsupervisor�ػ�����
		${Green_font_prefix}2.${Font_color_suffix} ���ssr�Ƿ�������
		${Green_font_prefix}3.${Font_color_suffix} �˻����˵�
		����������������������������������������������������������������"
		read -p "���������� :" num
		if [ ${num} == "1" ] ;then
			/root/shadowsocks/stop.sh
			yum install -y epel-release
			yum install -y supervisor
			cd ~
			wget -N --no-check-certificate https://git.mluoc.tk/mlch911/ss-node-script/raw/branch/master/ssr.conf
			mv ~/ssr.conf /etc/supervisord.d/ssr.conf
			sed -i "129c files = supervisord.d/*.ini /etc/supervisord.d/*.conf"
			wget -N --no-check-certificate https://git.mluoc.tk/mlch911/ss-node-script/raw/branch/master/supervisord.service
			mv ~/supervisord.service /lib/systemd/system/supervisord.service
			sed -i "21c nodaemon=true              ; (start in foreground if true;default false)"
			systemctl enable supervisord.service
			read -p "�Ƿ���web�� :(y/n)" web
			if [ ${web} == "y" ] ;then
				sed -i "10c [inet_http_server]         ; inet (TCP) server disabled by default"
				read -p "������web��ַ(ip:port��Ĭ��Ϊ127.0.0.1:9001) :" http_address_input
				http_address = "127.0.0.1:9001"
				if [ ${http_address} ] ;then
					http_address = http_address_input
				fi
				sed -i "11c port=${http_address}        ; (ip_address:port specifier, *:port for all iface)"

				read -p "�Ƿ���web�˵�½��֤(ǿ�ҽ��鿪��) :(y/n)" auth
				if [ ${auth} == "y" ] ;then
					read -p "�������½��(Ĭ��Ϊuser) :" username_input
					username = "user"
					if [ ${username_input} ] ;then
						username = username_input
					fi
					sed -i "12c username=${username}              ; (default is no username (open server))"
					read -p "�������½����(Ĭ��Ϊ123) :" pass_input
					pass = "123"
					if [ ${pass_input} ] ;then
						pass = pass_input
					fi
					sed -i "13c password=${pass}               ; (default is no password (open server))"
				fi
			fi
			systemctl start supervisor.service
			supervisorctl reload
			supervisorctl status ssr
			echo -e " ${Info} supervisor��װ��ɣ�"
			read -p "�Ƿ��˳��ű� :(y/n)" firewalld_input
			if [ ${firewalld_input} == "y" ] ;then
				exit 1
			fi
			sleep 2s
			start_menu
		fi
		if [ ${num} == "2" ] ;then
			supervisorctl status ssr
			sleep 2s
			start_menu
		fi
		if [ ${num} == "3" ] ;then
			start_menu
		fi
	fi
}


#############ϵͳ������#############

#���ϵͳ
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

#���Linux�汾
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

#��鰲װbbr��ϵͳҪ��
# check_sys_bbr(){
	# check_version
	# if [[ "${release}" == "centos" ]]; then
		# if [[ ${version} -ge "6" ]]; then
			# installbbr
		# else
			# echo -e "${Error} BBR�ں˲�֧�ֵ�ǰϵͳ ${release} ${version} ${bit} !" && exit 1
		# fi
	# elif [[ "${release}" == "debian" ]]; then
		# if [[ ${version} -ge "8" ]]; then
			# installbbr
		# else
			# echo -e "${Error} BBR�ں˲�֧�ֵ�ǰϵͳ ${release} ${version} ${bit} !" && exit 1
		# fi
	# elif [[ "${release}" == "ubuntu" ]]; then
		# if [[ ${version} -ge "14" ]]; then
			# installbbr
		# else
			# echo -e "${Error} BBR�ں˲�֧�ֵ�ǰϵͳ ${release} ${version} ${bit} !" && exit 1
		# fi
	# else
		# echo -e "${Error} BBR�ں˲�֧�ֵ�ǰϵͳ ${release} ${version} ${bit} !" && exit 1
	# fi
# }

#��鰲װLotsever��ϵͳҪ��
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
			# echo -e "${Error} Lotsever��֧�ֵ�ǰϵͳ ${release} ${version} ${bit} !" && exit 1
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
			# echo -e "${Error} Lotsever��֧�ֵ�ǰϵͳ ${release} ${version} ${bit} !" && exit 1
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
			# echo -e "${Error} Lotsever��֧�ֵ�ǰϵͳ ${release} ${version} ${bit} !" && exit 1
		# fi
	# else
		# echo -e "${Error} Lotsever��֧�ֵ�ǰϵͳ ${release} ${version} ${bit} !" && exit 1
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
				# run_status="�����ɹ�"
			# else
				# run_status="����ʧ��"
			# fi
		# else
			# run_status="δ��װ����ģ��"
		# fi
	# elif [[ ${kernel_status} == "BBR" ]]; then
		# run_status=`grep "net.ipv4.tcp_congestion_control" /etc/sysctl.conf | awk -F "=" '{print $2}'`
		# if [[ ${run_status} == "bbr" ]]; then
			# run_status=`lsmod | grep "bbr" | awk '{print $1}'`
			# if [[ ${run_status} == "tcp_bbr" ]]; then
				# run_status="BBR�����ɹ�"
			# else
				# run_status="BBR����ʧ��"
			# fi
		# elif [[ ${run_status} == "tsunami" ]]; then
			# run_status=`lsmod | grep "tsunami" | awk '{print $1}'`
			# if [[ ${run_status} == "tcp_tsunami" ]]; then
				# run_status="BBRħ�İ������ɹ�"
			# else
				# run_status="BBRħ�İ�����ʧ��"
			# fi
		# else
			# run_status="δ��װ����ģ��"
		# fi
	# fi
# }

#############ϵͳ������#############

check_sys
check_version
[[ ${release} != "centos" ]] && echo -e "${Error} ���ű���֧�ֵ�ǰϵͳ ${release} !" && exit 1
start_menu