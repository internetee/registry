# Registry lock

## POST api/v1/registrant/domains/$UUID/registry_lock

Set a registry lock on a domain.

#### Request
```
POST api/v1/registrant/domains/98d1083a-8863-4153-93e4-caee4a013535/registry_lock HTTP/1.1
Accept: application/json
Authorization: Bearer Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Type: application/json
```

#### Response for success

```
HTTP/1.1 200
Content-Type: application/json

{
  "id":"98d1083a-8863-4153-93e4-caee4a013535",
  "name":"domain0.ee",
  "registrar":{
    "name":"Best Names",
    "website":"example.com"
  },
  "registrant":{
    "name":"John Smith",
    "id":"acadf23e-47c4-4606-8f67-76e071a1cca2"
  },
  "admin_contacts":[
    {
      "name":"John Smith",
      "id":"62015e7d-42c8-4d68-8164-e9b71680fd95"
    },
    {
      "name":"William Smith",
      "id":"a041c5b6-7772-4fac-83cd-fbce3b2c8867"
    }
  ],
  "tech_contacts":[
    {
      "name":"John Smith",
      "id":"62015e7d-42c8-4d68-8164-e9b71680fd95"
    },
    {
      "name":"William Smith",
      "id":"a041c5b6-7772-4fac-83cd-fbce3b2c8867"
    }
  ],
  "registered_at":"2015-09-09T09:11:14.861Z",
  "valid_to":"2016-09-09T09:11:14.861Z",
  "transfer_code":"98oiewslkfkd",
  "created_at":"2015-09-09T09:11:14.861Z",
  "updated_at":"2015-09-09T09:11:14.860Z",
  "name_dirty":"domain0.ee",
  "name_puny":"domain0.ee",
  "period":1,
  "period_unit":"y",
  "creator_str":null,
  "updator_str":null,
  "outzone_at":"2016-09-24T09:11:14.861Z",
  "delete_date":"2016-10-24",
  "registrant_verification_asked_at":null,
  "registrant_verification_token":null,
  "locked_by_registrant_at":"2015-09-09T09:11:14.861Z",
  "pending_json":{

  },
  "force_delete_date":null,
  "statuses":[
    "serverUpdateProhibited",
    "serverDeleteProhibited",
    "serverTransferProhibited"
  ],
  "nameservers":[
    {
      "hostname":"ns1.bestnames.test",
      "ipv4":[
        "173.245.58.41"
      ],
      "ipv6":[
        "2400:cb00:2049:1::adf5:3a33"
      ]
    },
    {
      "hostname":"ns1.bestnames.test",
      "ipv4":[
        "173.245.58.51"
      ],
      "ipv6":[
        "2400:cb00:2049:1::adf5:3b29"
      ]
    }
  ],
  "status_notes":{

  },
  "statuses_backup":[

  ]
}
```

#### Response for failure

```
HTTP/1.1 422
Content-Type: application/json

{
  "errors": [
    { "base": "Domain cannot be locked" }
  ]
}

```

```
HTTP/1.1 404
Content-Type: application/json

{
  "errors": [
    { "base": "Domain not found" }
  ]
}

```
```
HTTP/1.1 401
Content-Type: application/json

{
  "errors": [
    { "base": ["Only administrative contacts can manage registry locks"] }
  ]
}

```


## DELETE api/v1/registrant/domains/$UUID/registry_lock

Remove a registry lock.

#### Request
```
DELETE api/v1/registrant/domains/98d1083a-8863-4153-93e4-caee4a013535/registry_lock HTTP/1.1
Accept: application/json
Authorization: Bearer Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Type: application/json
```

#### Response for success

```
HTTP/1.1 200
Content-Type: application/json

{
  "id":"98d1083a-8863-4153-93e4-caee4a013535",
  "name":"domain0.ee",
  "registrar":{
    "name":"Best Names",
    "website":"example.com"
  },
  "registered_at":"2015-09-09T09:11:14.861Z",
  "valid_to":"2016-09-09T09:11:14.861Z",
  "registrant":{
    "name":"John Smith",
    "id":"acadf23e-47c4-4606-8f67-76e071a1cca2"
  },
  "admin_contacts":[
    {
      "name":"John Smith",
      "id":"62015e7d-42c8-4d68-8164-e9b71680fd95"
    },
    {
      "name":"William Smith",
      "id":"a041c5b6-7772-4fac-83cd-fbce3b2c8867"
    }
  ],
  "tech_contacts":[
    {
      "name":"John Smith",
      "id":"62015e7d-42c8-4d68-8164-e9b71680fd95"
    },
    {
      "name":"William Smith",
      "id":"a041c5b6-7772-4fac-83cd-fbce3b2c8867"
    }
  ],
  "transfer_code":"98oiewslkfkd",
  "created_at":"2015-09-09T09:11:14.861Z",
  "updated_at":"2015-09-09T09:11:14.860Z",
  "name_dirty":"domain0.ee",
  "name_puny":"domain0.ee",
  "period":1,
  "period_unit":"y",
  "creator_str":null,
  "updator_str":null,
  "outzone_at":"2016-09-24T09:11:14.861Z",
  "delete_date":"2016-10-24",
  "registrant_verification_asked_at":null,
  "registrant_verification_token":null,
  "locked_by_registrant_at":null,
  "pending_json":{

  },
  "force_delete_date":null,
  "statuses":[
    "ok"
  ],
  "nameservers":[
    {
      "hostname":"ns1.bestnames.test",
      "ipv4":[
        "173.245.58.41"
      ],
      "ipv6":[
        "2400:cb00:2049:1::adf5:3a33"
      ]
    },
    {
      "hostname":"ns1.bestnames.test",
      "ipv4":[
        "173.245.58.51"
      ],
      "ipv6":[
        "2400:cb00:2049:1::adf5:3b29"
      ]
    }
  ],
  "status_notes":{

  },
  "statuses_backup":[

  ]
}
```

#### Response for failure

```
HTTP/1.1 422
Content-Type: application/json

{
  "errors": [
    { "base": "Domain is not locked" }
  ]
}

```

```
HTTP/1.1 404
Content-Type: application/json

{
  "errors": [
    { "base": "Domain not found" }
  ]
}

```

```
HTTP/1.1 401
Content-Type: application/json

{
  "errors": [
    { "base": ["Only administrative contacts can manage registry locks"] }
  ]
}

```
