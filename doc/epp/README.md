# EPP integration specification for Estonian Internet Foundation

## Introduction
Introduction text here


## Domain related functions


### Domain create

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [create](#topdomaincreate)            | true     |      |                  |
| [extension](#topdomainextension)         | true     |      |                  |

##### <a name="topdomaincreate"></a>create
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [domain:create](#domaincreate)     | true     | xmlns:domain (urn:ietf:params:xml:ns:domain-1.0) |                  |


##### domain:create
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| domain:name       | true     |  | Domain name. Can contain unicode characters. |
| domain:period     | false    | unit (y, m, d) | Registration period for domain. Must add up to 1 / 2 / 3 years. |
| [domain:ns](#domainns) | true     | | Nameserver listing |
| domain:registrant | true     | | Contact reference to the registrant |
| domain:contact    | false     | type (tech, admin) | Contact reference |
| domain:contact    | false     | type (tech, admin) | Contact reference |

##### <a name="topdomainextension"></a>extension
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [secDNS:create](#secdnscreate)     | false     |  | DNSSEC details |
| [eis:extdata](#eisextdata)     | true     | xmlns:eis (urn:ee:eis:xml:epp:eis-1.0) | Legal document |

[EXAMPLE REQUEST AND RESPONSE](https://github.com/domify/registry/blob/master/doc/epp-doc.md#epp-domain-with-valid-user-with-citizen-as-an-owner-creates-a-domain)

----

##### domain:ns
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| domain:hostAttr   | true     |  |  |


##### domain:hostAttr
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| domain:hostName   | true     |  | Hostname of the nameserver |
| domain:hostAddr   | true if nameserver is under domain zone     | ip (v4, v6) |  |
| domain:hostAddr   | true if nameserver is under domain zone     | ip (v4, v6) |  |

##### secDNS:create
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [secDNS:keyData](#secdnskeydata)       | true     | xmlns:secDNS (urn:ietf:params:xml:ns:secDNS-1.1) | DNSSEC key data |


##### secDNS:keyData
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| secDNS:flags     | true    |  | Allowed values: 0, 256, 257 |
| secDNS:protocol  | true     | | Allowed values: 3 |
| secDNS:alg | true     | | Allowed values: 3, 5, 6, 7, 8, 252, 253, 254, 255 |
| secDNS:pubKey    | true     |  | Public key |

##### eis:extdata
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| eis:legalDocument     | true    | type (pdf) | Base64 encoded document |
