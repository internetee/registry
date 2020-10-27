## GET /api/v1/registrant/companies
Returns list of companies registered in business register for the current registrant.


#### Parameters

| Field name | Required |  Type   |  Allowed values   |        Description         |
| ---------- | -------- |  ----   |  --------------   |        -----------         |
|   limit    |  false   | Integer |     [1..200]      | How many companies to show |
|   offset   |  false   | Integer |                   | Company number to start at |

#### Request
```
GET /api/v1/registrant/companies?limit=1 HTTP/1.1
Accept: application/json
Authorization: Bearer Z2l0bGFiOmdoeXQ5ZTRmdQ==
Content-Type: application/json
```

#### Response
```
HTTP/1.1 200
Content-Type: application/json

{
  "companies":[
    {
      "name":"ACME Ltd",
      "registry_no":"37605030299",
      "country_code":"EE"
    }
  ]
}
```
