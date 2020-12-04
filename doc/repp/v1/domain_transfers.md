# Domain transfers

## POST /repp/v1/domains/transfer
Transfers domains.

#### Request
```
POST /repp/v1/domains/transfer
Accept: application/json
Content-Type: application/json
Authorization: Basic dGVzdDp0ZXN0dGVzdA==

{
  "data": {
    "domain_transfers": [
      {
        "domain_name":"example.com",
        "transferCode":"63e7"
      },
      {
        "domain_name":"example.org",
        "transferCode":"15f9"
      }
    ]
  }
}
```

#### Response on success
```
HTTP/1.1 200
Content-Type: application/json
{
  "code": 1000,
  "message": "Command completed successfully",
  "data": {
    "success": [
      {
          "type": "domain_transfer",
          "domain_name": "example.com"
      },
      {
          "type": "domain_transfer",
          "domain_name": "example.org"
      }
    ],
    "failed": []
  }
}
```


#### Response on failure
```
HTTP/1.1 400
Content-Type: application/json
{
  "code": 1000,
  "message": "Command completed successfully",
  "data": {
    "success": [],
    "failed": [
      {
        "type": "domain_transfer",
        "domain_name": "example.com",
        "errors": [
          {
            "code": "2202",
            "msg": "Invalid authorization information"
          }
        ]
      },
      {
        "type": "domain_transfer",
        "domain_name": "example.org",
        "errors": [
          {
            "code": "2304",
            "msg": "Object status prohibits operation"
          }
        ]
      }
    ]
  }
}
```
