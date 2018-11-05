#!/bin/bash

# Patch Master configuration
sed -i "s/name: 'POOL_NAME'/name: '$POOL_NAME'/g" ./config/service.conf # Set pool name you see this in the default page.
sed -i "s/mySqlUsr: 'POOL_SERVICE_USER'/mySqlUsr: '$POOL_SERVICE_USER'/g" ./config/service.conf # Set Mysql user normaly this is pool_service in mysql container see ./mysql/sql/pool.sql
sed -i "s/mySqlPsw: 'POOL_SERVICE_PASS'/mySqlPsw: '$POOL_SERVICE_PASS'/g" ./config/service.conf # Set Mysql password in mysql container see ./mysql/sql/pool.sql
sed -i "s/mySqlHost: 'POOL_MYSQL_SERVER'/mySqlHost: '$POOL_MYSQL_SERVER'/g" ./config/service.conf # Set mysql server see docker-compose name default is mysql
sed -i "s/address: 'WALLET_ADDRESS'/address: '$WALLET_ADDRESS'/g" ./config/service.conf # Set the wallet address where you are mining at.
sed -i "s/host: 'POOL_DOMAIN'/host: '$POOL_DOMAIN'/g" ./config/service.conf # set domain name to be used by the node.

# Start Master
node index.js --config=./config/service.conf
