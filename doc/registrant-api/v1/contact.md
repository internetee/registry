## GET /api/v1/registrant/contacts
Returns contacts of the current registrar.


#### Parameters

| Field name | Required |  Type   |  Allowed values   |        Description         |
| ---------- | -------- |  ----   |  --------------   |        -----------         |
|   limit    |  false   | Integer |     [1..200]      | How many contacts to show  |
|   offset   |  false   | Integer |                   | Contact number to start at |

#### Request
```
GET /api/v1/registrant/contacts?limit=1 HTTP/1.1
Accept: application/json
Authorization: Bearer Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Type: application/json
```

#### Response
```
HTTP/1.1 200
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

## GET /api/v1/registrant/contacts/$UUID
Returns contacts of the current registrar.


#### Request
```
GET /api/v1/registrant/contacts/84c62f3d-e56f-40fa-9ca4-dc0137778949 HTTP/1.1
Accept: application/json
Authorization: Bearer Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Type: application/json
```

#### Response
```
HTTP/1.1 200
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

## PATCH /api/v1/registrant/contacts/$UUID

Update contact details for a contact.

#### Parameters

| Field name            | Required | Type   | Allowed values | Description                                               |
| ----                  | ---      | ---    | ---            | ---                                                       |
| name                  | false    | String |                | New name                                                  |
| email                 | false    | String |                | New email                                                 |
| phone                 | false    | String |                | New phone number                                          |
| fax                   | false    | String |                | New fax number                                            |
| address[street]       | false    | String |                | New street name                                           |
| address[zip]          | false    | String |                | New zip                                                   |
| address[city]         | false    | String |                | New city name                                             |
| address[state]        | false    | String |                | New state name                                            |
| address[country_code] | false    | String |                | New country code in 2 letter format (ISO 3166-1 alpha-2)  |


#### Request
```
PATCH /api/v1/registrant/contacts/84c62f3d-e56f-40fa-9ca4-dc0137778949 HTTP/1.1
Authorization: Bearer Z2l0bGFiOmdoeXQ5ZTRmdQ==
Accept: application/json
Content-type: application/json

{
  "name": "John Doe",
  "email": "foo@bar.baz",
  "phone": "+372.12345671",
  "fax": "+372.12345672",
  "address": {
    "street": "Main Street 123",
    "zip": "22222",
    "city": "New City",
    "state": "New state",
    "country_code": "LV"
  }
}

```
#### Response on success

```
HTTP/1.1 200
Content-Type: application/json

{
  "id": "84c62f3d-e56f-40fa-9ca4-dc0137778949",
  "name": "Karson Kessler0",
  "code": "REGISTRAR2:SH022086480",
  "ident": {
    "code": "37605030299",
    "type": "priv",
    "country_code": "EE"
  },
  "email": "foo@bar.baz",
  "phone": "+372.12345671",
  "fax": "+372.12345672",
  "address": {
    "street": "Main Street 123",
    "zip": "22222",
    "city": "New City",
    "state": "New state",
    "country_code": "LV"
  },
  "auth_info": "password",
  "statuses": [
    "ok"
  ]
}
```

### Response on failure
```
HTTP/1.1 400
Content-Type: application/json

{
  "errors": {
    "phone": ["Phone nr is invalid"]
  }
}
```
