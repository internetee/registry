# EPP integration specification for Estonian Internet Foundation

## Introduction

## Domain related functions
| Field name        | Required | Type | Field description |
| ----------------- |----------| -----|----------------- |
| domain:name       | true     | String | Domain name. Can contain unicode characters. |
| domain:period     | false    | Integer | Registration period for domain. Must add up to 1 / 2 / 3 years. |

### create command ###
| Field name        | Required | Attributes | Attr. values |
| ----------------- |----------|------------|--------------|
| domain:name       | true     |            | |
| domain:period     | false    |  unit      | "y", "m" |
| domain:ns         | true      | | |
| &nbsp;&nbsp;domain:hostAttr | true      | | |
| &nbsp;&nbsp;&nbsp;&nbsp;domain:hostAddr | false   | ip        | "v4", "v6" |
| &nbsp;&nbsp;&nbsp;&nbsp;domain:hostName | true    | | |
