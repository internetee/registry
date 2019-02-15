## GET /api/v1/auctions
Returns started auctions.

### Request
```
GET /api/v1/auctions HTTP/1.1
```

### Response
```
HTTP/1.1 200
Content-Type: application/json

[
  {
    "id": "1b3ee442-e8fe-4922-9492-8fcb9dccc69c",
    "domain": "shop.test",
    "status": "domain_registered" # https://github.com/internetee/registry/blob/0392984314f55640c8aae93f3b75b488d84ba73b/app/models/auction.rb#L2
  }
]
```

## GET /api/v1/auctions/$UUID
Returns auction details.

### Request
```
GET /api/v1/auctions/1b3ee442-e8fe-4922-9492-8fcb9dccc69c HTTP/1.1
```

### Response
```
HTTP/1.1 200
Content-Type: application/json

{
  "id": "1b3ee442-e8fe-4922-9492-8fcb9dccc69c",
  "domain": "shop.test",
  "status": "domain_registered" # https://github.com/internetee/registry/blob/0392984314f55640c8aae93f3b75b488d84ba73b/app/models/auction.rb#L2
}
```

## PATCH /api/v1/auctions/$UUID
Updates auction.

### Parameters
| Field name | Required | Type    | Allowed values                                              | Description              |
| ---------- | -------- | ----    | --------------                                              | -----------              |
| status     | no       | String  | "awaiting_payment", "no_bids", "payment_received", "payment_not_received", "domain_not_registered"

## Request
```
PATCH /api/v1/auctions/954cdccb-af43-4765-ac8d-d40600040ab9 HTTP/1.1
Content-type: application/json

{
  "status": "no_bids"
}
```

## Response
```
HTTP/1.1 200
Content-Type: application/json

{
  "id": "1b3ee442-e8fe-4922-9492-8fcb9dccc69c",
  "domain": "shop.test",
  "status": "domain_registered", # https://github.com/internetee/registry/blob/0392984314f55640c8aae93f3b75b488d84ba73b/app/models/auction.rb#L2
  "registration_code": "auction-001" # Revealed only if status is "payment_received", otherwise null is returned
}
```
