## Domain related functions

### Domain create

| Field name              | Min-max | Field description |
| ----------------------- |---------|------------------ |
| `<create>`              | 1     |   |
| `-<domain:create>`      | 1     | Attribute: xmlns:domain="urn:ietf:params:xml:ns:domain-1.0"      |
| `--<domain:name>`       | 1     | Domain name. Can contain unicode characters. |
| `--<domain:period>`     | 0-1   | Registration period for domain. Must add up to 1 / 2 / 3 years. Attribute: unit="y/m/d"|
| `--<domain:registrant>` | 1     | Contact reference to the registrant |
| `--<domain:contact>`    | 0-n   | Contact reference. Admin contact is required if registrant is a juridical person. Attribute: type="admin / tech" |
| `--<domain:ns>`         | 1     |  |
| `---<domain:hostAttr>`  | 2-11  |  |
| `----<domain:hostName>` | 1     | Hostname of the nameserver |
| `----<domain:hostAddr>` | 0-2   | Required if nameserver is under domain zone. Attribute ip="v4 / v6" |
| `<extension>`           | 1     |   |
| `-<secDNS:create>`      | 0-1   | Attribute: xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" |
| `--<secDNS:keyData>`    | 1-n   |  |
| `---<secDNS:flags>`     | 1     | Allowed values: 0, 256, 257 |
| `---<secDNS:protocol>`  | 1     | Allowed values: 3 |
| `---<secDNS:alg>`       | 1     | Allowed values: 3, 5, 6, 7, 8, 252, 253, 254, 255 |
| `---<secDNS:pubKey>`    | 1     | Public key |
| `-<eis:extdata>`        | 1     | Attribute: xmlns:eis="urn:ee:eis:xml:epp:eis-1.0" |
| `--<eis:legalDocument>` | 1     | Base64 encoded document |
| `<clTRID>`               | 0-1   | Client transaction id |

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-domain-with-valid-user-with-citizen-as-an-owner-creates-a-domain)

### Domain update

| Field name               | Min-max | Field description |
| ------------------------ |---------|------------------ |
| `<update>`               | 1     |   |
| `-<domain:update>`       | 1     | Attribute: xmlns:domain="urn:ietf:params:xml:ns:domain-1.0"      |
| `--<domain:name>`        | 1     | Domain name. Can contain unicode characters. |
| `--<domain:chg>`         | 0-1   | Attributes to change |
| `---<domain:registrant>` | 0-1   | Contact reference to the registrant |
| `--<domain:add>`         | 0-1   | Objects to add |
| `---<domain:contact>`    | 0-n   | Contact reference. Attribute: type="admin / tech" |
| `---<domain:status>`     | 0-n   | Status description. Attribute: s="clientDeleteProhibited / clientHold / clientRenewProhibited / clientTransferProhibited / clientUpdateProhibited" |
| `---<domain:ns>`         | 0-1   |  |
| `----<domain:hostAttr>`  | 1     |  |
| `-----<domain:hostName>` | 1     | Hostname of the nameserver |
| `-----<domain:hostAddr>` | 0-2   | Required if nameserver is under domain zone. Attribute ip="v4 / v6" |
| `--<domain:rem>`         | 0-1   | Objects to remove |
| `---<domain:contact>`    | 0-n   | Contact reference. Attribute: type="admin / tech" |
| `---<domain:status>`     | 0-n   | Attribute: s="clientDeleteProhibited / clientHold / clientRenewProhibited / clientTransferProhibited / clientUpdateProhibited" |
| `---<domain:ns>`         | 0-1   |  |
| `----<domain:hostAttr>`  | 1     |  |
| `-----<domain:hostName>` | 1     | Hostname of the nameserver |
| `<extension>`            | 0-1   | Required if registrant is changing |
| `-<secDNS:update>`       | 0-1   | Attribute: xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" |
| `--<secDNS:add>`         | 0-1   |  |
| `---<secDNS:keyData>`    | 1-n   |  |
| `----<secDNS:flags>`     | 1     | Allowed values: 0, 256, 257 |
| `----<secDNS:protocol>`  | 1     | Allowed values: 3 |
| `----<secDNS:alg>`       | 1     | Allowed values: 3, 5, 6, 7, 8, 252, 253, 254, 255 |
| `----<secDNS:pubKey>`    | 1     | Public key |
| `--<secDNS:rem>`         | 0-1   |  |
| `---<secDNS:keyData>`    | 1-n   |  |
| `----<secDNS:pubKey>`    | 1     | Public key |
| `-<eis:extdata>`         | 0-1   | Required if registrant is changing. Attribute: xmlns:eis="urn:ee:eis:xml:epp:eis-1.0" |
| `--<eis:legalDocument>`  | 1     | Base64 encoded document |
| `<clTRID>`               | 0-1   | Client transaction id |

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-domain-with-valid-user-with-valid-domain-updates-domain-and-adds-objects)

