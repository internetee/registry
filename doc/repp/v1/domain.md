## GET /repp/v1/domains
Returns domains of the current registrar.

### Example

#### Request
```
GET /repp/v1/domains?page=1 HTTP/1.1
Accept: application/json
Authorization: Basic Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Length: 0
Content-Type: application/json
Host: www.example.com
```

#### Response
```
HTTP/1.1 200
Cache-Control: max-age=0, private, must-revalidate
Content-Length: 1859
Content-Type: application/json
ETag: W/"a63861e741f479e8099f9fdb913a8e66"
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Request-Id: bdda3b2d-d65a-441f-8c2e-751e56de4d18
X-Runtime: 0.017877
X-XSS-Protection: 1; mode=block

{
  "domains": [
    {
      "registrar_id": 1,
      "id": 1,
      "name": "domain0.ee",
      "registered_at": "2015-03-18T09:03:02.686Z",
      "status": null,
      "valid_from": "2015-03-18T00:00:00.000Z",
      "valid_to": "2016-03-18T00:00:00.000Z",
      "owner_contact_id": 1,
      "auth_info": "085f8c4cf5af0c14615a2da64f6a84c2",
      "created_at": "2015-03-18T09:03:02.681Z",
      "updated_at": "2015-03-18T09:03:02.680Z",
      "name_dirty": "domain0.ee",
      "name_puny": "domain0.ee",
      "period": 1,
      "period_unit": "y",
      "creator_str": null,
      "updator_str": null,
      "whois_body": "    This Whois Server contains information on\n    Estonian Top Level Domain ee TLD\n\n    domain:    domain0.ee\n    registrar: registrar1\n    status:\n    registered:\n    changed:   2015-03-18 09:03:02\n    expire:\n    outzone:\n    delete:\n\n    contact\n    name:\n    e-mail:\n    registrar:\n    created:\n\n    contact:\n\n    nsset:\n    nserver:\n\n    registrar:\n    org:\n    url:\n    phone:\n    address:\n    created:\n    changed:\n"
    },
    {
      "registrar_id": 1,
      "id": 2,
      "name": "domain1.ee",
      "registered_at": "2015-03-18T09:03:02.856Z",
      "status": null,
      "valid_from": "2015-03-18T00:00:00.000Z",
      "valid_to": "2016-03-18T00:00:00.000Z",
      "owner_contact_id": 3,
      "auth_info": "79fdd1a0174be7e141c2930aff278b43",
      "created_at": "2015-03-18T09:03:02.854Z",
      "updated_at": "2015-03-18T09:03:02.854Z",
      "name_dirty": "domain1.ee",
      "name_puny": "domain1.ee",
      "period": 1,
      "period_unit": "y",
      "creator_str": null,
      "updator_str": null,
      "whois_body": "    This Whois Server contains information on\n    Estonian Top Level Domain ee TLD\n\n    domain:    domain1.ee\n    registrar: registrar1\n    status:\n    registered:\n    changed:   2015-03-18 09:03:02\n    expire:\n    outzone:\n    delete:\n\n    contact\n    name:\n    e-mail:\n    registrar:\n    created:\n\n    contact:\n\n    nsset:\n    nserver:\n\n    registrar:\n    org:\n    url:\n    phone:\n    address:\n    created:\n    changed:\n"
    }
  ],
  "total_pages": 1
}
```
