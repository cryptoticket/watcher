# Watcher 

## Deployment

## API Description

### Contracts

#### POST contract/:event/info

Return contract metadata and tickets processing events

##### Request 

###### Parameters
| Parameter | Type | Required | Description |
|:--:|:--:|:--:|:--:|
| event | string | Yes | Contract Address in Ethereum Network |

##### Response

###### Parameters
| Parameter | Type | Required | Description |
|:--:|:--:|:--:|:--:|
| metadata | object | Yes | Event metadata from IPFS |
| tickets | array | Yes | All tickets processing events |

###### Example
**200 OK**
```json
{
    "metadata": {
        "name": "400 les coups, Truffaut",
        "description": "K I N O",
        "start": "1527764400",
        "end": "1528311600",
        "language": "ru",
        "currency": "RUB",
        "venue": {
            "address": "пр. Энгельса, 30",
            "city": "498817",
            "country_code": "RU",
            "lat": "60.00711782796839",
            "lon": "30.327372550964355",
            "name": "Шурпа на Энгельса",
            "region": "",
            "zip_code": ""
        },
        "organizer": {
            "created": "1527593035",
            "external_id": "5b0d374f0944c10017fcce16",
            "id": "650",
            "is_active": "true",
            "name": "Дед купи конфет",
            "updated": "1527593036",
            "wallet": "0x631ef5701545e006a07a50b4536ef009442a0a86"
        },
        "legals": {
            "bank": "",
            "detail": "ООО \"Первая Развлекательная компания\", , г. Москва, Графский переулок, дом 14, строение 2, 4 этаж, ОГРН: 3452340982112, ИНН: 2345423521, КПП: 245345223",
            "name": "ООО \"Первая Развлекательная компания\"",
            "ssn": ""
        }
    },
    "tickets": [
        {
            "event": "TicketAllocated",
            "ticket": "0x71a41f8125c40fe23179007c8f61e69aad39ab4f743a738fd5492e80f587a735",
            "to": "0x4da0e910505d8678d774154096d619fe6515f3b0",
            "ipfs": "QmVzFvvyc2dmMYE3nLRf5wTPXQjvq9S6dtmCjwjUSvdMmW",
            "metadata": {
                "category": "Танцпол или ВИП",
                "created": "1527593122",
                "external_id": "5b0d37cde9879a0001b604f3",
                "price": {
                    "currency": "RUB",
                    "nominal": "150"
                },
                "type": "common"
            }
        },
        {
            "event": "TicketAllocated",
            "ticket": "0x933fdaa1e2169cc87082e010e40b106209f7f7372e2d898f46ebb0034fc4b6da",
            "to": "0x4da0e910505d8678d774154096d619fe6515f3b0",
            "ipfs": "QmYFT7ZYVd3JhrsBWmxe45BkEfNEsBaGizQENGYfRKMHZT",
            "metadata": {
                "category": "Танцпол или ВИП",
                "created": "1527593125",
                "external_id": "5b0d37cde9879a0001b604f0",
                "price": {
                    "currency": "RUB",
                    "nominal": "150"
                },
                "type": "common"
            }
        },
        {
            "event": "TicketAllocated",
            "ticket": "0xab8dbcaa2a6df5fe64d1a3c17a606c4a4fe0437d2586e68a3d0205c9a5fb8f23",
            "to": "0x4da0e910505d8678d774154096d619fe6515f3b0",
            "ipfs": "QmZtKn7yLdJVuZXxYUEfK4xx3DWBeLCMxTwFepYBaxNuir",
            "metadata": {
                "category": "Танцпол или ВИП",
                "created": "1527593130",
                "external_id": "5b0d37cde9879a0001b604f5",
                "price": {
                    "currency": "RUB",
                    "nominal": "150"
                },
                "type": "common"
            }
        },
        {
            "event": "TicketAllocated",
            "ticket": "0x2975764896425c86585f43d60cc8208935f89b1d971d1f0470ed03fea59c9548",
            "to": "0x4da0e910505d8678d774154096d619fe6515f3b0",
            "ipfs": "QmR8VJtKEqrHCEvAwJVsr14vxyFEPiBghcjc4aNM6yBcas",
            "metadata": {
                "category": "Танцпол или ВИП",
                "created": "1527593134",
                "external_id": "5b0d37cde9879a0001b604ef",
                "price": {
                    "currency": "RUB",
                    "nominal": "150"
                },
                "type": "common"
            }
        },
        {
            "event": "TicketAllocated",
            "ticket": "0x7500b8ff97920f60628ab10b0d95944dd95f3fb82af1aab5e399c25310d14c0a",
            "to": "0x4da0e910505d8678d774154096d619fe6515f3b0",
            "ipfs": "QmWDP3p4xeCCxf8C6oFhpyTdVWMYQ8kDykGqK5J8srZuKP",
            "metadata": {
                "category": "Танцпол или ВИП",
                "created": "1527593137",
                "external_id": "5b0d37cde9879a0001b604f4",
                "price": {
                    "currency": "RUB",
                    "nominal": "150"
                },
                "type": "common"
            }
        },
        {
            "event": "TicketAllocated",
            "ticket": "0x881f56a1ae45f9b0472456ed8f9cfcc0c38ddab5d5d8266cb1c34e07288a8f08",
            "to": "0x4da0e910505d8678d774154096d619fe6515f3b0",
            "ipfs": "QmXW1sYbQ5mhBgTD31gzziwDTLcRk9EE3A3nMEoBMRfABH",
            "metadata": {
                "category": "Танцпол или ВИП",
                "created": "1527593144",
                "external_id": "5b0d37cde9879a0001b604f2",
                "price": {
                    "currency": "RUB",
                    "nominal": "150"
                },
                "type": "common"
            }
        },
        {
            "event": "TicketAllocated",
            "ticket": "0x647872e066d1bc03559b69c32d5b4bfd7ac0245c4c98846670c806da8a6708f1",
            "to": "0x4da0e910505d8678d774154096d619fe6515f3b0",
            "ipfs": "QmV6r1EMgrEK4cKTdKC7Um75KPqbRs4f319FDGGL74Qx2t",
            "metadata": {
                "category": "Танцпол или ВИП",
                "created": "1527593149",
                "external_id": "5b0d37cde9879a0001b604f6",
                "price": {
                    "currency": "RUB",
                    "nominal": "150"
                },
                "type": "common"
            }
        },
        {
            "event": "TicketAllocated",
            "ticket": "0x05d4fa9fe590ac61b384045a1a27e4af6ff8f97c39f0e4744643278c3257f712",
            "to": "0x4da0e910505d8678d774154096d619fe6515f3b0",
            "ipfs": "QmNjR7CgEAFNhhzzsjkoyoHWCrfn5jtSaKrzggeRppCsLu",
            "metadata": {
                "category": "Танцпол или ВИП",
                "created": "1527593157",
                "external_id": "5b0d37cde9879a0001b604f1",
                "price": {
                    "currency": "RUB",
                    "nominal": "150"
                },
                "type": "common"
            }
        }
    ]
}
```

