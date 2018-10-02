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
  "id": "98d1083a-8863-4153-93e4-caee4a013535",
  "name": "domain0.ee",
  "registrar": "Best Names",
  "registered_at": "2015-09-09T09:11:14.861Z",
  "valid_to": "2016-09-09T09:11:14.861Z",
  "registrant_id": 1,
  "transfer_code": "98oiewslkfkd",
  "created_at": "2015-09-09T09:11:14.861Z",
  "updated_at": "2015-09-09T09:11:14.860Z",
  "name_dirty": "domain0.ee",
  "name_puny": "domain0.ee",
  "period": 1,
  "period_unit": "y",
  "creator_str": null,
  "updator_str": null,
  "legacy_id": null,
  "legacy_registrar_id": null,
  "legacy_registrant_id": null,
  "outzone_at": "2016-09-24T09:11:14.861Z",
  "delete_at": "2016-10-24T09:11:14.861Z",
  "registrant_verification_asked_at": null,
  "registrant_verification_token": null,
  "locked_by_registrant_at": "2015-09-09T09:11:14.861Z",
  "pending_json": {},
  "force_delete_at": null,
  "statuses": [
    "serverUpdateProhibited",
    "serverDeleteProhibited",
    "serverTransferProhibited"
  ],
  "reserved": false,
  "status_notes": {},
  "statuses_backup": []
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
  "id": "98d1083a-8863-4153-93e4-caee4a013535",
  "name": "domain0.ee",
  "registrar": "Best Names",
  "registered_at": "2015-09-09T09:11:14.861Z",
  "valid_to": "2016-09-09T09:11:14.861Z",
  "registrant_id": 1,
  "transfer_code": "98oiewslkfkd",
  "created_at": "2015-09-09T09:11:14.861Z",
  "updated_at": "2015-09-09T09:11:14.860Z",
  "name_dirty": "domain0.ee",
  "name_puny": "domain0.ee",
  "period": 1,
  "period_unit": "y",
  "creator_str": null,
  "updator_str": null,
  "legacy_id": null,
  "legacy_registrar_id": null,
  "legacy_registrant_id": null,
  "outzone_at": "2016-09-24T09:11:14.861Z",
  "delete_at": "2016-10-24T09:11:14.861Z",
  "registrant_verification_asked_at": null,
  "registrant_verification_token": null,
  "locked_by_registrant_at": null,
  "pending_json": {},
  "force_delete_at": null,
  "statuses": [
    "ok"
  ],
  "reserved": false,
  "status_notes": {},
  "statuses_backup": []
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
