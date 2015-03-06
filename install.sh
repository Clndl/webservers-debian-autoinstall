#!/bin/sh
#
# (c) Adowya 2015
#

# Colors
red='\033[0;31m'
green=`tput setaf 2`
reset=`tput sgr0`
end='\033[0m' # No Color

clear
echo "${green}################################# ${reset}"
echo "${green} WELCOME : START Linux Installer  ${reset}"
echo "${green}################################# ${reset}"

echo "${green}  █████╗ ██████╗  ██████╗ ██╗    ██╗██╗   ██╗ █████╗ ${reset}"
echo "${green} ██╔══██╗██╔══██╗██╔═══██╗██║    ██║╚██╗ ██╔╝██╔══██╗${reset}"
echo "${green} ███████║██║  ██║██║   ██║██║ █╗ ██║ ╚████╔╝ ███████║${reset}"
echo "${green} ██╔══██║██║  ██║██║   ██║██║███╗██║  ╚██╔╝  ██╔══██║${reset}"
echo "${green} ██║  ██║██████╔╝╚██████╔╝╚███╔███╔╝   ██║   ██║  ██║${reset}"
echo "${green} ╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚══╝╚══╝    ╚═╝   ╚═╝  ╚═╝${reset}"
                                                    

#--------------------------------------------------------------------------------------------------------------------------------
# Install basic tools (nano, tree, zip, htop, discus, nmap)
#--------------------------------------------------------------------------------------------------------------------------------
install_basic (){
	cd /
	echo "${green}Execute: nano ~/.bashrc ${reset}"
	echo '# log every command typed and when
	if [ -n "${BASH_VERSION}" ]; then
		trap "caller >/dev/null || \printf "%s\\n" \"\$(date "")\\$(tty) \${BASH_COMMAND}\" 2>/dev/null >>~/.command_log" DEBUG
	fi' >> ~/.bashrc

	echo "${green}Execute: apt-get update ${reset}"
	apt-get update

	echo "${green}Execute: apt-get install nano ${reset}"
	apt-get install nano

	echo "${green}Execute: apt-get install tree ${reset}"
	apt-get install tree

	echo "${green}Execute: apt-get install zip ${reset}"
	apt-get install zip

	echo "${green}Execute: apt-get install htop ${reset}"
	apt-get install htop

	echo "${green}Execute: apt-get install discus ${reset}"
	apt-get install discus
	
	read -p 'Do you want install nmap? [Y/n] ' answer
	case "${answer}" in
		[yY]|[yY][eE][sS])

	echo "${green}Execute: apt-get install nmap ${reset}"
	apt-get install nmap;;
	esac

	create_iptable_config
	install_apach2
	install_mysql
	install_php5
	install_mongodb
	install_node
	install_git
	install_dev_tools
	finish
}


#--------------------------------------------------------------------------------------------------------------------------------
# IPTableConfig autoconfiguration
#--------------------------------------------------------------------------------------------------------------------------------
create_iptable_config (){
	read -p 'Do you want configure IPtables ? [Y/n] ' answer
	case "${answer}" in
		[yY]|[yY][eE][sS])

	clear
	echo "${green}###################### ${reset}"
	echo "${green}Iptables configuration ${reset}"
	echo "${green}###################### ${reset}"
	echo -n '.'

	echo "${green}Execute: iptables -P INPUT ACCEPT ${reset}"
	iptables -P INPUT ACCEPT
	echo -n '.'

	echo "${green}Execute: iptables -P OUTPUT ACCEPT ${reset}"
	iptables -P OUTPUT ACCEPT
	echo -n '.'

	echo "${green}Execute: iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT ${reset}"
	iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
	echo -n '.'

	echo "${green}Execute: iptables -A INPUT -p tcp --dport 22 -j ACCEPT ${reset}"
	iptables -A INPUT -p tcp --dport 22 -j ACCEPT
	echo -n '.'

	echo "${green}Execute: iptables -A INPUT -p tcp --dport 80 -j ACCEPT ${reset}"
	iptables -A INPUT -p tcp --dport 80 -j ACCEPT
	echo -n '.'

	echo "${green}Execute: iptables -A INPUT -p tcp --dport 53 -j ACCEPT ${reset}"
	iptables -A INPUT -p tcp --dport 53 -j ACCEPT
	echo -n '.'

	echo "${green}Execute: iptables -A INPUT -p tcp --dport 27017 -j ACCEPT ${reset}"
	iptables -A INPUT -p tcp --dport 27017 -j ACCEPT
	echo -n '.'

	echo "${green}Execute: iptables -A INPUT -p tcp --dport 9418 -j ACCEPT ${reset}"
	iptables -A INPUT -p tcp --dport 9418 -j ACCEPT
	echo -n '.'

	echo "${green}Execute: iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT ${reset}"
	iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
	echo -n '.'

	echo "${green}Execute: iptables -I INPUT 1 -i lo -j ACCEPT ${reset}"
	iptables -I INPUT 1 -i lo -j ACCEPT
	echo -n '.'

	echo "${green}Execute: iptables -P INPUT ACCEPT ${reset}"
	iptables -P INPUT ACCEPT
	echo -n '.'

	echo "${green}Execute: iptables -A INPUT -j DROP ${reset}"
	iptables -A INPUT -j DROP
	echo -n '.'
	iptables-save > /etc/iptables;;

	esac
}

