const Web3  = require("web3");

module.exports = class web3 {
    constructor(url, address, abi) {
        this.connection = new Web3(new Web3.providers.HttpProvider(url));
        this.address = address;
        this.instance = this.connection.eth.contract(abi).at(address);
        this.version = this.instance.version.call().toString();
        this.ipfs_hash = this.instance.metadata.call().toString();
    }
}