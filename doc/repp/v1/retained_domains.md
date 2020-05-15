## GET /repp/v1/retained_domains

Return a list of reserved and blocked domains, along with total count. You can
filter them by type of the domain, which can be either reserved or blocked.

In contrast with other endpoints in REPP, this one is publicly available for
anyone without authentication.

#### Parameters

| Field name | Required |  Type   |     Allowed values      |        Description         |
| ---------- | -------- |  ----   |  --------------         |        -----------         |
|   type     |  false   | string  | ["reserved", "blocked"] | Type of domains to show    |


#### Request

```
GET /repp/v1/retained_domains?type=reserved HTTP/1.1
Accept: application/json
User-Agent: curl/7.64.1
```

#### Response

```
HTTP/1.1 200 OK
Date: Fri, 15 May 2020 11:30:07 GMT
Content-Type: application/json; charset=utf-8
ETag: W/"a905b531243a6b0be42beb9d6ce60619"
Cache-Control: max-age=0, private, must-revalidate
Transfer-Encoding: chunked

{
  "count": 1,
  "domains": [
    {
      "name": "reserved.test",
      "status": "reserved",
      "punycode_name": "reserved.test"
    }
  ]
}
```

After you have made the first request, you can save the ETag header, and
send it as If-None-Match in the subsequent request for cache validation.
Due to the fact that the lists are not changing frequently and are quite long,
it is recommended that you take advantage of ETag cache.

ETag key values depend on the request parameters. A request for only blocked
domains returns different cache key than request for all domains.

### Cache Request

```
GET /repp/v1/retained_domains?type=reserved HTTP/1.1
Accept: application/json
User-Agent: curl/7.64.1
If-None-Match: W/"a905b531243a6b0be42beb9d6ce60619"
```

#### Cache hit response

Response with no body and status 304 is sent in case the list have not changed.

```
HTTP/1.1 304 Not Modified
Date: Fri, 15 May 2020 11:34:25 GMT
ETag: W/"a905b531243a6b0be42beb9d6ce60619"
Cache-Control: max-age=0, private, must-revalidate
```

#### Cache miss response

Standard 200 response is sent when the list have changed since last requested.


```
HTTP/1.1 200 OK
Date: Fri, 15 May 2020 11:30:07 GMT
Content-Type: application/json; charset=utf-8
ETag: W/"a905b531243a6b0be42beb9d6ce60619"
Transfer-Encoding: chunked

{
  "count": 1,
  "domains": [
    {
      "name": "reserved.test",
      "status": "reserved",
      "punycode_name": "reserved.test"
    }
  ]
}
```
