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
  "contacts":[
    {
      "id":"84c62f3d-e56f-40fa-9ca4-dc0137778949",
      "name":"Karson Kessler",
      "code":"REGISTRAR2:SH022086480",
      "ident":{
        "code":"37605030299",
        "type":"priv",
        "country_code":"EE"
      },
      "email":"foo@bar.baz",
      "phone":"+372.12345671",
      "fax":"+372.12345672",
      "address":{
        "street":"Main Street 123",
        "zip":"22222",
        "city":"New City",
        "state":"New state",
        "country_code":"LV"
      },
      "auth_info":"password",
      "statuses":[
        "ok"
      ]
    }
  ]
}
```

## GET /api/v1/registrant/contacts/$UUID
Returns contact details.


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
  "id": "84c62f3d-e56f-40fa-9ca4-dc0137778949",
  "name": "Karson Kessler",
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
  "name":"John Doe",
  "email":"foo@bar.baz",
  "phone":"+372.12345671",
  "fax":"+372.12345672",
  "address":{
    "street":"Main Street 123",
    "zip":"22222",
    "city":"New City",
    "state":"New state",
    "country_code":"LV"
  }
}

```
#### Response on success

Same as for [GET /api/v1/registrant/contacts/$UUID](#get-apiv1registrantcontactsuuid).

### Response on failure
```
HTTP/1.1 400
Content-Type: application/json

{
  "errors":{
    "phone":[
      "Phone nr is invalid"
    ]
  }
}
```
