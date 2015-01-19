## Session related functions
Here are functions like login, logout, hello, poll

### Login request

| Field name              | Min-max | Field description |
| ----------------------- |---------|------------------ |
| `<login>`               | 1     |   |
| `-<clID>`               | 1     | Username      |
| `-<pw>`                 | 1     | Password      |
| `-<options>`            | 0-1     |       |
| `--<version>`           | 0-1     | 1.0      |
| `--<lang>`              | 0-1     | en      |
| `-<svcs>`               | 0-1     |       |
| `--<objURI>`            | 0-n   | Object URI that is going to be used in current connection. |
| `--<svcExtension>`      | 0-1   |  |
| `---<extURI>`           | 0-n   | Extension URI that is going to be used in current connection. |
| `<clTRID>`              | 0-1   | Client transaction id |

| `--<domain:name>`       | 1     | Domain name. Can contain unicode characters. |
| `<extension>`           | 1     |   |
| `-<eis:extdata>`        | 1     | Attribute: xmlns:eis="urn:ee:eis:xml:epp:eis-1.0" |
| `--<eis:legalDocument>` | 1     | Base64 encoded document |
| `<clTRID>`              | 0-1   | Client transaction id |

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-session-when-connected-with-valid-user-logs-in-epp-user)

### Logout request

| Field name              | Min-max | Field description |
| ----------------------- |---------|------------------ |
| `<logout>`               | 1     |   |
| `<clTRID>`              | 0-1   | Client transaction id |

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-session-when-connected-with-valid-user-logs-out-epp-user)

### Poll request

| Field name              | Min-max | Field description |
| ----------------------- |---------|------------------ |
| `<poll>`               | 1     | Rec for receiving messages, ack for dequeuing Attribute: op="req / ack"  |
| `<clTRID>`              | 0-1   | Client transaction id |

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-poll-with-valid-user-queues-and-dequeues-messages)
