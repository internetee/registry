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
Content-Length: 564
Content-Type: application/json

{
  "contacts": [
    {
      "id": 1,
      "code": "REGISTRAR2:SH022086480",
      "phone": "+372.12345678",
      "email": "hoyt@deckowbechtelar.net",
      "fax": null,
      "created_at": "2015-09-09T09:11:14.130Z",
      "updated_at": "2015-09-09T09:11:14.130Z",
      "ident": "37605030299",
      "ident_type": "priv",
      "auth_info": "password",
      "name": "Karson Kessler0",
      "org_name": null,
      "registrar_id": 2,
      "creator_str": null,
      "updator_str": null,
      "ident_country_code": "EE",
      "city": "Tallinn",
      "street": "Short street 11",
      "zip": "11111",
      "country_code": "EE",
      "state": null,
      "statuses": [
        "ok"
      ],
      "status_notes": {
      }
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
Content-Length: 67
Content-Type: application/json

{
  "contacts": [
    "REGISTRAR2:SH749456461"
  ],
  "total_number_of_records": 2
}
```

## POST /repp/v1/contacts
Creates new contact


#### Request
```
POST /repp/v1/contacts HTTP/1.1
Authorization: Basic dGVzdDp0ZXN0MTIz
Content-Type: application/json

{
    "contact": {
        "name": "John Doe",
        "email": "john@doe.com",
        "phone": "+371.1234567",
        "ident": {
            "ident": "12345678901",
            "ident_type": "priv",
            "ident_country_code": "EE"
        }
    }
}
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
    "contact": {
      "id": "ATSAA:20DCDCA1"
    }
  }
}
```

#### Failed response
```
HTTP/1.1 400
Cache-Control: max-age=0, private, must-revalidate
Content-Type: application/json

{
  "code": 2005,
  "message": "Ident code does not conform to national identification number format of Estonia",
  "data": {}
}
```

## PUT /repp/v1/contacts/**contact id**
Updates existing contact


#### Request
```
PUT /repp/v1/contacts/ATSAA:9CD5F321 HTTP/1.1
Authorization: Basic dGVzdDp0ZXN0MTIz
Content-Type: application/json

{
  "contact": {
    "phone": "+372.123123123"
  }
}
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
    "contact": {
      "id": "ATSAA:20DCDCA1"
    }
  }
}
```

#### Failed response
```
HTTP/1.1 400
Cache-Control: max-age=0, private, must-revalidate
Content-Type: application/json

{
  "code": 2005,
  "message": "Phone nr is invalid [phone]",
  "data": {}
}
```

## DELETE /repp/v1/contacts/**contact id**
Deletes existing contact


#### Request
```
DELETE /repp/v1/contacts/ATSAA:9CD5F321 HTTP/1.1
Authorization: Basic dGVzdDp0ZXN0MTIz
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
  "data": {}
}
```

#### Failed response
```
HTTP/1.1 400
Cache-Control: max-age=0, private, must-revalidate
Content-Type: application/json

{
  "code": 2305,
  "message": "Object association prohibits operation [domains]",
  "data": {}
}
```
