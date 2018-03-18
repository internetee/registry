# Domain contacts

## PATCH https://repp.internet.ee/v1/domains/contacts
Replaces all domain contacts of the current registrar.

### Example request
```
$ curl https://repp.internet.ee/v1/domains/contacts \
   -X PATCH \
   -u username:password \
   -d predecessor=foo \
   -d successor=bar
```
### Example response
```
{
  "affected_domains": ["example.com", "example.org"]
}
```
