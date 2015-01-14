## Session related functions
Here are functions like login, logout, hello, poll

### Login request

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [login](#login)            | true     |      |                  |
| clTRID         | false     |      | Client transaction id |

##### login
| Field name        | Required | Field description |
| ----------------- |----------|----------------- |
| clID     | true     | Username |
| pw     | true     | Password |
| [options](#options)     | false     |  |
| [svcs](#svcs)     | false     |  |


##### options
| Field name        | Required | Field description |
| ----------------- |----------|----------------- |
| version     | false     | 1.0 |
| lang     | false     | en |

##### svcs
| Field name        | Required | Field description |
| ----------------- |----------|----------------- |
| objURI     | false     | Object URI that is going to be used in current connection. (0-n) |
| [svcExtension](#svcextension)     | false     |  |

##### svcExtension
| Field name        | Required | Field description |
| ----------------- |----------|----------------- |
| extURI     | false     | Extension URI that is going to be used in current connection. (0-n) |

[EXAMPLE REQUEST AND RESPONSE](/blob/master/doc/epp-doc.md#epp-session-when-connected-with-valid-user-logs-in-epp-user)

### Logout request

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| logout            | true     |      |                  |
| clTRID         | false     |      | Client transaction id |

[EXAMPLE REQUEST AND RESPONSE](https://github.com/domify/registry/blob/master/doc/epp-doc.md#epp-session-when-connected-with-valid-user-logs-out-epp-user)

