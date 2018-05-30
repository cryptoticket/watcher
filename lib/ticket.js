const keccak     = require("keccak");
const secp256k1  = require("secp256k1");

const expirationTime = 5;

function getMessage(event, ticket) {
    return event + ticket + (Math.ceil((new Date()).getTime() / (1000 * 60 * expirationTime)) * (1000 * 60 * expirationTime)) / 1000;
}

module.exports = {
    sign: (contract, ticket, privateString) => {
        const message = getMessage(contract, ticket);
        const privateKey = new Buffer(privateString, 'hex');
        const sign = secp256k1.sign(keccak('keccak' + 256).update(Buffer.concat([
            Buffer.from('\u0019Ethereum Signed Message:\n' + message.length.toString()),
            Buffer.from(message)
        ])).digest(), privateKey);

        return '0x' + Buffer.concat([
            sign.signature.slice(0, 32),
            sign.signature.slice(32, 64),
            new Buffer(`0x${(sign.recovery.toString(16).length % 2) ? `0${sign.recovery.toString(16)}` : sign.recovery.toString(16)}`.slice(2), 'hex')
        ]).toString('hex');
    },

    verify: (contract, ticket, signature) => {
        const message = getMessage(contract, ticket);
        const sign = Buffer.from(signature.slice(2), 'hex');

        const publicKey = secp256k1.publicKeyConvert(secp256k1.recover(
            keccak('keccak' + 256).update(Buffer.concat([
                Buffer.from('\u0019Ethereum Signed Message:\n' + message.length.toString()),
                Buffer.from(message)
            ])).digest(),
            Buffer.concat([sign.slice(0, 32), sign.slice(32, 64)], 64), sign[64]
        ), false).slice(1);

        return '0x' + keccak('keccak' + 256).update(publicKey).digest().slice(-20).toString('hex');
    }
}