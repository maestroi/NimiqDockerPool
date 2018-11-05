#!/bin/bash

# Patch Node configuration
sed -i "s/name: 'POOL_NAME'/name: '$POOL_NAME'/g" ./config/server.conf # Set pool name you see this in the default page.
sed -i "s/mySqlUsr: 'POOL_SERVER_USER'/mySqlUsr: '$POOL_SERVER_USER'/g" ./config/server.conf  # Set Mysql user normaly this is pool_server in mysql container see ./mysql/sql/pool.sql
sed -i "s/mySqlPsw: 'POOL_SERVER_PASS'/mySqlPsw: '$POOL_SERVER_PASS'/g" ./config/server.conf # Set Mysql password in mysql container see ./mysql/sql/pool.sql
sed -i "s/mySqlHost: 'POOL_MYSQL_SERVER'/mySqlHost: '$POOL_MYSQL_SERVER'/g" ./config/server.conf # Set mysql server see docker-compose name default is mysql
sed -i "s/address: 'WALLET_ADDRESS'/address: '$WALLET_ADDRESS'/g" ./config/server.conf # Set the wallet address where you are mining at.
sed -i "s/host: 'POOL_DOMAIN'/host: '$POOL_DOMAIN'/g" ./config/server.conf # set domain name to be used by the node.

# Start Node
node index.js --config=./config/server.conf
