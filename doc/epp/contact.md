## Contact related functions

### Contact create

| Field name              | Min-max | Field description |
| ----------------------- |---------|------------------ |
| `<create>`              | 1     |   |
| `-<contact:create>`     | 1     | Attribute: xmlns:domain="urn:ietf:params:xml:ns:contact-1.0"      |
| `-<contact:voice>`      | 1     | Phone |
| `-<contact:email>`      | 1     | E-mail |
| `-<contact:Ident>`      | 1     | Contact identificator. Attribute: type="ico / op / passport / birthday" |
| `-<contact:postalInfo>` | 1     | Contact information |
| `--<contact:name>`      | 1     | Full name |
| `--<contact:addr>`      | 1     | Address |
| `---<contact:street>`   | 0-1     | Street name |
| `---<contact:city>`     | 1     | City name |
| `---<contact:cc>`       | 1     | Country code |
| `<extension>`           | 0-1   |   |
| `-<eis:extdata>`        | 0-1   | Attribute: xmlns:eis="urn:ee:eis:xml:epp:eis-1.0" |
| `--<eis:legalDocument>` | 1     | Base64 encoded document. Attribute: type="pdf" |
| `<clTRID>`              | 0-1   | Client transaction id |

NB! Extension is not implemented yet!

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-doc.md#epp-contact-with-valid-user-create-command-successfully-creates-a-contact)
