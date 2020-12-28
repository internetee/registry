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
Content-Type: application/json

{
  "code": 1000,
  "message": "Command completed successfully",
  "data": {
    "domains": [
      {
        "id": 7,
        "name": "private.ee",
        "registrar_id": 2,
        "valid_to": "2022-09-23T00:00:00.000+03:00",
        "registrant_id": 11,
        "created_at": "2020-09-22T14:16:47.420+03:00",
        "updated_at": "2020-10-21T13:31:43.733+03:00",
        "name_dirty": "private.ee",
        "name_puny": "private.ee",
        "period": 1,
        "period_unit": "y",
        "creator_str": "2-ApiUser: test",
        "updator_str": null,
        "outzone_at": null,
        "delete_date": null,
        "registrant_verification_asked_at": null,
        "registrant_verification_token": null,
        "pending_json": {},
        "force_delete_date": null,
        "statuses": [
          "serverRenewProhibited"
        ],
        "status_notes": {
          "ok": "",
          "serverRenewProhibited": ""
        },
        "upid": null,
        "up_date": null,
        "uuid": "6b6affa7-1449-4bd8-acf5-8b4752406705",
        "locked_by_registrant_at": null,
        "force_delete_start": null,
        "force_delete_data": null,
        "auth_info": "367b1e6d1f0d9aa190971ad8f571cd4d",
        "valid_from": "2020-09-22T14:16:47.420+03:00"
      }
    ],
    "total_number_of_records": 10
  }
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
Content-Type: application/json

{
    "code": 1000,
    "message": "Command completed successfully",
    "data": {
        "domains": [
            "private.ee",
        ],
        "total_number_of_records": 1
    }
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
Content-Type: application/json
{
  "code": 1000,
  "message": "Command completed successfully",
  "data": {
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
  }
}
```
