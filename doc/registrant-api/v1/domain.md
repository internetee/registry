# Domain related actions

## GET /api/v1/registrant/domains

Returns domains of the current registrant.


#### Parameters

| Field name | Required | Type    | Allowed values    | Description                |
| ---------- | -------- | ----    | --------------    | -----------                |
| limit      | false    | Integer | [1..200]          | How many domains to show   |
| offset     | false    | Integer |                   | Domain number to start at  |
| details    | false    | String  | ["true", "false"] | Whether to include details |

#### Request
```
GET api/v1/registrant/domains?limit=1&details=true HTTP/1.1
Accept: application/json
Authorization: Bearer Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Type: application/json
```

#### Response
```
HTTP/1.1 200
Content-Type: application/json

{
  "domains": [
    {
      "uuid": "98d1083a-8863-4153-93e4-caee4a013535",
      "name": "domain0.ee",
      "registrar_id": 2,
      "registered_at": "2015-09-09T09:11:14.861Z",
      "status": null,
      "valid_from": "2015-09-09T09:11:14.861Z",
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
      "pending_json": {
      },
      "force_delete_at": null,
      "statuses": [
        "ok"
      ],
      "reserved": false,
      "status_notes": {
      },
      "statuses_backup": [
      ]
    }
  ],
  "total_number_of_records": 2
}
```

## GET api/v1/registrant/domains

Returns domain names with offset.


#### Request
```
GET api/v1/registrant/domains?offset=1 HTTP/1.1
Accept: application/json
Authorization: Bearer Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Type: application/json
```

#### Response
```
HTTP/1.1 200
Content-Type: application/json

{
  "domains": [
    "domain1.ee"
  ],
  "total_number_of_records": 2
}
```

## GET api/v1/registrant/domains/$UUID

Returns a single domain object.


#### Request
```
GET api/v1/registrant/domains/98d1083a-8863-4153-93e4-caee4a013535 HTTP/1.1
Accept: application/json
Authorization: Bearer Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Type: application/json
```

#### Response for success

```
HTTP/1.1 200
Content-Type: application/json

{
  "uuid": "98d1083a-8863-4153-93e4-caee4a013535",
  "name": "domain0.ee",
  "registrar_id": 2,
  "registered_at": "2015-09-09T09:11:14.861Z",
  "status": null,
  "valid_from": "2015-09-09T09:11:14.861Z",
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
HTTP/1.1 404
Content-Type: application/json

{ "errors": ["Domain not found"] }
```
