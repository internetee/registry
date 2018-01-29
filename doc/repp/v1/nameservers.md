# Nameservers

## PUT /repp/v1/nameservers
Replaces nameservers

#### Request
```
PUT /repp/v1/nameservers
Accept: application/json
Content-Type: application/json
Authorization: Basic dGVzdDp0ZXN0dGVzdA==

{
   "data":{
      "nameservers":[
         {
            "hostname":"ns1.example.com",
            "ipv4":"192.0.2.1"
            "ipv6":"2001:DB8::1"
         },
         {
            "hostname":"ns2.example.com",
            "ipv4":"192.0.2.1"
            "ipv6":"2001:DB8::1"
         }
      ]
   }
}
```

#### Response on success
```
HTTP/1.1 204
```

#### Response on failure
```
HTTP/1.1 400
Content-Type: application/json
{
   "errors":[
      {
         "title":"ns1.example.com does not exist"
      },
      {
         "title":"192.0.2.1 is not a valid IPv4 address"
      }
   ]
}
```
