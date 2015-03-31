## GET /repp/v1/domains
Returns domains of the current registrar.

### Example

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
Content-Length: 909
Content-Type: application/json

{
  "domains": [
    {
      "id": 1,
      "name": "domain0.ee",
      "registrar_id": 1,
      "registered_at": "2015-03-31T07:39:11.598Z",
      "status": null,
      "valid_from": "2015-03-31T00:00:00.000Z",
      "valid_to": "2016-03-31T00:00:00.000Z",
      "owner_contact_id": 1,
      "auth_info": "fc7828fbc275ff16b86a31def3e7a60d",
      "created_at": "2015-03-31T07:39:11.595Z",
      "updated_at": "2015-03-31T07:39:11.591Z",
      "name_dirty": "domain0.ee",
      "name_puny": "domain0.ee",
      "period": 1,
      "period_unit": "y",
      "creator_str": null,
      "updator_str": null,
      "whois_body": "  This Whois Server contains information on\n  Estonian Top Level Domain ee TLD\n\n  domain:    domain0.ee\n  registrar: registrar1\n  status:\n  registered: \n  changed:   2015-03-31 07:39:11\n  expire:\n  outzone:\n  delete:\n\n  \n\n  nsset:\n  nserver:\n\n  registrar: registrar1\n  phone: \n  address: Street 111, Town, County, Postal\n  created: 2015-03-31 07:39:11\n  changed: 2015-03-31 07:39:11\n"
    }
  ],
  "total_number_of_records": 2
}
```

## GET /repp/v1/domains
Returns domain names with offset.

### Example

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

## GET /repp/v1/domains
Returns domain names of the current registrar.

### Example

#### Request
```
GET /repp/v1/domains HTTP/1.1
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
  "domains": [
    "domain0.ee",
    "domain1.ee"
  ],
  "total_number_of_records": 2
}
```

## GET /repp/v1/domains
Returns an error with invalid parameters in domain index.

### Example

#### Request
```
GET /repp/v1/domains?limit=0 HTTP/1.1
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
