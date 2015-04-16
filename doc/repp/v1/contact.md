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
Content-Length: 533
Content-Type: application/json

{
  "contacts": [
    {
      "id": 1,
      "code": "sh135909910",
      "phone": "+372.12345678",
      "email": "natasha.bechtelar@breitenberg.name",
      "fax": null,
      "created_at": "2015-04-16T08:44:33.041Z",
      "updated_at": "2015-04-16T08:44:33.041Z",
      "ident": "37605030299",
      "ident_type": "priv",
      "auth_info": "password",
      "name": "Miss Sherwood Jacobi0",
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
    "sh056866451"
  ],
  "total_number_of_records": 2
}
```
