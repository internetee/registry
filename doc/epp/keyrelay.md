## Keyrelay related functions

### Keyrelay

| Field name        | Required  | Field description |
| ----------------- |--------------------------- |
| [ext:keyrelay](#extkeyrelay)            | true     |                  |
| ext:clTRID         | false   | Client transaction id |


### ext:keyrelay

| Field name        | Required |  Field description |
| ----------------- |----------| ----------------- |
| ext:name         | true     |   Domain name |
| [ext:keyData](#extkeydata)            | true     |                        |
| [ext:authInfo](#extauthinfo)            | true     |                        |
| [ext:expiry](#extexpiry)            | true     |                       |

### ext:keyData

| Field name        | Required | Field description |
| ----------------- |----------|----------------- |
| secDNS:flags         | true     | Allowed values: 0, 256, 257 |
| secDNS:protocol         | true     | Allowed values: 3 |
| secDNS:alg         | true     | Allowed values: 3, 5, 6, 7, 8, 252, 253, 254, 255 |
| secDNS:pubKey         | true     | Public key |


### ext:authInfo

| Field name        | Required | Field description |
| ----------------- |----------|----------------- |
| domain:pw         | true     | Domain password |

### ext:expiry

| Field name        | Required | Field description |
| ----------------- |----------|----------------- |
| ext:relative         | true if ext:absolute is not specified     | Relative expiry duration (ISO8601) |
| ext:absolute         | true if ext:relative is not specified     | Absolute expiry date (ISO8601) |
