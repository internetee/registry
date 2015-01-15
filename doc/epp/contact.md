## Contact related functions

### Contact create

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [create](#create)            | true     |      |                  |
| [extension](#ext-0)         | true     |      |                  |
| clTRID         | false     |      | Client transaction id |

##### create

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [contact:create](#contactcreate)    | true     | xmlns:contact (urn:ietf:params:xml:ns:contact-1.0)   |  |

##### contact:create

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [contact:postalInfo](#contactpostalinfo) | true     |      | Address information |
| contact:voice | true |      | Phone |
| contact:email | true |      | E-mail |
| contact:ident | true | type (ico, op, passport, birthday)     | Ident |

##### contact:postalInfo

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| contact:name      | true     |      | Full name |
| [contact:addr](#contactaddr)      | true     |      | Address |

##### contact:addr

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| contact:street    | false     |      | Street name |
| contact:city      | true     |      | City name |
| contact:cc      | true     |      | Country code |

##### <a name="ext-0"></a>extension !!! NOT IMPLEMENTED YET

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| [eis:extdata](#eisextdata)     | false     | xmlns:eis (urn:ee:eis:xml:epp:eis-1.0) | Legal document |

##### eis:extdata

| Field name        | Required | Attributes | Field description |
| ----------------- |----------| -----|----------------- |
| eis:legalDocument     | true    | type (pdf) | Base64 encoded document |


[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-contact-with-valid-user-create-command-successfully-creates-a-contact)
