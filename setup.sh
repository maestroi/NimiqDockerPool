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
username="pooluser" 
< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo $password;
thisisthepoolname="NIMIQ-POOL" #CHANGEME 
## needed voor lets encrypt cert.
thisisthedomain="DOMAIN.COM" #CHANGEME 
email="email" #CHANGEME 
## config Wallet settings
## get your wallet and seed from: https://tools.sushipool.com/ !!!!SAVE IT!!!!
thisisthewalletaddress="NQ32 473Y R5T3 979R 325K S8UT 7E3A NRNS VBX2" #CHANGEME
thisisthewalletseed="" #CHANGEME 
## certbot for certificates
certbot_image="certbot/certbot" 
certbot_release="latest"
##pool settings
< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo $mysql_root_password; ## random generate password
< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo $pool_payout_password; ## random generate password
< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo $pool_service_password; ## random generate password
< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo $pool_server_password; ## random generate password
< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo $pool_info_password; ## random generate password
#save all the passwords :) delete it when you store it at your password vault.
echo -e "OS_password: $password \n mysql_root_password: $mysql_root_password \n pool_payout_password: $pool_payout_password \n pool_service_password: $pool_service_password \n pool_server_password: $pool_server_password \n pool_info_password: $pool_info_password \n" > /root/passwords.txt
echo '+-----------------------------------------------+'
echo '| Make sure your domain is linked to your ip!   |'
echo '+-----------------------------------------------+'
sleep 5
# First update and install requirements
echo '+-----------------------------------------------+'
echo '|  Setup some needed stuff!                     |'
echo '+-----------------------------------------------+'
sudo add-apt-repository ppa:certbot/certbot -y  && sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common 
echo '+-----------------------------------------------+'
echo '|  Setup Docker-CE!                             |'
echo '+-----------------------------------------------+'
# Curl the key for docker Ubuntu :)
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# install Docker!!
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" -y && sudo apt-get update -y &&  sudo apt-get install docker-ce -y
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
docker volume create node_cert
docker pull $certbot_image:$certbot_release
docker run -it --rm -p 80:80 --name certbot \
	-v node_cert:/etc/letsencrypt \
	$certbot_image:$certbot_release certonly --standalone --rsa-key-size 4096 --agree-tos --email $email -n -d $thisisthedomain 
echo '+-----------------------------------------------+'
echo '|  Getting main-consensus                       |'
echo '|  This may take a while                        |'
echo '+-----------------------------------------------+'
docker volume create node_main-full-consensus_master
docker volume create node_main-full-consensus_node
docker volume create node_main-full-consensus_payout
wget https://download.sushipool.com/main-full-consensus.tar.bz2
mkdir /tmp/node
sudo tar -jxf main-full-consensus.tar.bz2 --directory /tmp/node/
cp -a /tmp/node/. /var/lib/docker/volumes/node_main-full-consensus_node/_data
cp -a /tmp/node/. /var/lib/docker/volumes/node_main-full-consensus_master/_data
cp -a /tmp/node/. /var/lib/docker/volumes/node_main-full-consensus_payout/_data
sudo rm main-full-consensus.tar.bz2
sudo rm -r /tmp/node
sudo rm -r /root/NimiqDockerPool
echo '+-----------------------------------------------+'
echo '|  Start docker-pool                            |'
echo '+-----------------------------------------------+'
sudo docker network create proxy
sudo docker-compose -f /home/$username/node/docker-compose.yml up -d --build