### Tickets Methods

#### POST /ticket/:ticket/info

Return ticket information 

##### Request

###### Parameters
| Parameter | Type | Required | Description |
|:--:|:--:|:--:|:--:|
| ticket | string | Yes | Ticket Identifier |
| event | string | Yes | Contract Address in Ethereum Network |

###### Example
```json
{
	"event": "0x94585c22cddfe4723c1175feccbfb213d5016d38"
}
```

##### Response

###### Parameters
| Parameter | Type | Required | Description |
|:--:|:--:|:--:|:--:|
| owner | string | Yes | Customer address in Ethereum Network |
| metadata | object | Yes | Ticket metadata from IPFS |

###### Example
**200 OK**
```json
    {
        "owner": "0x4da0e910505d8678d774154096d619fe6515f3b0",
        "metadata": {
            "category": "Танцпол или ВИП",
            "created": "1527593122",
            "external_id": "5b0d37cde9879a0001b604f3",
            "price": {
                "currency": "RUB",
                "nominal": "150"
            },
            "type": "common"
        }
    }
```

#### POST ticket/:ticket/verify

Method to verify ticket ownership

##### Request 

###### Parameters
| Parameter | Type | Required | Description |
|:--:|:--:|:--:|:--:|
| ticket | string | Yes | Ticket Identifier |
| event | string | Yes | Contract Address in Ethereum Network |
| signature | string | Yes | Message signature |

###### Example
```json
{
	"event": "0x94585c22cddfe4723c1175feccbfb213d5016d38",
	"signature": "0x2aa6adef43d4c386b3c3be21a4726a1a03b01ebc5a2e1fb79c6fc16f3d94e6a072cf81e43bea3ec6d65c1ad1efd240c02245dca8e0e2d887c676c8768baa73ee01"
}
```

##### Response

###### Parameters
| Parameter | Type | Required | Description |
|:--:|:--:|:--:|:--:|
| isValid | boolean | Yes | Signature verifying result |
| signer | string | Yes | Customer address signed message |
| owner | string | Yes | Customer address in Ethereum Network |
| metadata | object | Yes | Ticket metadata from IPFS |

###### Example
**200 OK**
```json
{
    "isValid": true,
    "signer": "0x4da0e910505d8678d774154096d619fe6515f3b0",
    "owner": "0x4da0e910505d8678d774154096d619fe6515f3b0",
    "metadata": {
        "category": "Танцпол или ВИП",
        "created": "1527593122",
        "external_id": "5b0d37cde9879a0001b604f3",
        "price": {
            "currency": "RUB",
            "nominal": "150"
        },
        "type": "common"
    }
}
```