#--------------------------------------------------------------------------------------------------------------------------------
# Install Apach2 
#--------------------------------------------------------------------------------------------------------------------------------
install_apach2(){
	read -p 'Do you want install Apach2 ? [Y/n] ' answer
	case "${answer}" in
		[yY]|[yY][eE][sS])
	
	echo "${green}Execute: apt-get install apache2 apache2.2-common apache2-doc apache2-mpm-prefork apache2-utils libexpat1 ssl-cert libapache2-mod-fcgid apache2-suexec ${reset}"
	apt-get -y install apache2 apache2.2-common apache2-doc apache2-mpm-prefork apache2-utils libexpat1 ssl-cert libapache2-mod-fcgid apache2-suexec
	
	a2enmod suexec rewrite ssl actions include
	a2enmod dav_fs dav auth_digest

	#Fix Ming Error
	rm /etc/php5/cli/conf.d/ming.ini
	cat > /etc/php5/cli/conf.d/ming.ini <<"EOF"
	extension=ming.so
EOF
	#Fix SuPHP
	cp /etc/apache2/mods-available/suphp.conf /etc/apache2/mods-available/suphp.conf.backup
	rm /etc/apache2/mods-available/suphp.conf
	cat > /etc/apache2/mods-available/suphp.conf <<"EOF"
	<IfModule mod_suphp.c>
	    #<FilesMatch "\.ph(p3?|tml)$">
	    #    SetHandler application/x-httpd-suphp
	    #</FilesMatch>
	        AddType application/x-httpd-suphp .php .php3 .php4 .php5 .phtml
	        suPHP_AddHandler application/x-httpd-suphp
	    <Directory />
	        suPHP_Engine on
	    </Directory>
	    # By default, disable suPHP for debian packaged web applications as files
	    # are owned by root and cannot be executed by suPHP because of min_uid.
	    <Directory /usr/share>
	        suPHP_Engine off
	    </Directory>
	# # Use a specific php config file (a dir which contains a php.ini file)
	#       suPHP_ConfigPath /etc/php5/cgi/suphp/
	# # Tells mod_suphp NOT to handle requests with the type <mime-type>.
	#       suPHP_RemoveHandler <mime-type>
	</IfModule>
EOF

	#Enable Ruby Support
	sed -i 's|application/x-ruby|#application/x-ruby|' /etc/mime.types

	#Install XCache
	apt-get -y -qq install php5-xcache

	#Restart Apache
	service apache2 restart >> /dev/null;;
	esac
}

#--------------------------------------------------------------------------------------------------------------------------------
# Install MySql 
#--------------------------------------------------------------------------------------------------------------------------------
install_mysql(){
	read -p 'Do you want install MySql ? [Y/n] ' answer
	case "${answer}" in
		[yY]|[yY][eE][sS])

	echo "${green}Execute: apt-get -y install mysql-client mysql-server ${reset}"
	apt-get -y install mysql-client mysql-server
	#Allow MySQL to listen on all interfaces
	echo "${green}Execute: cp /etc/mysql/my.cnf /etc/mysql/my.cnf.backup ${reset}"
	cp /etc/mysql/my.cnf /etc/mysql/my.cnf.backup
	sed -i 's|bind-address           = 127.0.0.1|#bind-address           = 127.0.0.1|' /etc/mysql/my.cnf
	echo "${green}Execute: service mysql restart >> /dev/null ${reset}"
	service mysql restart >> /dev/null;;
	esac
}

