## GET /repp/v1/domains
Returns domains of the current registrar.


#### Parameters

| Field name | Required |  Type   |  Allowed values   |        Description         |
| ---------- | -------- |  ----   |  --------------   |        -----------         |
|   limit    |  false   | Integer |     [1..200]      |  How many domains to show  |
|   offset   |  false   | Integer |                   | Domain number to start at  |
|  details   |  false   | String  | ["true", "false"] | Whether to include details |

#### Request
```
GET /repp/v1/domains?limit=1&details=true HTTP/1.1
Accept: application/json
Authorization: Basic Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Length: 0
Content-Type: application/json
```

#### Response
```
HTTP/1.1 200
Cache-Control: max-age=0, private, must-revalidate
Content-Length: 578
Content-Type: application/json

{
  "domains": [
    {
      "id": 1,
      "name": "domain0.ee",
      "registrar_id": 1,
      "registered_at": "2015-04-16T08:44:33.499Z",
      "status": null,
      "valid_from": "2015-04-16T00:00:00.000Z",
      "valid_to": "2016-04-16T00:00:00.000Z",
      "owner_contact_id": 1,
      "auth_info": "d081ba64515bc8ae9a512a98e6b1baa1",
      "created_at": "2015-04-16T08:44:33.496Z",
      "updated_at": "2015-04-16T08:44:33.496Z",
      "name_dirty": "domain0.ee",
      "name_puny": "domain0.ee",
      "period": 1,
      "period_unit": "y",
      "creator_str": null,
      "updator_str": null,
      "whois_body": null,
      "legacy_id": null,
      "legacy_registrar_id": null,
      "legacy_registrant_id": null
    }
  ],
  "total_number_of_records": 2
}
```

## GET /repp/v1/domains
Returns domain names with offset.


#### Request
```
GET /repp/v1/domains?offset=1 HTTP/1.1
Accept: application/json
Authorization: Basic Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Length: 0
Content-Type: application/json
```

#### Response
```
HTTP/1.1 200
Cache-Control: max-age=0, private, must-revalidate
Content-Length: 54
Content-Type: application/json

{
  "domains": [
    "domain1.ee"
  ],
  "total_number_of_records": 2
}
```
