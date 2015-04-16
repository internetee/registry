## GET /repp/v1/accounts/balance
Returns domains of the current registrar.


#### Request
```
GET /repp/v1/accounts/balance HTTP/1.1
Accept: application/json
Authorization: Basic Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Length: 0
Content-Type: application/json
```

#### Response
```
HTTP/1.1 200
Cache-Control: max-age=0, private, must-revalidate
Content-Length: 37
Content-Type: application/json

{
  "balance": "324.45",
  "currency": "EUR"
}
```