#--------------------------------------------------------------------------------------------------------------------------------
# Install Php5 
#--------------------------------------------------------------------------------------------------------------------------------
install_php5(){
	read -p 'Do you want install Php5 ? [Y/n] ' answer
	case "${answer}" in
		[yY]|[yY][eE][sS])

	echo "${green}Execute: apt-get install php5 php5-cli libapache2-mod-php5 php5-mysql php5-curl php5-gd php-pear php5-imagick php5-mcrypt php5-memcache php5-mhash php5-sqlite php5-xmlrpc php5-xsl php5-json php5-dev libpcre3-dev make sed -y ${reset}"
	apt-get install php5 php5-cli libapache2-mod-php5 php5-mysql php5-curl php5-gd php-pear php5-imagick php5-mcrypt php5-memcache php5-mhash php5-sqlite php5-xmlrpc php5-xsl php5-json php5-dev libpcre3-dev make sed -y;;
	esac
}

#--------------------------------------------------------------------------------------------------------------------------------
# Install mongoDB 
#--------------------------------------------------------------------------------------------------------------------------------
install_mongodb (){
	read -p 'Do you want install MongoDB ? [Y/n] ' answer
	case "${answer}" in
		[yY]|[yY][eE][sS])

	clear
	echo "${green}############### ${reset}"
	echo "${green}MongoDB install ${reset}"
	echo "${green}############### ${reset}"
	echo -n '.'

	echo "${green}Execute: apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 ${reset}"
	apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
	echo -n '.'

	echo "${green}Execute: tee /etc/apt/sources.list.d/mongodb.list ${reset}"
	echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list
	echo -n '.'

	echo "${green}Execute: apt-get update ${reset}"
	apt-get update
	echo -n '.'

	echo "${green}Execute: apt-get install -y mongodb-org ${reset}"
	apt-get install -y mongodb-org
	mkdir /data
	mkdir /data/db

	echo "${green}Execute: service mongod start ${reset}"
	service mongod start;;
	esac
}

#--------------------------------------------------------------------------------------------------------------------------------
# Install node (culr, nodejs, npm, forever, crontab)
#--------------------------------------------------------------------------------------------------------------------------------
install_node (){
	read -p 'Do you want install and configure Node ? [Y/n] ' answer
	case "${answer}" in
		[yY]|[yY][eE][sS])

	clear
	cd /

	echo "${green}############################### ${reset}"
	echo "${green}Node install (NPM, Forever)${reset}"
	echo "${green}############################### ${reset}"

	echo "${green}Execute: apt-get install curl ${reset}"
	apt-get install curl
	echo -n '.'

	echo "${green}Execute: curl -sL https://deb.nodesource.com/setup | bash - ${reset}"
	curl -sL https://deb.nodesource.com/setup | bash -
	echo -n '.'

	echo "${green}Execute: apt-get install nodejs ${reset}"
	apt-get install nodejs
	echo -n '.'

	echo "${green}Execute: cd /usr/bin/ ${reset}"
	cd /usr/bin/
	echo -n '.'

	echo "${green}Execute: ln -s nodejs node ${reset}"
	ln -s nodejs node
	echo -n '.'

	echo "${green}Execute: cd / ${reset}"
	cd /
	echo -n '.'

	echo "${green}Execute: apt-get install npm ${reset}"
	apt-get install npm
	echo -n '.'

	echo "${green}Execute: npm install forever -g ${reset}"
	npm install forever -g
	echo -n '.'

	echo "${green}Execute: npm install forever-monitor ${reset}"
	npm install forever-monitor
	echo -n '.'

	echo "${green}Execute: nano crontab.sh ${reset}"
	echo "@reboot /usr/bin/forever start -c /usr/bin/node -l /var/node/.foreverlog -e /var/node/.log -o /var/node/.log -a /var/node/depo/server.js" >> crontab.sh
	echo -n '.'

	echo "${green}Execute: crontab crontab.sh  ${reset}"
	crontab crontab.sh
	echo -n '.'

	echo "${green}Execute: rm -rf crontab.sh  ${reset}"
	rm -rf crontab.sh
	echo -n '.';;
	esac
}

