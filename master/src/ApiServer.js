const HttpDispatcher = require('httpdispatcher');
const http = require('http');
const dispatcher = new HttpDispatcher();
const Nimiq = require('@nimiq/core');
const Helper = require('./Helper');

class ApiServer {
    static handleRequest(request, response, poolServer) {
        request.poolServer = poolServer;
        dispatcher.dispatch(request, response, poolServer);
    }

    static sendJSON(res, data){
        res.writeHead(200, {"Content-Type": "application/json"});
        res.end(JSON.stringify(data));
    }
}

dispatcher.onGet('/', function (req, res) {
    const poolServer = req.poolServer;
    res.writeHead(200);
    res.end(`
${poolServer.config.name}
${Array(poolServer.config.name.length).fill('-').join('')}

### STATS ###

Connected miners:    ${poolServer.numClients}
Pool hashrate:       ${Math.round(poolServer.averageHashrate)} H/s
Blocks mined:        ${poolServer.totalBlocksMined}
Network:             main


### HOW TO CONNECT ###

To connect, add '--pool=${poolServer.config.name}:${poolServer.port}' to your NodeJS miner command line, or add this to your config file:

poolMining: {
    enabled: true,
    host: '${poolServer.config.name}',
    port: ${poolServer.port},
}
`);
});

dispatcher.onGet('/api/v1/stats/pool', function (req, res) {
    const poolServer = req.poolServer;
    ApiServer.sendJSON(res, {
        'clients': poolServer.getClientModeCounts(),
        'hashrate': poolServer.averageHashrate * 1000,
        'banned_ips': poolServer.numIpsBanned,
        'blocks_mined_since_restart': poolServer.numBlocksMined,
        'wallet_address': poolServer.config.address,
        'host': `${poolServer.config.name}:${poolServer.port}`
    });
});

module.exports = exports = ApiServer;
