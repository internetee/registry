# Domain listing

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
Content-Length: 808
Content-Type: application/json

{
  "domains": [
    {
      "id": 1,
      "name": "domain0.ee",
      "registrar_id": 2,
      "registered_at": "2015-09-09T09:11:14.861Z",
      "status": null,
      "valid_from": "2015-09-09T09:11:14.861Z",
      "valid_to": "2016-09-09T09:11:14.861Z",
      "registrant_id": 1,
      "transfer_code": "98oiewslkfkd",
      "created_at": "2015-09-09T09:11:14.861Z",
      "updated_at": "2015-09-09T09:11:14.860Z",
      "name_dirty": "domain0.ee",
      "name_puny": "domain0.ee",
      "period": 1,
      "period_unit": "y",
      "creator_str": null,
      "updator_str": null,
      "legacy_id": null,
      "legacy_registrar_id": null,
      "legacy_registrant_id": null,
      "outzone_at": "2016-09-24T09:11:14.861Z",
      "delete_at": "2016-10-24T09:11:14.861Z",
      "registrant_verification_asked_at": null,
      "registrant_verification_token": null,
      "pending_json": {
      },
      "force_delete_date": null,
      "statuses": [
        "ok"
      ],
      "reserved": false,
      "status_notes": {
      }
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

# Transfer info

## GET /repp/v1/domains/*domainname.ee*/transfer_info
Returns details of contacts associated with a domain to be transfered. Necessary for pre-transfer checks and better user experience in automated registrar systems.

Please note the domain name in the path

#### Request
```
GET /repp/v1/domains/ee-test.ee/transfer_info HTTP/1.1
Accept: application/json
Authorization: Basic Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Length: 0
Content-Type: application/json
Auth-Code: authinfopw
```

Please note that domain transfer/authorisation code must be placed in header - *Auth-Code*

#### Response
```
HTTP/1.1 200 OK
Cache-Control: max-age=0, private, must-revalidate
Content-Length: 784
Content-Type: application/json

{
  "domain":"ee-test.ee",
  "registrant":{
    "code":"EE:R1",
    "name":"Registrant",
    "ident":"17612535",
    "ident_type":"org",
    "ident_country_code":"EE",
    "phone":"+372.1234567",
    "email":"registrant@cache.ee",
    "street":"Businesstreet 1",
    "city":"Tallinn",
    "zip":"10101",
    "country_code":"EE",
    "statuses":[
      "ok",
      "linked"
    ]
  },
  "admin_contacts":[
    {
      "code":"EE:A1",
      "name":"Admin Contact",
      "ident":"17612535376",
      "ident_type":"priv",
      "ident_country_code":"EE",
      "phone":"+372.7654321",
      "email":"admin@cache.ee",
      "street":"Adminstreet 2",
      "city":"Tallinn",
      "zip":"12345",
      "country_code":"EE",
      "statuses":[
        "ok",
        "linked"
      ]
    }
  ],
  "tech_contacts":[
    {
      "code":"EE:T1",
      "name":"Tech Contact",
      "ident":"17612536",
      "ident_type":"org",
      "ident_country_code":"EE",
      "phone":"+372.7654321",
      "email":"tech@cache.ee",
      "street":"Techstreet 1",
      "city":"Tallinn",
      "zip":"12345",
      "country_code":"EE",
      "statuses":[
        "ok",
        "linked"
      ]
    }
  ]
}
```
