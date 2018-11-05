#!/bin/ash
# Patch payout configuration
sed -i "s/name: 'POOL_NAME'/name: '$POOL_NAME'/g" ./config/payout.conf
sed -i "s/mySqlUsr: 'POOL_PAYOUT_USER'/mySqlUsr: '$POOL_PAYOUT_USER'/g" ./config/payout.conf 
sed -i "s/mySqlPsw: 'POOL_PAYOUT_PASS'/mySqlPsw: '$POOL_PAYOUT_PASS'/g" ./config/payout.conf 
sed -i "s/mySqlHost: 'POOL_MYSQL_SERVER'/mySqlHost: '$POOL_MYSQL_SERVER'/g" ./config/payout.conf
sed -i "s/address: 'WALLET_ADDRESS'/address: '$WALLET_ADDRESS'/g" ./config/payout.conf 
sed -i "s/seed: 'WALLET_SEED'/address: '$WALLET_SEED'/g" ./config/payout.conf 
sed -i "s/host: 'POOL_DOMAIN'/host: '$POOL_DOMAIN'/g" ./config/payout.conf


n=1
while true; do
	sleep $SLEEP_TIMER
	timestamp=$(date +"%D %T")
	echo -e "\nStaged PayOut is running. Payout in 3 Hours"
	echo "$timestamp | Running for the $n time!"
	node index.js --config=./config/payout.conf
	let n=n+1 
done



