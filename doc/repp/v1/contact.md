## GET /repp/v1/contacts
Returns contacts of the current registrar.


#### Parameters

| Field name | Required |  Type   |  Allowed values   |        Description         |
| ---------- | -------- |  ----   |  --------------   |        -----------         |
|   limit    |  false   | Integer |      [1..20]      | How many contacts to show  |
|   offset   |  false   | Integer |                   | Contact number to start at |
|  details   |  false   | String  | ["true", "false"] | Whether to include details |

#### Request
```
GET /repp/v1/contacts?limit=1&details=true HTTP/1.1
Accept: application/json
Authorization: Basic Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Length: 0
Content-Type: application/json
```

#### Response
```
HTTP/1.1 200
Cache-Control: max-age=0, private, must-revalidate
Content-Length: 573
Content-Type: application/json

{
  "contacts": [
    {
      "id": 1,
      "code": "sh095058820",
      "reg_no": null,
      "phone": "+372.12345678",
      "email": "shakira.reichert@corkery.com",
      "fax": null,
      "created_at": "2015-04-01T10:51:49.854Z",
      "updated_at": "2015-04-01T10:51:49.854Z",
      "ident": "37605030299",
      "ident_type": "priv",
      "created_by_id": null,
      "updated_by_id": null,
      "auth_info": "password",
      "name": "Henderson Feest0",
      "org_name": null,
      "registrar_id": 1,
      "creator_str": "autotest",
      "updator_str": "autotest",
      "ident_country_code": "EE",
      "city": "Tallinn",
      "street": "Short street 11",
      "zip": "11111",
      "country_code": "EE",
      "state": null
    }
  ],
  "total_number_of_records": 2
}
```

## GET /repp/v1/contacts
Returns contact names with offset.


#### Request
```
GET /repp/v1/contacts?offset=1 HTTP/1.1
Accept: application/json
Authorization: Basic Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Length: 0
Content-Type: application/json
```

#### Response
```
HTTP/1.1 200
Cache-Control: max-age=0, private, must-revalidate
Content-Length: 56
Content-Type: application/json

{
  "contacts": [
    "sh331036241"
  ],
  "total_number_of_records": 2
}
```
