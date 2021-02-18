# Admin domain contacts

## PATCH https://repp.internet.ee/v1/domains/admin_contacts
Replaces admin domain contacts of the current registrar.

### Example request
```
PATCH /repp/v1/domains/admin_contacts HTTP/1.1
Accept: application/json
Content-Type: application/json
Authorization: Basic dGVzdDp0ZXN0dGVzdA==

{
  "current_contact_id": "ATSAA:749AA80F",
  "new_contact_id": "ATSAA:E36957D7"
}
```
### Example response
```
{
  "code": 1000,
  "message": "Command completed successfully",
  "data": {
    "affected_domains": [
      "private.ee",
    ],
    "skipped_domains": []
  }
}
```
