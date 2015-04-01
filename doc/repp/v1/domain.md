## GET /repp/v1/domains
Returns domains of the current registrar.


#### Parameters

| Field name | Required |  Type   |                             Allowed values                              |
| ---------- | -------- |  ----   |                             --------------                              |
|   limit    |  false   | Integer | [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20] |
|   offset   |  false   | Integer |                                                                         |
|  details   |  false   | String  |                            ["true", "false"]                            |

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
      "registered_at": "2015-04-01T10:30:48.773Z",
      "status": null,
      "valid_from": "2015-04-01T00:00:00.000Z",
      "valid_to": "2016-04-01T00:00:00.000Z",
      "owner_contact_id": 1,
      "auth_info": "1a93d4599945df52de0a38c64b470e67",
      "created_at": "2015-04-01T10:30:48.768Z",
      "updated_at": "2015-04-01T10:30:48.762Z",
      "name_dirty": "domain0.ee",
      "name_puny": "domain0.ee",
      "period": 1,
      "period_unit": "y",
      "creator_str": null,
      "updator_str": null,
      "whois_body": "  This Whois Server contains information on\n  Estonian Top Level Domain ee TLD\n\n  domain:    domain0.ee\n  registrar: registrar1\n  status:\n  registered: \n  changed:   2015-04-01 10:30:48\n  expire:\n  outzone:\n  delete:\n\n  \n\n  nsset:\n  nserver:\n\n  registrar: registrar1\n  phone: \n  address: Street 111, Town, County, Postal\n  created: 2015-04-01 10:30:48\n  changed: 2015-04-01 10:30:48\n"
    }
  ],
  "total_number_of_records": 2
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
Content-Length: 54
Content-Type: application/json

{
  "domains": [
    "domain1.ee"
  ],
  "total_number_of_records": 2
}
```
