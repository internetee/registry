## GET /repp/v1/contacts
Returns contacts of the current registrar.


#### Parameters

| Field name | Required |  Type   |  Allowed values   |        Description         |
| ---------- | -------- |  ----   |  --------------   |        -----------         |
|   limit    |  false   | Integer |     [1..200]      | How many contacts to show  |
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
Content-Length: 524
Content-Type: application/json

{
  "contacts": [
    {
      "id": 1,
      "code": "sh523328490",
      "phone": "+372.12345678",
      "email": "corene_koch@caspermoen.net",
      "fax": null,
      "created_at": "2015-04-16T08:48:39.551Z",
      "updated_at": "2015-04-16T08:48:39.551Z",
      "ident": "37605030299",
      "ident_type": "priv",
      "auth_info": "password",
      "name": "Alana Williamson II0",
      "org_name": null,
      "registrar_id": 1,
      "creator_str": null,
      "updator_str": null,
      "ident_country_code": "EE",
      "city": "Tallinn",
      "street": "Short street 11",
      "zip": "11111",
      "country_code": "EE",
      "state": null,
      "legacy_id": null
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
    "sh629765881"
  ],
  "total_number_of_records": 2
}
```
