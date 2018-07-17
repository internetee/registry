## GET /repp/v1/registrant/contacts
Returns contacts of the current registrar.


#### Parameters

| Field name | Required |  Type   |  Allowed values   |        Description         |
| ---------- | -------- |  ----   |  --------------   |        -----------         |
|   limit    |  false   | Integer |     [1..200]      | How many contacts to show  |
|   offset   |  false   | Integer |                   | Contact number to start at |

#### Request
```
GET /repp/v1/registrant/contacts?limit=1 HTTP/1.1
Accept: application/json
Authorization: Bearer Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Type: application/json
```

#### Response
```
HTTP/1.1 200
Cache-Control: max-age=0, private, must-revalidate
Content-Type: application/json

{
  "contacts": [
    {
      "uuid": "84c62f3d-e56f-40fa-9ca4-dc0137778949",
      "domain_names": ["example.com"],
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
      "legacy_id": null,
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

## GET /repp/v1/registrant/contacts/$UUID
Returns contacts of the current registrar.


#### Request
```
GET /repp/v1/registrant/contacts/84c62f3d-e56f-40fa-9ca4-dc0137778949 HTTP/1.1
Accept: application/json
Authorization: Bearer Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Type: application/json
```

#### Response
```
HTTP/1.1 200
Cache-Control: max-age=0, private, must-revalidate
Content-Type: application/json

{
  "uuid": "84c62f3d-e56f-40fa-9ca4-dc0137778949",
  "domain_names": ["example.com"],
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
  "legacy_id": null,
  "statuses": [
    "ok"
  ],
  "status_notes": {}
}
```

## PUT/PATCH /repp/v1/registrant/contacts/$UUID

Update contact details for a contact.

#### Parameters

| Field name   | Required | Type   | Allowed values | Description                                       |
| ----         | ---      | ---    | ---            | ---                                               |
| email        | false    | String |                | New email address                                 |
| phone        | false    | String |                | New phone number                                  |
| fax          | false    | String |                | New fax number                                    |
| city         | false    | String |                | New city name                                     |
| street       | false    | String |                | New street name                                   |
| zip          | false    | String |                | New zip code                                      |
| country_code | false    | String |                | New  country code in 2 letter format ('EE', 'LV') |
| state        | false    | String |                | New state name                                    |


#### Request
```
PUT /repp/v1/registrant/contacts/84c62f3d-e56f-40fa-9ca4-dc0137778949 HTTP/1.1
Authorization: Bearer Z2l0bGFiOmdoeXQ5ZTRmdQ==
Accept: application/json
Content-type: application/json

{
  "email": "foo@bar.baz",
  "phone": "+372.12345671",
  "fax": "+372.12345672",
  "city": "New City",
  "street": "Main Street 123",
  "zip": "22222",
  "country_code": "LV",
  "state": "New state"
}

```
#### Response on success

```
HTTP/1.1 200
Content-Type: application.json

{
  "uuid": "84c62f3d-e56f-40fa-9ca4-dc0137778949",
  "domain_names": ["example.com"],
  "code": "REGISTRAR2:SH022086480",
  "phone": "+372.12345671",
  "email": "foo@bar.baz",
  "fax": "+372.12345672",
  "created_at": "2015-09-09T09:11:14.130Z",
  "updated_at": "2018-09-09T09:11:14.130Z",
  "ident": "37605030299",
  "ident_type": "priv",
  "auth_info": "password",
  "name": "Karson Kessler0",
  "org_name": null,
  "registrar_id": 2,
  "creator_str": null,
  "updator_str": null,
  "ident_country_code": "EE",
  "city": "New City",
  "street": "Main Street 123",
  "zip": "22222",
  "country_code": "LV",
  "state": "New state"
  "legacy_id": null,
  "statuses": [
    "ok"
  ],
  "status_notes": {}
}
```

### Response on failure
```
HTTP/1.1 400
Content-Type: application.json

{
  "errors": [
    { "phone": "Phone nr is invalid" }
  ]
}
```
