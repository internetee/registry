## GET /repp/v1/contacts
Returns contacts of the current registrar.

### Example

#### Request
```
GET /repp/v1/contacts?page=1 HTTP/1.1
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
Content-Length: 867
Content-Type: application/json
ETag: W/"0fe2b795798cd8d371fc1ba5e0a7d8c4"
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Request-Id: 4629e62c-8636-4624-b5ab-3ffa91ec799b
X-Runtime: 0.147222
X-XSS-Protection: 1; mode=block

{
  "contacts": [
    {
      "registrar_id": 1,
      "id": 1,
      "code": "sh16377490",
      "reg_no": null,
      "phone": "+372.12345678",
      "email": "juliet@oreilly.org",
      "fax": null,
      "created_at": "2015-03-18T09:03:02.001Z",
      "updated_at": "2015-03-18T09:03:02.001Z",
      "ident": "37605030299",
      "ident_type": "priv",
      "created_by_id": null,
      "updated_by_id": null,
      "auth_info": "password",
      "name": "Adrianna Ferry0",
      "org_name": null,
      "creator_str": null,
      "updator_str": null,
      "ident_country_code": "EE"
    },
    {
      "registrar_id": 1,
      "id": 2,
      "code": "sh63156547",
      "reg_no": null,
      "phone": "+372.12345678",
      "email": "juliet@oreilly.org",
      "fax": null,
      "created_at": "2015-03-18T09:03:02.052Z",
      "updated_at": "2015-03-18T09:03:02.052Z",
      "ident": "37605030299",
      "ident_type": "priv",
      "created_by_id": null,
      "updated_by_id": null,
      "auth_info": "password",
      "name": "Miss Stuart Ritchie1",
      "org_name": null,
      "creator_str": null,
      "updator_str": null,
      "ident_country_code": "EE"
    }
  ],
  "total_pages": 1
}
```
