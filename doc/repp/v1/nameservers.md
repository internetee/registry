# Nameservers

## PUT /repp/v1/registrar/nameservers
Replaces all name servers of current registrar domains.

#### Request
```
PUT /repp/v1/registrar/nameservers
Accept: application/json
Content-Type: application/json
Authorization: Basic dGVzdDp0ZXN0dGVzdA==
{
  "data": {
    "type": "nameserver",
    "id": "ns1.example.com",
    "attributes": {
      "hostname": "new-ns1.example.com",
      "ipv4": ["192.0.2.1", "192.0.2.2"],
      "ipv6": ["2001:db8::1", "2001:db8::2"]
    }
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
        "type": "nameserver",
        "id": "new-ns1.example.com",
        "attributes": {
            "hostname": "new-ns1.example.com",
            "ipv4": [
                "192.0.2.1",
                "192.0.2.2"
            ],
            "ipv6": [
                "2001:db8::1",
                "2001:db8::2"
            ]
        },
        "affected_domains": [
            "private.ee"
        ]
    }
}
```

#### Response on failure
```
HTTP/1.1 400
Content-Type: application/json

{
    "code": 2005,
    "message": "IPv4 is invalid [ipv4]",
    "data": {}
}
```
