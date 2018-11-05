#!/usr/bin/env bash
echo '+-----------------------------------------------+'
echo '| NimiqPool setup                               |'
echo '| Script made by Maestro                        |'
echo '+-----------------------------------------------+'
# This is tested on Ubuntu 18.04, inbstall Docker CE
# This script assumes a clean ubuntu 18.04 install 
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
##general
osusername="nimiq"
ospassword="thisisasafepassword"
thisisthepoolname="nimiq"
## needed voor lets encrypt cert.
thisisthedomain="nimiq.ovh"
email="email"
## certbot
certbot_image="certbot/certbot" 
certbot_release="latest"
##pool settings
mysql_root_password="thisismysqlrootpassword"
pool_payout_password="thisispoolpayoutpassword"
pool_service_password="thisistheservicepassword"
pool_server_password="thisistheserverpassword"
pool_info_password="thisispoolinfopassword"
## config Wallet settings
thisisthewalletaddress="NQ32 473Y R5T3 979R 325K S8UT 7E3A NRNS VBX2"
thisisthewalletseed=""

echo '+-----------------------------------------------+'
echo '| Make sure your domain is linked to your ip!   |'
echo '+-----------------------------------------------+'
sleep 5
# First update and install requirements
echo '+-----------------------------------------------+'
echo '|  Setup some needed stuff!                     |'
echo '+-----------------------------------------------+'
sudo add-apt-repository ppa:certbot/certbot -y && sudo apt-get update -y && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
echo '+-----------------------------------------------+'
echo '|  Setup Docker-CE!                             |'
echo '+-----------------------------------------------+'
# Curl the key for docker Ubuntu :)
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# install Docker!!
sudo apt-get update && sudo apt-get install docker-ce
echo '+-----------------------------------------------+'
echo '|  Setup Docker-Compose!                        |'
echo '+-----------------------------------------------+'
# time fore docker compose 
sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# Set right permissions
sudo chmod +x /usr/local/bin/docker-compose
# Setup user :)
echo '+-----------------------------------------------+'
echo '|  Setup user!                                  |'
echo '+-----------------------------------------------+'
getent passwd $username > /dev/null 2&>1
if [ $? -eq 0 ]; then
    echo "User $username already exist"
else
	echo "user does not exist making user..."
	useradd -m -s /bin/bash $username; echo $username:$password | chpasswd
	adduser $username sudo
fi
# setup security stff
echo '+-----------------------------------------------+'
echo '|  Install security packages                    |'
echo '+-----------------------------------------------+'
sudo apt install sysstat libpam-cracklib lynis ntpdate auditd debsecan debian-goodies fail2ban clamav unattended-upgrades -y
# Download pool
echo '+-----------------------------------------------+'
echo '|  Install Pool                                 |'
echo '+-----------------------------------------------+'
sudo -u $username git clone https://github.com/maestroi/NimiqDockerPool.git /home/$username/node
echo '+-----------------------------------------------+'
echo '|  Config pool                                  |'
echo '+-----------------------------------------------+'
## pool stuff
sed -i "s/thisisthepoolname/$thisisthepoolname/g" /home/$username/node/docker-compose.yml
sed -i "s/thisisthedomain/$thisisthedomain/g" /home/$username/node/docker-compose.yml
sed -i "s/thisisthewalletaddress/$thisisthewalletaddress/g" /home/$username/node/docker-compose.yml
sed -i "s/thisisthewalletseed/$thisisthewalletseed/g" /home/$username/node/docker-compose.yml
## setup docker-compose pool SQL
sed -i "s/thisismysqlrootpassword/$mysql_root_password/g" /home/$username/node/docker-compose.yml
sed -i "s/thisistheservicepassword/$pool_service_password/g" /home/$username/node/docker-compose.yml
sed -i "s/thisistheserverpassword/$pool_server_password/g" /home/$username/node/docker-compose.yml
sed -i "s/thisispoolpayoutpassword/$pool_payout_password/g" /home/$username/node/docker-compose.yml
sed -i "s/thisispoolinfopassword/$pool_info_password/g" /home/$username/node/docker-compose.yml
## setup sql.
sed -i "s/thisispoolpayoutpassword/$pool_payout_password/g" /home/$username/node/mysql/sql/pool.sql
sed -i "s/thisistheservicepassword/$pool_service_password/g" /home/$username/node/mysql/sql/pool.sql
sed -i "s/thisistheserverpassword/$pool_server_password/g" /home/$username/node/mysql/sql/pool.sql
sed -i "s/thisispoolinfopassword/$pool_info_password/g" /home/$username/node/mysql/sql/pool.sql
## SSL
docker volume create cert
docker pull $certbot_image:$certbot_release
docker run -it --rm -p 80:80 --name certbot \
	-v cert:/etc/letsencrypt \
	$certbot_image:$certbot_release certonly --standalone --rsa-key-size 4096 --agree-tos --email $email -n -d $thisisthedomain 
#docker run --rm -it -v "/root/letsencrypt/log:/var/log/letsencrypt" -v "/var/www/html/shared:/var/www/" -v "cert:/etc/letsencrypt" -v "/root/letsencrypt/lib:/var/lib/letsencrypt" lojzik/letsencrypt certonly --webroot --webroot-path /var/www --email $email -d $thisisthedomain
echo '+-----------------------------------------------+'
echo '|  Start docker-pool                            |'
echo '+-----------------------------------------------+'
sudo -u $username /home/$username/node/docker-compose up -d --build