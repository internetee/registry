# Domain transfers

## POST /repp/v1/domain_transfers
Transfers domains.

#### Request
```
POST /repp/v1/domain_transfers
Accept: application/json
Content-Type: application/json
Authorization: Basic dGVzdDp0ZXN0dGVzdA==

{
   "data":{
      "domainTransfers":[
         {
            "domainName":"example.com",
            "transferCode":"63e7"
         },
         {
            "domainName":"example.org",
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
   "data":[
      {
         "type":"domain_transfer"
      },
      {
         "type":"domain_transfer"
      }
   ]
}
```


#### Response on failure
```
HTTP/1.1 400
Content-Type: application/json
{
   "errors":[
      {
         "title":"example.com transfer code is wrong"
      },
      {
         "title":"example.org does not exist"
      }
   ]
}
```