#--------------------------------------------------------------------------------------------------------------------------------
# Install git
#--------------------------------------------------------------------------------------------------------------------------------
install_git (){

	read -p 'Do you want install and configure Git ?  [Y/n] ' answer
	case "${answer}" in
		[yY]|[yY][eE][sS])

	clear
	if [ -d '/var/git' ]; then
		echo "${red}You are already Git install${end}"
	else
		echo "${green}########## ${reset}"
		echo "${green}Git install${reset}"
		echo "${green}########## ${reset}"
		echo -n '.'

		echo "${green}Execute: apt-get install git ${reset}"
		apt-get install git
		echo -n '.'

		echo "${green}Execute: adduser --system --shell /bin/bash --group --disabled-password --home /var/git/ git ${reset}"
		adduser --system --shell /bin/bash --group --disabled-password --home /var/git/ git
		echo -n '.'

		echo "${green}Execute: mkdir /var/git ${reset}"
		mkdir /var/git
		echo -n '.'

		echo "${green}Execute: chown git:git /var/git ${reset}"
		chown git:git /var/git
		echo -n '.'

		echo "${green}Execute: mkdir /var/git/.ssh ${reset}"
		mkdir /var/git/.ssh
		echo -n '.'

		echo "${green}Execute: touch /var/git/.ssh/authorized_keys ${reset}"
		touch /var/git/.ssh/authorized_keys
		echo -n '.'

		echo "${green}Execute: mkdir /var/git/depo.git ${reset}"
		mkdir /var/git/depo.git
		echo -n '.'

		echo "${green}Execute: cd /var/git/depo.git/ ${reset}"
		cd /var/git/depo.git/
		echo -n '.'

		echo "${green}Execute: git init --bare ${reset}"
		git init --bare
		echo -n '.'

		echo "${green}Execute: chown -R git:git /var/git/depo.git/ ${reset}"
		chown -R git:git /var/git/depo.git/
		echo -n '.'

		echo "${green}Execute: chown -R git:git /var/git/depo.git/.git ${reset}"
		chown -R git:git /var/git/depo.git/.git
		echo -n '.'

		echo "${green}Execute: nano /var/git/depo.git/hooks/post-update ${reset}"
		echo "#!/bin/bash
		cd /var/node/depo
		unset GIT_DIR
		git pull origin master" >> /var/git/depo.git/hooks/post-update
		echo -n '.'

		echo "${green}Execute: chmod +x /var/git/depo.git/hooks/post-update ${reset}"
		chmod +x /var/git/depo.git/hooks/post-update
		echo '... Install done'
	fi
	;;
	esac
}

#--------------------------------------------------------------------------------------------------------------------------------
# Install Dev Tools (gem, bower, grunt, gulp, sass, compass, less)
#--------------------------------------------------------------------------------------------------------------------------------
install_dev_tools(){
	read -p 'Do you want install dev tools (bower, grunt, gulp, sass, compass, less) ?  [Y/n] ' answer
	case "${answer}" in
		[yY]|[yY][eE][sS])

	clear

	echo "${green}Execute: apt-get install rubygems ${reset}"
	apt-get install rubygems
	gem source -a http://rubygems.org
	gem update

	echo "${green}Execute: npm install -g bower ${reset}"
	npm install -g bower

	echo "${green}Execute: npm install -g gulp ${reset}"
	npm install -g gulp

	echo "${green}Execute: npm install -g grunt-cli ${reset}"
	npm install -g grunt-cli

	echo "${green}Execute: gem install sass ${reset}"
	gem install sass

	echo "${green}Execute: gem install compass ${reset}"
	gem install compass;;
	esac
}

finish(){
	echo "${green}Execute: source ~/.bashrc ${reset}"
	source ~/.bashrc

	echo "${green}Installation has completed.${reset}"
	echo "${green}It is recommended to reboot ${reset}"
	echo "${green}You must execute: crontab -e  ${reset}"
	echo "${green}You must configure user mongo http://docs.mongodb.org/manual/tutorial/add-admin-user/ and auth /etc/mongod.conf ${reset}"
	echo "${green}You must execute: git clone /var/git/depo.git/ /var/node/depo/"
	echo "${green}Please send your comments and/or suggestions to contact@adowya.fr${reset}"
}


if [ -f ~/.command_log ]
	then
	echo "${red}You have already pre-install version${end}"
	read -p 'Do you want re-install ? [Y/n] ' answer
		case "${answer}" in
			[yY]|[yY][eE][sS])
	
	echo "${green}Execute: install_basic ${reset}"
	install_basic;;
	esac

else
	echo "${green}Execute: install_basic ${reset}"
	install_basic
fi
