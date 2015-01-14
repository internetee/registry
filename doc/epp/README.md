# EPP integration specification for Estonian Internet Foundation

## Introduction
Introduction text here


## Domain related functions


### Domain create

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [create](#top-domain-create)            | true     |      |                  |
| [extension](#top-domain-create-extension)         | true     |      |                  |
| clTRID         | false     |      | Client transaction id |

##### <a name="top-domain-create"></a>create
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [domain:create](#domaincreate)     | true     | xmlns:domain (urn:ietf:params:xml:ns:domain-1.0) |  |


##### domain:create
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| domain:name       | true     |  | Domain name. Can contain unicode characters. |
| domain:period     | false    | unit (y, m, d) | Registration period for domain. Must add up to 1 / 2 / 3 years. |
| [domain:ns](#domainns) | true     | | Nameserver listing (2-11) |
| domain:registrant | true     | | Contact reference to the registrant |
| domain:contact    | true if registrant is a juridical person     | type (admin) | Contact reference |
| domain:contact    | false     | type (tech, admin) | Contact reference (0 - n) |

##### domain:ns
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [domain:hostAttr](#domainhostattr)   | true     |  |  |

##### domain:hostAttr
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| domain:hostName   | true     |  | Hostname of the nameserver |
| domain:hostAddr   | true if nameserver is under domain zone     | ip (v4, v6) | (0 - n) |

##### <a name="top-domain-create-extension"></a>extension
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [secDNS:create](#secdnscreate)     | false     |  | DNSSEC details |
| [eis:extdata](#eisextdata)     | true     | xmlns:eis (urn:ee:eis:xml:epp:eis-1.0) | Legal document |

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

[EXAMPLE REQUEST AND RESPONSE](https://github.com/domify/registry/blob/master/doc/epp-doc.md#epp-domain-with-valid-user-with-citizen-as-an-owner-creates-a-domain)


### Domain update

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [update](#top-domain-update)            | true     |      |                  |
| [extension](#top-domain-update-extension)         | true if registrant is changing |      |                  |
| clTRID         | false     |      | Client transaction id |

##### <a name="top-domain-update"></a>update
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [domain:update](#domainupdate) | true | xmlns:domain (urn:ietf:params:xml:ns:domain-1.0) |  |

##### domain:update
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| domain:name       | true     |  | Domain name. Can contain unicode characters. |
| [domain:chg](#domainchg) | false |  | Attributes to change |
| [domain:add](#domainadd) | false |  | Objects to add |
| [domain:rem](#domainrem) | false |  | Objects to remove |

##### domain:chg
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| domain:registrant | false     | | Contact reference to the registrant |

##### domain:add
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [domain:ns](#domainns) | false     | | Nameservers TODO: Get rid of hostObj |
| domain:contact    | false     | type (tech, admin) | Contact reference (0 - n) |
| domain:status    | false     | s (clientDeleteProhibited, clientHold, clientRenewProhibited, clientTransferProhibited, clientUpdateProhibited) | Status description (may be left empty) (0 - n)|

##### domain:rem
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [domain:ns](#domainns) | false     | | Nameservers TODO: Get rid of hostObj |
| domain:contact    | false     | type (tech, admin) | Contact reference (0 - n) |
| domain:status    | false     | s (clientDeleteProhibited, clientHold, clientRenewProhibited, clientTransferProhibited, clientUpdateProhibited) | Status description (may be left empty) (0 - n)|

##### <a name="top-domain-update-extension"></a>extension
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [secDNS:create](#secdnsupdate)     | false     |  | DNSSEC details TODO: MAYBE THIS SHOULD BE secDNS:update ? |
| [eis:extdata](#eisextdata)     | true if registrant is changing     | xmlns:eis (urn:ee:eis:xml:epp:eis-1.0) | Legal document |

##### <a name="secdnsupdate"></a>secDNS:create TODO: secDNS:update??
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [secDNS:add](#secdnsadd)     | false     |  | Objects to add |
| [secDNS:rem](#secdnsrem)     | false     |  | Objects to remove |

##### secDNS:add
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [secDNS:keyData](#secdnskeydata)       | true     | xmlns:secDNS (urn:ietf:params:xml:ns:secDNS-1.1) | DNSSEC key data (0 - n)|

##### secDNS:rem
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [secDNS:keyData](#secdnskeydata)       | true     | xmlns:secDNS (urn:ietf:params:xml:ns:secDNS-1.1) | DNSSEC key data (0 - n)|

[EXAMPLE REQUEST AND RESPONSE](https://github.com/domify/registry/blob/master/doc/epp-doc.md#epp-domain-with-valid-user-with-valid-domain-updates-domain-and-adds-objects)
