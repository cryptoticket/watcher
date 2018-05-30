const ipfsAPI = require('ipfs-api');
const bs58    = require('bs58');

module.exports = class ipfs {
    constructor(protocol, host, port, url) {
        this.url = url;
        this.connection = new ipfsAPI({protocol: protocol, host: host, port: port});
    }

    getMetadata(hash, callback) {
        this.connection.files.get(hash, (err, files) => {
            if(err) callback(err, null)

            let data = {};
            files.forEach((file) => {
                if(file.content) {
                    let current = data;
                    let keys = file.path.replace(hash + '/', '').split('/');
                    keys.forEach((key, index) => {
                        if(key == 'media') {
                            current[key] = this.url + file.path;
                        } else if(keys.length == index + 1) {
                            current[key] = file.content.toString();
                        } else if(!data[key]) {
                            data[key] = {}; current = data[key];
                        } else {
                            current = data[key];
                        }
                    })
                }
            });

            callback(null, data);
        })
    }

    getIpfsHashFromBytes32(ticket) {
        return bs58.encode(Buffer.from("1220" + ticket.slice(2), 'hex'));
    }

    getBytes32FromIpfsHash(hash) {
        return '0x' + bs58.decode(hash).slice(2).toString('hex');
    }
}