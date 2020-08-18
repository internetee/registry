## GET /repp/v1/auctions

Return a list of auctions currently in progress. The list of domains changes
every day.

In contrast with other endpoints in REPP, this one is publicly available for
anyone without authentication.

#### Request

```
GET /repp/v1/auctions HTTP/1.1
Host: registry.test
User-Agent: curl/7.64.1
Accept: */*
```

#### Response

```
HTTP/1.1 200 OK
Date: Thu, 21 May 2020 10:39:45 GMT
Content-Type: application/json; charset=utf-8
ETag: W/"217bd9ee4dfbb332172a1baf80ee0ba9"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: a26b6801-bf3f-4922-b0db-3b081bacb130
X-Runtime: 1.481174
Transfer-Encoding: chunked

{
  "count":1,
  "auctions": [
    {
      "domain_name": "auctionäöüõ.test",
      "punycode_domain_name": "xn--auction-cxa7mj0e.test"
    }
  ]
}
```