### Domain delete

| Field name              | Min-max | Field description |
| ----------------------- |---------|------------------ |
| `<delete>`              | 1     |   |
| `-<domain:delete>`      | 1     | Attribute: xmlns:domain="urn:ietf:params:xml:ns:domain-1.0"      |
| `--<domain:name>`       | 1     | Domain name. Can contain unicode characters. |
| `<extension>`           | 1     |   |
| `-<eis:extdata>`        | 1     | Attribute: xmlns:eis="urn:ee:eis:xml:epp:eis-1.0" |
| `--<eis:legalDocument>` | 1     | Base64 encoded document |
| `<clTRID>`               | 0-1   | Client transaction id |

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-domain-with-valid-user-with-valid-domain-deletes-domain)


### Domain info

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [info](#info)            | true     |      |                  |
| [extension](#ext-legal-not-required)         | false |      |                  |
| clTRID         | false     |      | Client transaction id |


##### info
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [domain:info](#domaininfo) | true | xmlns:domain (urn:ietf:params:xml:ns:domain-1.0) |  |


##### domain:info
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| domain:name       | true     | hosts (all, TODO) | Domain name. Can contain unicode characters. |
| [domain:authInfo](#domainauthinfo)       | false     |  | Domain password |

##### domain:authinfo
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| domain:pw       | true     | roid (String) TODO: find out why we need roid | Domain password |

##### <a name="ext-legal-not-required"></a>extension
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [eis:extdata](#eisextdata)     | false     | xmlns:eis (urn:ee:eis:xml:epp:eis-1.0) | Legal document |

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-domain-with-valid-user-with-valid-domain-returns-domain-info)


### Domain renew

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [renew](#renew)            | true     |      |                  |
| [extension](#ext-legal-not-required)         | false |      |                  |
| clTRID         | false     |      | Client transaction id |


##### renew
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [domain:renew](#domainrenew) | true | xmlns:domain (urn:ietf:params:xml:ns:domain-1.0) |  |

##### domain:renew
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| domain:name       | true     |  | Domain name. Can contain unicode characters. |
| domain:curExpDate | true     |  | Current expiry date (ISO8601 format) |
| domain:period | true     | unit (y, m, d) | Renew period, must add up to 1, 2 or 3 years. |

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-domain-with-valid-user-with-valid-domain-renews-a-domain)


### Domain transfer
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [transfer](#transfer) | true     | op (approve, query, reject)     |     |
| [extension](#ext-legal-not-required)         | false |      |                  |
| clTRID         | false     |      | Client transaction id |

##### transfer
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [domain:transfer](#domaintransfer) | true | xmlns:domain (urn:ietf:params:xml:ns:domain-1.0) |  |

##### domain:transfer
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| domain:name       | true     |  | Domain name. Can contain unicode characters. |
| [domain:authInfo](#domainauthinfo)       | true     |  | Domain password |

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-domain-with-valid-user-with-valid-domain-returns-domain-info)

### Domain check

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [check](#check) | true     |      |     |
| [extension](#ext-legal-not-required)         | false |      |                  |
| clTRID         | false     |      | Client transaction id |

##### check
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [domain:check](#domaincheck) | true | xmlns:domain (urn:ietf:params:xml:ns:domain-1.0) |  |

##### domain:transfer
| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| domain:name       | true     |  | Domain name. Can contain unicode characters. |

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-domain-with-valid-user-checks-a-domain)
