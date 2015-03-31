## GET /repp/v1/contacts
Returns contacts of the current registrar.

### Example

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
Content-Length: 483
Content-Type: application/json

{
  "contacts": [
    {
      "id": 1,
      "code": "sh470279120",
      "reg_no": null,
      "phone": "+372.12345678",
      "email": "bettye.feil@ratkegoldner.net",
      "fax": null,
      "created_at": "2015-03-31T07:39:10.854Z",
      "updated_at": "2015-03-31T07:39:10.854Z",
      "ident": "37605030299",
      "ident_type": "priv",
      "created_by_id": null,
      "updated_by_id": null,
      "auth_info": "password",
      "name": "Leopoldo Waelchi0",
      "org_name": null,
      "registrar_id": 1,
      "creator_str": "autotest",
      "updator_str": "autotest",
      "ident_country_code": "EE"
    }
  ],
  "total_number_of_records": 2
}
```

## GET /repp/v1/contacts
Returns contact names with offset.

### Example

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
    "sh226475261"
  ],
  "total_number_of_records": 2
}
```

## GET /repp/v1/contacts
Returns contact names of the current registrar.

### Example

#### Request
```
GET /repp/v1/contacts HTTP/1.1
Accept: application/json
Authorization: Basic Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Length: 0
Content-Type: application/json
```

#### Response
```
HTTP/1.1 200
Cache-Control: max-age=0, private, must-revalidate
Content-Length: 70
Content-Type: application/json

{
  "contacts": [
    "sh470279120",
    "sh226475261"
  ],
  "total_number_of_records": 2
}
```

## GET /repp/v1/contacts
Returns an error with invalid parameters in contact index.

### Example

#### Request
```
GET /repp/v1/contacts?limit=0 HTTP/1.1
Accept: application/json
Authorization: Basic Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Length: 0
Content-Type: application/json
```

#### Response
```
HTTP/1.1 400
Cache-Control: no-cache
Content-Length: 45
Content-Type: application/json

{
  "error": "limit does not have a valid value"
}
```
