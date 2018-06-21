const config         = require('./config.json');
const express        = require('express');
const bodyParser     = require('body-parser');
const fs             = require('fs');

const ipfsLib        = require('./lib/ipfs');
const eventLib        = require('./lib/event');
const ticketLib      = require('./lib/ticket');

const ipfs           = new ipfsLib(config.ipfs.protocol, config.ipfs.host, config.ipfs.port, config.ipfs.url);
const contractAbi    = JSON.parse(fs.readFileSync(`${config.contracts.abi}${config.contracts.default}.abi`));
const ticketEvents   = ['TicketAllocated', 'TicketRefunded', 'TicketRedeemed',  'TicketTransferred'];
const app            = express();

app.use(bodyParser.json());

app.get('/', function (req, res) {
    res.send({status: true, timestamp: Date.now()});
});

app.get('/contract/:address/info', function (req, res) {
    const contract = new eventLib(config.eth_rpc.http, req.params.address, contractAbi);

    let contractInfo = {};
    ipfs.getMetadata(contract.ipfs_hash, (err, metadata) => {
        if(err) { res.status('422').send({error: 'Contract metadata fetching error', message: err.message}); return; }

        contractInfo['metadata'] = metadata;
        contract.instance.allEvents({fromBlock: 0, toBlock: 'latest'}).get(function(err, events){
            if(err) { res.status('422').send({error: 'Contract events fetching error', message: err.message}); return; }
            console.log(`Contract ${contract.address} events count ${events.length}`);

            let promises = [];
            events.filter(event => event.event in ticketEvents).forEach((event) => {
                console.log(`${event.event} ${event.args._ticket} at block ${event.blockNumber}`);

                promises.push(new Promise((resolve) => {
                    ipfs.getMetadata(ipfs.getIpfsHashFromBytes32(event.args._ticket), (err, metadata) => {
                        if(err) { res.status('422').send({error: 'Ticket metadata fetching error', message: err.message}); return; }

                        resolve({
                            event: event.event,
                            ticket: event.args._ticket,
                            to: event.args._to,
                            from: event.args._from,
                            ipfs: ipfs.getIpfsHashFromBytes32(event.args._ticket),
                            metadata: metadata
                        });
                    });
                }));
            });

            Promise.all(promises).then((ticket) => {
                contractInfo['tickets'] = [].concat.apply([], ticket);
                res.send(contractInfo);
            });
        });
    });
});

app.post('/ticket/:ticket/info', function (req, res) {
    const event  = req.body.event;
    const ticket = req.params.ticket;

    const contract = new eventLib(config.eth_rpc.http, event, contractAbi);
    const owner = contract.instance.allocatedTickets.call(ticket);

    ipfs.getMetadata(ipfs.getIpfsHashFromBytes32(ticket), (err, metadata) => {
        if(err) { res.status('422').send({error: 'Ticket metadata fetching error', message: err.message}); return; }

        res.send({
            owner: owner,
            metadata: metadata
        });
    });
});

app.post('/ticket/:ticket/verify', function (req, res) {
    const event       = req.body.event;
    const ticket      = req.params.ticket;
    const signature   = req.body.signature;

    const address = ticketLib.verify(event, ticket, signature);

    const contract = new eventLib(config.eth_rpc.http, event, contractAbi);
    const owner = contract.instance.allocatedTickets.call(ticket);

    ipfs.getMetadata(ipfs.getIpfsHashFromBytes32(ticket), (err, metadata) => {
        res.send({
            isValid: owner == address ? true : false,
            signer: address,
            owner: owner,
            metadata: metadata
        });
    });
});

app.listen(config.app.port, config.app.host, () => {
    console.log(`Scanner API run at ${config.app.host}:${config.app.port}`);
});