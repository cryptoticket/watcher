# Dynamic QR code generation and verification

Dynamic QR code representing concatenation signed message, ticket hash and client timestamp.      
QR code always have the same length 208 symbols:
 * Signed message is first 132 symbols, 
 * Ticket hash is next 66 symbols 
 * Timestamp is last 10 symbols.

## Message generation

Open Message is concatenation of Event SmartContract Address, Ticket Hash and Timestamp in UTC rounded with precision up to the minute.    

#### Example:

```js
function generateMessage(event, ticket, expire = 1) {
    let timestamp = (Math.ceil((new Date()).getTime() / (1000 * 60 * expire)) * (1000 * 60 * expire)) / 1000;
    
    return event + ticket + timestamp;
}
```

## Message signing

Message sign with Ethereum private key using `keecak` and `secp256k1` cryptographic algorithms and completely compatible with [eth_sign](https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign) method.   

#### Example:

```js
function signMessage(message, privateString) {    
    const keccak = require("keccak");
    const secp256k1 = require("secp256k1");
    
    const privateKey = new Buffer(privString, 'hex');
    const sig = secp256k1.sign(keccak('keccak256').update(Buffer.concat([
        Buffer.from('\u0019Ethereum Signed Message:\n' + message.length.toString()),
        Buffer.from(message)
    ])).digest(), privateKey);
    
    return '0x' + Buffer.concat([
        sig.signature.slice(0, 32), 
        sig.signature.slice(32, 64), 
        new Buffer((sig.recovery + 27).toString(16), 'hex')
    ]).toString('hex');
}
```

## Message verification

Verification of Signed Message verifying using same `keecak` and `secp256k1` cryptographic algorithms. Verification function return public part of key that sign the Message. 

#### Example:

```js
function verifySignedMessage(message, sign) {
    const keccak = require("keccak");
    const secp256k1 = require("secp256k1");

    const sig = Buffer.from(sign.slice(2), 'hex');    
    const publicKey = secp256k1.publicKeyConvert(secp256k1.recover(
        keccak('keccak256').update(Buffer.concat([
            Buffer.from('\u0019Ethereum Signed Message:\n' + message.length.toString()), 
            Buffer.from(message)
        ])).digest(), 
        Buffer.concat([sig.slice(0, 32), sig.slice(32, 64)], 64), sig[64] - 27
    ), false).slice(1);
    
    return '0x' + keccak('keccak256').update(publicKey).digest().slice(-20).toString('hex');
}
```

## QR code verification

#### Example:

```js
const event = '0xfc5e4fee985db8df090aa22b33d0925ac8fd6178';

function qrCodeVerification(qr) {
    let serverTimestamp = (Math.ceil((new Date()).getTime() / (1000 * 60 * expire)) * (1000 * 60 * expire)) / 1000;

    let signedMessage = qr.slice(0, 132);
    let ticketHash = qr.slice(132, 198);
    let customerTimestamp = qr.slice(198);
    
    if (qr.length != 208)
        throw new Error(`Invalid QR code length. Recived length is ${qr.length} but expected is ${208}`);
        
    if (serverTimestamp != customerTimestamp)
        throw new Error(`Invalid QR code timestamp. Expected timestamp is ${serverTimestamp} but recived ${customerTimestamp}`);
            
    let message = getMessage(event, ticketHash, serverTimestamp);
    let address = verifySignedMessage(message, signedMessage);
    
    return {address: address, ticket: ticketHash};
}
```