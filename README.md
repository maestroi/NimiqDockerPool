# Nimiq Mining-Pool Server
This mining pool server combines resources of multiple clients mining on the Nimiq blockchain.
Clients are independent network nodes and generate or validate blocks themselves to support decentralization.
Details about the mining pool protocol can be found [here](https://nimiq-network.github.io/developer-reference/chapters/pool-protocol.html#mining-pool-protocol).
A mining pool client is implemented in [Nimiq Core](https://github.com/nimiq-network/core/tree/master/src/main/generic/miner).
Created with love by Nimiq, and DockerPool with SushiPool.

## Architecture
The pool server consists of three parts which communicate through a common Mariadb database (schema see `sql/create.sql`)
* The pool **server** interacts with clients and verifies their shares. There can be multiple pool server instances.
* The pool **service** computes client rewards using a PPLNS reward system.
* The pool **payout** processes automatic payouts above a certain user balance and payout requests.

While the server(s) and the service are designed to run continuously, the pool payout has to be executed whenever a payout is desired.

## WARNING
By Running a miningpool you are handeling nimiq currency for your users please handle with care!

## Generating wallet.
For payout you can get a wallet with seed here https://tools.sushipool.com/.
Use at your own risk!

## Requirements
- VPS/Dedicated server with own public IP
- Ubuntu 18.04+
- Domain name
- Cloudflare account
- Some IT knowledge
- Coffee.(Critical)

## TESTED ON
- Digital ocean.
- Cloudflare dns only domain.
- Ubuntu 18.04 x64 server.

## First run
steps:
- First of all setup cloudflare by following this guide https://support.cloudflare.com/hc/en-us/articles/201720164-Step-2-Create-a-Cloudflare-account-and-add-a-website
- second `git clone https://github.com/maestroi/NimiqDockerPool.git` in the /root directory.
- change with `nano setup.sh` the configuration where it states #changeme.
- and finaly run `bash setup.sh` and watch the magic happen.
- Have fun :)
  
## Run
Run `sudo docker-compose up --build -d`, this is done in /home/USER/node directory of the created user.

## LIMITED SUPPORT.
there is limited support on this project, i will keep it up to date if i feel like it :-).

Donations on: NQ29 Q4X7 JS4A 5Y7E 6ATR B44S 5FMC UNMR 3A2H are appreciated. 

# Changes:
Added:
- origin/soeren/pool-stats 
- origin/soeren/owner-payout
- origin/fiaxh/optimize_db_qrys
- origin/soeren/proxied-ip