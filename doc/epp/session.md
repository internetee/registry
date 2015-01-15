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

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-session-when-connected-with-valid-user-logs-in-epp-user)

### Logout request

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| logout            | true     |      |                  |
| clTRID         | false     |      | Client transaction id |

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-session-when-connected-with-valid-user-logs-out-epp-user)

### Poll request

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [poll](#poll)            | true     |      |                  |
| clTRID         | false     |      | Client transaction id |

##### poll

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| poll            | true     | op (req, ack)     | Rec for receiving messages, ack for dequeuing |

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-poll-with-valid-user-queues-and-dequeues-messages)
