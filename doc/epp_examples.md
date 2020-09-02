Run options: include {:focus=>true, :epp=>true}
# EPP REQUEST - RESPONSE EXAMPLES
GENERATED AT: 2015-09-09 09:40:26 UTC  
EXAMPLE COUNT: 189  

---

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3885524928</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command fails if request xml is missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd"/>
    </create>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-ee-1.1.xsd}create': Missing child element(s). Expected is one of ( {https://epp.tld.ee/schema/contact-ee-1.1.xsd}id, {https://epp.tld.ee/schema/contact-ee-1.1.xsd}postalInfo ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8521459787</svTRID>
    </trID>
  </response>
</epp>
```

### EPP contact create command with postal address element successfully creates the object (address processing disabled)

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1100">
      <msg>Command completed successfully; Postal address data discarded</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:84FC4612</contact:id>
        <contact:crDate>2015-09-09T09:40:29Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7245575567</svTRID>
    </trID>
  </response>
</epp>
```

### EPP contact create command without postal address element successfully creates the object (address processing disabled)

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:84FC4612</contact:id>
        <contact:crDate>2015-09-09T09:40:29Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7245575567</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command creates a contact with custom auth info  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
        <contact:authInfo>
          <contact:pw>custompw</contact:pw>
        </contact:authInfo>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:467382DF</contact:id>
        <contact:crDate>2015-09-09T09:40:29Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6773218727</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command successfully saves ident type with legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="birthday" cc="US">1990-22-12</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:ECE6546C</contact:id>
        <contact:crDate>2015-09-09T09:40:29Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3052510277</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command successfully adds registrar  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:E5EB4D84</contact:id>
        <contact:crDate>2015-09-09T09:40:29Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6438471511</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command returns result data upon success  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:EAB46720</contact:id>
        <contact:crDate>2015-09-09T09:40:29Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9454779652</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should return email issue  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>not@valid</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Email is invalid [email]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7361191539</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should add registrar prefix for code when missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>abc12345</contact:id>
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:ABC12345</contact:id>
        <contact:crDate>2015-09-09T09:40:30Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5728692448</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should add registrar prefix for code when missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>abc:ABC:12345</contact:id>
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:ABC:ABC:12345</contact:id>
        <contact:crDate>2015-09-09T09:40:30Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4533576272</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should not allow spaces in custom code  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>abc 123</contact:id>
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">is invalid [code]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2978768860</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should not strange characters in custom code  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>33&amp;$@@</contact:id>
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">is invalid [code]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9458101032</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should not strange characters in custom code  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa</contact:id>
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Contact code is too long, max 100 characters [code]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2930253906</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should not saves ident type with wrong country code  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="birthday" cc="WRONG">1990-22-12</eis:ident>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/eis-1.0.xsd}ident', attribute 'cc': [facet 'maxLength'] The value 'WRONG' has a length of '5'; this exceeds the allowed maximum length of '2'.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/eis-1.0.xsd}ident', attribute 'cc': 'WRONG' is not a valid value of the atomic type '{https://epp.tld.ee/schema/eis-1.0.xsd}ccType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4181323352</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should return country missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="birthday">1990-22-12</eis:ident>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/eis-1.0.xsd}ident': The attribute 'cc' is required but missing.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7347010854</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should return country missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident>1990-22-12</eis:ident>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/eis-1.0.xsd}ident': The attribute 'type' is required but missing.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/eis-1.0.xsd}ident': The attribute 'cc' is required but missing.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1469555105</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should add registrar prefix for code when legacy prefix present  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>CID:FIRST0:abc:ABC:NEW:12345</contact:id>
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:CID:FIRST0:ABC:ABC:NEW:12345</contact:id>
        <contact:crDate>2015-09-09T09:40:36Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8659799699</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should not remove suffix CID  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>CID:FIRST0:abc:CID:ABC:NEW:12345</contact:id>
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:CID:FIRST0:ABC:CID:ABC:NEW:12345</contact:id>
        <contact:crDate>2015-09-09T09:40:36Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9265666981</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should not add registrar prefix for code when prefix present  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:abc22</contact:id>
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:ABC22</contact:id>
        <contact:crDate>2015-09-09T09:40:36Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5547036409</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should add registrar prefix for code does not match exactly to prefix  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>cid2:first0:abc:ABC:11111</contact:id>
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:CID2:FIRST0:ABC:ABC:11111</contact:id>
        <contact:crDate>2015-09-09T09:40:36Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5904746110</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should ignore custom code when only contact prefix given  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>CID:FIRST0</contact:id>
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:CID:FIRST0</contact:id>
        <contact:crDate>2015-09-09T09:40:37Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2802891483</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should generate server id when id is empty  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:0D91E51A</contact:id>
        <contact:crDate>2015-09-09T09:40:37Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9050239318</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should generate server id when id is empty  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:4F138386</contact:id>
        <contact:crDate>2015-09-09T09:40:37Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1715682253</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should return parameter value policy error for org  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:org>should not save</contact:org>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Org must be blank: postalInfo &gt; org [org]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2280144487</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should return parameter value policy error for fax  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:pc>123456</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:fax>should not save</contact:fax>
        <contact:email>test@example.example</contact:email>
      </contact:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Fax must be blank: fax [fax]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4349113709</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command fails if request is invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd"/>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-ee-1.1.xsd}update': Missing child element(s). Expected is ( {https://epp.tld.ee/schema/contact-ee-1.1.xsd}id ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7286028459</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command returns error if obj doesnt exist  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>not-exists</contact:id>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
          <contact:voice>+372.7654321</contact:voice>
          <contact:email>edited@example.example</contact:email>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
        </contact:chg>
      </contact:update>
    </update>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Object does not exist</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:id>NOT-EXISTS</obj:id>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2074703171</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command is succesful  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
          <contact:voice>+372.7654321</contact:voice>
          <contact:email>edited@example.example</contact:email>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
        </contact:chg>
      </contact:update>
    </update>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:crDate>2015-09-09T09:40:39Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3491459904</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command is succesful for own contact without password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
        </contact:chg>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:crDate>2015-09-09T09:40:39Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0870722687</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should update other contact with correct password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4631527659</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
          <contact:voice>+372.7654321</contact:voice>
          <contact:email>edited@example.example</contact:email>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
        </contact:chg>
      </contact:update>
    </update>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:crDate>2015-09-09T09:40:39Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2316245904</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6653164016</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should not update other contact without password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1869422463</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
        </contact:chg>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1310988362</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5729503440</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command returns phone and email error  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
          <contact:voice>123213</contact:voice>
          <contact:email>wrong</contact:email>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
        </contact:chg>
      </contact:update>
    </update>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Phone nr is invalid [phone]</msg>
    </result>
    <result code="2005">
      <msg lang="en">Email is invalid [email]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3321892849</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should return email issue  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
          <contact:voice>+372.7654321</contact:voice>
          <contact:email>legacy@wrong</contact:email>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
        </contact:chg>
      </contact:update>
    </update>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Email is invalid [email]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6744241029</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should not update code with custom string  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
          <contact:voice>+372.7654321</contact:voice>
          <contact:email>edited@example.example</contact:email>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
          <contact:id>notpossibletoupdate</contact:id>
        </contact:chg>
      </contact:update>
    </update>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-ee-1.1.xsd}id': This element is not expected.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8679770784</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should not be able to update ident  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
          <contact:voice>+372.7654321</contact:voice>
          <contact:email>edited@example.example</contact:email>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
        </contact:chg>
      </contact:update>
    </update>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="birthday" cc="US">1990-22-12</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Update of ident data not allowed [ident]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1951064233</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should return parameter value policy errror for org update  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
            <contact:org>should not save</contact:org>
          </contact:postalInfo>
          <contact:voice>+372.7654321</contact:voice>
          <contact:email>edited@example.example</contact:email>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
        </contact:chg>
      </contact:update>
    </update>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Org must be blank: postalInfo &gt; org [org]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5350033657</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should return parameter value policy errror for fax update  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
          <contact:voice>+372.7654321</contact:voice>
          <contact:fax>should not save</contact:fax>
          <contact:email>edited@example.example</contact:email>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
        </contact:chg>
      </contact:update>
    </update>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Fax must be blank: fax [fax]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9118950841</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command does not allow to edit statuses if policy forbids it  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:add>
          <contact:status s="clientDeleteProhibited" lang="en">Payment overdue.</contact:status>
          <contact:status s="clientUpdateProhibited"/>
        </contact:add>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Client-side object status management not supported: status [status]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8671401358</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should update auth info  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:authInfo>
            <contact:pw>newpassword</contact:pw>
          </contact:authInfo>
        </contact:chg>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:crDate>2015-09-09T09:40:39Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8238101481</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should add value voice value  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:voice>+372.11111111</contact:voice>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
        </contact:chg>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:creData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:crDate>2015-09-09T09:40:39Z</contact:crDate>
      </contact:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9487792357</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should return error when add attributes phone value is empty  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:voice/>
          <contact:email>example@example.ee</contact:email>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
        </contact:chg>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing - phone [phone]</msg>
    </result>
    <result code="2005">
      <msg lang="en">Phone nr is invalid [phone]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3038821005</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should not allow to remove required voice attribute  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:voice/>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
        </contact:chg>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing - phone [phone]</msg>
    </result>
    <result code="2005">
      <msg lang="en">Phone nr is invalid [phone]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7710739186</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should return general policy error when updating org  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:postalInfo>
            <contact:org>shouldnot</contact:org>
          </contact:postalInfo>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
        </contact:chg>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Org must be blank: postalInfo &gt; org [org]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6592307898</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command does not allow to edit statuses if policy forbids it  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:add>
          <contact:status s="clientUpdateProhibited"/>
        </contact:add>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Client-side object status management not supported: status [status]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5234465789</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command fails if request is invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd"/>
    </delete>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-ee-1.1.xsd}delete': Missing child element(s). Expected is ( {https://epp.tld.ee/schema/contact-ee-1.1.xsd}id ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1626853684</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command returns error if obj doesnt exist  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>not-exists</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Object does not exist</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:id>NOT-EXISTS</obj:id>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7073768118</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command deletes contact  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH159792243</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0218425687</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command deletes own contact even with wrong password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH281327764</contact:id>
        <contact:authInfo>
          <contact:pw>wrong password</contact:pw>
        </contact:authInfo>
      </contact:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3065209311</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command deletes own contact even without password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH671824275</contact:id>
      </contact:delete>
    </delete>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9577129072</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command fails if contact has associated domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH584167436</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2305">
      <msg lang="en">Object association prohibits operation [domains]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9195498943</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command should delete when not owner but with correct password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5140790883</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH184575429</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8609941835</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5202273416</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command should not delete when not owner without password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0752802683</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH5548884710</contact:id>
      </contact:delete>
    </delete>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0482443818</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2840106728</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command should not delete when not owner with wrong password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0001093939</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH2027223711</contact:id>
        <contact:authInfo>
          <contact:pw>wrong password</contact:pw>
        </contact:authInfo>
      </contact:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1181916838</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7765829729</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user check command fails if request is invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <check>
      <contact:check xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd"/>
    </check>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-ee-1.1.xsd}check': Missing child element(s). Expected is ( {https://epp.tld.ee/schema/contact-ee-1.1.xsd}id ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9452731556</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user check command returns info about contact availability  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <check>
          <contact:check xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
            <contact:id>FIXED:CHECK-1234</contact:id>
            <contact:id>check-4321</contact:id>
          </contact:check>
        </check>
        <clTRID>ABC-12345</clTRID>
      </command>
    </epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:chkData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:cd>
          <contact:id avail="0">FIXED:CHECK-1234</contact:id>
          <contact:reason>in use</contact:reason>
        </contact:cd>
        <contact:cd>
          <contact:id avail="1">check-4321</contact:id>
        </contact:cd>
      </contact:chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6286464515</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user check command should support legacy CID farmat  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <command>
        <check>
          <contact:check xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
            <contact:id>FIXED:CHECK-LEGACY</contact:id>
            <contact:id>CID:FIXED:CHECK-LEGACY</contact:id>
          </contact:check>
        </check>
        <clTRID>ABC-12345</clTRID>
      </command>
    </epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:chkData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:cd>
          <contact:id avail="0">FIXED:CHECK-LEGACY</contact:id>
          <contact:reason>in use</contact:reason>
        </contact:cd>
        <contact:cd>
          <contact:id avail="1">CID:FIXED:CHECK-LEGACY</contact:id>
        </contact:cd>
      </contact:chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0632765583</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command fails if request invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd"/>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-ee-1.1.xsd}info': Missing child element(s). Expected is ( {https://epp.tld.ee/schema/contact-ee-1.1.xsd}id ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3832713679</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command returns error when object does not exist  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>no-contact</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Object does not exist</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:id>NO-CONTACT</obj:id>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8022802814</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command return info about contact  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIXED:INFO-4444</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:infData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIXED:INFO-4444</contact:id>
        <contact:roid>EIS-30</contact:roid>
        <contact:status s="ok"/>
        <contact:postalInfo type="int">
          <contact:name>Johnny Awesome</contact:name>
          <contact:addr>
            <contact:street>Short street 11</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:sp/>
            <contact:pc>11111</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.12345678</contact:voice>
        <contact:email>jerod@monahan.name</contact:email>
        <contact:clID>fixed registrar</contact:clID>
        <contact:crID>TEST-CREATOR</contact:crID>
        <contact:crDate>2015-09-09T09:40:57Z</contact:crDate>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:infData>
    </resData>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
      </eis:extdata>
    </extension>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3973009107</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command should add legacy CID format as append  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIXED:CID:FIXED:INFO-5555</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:infData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIXED:CID:FIXED:INFO-5555</contact:id>
        <contact:roid>EIS-31</contact:roid>
        <contact:status s="ok"/>
        <contact:postalInfo type="int">
          <contact:name>Johnny Awesome</contact:name>
          <contact:addr>
            <contact:street>Short street 11</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:sp/>
            <contact:pc>11111</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.12345678</contact:voice>
        <contact:email>jerod@monahan.name</contact:email>
        <contact:clID>fixed registrar</contact:clID>
        <contact:crID>TEST-CREATOR</contact:crID>
        <contact:crDate>2015-09-09T09:40:57Z</contact:crDate>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:infData>
    </resData>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
      </eis:extdata>
    </extension>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5286311125</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command should return ident in extension  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:INFO-IDENT</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:infData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:INFO-IDENT</contact:id>
        <contact:roid>EIS-32</contact:roid>
        <contact:status s="ok"/>
        <contact:postalInfo type="int">
          <contact:name>Johnny Awesome</contact:name>
          <contact:addr>
            <contact:street>Short street 11</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:sp/>
            <contact:pc>11111</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.12345678</contact:voice>
        <contact:email>jerod@monahan.name</contact:email>
        <contact:clID>registrar1</contact:clID>
        <contact:crID>TEST-CREATOR</contact:crID>
        <contact:crDate>2015-09-09T09:40:57Z</contact:crDate>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:infData>
    </resData>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
      </eis:extdata>
    </extension>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2715010887</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command returns no authorization error for wrong password when registrant  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH146764510</contact:id>
        <contact:authInfo>
          <contact:pw>wrong-pw</contact:pw>
        </contact:authInfo>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:infData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH146764510</contact:id>
        <contact:roid>EIS-1</contact:roid>
        <contact:status s="ok"/>
        <contact:postalInfo type="int">
          <contact:name>Jeffrey Grant0</contact:name>
          <contact:addr>
            <contact:street>Short street 11</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:sp/>
            <contact:pc>11111</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.12345678</contact:voice>
        <contact:email>jerod@monahan.name</contact:email>
        <contact:clID>registrar1</contact:clID>
        <contact:crID>TEST-CREATOR</contact:crID>
        <contact:crDate>2015-09-09T09:40:28Z</contact:crDate>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:infData>
    </resData>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
      </eis:extdata>
    </extension>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8292511662</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command should honor new contact code format  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIXED:TEST:CUSTOM:CODE</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:infData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIXED:TEST:CUSTOM:CODE</contact:id>
        <contact:roid>EIS-33</contact:roid>
        <contact:status s="ok"/>
        <contact:postalInfo type="int">
          <contact:name>Faustino Kiehn Sr.15</contact:name>
          <contact:addr>
            <contact:street>Short street 11</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:sp/>
            <contact:pc>11111</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.12345678</contact:voice>
        <contact:email>jerod@monahan.name</contact:email>
        <contact:clID>fixed registrar</contact:clID>
        <contact:crID>TEST-CREATOR</contact:crID>
        <contact:crDate>2015-09-09T09:40:57Z</contact:crDate>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:infData>
    </resData>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
      </eis:extdata>
    </extension>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2742211564</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command returns no authorization error for wrong user but correct password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5339607923</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH146764510</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:infData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH146764510</contact:id>
        <contact:roid>EIS-1</contact:roid>
        <contact:status s="ok"/>
        <contact:postalInfo type="int">
          <contact:name>Jeffrey Grant0</contact:name>
          <contact:addr>
            <contact:street>Short street 11</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:sp/>
            <contact:pc>11111</contact:pc>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.12345678</contact:voice>
        <contact:email>jerod@monahan.name</contact:email>
        <contact:clID>registrar1</contact:clID>
        <contact:crID>TEST-CREATOR</contact:crID>
        <contact:crDate>2015-09-09T09:40:28Z</contact:crDate>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:infData>
    </resData>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:ident type="priv" cc="EE">37605030299</eis:ident>
      </eis:extdata>
    </extension>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4555418710</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7907175242</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command returns authorization error for wrong user and wrong password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7050713206</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH146764510</contact:id>
        <contact:authInfo>
          <contact:pw>wrong-pw</contact:pw>
        </contact:authInfo>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3204958197</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1892508078</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command returns no authorization error for wrong user and no password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3785317019</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH146764510</contact:id>
        <contact:authInfo>
          <contact:pw/>
        </contact:authInfo>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <contact:infData xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd">
        <contact:id>FIRST0:SH146764510</contact:id>
        <contact:roid>EIS-1</contact:roid>
        <contact:status s="ok"/>
        <contact:postalInfo type="int">
          <contact:name>Jeffrey Grant0</contact:name>
        </contact:postalInfo>
        <contact:clID>registrar1</contact:clID>
        <contact:crID>TEST-CREATOR</contact:crID>
        <contact:crDate>2015-09-09T09:40:28Z</contact:crDate>
      </contact:infData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3241486821</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7490542266</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6673928791</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain should return error if balance low  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example32394753088423663.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2104">
      <msg lang="en">Billing failure - credit balance low</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4631997903</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain returns error if contact does not exists  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example63142357207051675.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:CITIZEN_1234</domain:contact>
        <domain:contact type="tech">sh1111</domain:contact>
        <domain:contact type="tech">sh2222</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:contact>sh1111</obj:contact>
      </value>
    </result>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:contact>sh2222</obj:contact>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7654601624</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain validates required parameters  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>test.ee</domain:name>
      </domain:create>
    </create>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; ns [ns]</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; registrant [registrant]</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; ns &gt; hostAttr [host_attr]</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: extension &gt; extdata &gt; legalDocument [legal_document]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9189535106</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example1689235482901404.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:creData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example1689235482901404.ee</domain:name>
        <domain:crDate>2015-09-09T09:41:01Z</domain:crDate>
        <domain:exDate>2016-09-09T09:41:01Z</domain:exDate>
      </domain:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3255346228</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain with legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example72027123606093573.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:creData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example72027123606093573.ee</domain:name>
        <domain:crDate>2015-09-09T09:41:02Z</domain:crDate>
        <domain:exDate>2016-09-09T09:41:02Z</domain:exDate>
      </domain:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3043773295</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain with custom auth info  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example96684879878217632.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
        <domain:authInfo>
          <domain:pw>asdasd</domain:pw>
        </domain:authInfo>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:creData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example96684879878217632.ee</domain:name>
        <domain:crDate>2015-09-09T09:41:02Z</domain:crDate>
        <domain:exDate>2016-09-09T09:41:02Z</domain:exDate>
      </domain:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0073549975</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant validates nameserver ipv4 when in same zone as domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example45910644144337606.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example45910644144337606.ee</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example45910644144337606.ee</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">IPv4 is missing [ipv4]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5586399806</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create domain longer than 63 punicode characters  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>äääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääää.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Domain name is too long (maximum is 63 characters) [puny_label]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9162320725</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create reserved domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>1162.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing; reserved&gt;pw element required for reserved domains</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0860231877</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>1162.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
        <eis:reserved>
          <eis:pw>wrong_pw</eis:pw>
        </eis:reserved>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2202">
      <msg lang="en">Invalid authorization information; invalid reserved&gt;pw value</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8149655863</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a reserved domain with correct auth info  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>1162.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
        <eis:reserved>
          <eis:pw>abc</eis:pw>
        </eis:reserved>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:creData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>1162.ee</domain:name>
        <domain:crDate>2015-09-09T09:41:06Z</domain:crDate>
        <domain:exDate>2016-09-09T09:41:06Z</domain:exDate>
      </domain:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4813370613</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create blocked domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>ftp.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2308">
      <msg lang="en">Data management policy violation: Domain name is blocked [name]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:name>ftp.ee</obj:name>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4786758523</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create domain without contacts and registrant  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example86925094014004001.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; registrant [registrant]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5177530285</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create domain without nameservers  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example63977486611499251.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; ns [ns]</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; ns &gt; hostAttr [host_attr]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2610611681</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create domain with too many nameservers  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example86507962690441139.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns0.example.net</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns3.example.net</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns4.example.net</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns5.example.net</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns6.example.net</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns7.example.net</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns8.example.net</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns9.example.net</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns10.example.net</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns11.example.net</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns12.example.net</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns13.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">Nameservers count must be between 2-11 [nameservers]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4995605429</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant returns error when invalid nameservers are present  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example19609682814519922.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>invalid1-</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>-invalid2</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Hostname is invalid [hostname]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:hostAttr>invalid1-</obj:hostAttr>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Hostname is invalid [hostname]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:hostAttr>-invalid2</obj:hostAttr>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6098198030</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant checks hostAttr presence  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example72458770500119079.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostObj>ns1.example.ee</domain:hostObj>
          <domain:hostObj>ns2.example.ee</domain:hostObj>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; ns &gt; hostAttr [host_attr]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7334614041</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates domain with nameservers with ips  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example31353413112314524.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:creData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example31353413112314524.ee</domain:name>
        <domain:crDate>2015-09-09T09:41:13Z</domain:crDate>
        <domain:exDate>2016-09-09T09:41:13Z</domain:exDate>
      </domain:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4674113477</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant returns error when nameserver has invalid ips  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example5402226134684202.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2.invalid</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
            <domain:hostAddr ip="v6">invalid_ipv6</domain:hostAddr>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">IPv4 is invalid [ipv4]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:hostAddr>192.0.2.2.invalid</obj:hostAddr>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">IPv6 is invalid [ipv6]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:hostAddr>INVALID_IPV6</obj:hostAddr>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8298366234</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain with period in days  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example21033998568612387.ee</domain:name>
        <domain:period unit="d">365</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:creData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example21033998568612387.ee</domain:name>
        <domain:crDate>2015-09-09T09:41:14Z</domain:crDate>
        <domain:exDate>2016-09-09T09:41:14Z</domain:exDate>
      </domain:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1708461985</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain with longer periods  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example14768162587822699.ee</domain:name>
        <domain:period unit="y">2</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:creData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example14768162587822699.ee</domain:name>
        <domain:crDate>2015-09-09T09:41:14Z</domain:crDate>
        <domain:exDate>2017-09-09T09:41:14Z</domain:exDate>
      </domain:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3258212733</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain with longer periods  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example61003665883943636.ee</domain:name>
        <domain:period unit="m">36</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:creData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example61003665883943636.ee</domain:name>
        <domain:crDate>2015-09-09T09:41:15Z</domain:crDate>
        <domain:exDate>2018-09-09T09:41:15Z</domain:exDate>
      </domain:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5642259320</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain without period  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example58414536116868691.ee</domain:name>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:creData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example58414536116868691.ee</domain:name>
        <domain:crDate>2015-09-09T09:41:15Z</domain:crDate>
        <domain:exDate>2016-09-09T09:41:15Z</domain:exDate>
      </domain:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2981760947</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create a domain with invalid period  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example81669530628884297.ee</domain:name>
        <domain:period unit="d">367</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Period must add up to 1, 2 or 3 years [period]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:period>367</obj:period>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2538984079</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create a domain with invalid period unit  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example31154705462486343.ee</domain:name>
        <domain:period unit="">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': [facet 'enumeration'] The value '' is not an element of the set {'y', 'm', 'd'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': '' is not a valid value of the atomic type '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}pUnitType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7922608658</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example18093312080283547.ee</domain:name>
        <domain:period unit="bla">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': [facet 'enumeration'] The value 'bla' is not an element of the set {'y', 'm', 'd'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': 'bla' is not a valid value of the atomic type '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}pUnitType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3944282239</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain with multiple dnskeys  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example96784698546357615.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>3</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
        <secDNS:keyData>
          <secDNS:flags>0</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
        </secDNS:keyData>
        <secDNS:keyData>
          <secDNS:flags>256</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>254</secDNS:alg>
          <secDNS:pubKey>841936717ae427ace63c28d04918569a841936717ae427ace63c28d0</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:creData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example96784698546357615.ee</domain:name>
        <domain:crDate>2015-09-09T09:41:18Z</domain:crDate>
        <domain:exDate>2016-09-09T09:41:18Z</domain:exDate>
      </domain:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8784557440</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create a domain when dnskeys are invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example38612160126016755.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>250</secDNS:flags>
          <secDNS:protocol>4</secDNS:protocol>
          <secDNS:alg>9</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
        <secDNS:keyData>
          <secDNS:flags>1</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>10</secDNS:alg>
          <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
        </secDNS:keyData>
        <secDNS:keyData>
          <secDNS:flags>256</secDNS:flags>
          <secDNS:protocol>5</secDNS:protocol>
          <secDNS:alg>254</secDNS:alg>
          <secDNS:pubKey/>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{urn:ietf:params:xml:ns:secDNS-1.1}pubKey': [facet 'minLength'] The value has a length of '0'; this underruns the allowed minimum length of '1'.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{urn:ietf:params:xml:ns:secDNS-1.1}pubKey': '' is not a valid value of the atomic type '{urn:ietf:params:xml:ns:secDNS-1.1}keyType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9401570081</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example95030742988639556.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>250</secDNS:flags>
          <secDNS:protocol>4</secDNS:protocol>
          <secDNS:alg>9</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
        <secDNS:keyData>
          <secDNS:flags>1</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>10</secDNS:alg>
          <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
        </secDNS:keyData>
        <secDNS:keyData>
          <secDNS:flags>256</secDNS:flags>
          <secDNS:protocol>5</secDNS:protocol>
          <secDNS:alg>254</secDNS:alg>
          <secDNS:pubKey>AwEAAbuFiHS4jZL7ZQKvEPBmsbceNHTVYpEVMdxz2A6YCjlZTEoAH3qK</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Valid algorithms are: 3, 5, 6, 7, 8, 252, 253, 254, 255 [alg]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:alg>9</obj:alg>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid protocols are: 3 [protocol]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:protocol>4</obj:protocol>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid flags are: 0, 256, 257 [flags]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:flags>250</obj:flags>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid algorithms are: 3, 5, 6, 7, 8, 252, 253, 254, 255 [alg]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:alg>10</obj:alg>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid flags are: 0, 256, 257 [flags]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:flags>1</obj:flags>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid protocols are: 3 [protocol]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:protocol>5</obj:protocol>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8923945468</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create a domain with two identical dnskeys  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example83981486968220519.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>3</secDNS:alg>
          <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
        </secDNS:keyData>
        <secDNS:keyData>
          <secDNS:flags>0</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2302">
      <msg lang="en">Public key already exists [public_key]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</obj:pubKey>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2492711305</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant validated dnskeys count  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example59256456902214771.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>3</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
        <secDNS:keyData>
          <secDNS:flags>0</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">DNS keys count must be between 0-1 [dnskeys]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2006759511</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates domain with ds data  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example82964748602082529.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:dsData>
          <secDNS:keyTag>12345</secDNS:keyTag>
          <secDNS:alg>3</secDNS:alg>
          <secDNS:digestType>1</secDNS:digestType>
          <secDNS:digest>49FD46E6C4B45C55D4AC</secDNS:digest>
        </secDNS:dsData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:creData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example82964748602082529.ee</domain:name>
        <domain:crDate>2015-09-09T09:41:23Z</domain:crDate>
        <domain:exDate>2016-09-09T09:41:23Z</domain:exDate>
      </domain:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6319561515</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates domain with ds data with key  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example2506953435883800.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:dsData>
          <secDNS:keyTag>12345</secDNS:keyTag>
          <secDNS:alg>3</secDNS:alg>
          <secDNS:digestType>1</secDNS:digestType>
          <secDNS:digest>49FD46E6C4B45C55D4AC</secDNS:digest>
          <secDNS:keyData>
            <secDNS:flags>0</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>5</secDNS:alg>
            <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:dsData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:creData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example2506953435883800.ee</domain:name>
        <domain:crDate>2015-09-09T09:41:23Z</domain:crDate>
        <domain:exDate>2016-09-09T09:41:23Z</domain:exDate>
      </domain:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0568896775</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant prohibits dsData  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example56190705875115023.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:dsData>
          <secDNS:keyTag>12345</secDNS:keyTag>
          <secDNS:alg>3</secDNS:alg>
          <secDNS:digestType>1</secDNS:digestType>
          <secDNS:digest>49FD46E6C4B45C55D4AC</secDNS:digest>
          <secDNS:keyData>
            <secDNS:flags>0</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>5</secDNS:alg>
            <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:dsData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">dsData object is not allowed</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7605522992</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant prohibits keyData  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example89080816292222405.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>0</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">keyData object is not allowed</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4787538812</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant prohibits dsData and keyData when they exists together  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example21199712387956820.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
        <domain:contact type="tech">FIXED:SH801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:dsData>
          <secDNS:keyTag>12345</secDNS:keyTag>
          <secDNS:alg>3</secDNS:alg>
          <secDNS:digestType>1</secDNS:digestType>
          <secDNS:digest>49FD46E6C4B45C55D4AC</secDNS:digest>
        </secDNS:dsData>
        <secDNS:keyData>
          <secDNS:flags>0</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{urn:ietf:params:xml:ns:secDNS-1.1}keyData': This element is not expected. Expected is ( {urn:ietf:params:xml:ns:secDNS-1.1}dsData ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3955018411</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with juridical persion as a registrant creates a domain with contacts  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example93046670137508351.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:JURIDICAL_1234</domain:registrant>
        <domain:contact type="admin">FIXED:SH8013</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:creData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example93046670137508351.ee</domain:name>
        <domain:crDate>2015-09-09T09:41:27Z</domain:crDate>
        <domain:exDate>2016-09-09T09:41:27Z</domain:exDate>
      </domain:creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0734653871</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with juridical persion as a registrant does not create a domain without admin contact  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example94787272642380605.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:JURIDICAL_1234</domain:registrant>
        <domain:contact type="tech">FIXED:SH8013</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">Admin contacts count must be between 1-10 [admin_domain_contacts]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1085195815</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with juridical persion as a registrant cannot assign juridical person as admin contact  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example23419345140335240.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.net</domain:hostName>
            <domain:hostAddr ip="v4">192.0.2.2</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.net</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>FIXED:JURIDICAL_1234</domain:registrant>
        <domain:contact type="admin">FIXED:JURIDICAL_1234</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>5</secDNS:alg>
          <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Admin contact can be private person only</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:contact>FIXED:JURIDICAL_1234</obj:contact>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0810446547</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7828185295</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain1.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain1.ee</domain:name>
        <domain:trStatus>serverApproved</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:29Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:29Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:29Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2148927658</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1593572039</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="req"/>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="1" id="1">
      <qDate>2015-09-09T09:41:29Z</qDate>
      <msg>Domain transfer was approved, associated contacts were: ["FIXED:SH2663701812", "FIXED:SH3175529913"] and registrant was FIXED:REGISTRANT913878660</msg>
    </msgQ>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain1.ee</domain:name>
        <domain:trStatus>serverApproved</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:29Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:29Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:29Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1639019345</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="ack" msgID="1"/>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="0" id="1"/>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1963831601</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain creates a domain transfer with legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0802274548</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain2.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain2.ee</domain:name>
        <domain:trStatus>serverApproved</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:30Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:30Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:29Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2688296103</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3304754829</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2313222824</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain2.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5420487215</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4095542898</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain creates transfer successfully without legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7912829461</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain3.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain3.ee</domain:name>
        <domain:trStatus>serverApproved</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:30Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:30Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:30Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3728181402</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3347588130</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers domain with contacts  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2096902160</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain4.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain4.ee</domain:name>
        <domain:trStatus>serverApproved</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:30Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:30Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:30Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0003363953</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4205813478</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers domain when registrant has more domains  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0906683422</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain5.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain5.ee</domain:name>
        <domain:trStatus>serverApproved</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:31Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:31Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:31Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6110058927</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2774972327</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers domain when registrant is admin or tech contact on some other domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5864783350</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain8.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain8.ee</domain:name>
        <domain:trStatus>serverApproved</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:31Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:31Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:31Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9391063829</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7240137168</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers domain when domain contacts are some other domain contacts  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5504727594</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain9.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain9.ee</domain:name>
        <domain:trStatus>serverApproved</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:32Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:32Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:32Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5448155887</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7456902810</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers domain when multiple domain contacts are some other domain contacts  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3348741723</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain11.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain11.ee</domain:name>
        <domain:trStatus>serverApproved</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:33Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:33Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:32Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5417834733</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9273023652</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers domain and references exsisting registrant to domain contacts  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7189930594</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain14.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain14.ee</domain:name>
        <domain:trStatus>serverApproved</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:33Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:33Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:33Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2306111033</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7319981634</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not transfer contacts if they are already under new registrar  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1377196507</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain15.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain15.ee</domain:name>
        <domain:trStatus>serverApproved</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:34Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:34Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:33Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4364063971</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0107899416</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not creates transfer without password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3278294268</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain16.ee</domain:name>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5086055350</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7046842396</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain approves the transfer request  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="approve">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain17.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain17.ee</domain:name>
        <domain:trStatus>clientApproved</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:34Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:34Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:34Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6090313843</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain rejects a domain transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9064662881</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="reject">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain18.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Transfer can be rejected only by current registrar</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6649488054</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6427589575</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="reject">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain18.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain18.ee</domain:name>
        <domain:trStatus>clientRejected</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:34Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:34Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:34Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7970427120</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain prohibits wrong registrar from approving transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5059016132</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="approve">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain19.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Transfer can be approved only by current domain registrar</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3020143274</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9653977873</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not transfer with invalid pw  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain20.ee</domain:name>
        <domain:authInfo>
          <domain:pw>test</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7942946624</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain ignores transfer when domain already belongs to registrar  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain21.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2002">
      <msg lang="en">Domain already belongs to the querying registrar</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7203880679</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain returns an error for incorrect op attribute  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="bla">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example56971068434133908.ee</domain:name>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/epp-ee-1.0.xsd}transfer', attribute 'op': [facet 'enumeration'] The value 'bla' is not an element of the set {'approve', 'cancel', 'query', 'reject', 'request'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/epp-ee-1.0.xsd}transfer', attribute 'op': 'bla' is not a valid value of the atomic type '{https://epp.tld.ee/schema/epp-ee-1.0.xsd}transferOpType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7656417770</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain creates new pw after successful transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2062686029</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain22.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:trnData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain22.ee</domain:name>
        <domain:trStatus>serverApproved</domain:trStatus>
        <domain:reID>REGDOMAIN2</domain:reID>
        <domain:reDate>2015-09-09T09:41:39Z</domain:reDate>
        <domain:acID>REGDOMAIN1</domain:acID>
        <domain:acDate>2015-09-09T09:41:39Z</domain:acDate>
        <domain:exDate>2016-09-09T09:41:39Z</domain:exDate>
      </domain:trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0905740213</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain22.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3957714553</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8977429934</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should get an error when there is no pending transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="approve">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain23.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">No transfers found</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8643991398</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not return transfers when there are none  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain24.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">No transfers found</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7715690534</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not cancel transfer when there are none  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="cancel">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain25.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">No transfers found</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3882289733</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not transfer when period element is present  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7490394774</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain26.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2307">
      <msg lang="en">Unimplemented object service</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:period/>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7566671378</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0290654375</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should update right away without update pending status  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain27.ee</domain:name>
        <domain:chg>
          <domain:registrant verified="yes">FIXED:CITIZEN_1234</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4097523911</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain updates a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain28.ee</domain:name>
        <domain:chg>
          <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1001">
      <msg>Command completed successfully; action pending</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7215329159</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain updates a domain and changes auth info  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain29.ee</domain:name>
        <domain:chg>
          <domain:authInfo>
            <domain:pw>newpw</domain:pw>
          </domain:authInfo>
        </domain:chg>
      </domain:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5676404407</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not return action pending when changes are invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain30.ee</domain:name>
        <domain:rem>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns.pfefferjakubowski90.ee</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns.macejkovic91.ee</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns.heidenreichreinger92.ee</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
        </domain:rem>
        <domain:chg>
          <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">Nameservers count must be between 2-11 [nameservers]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1427470422</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not return action pending when domain itself is already invaid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain31.ee</domain:name>
        <domain:chg>
          <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">Nameservers count must be between 2-11 [nameservers]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4190497795</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not allow any update when status pending update  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain32.ee</domain:name>
        <domain:chg>
          <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Object status prohibits operation</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2937127567</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not allow any update when status force delete  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain33.ee</domain:name>
        <domain:chg>
          <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Object status prohibits operation</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9675691845</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain updates domain and adds objects  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain34.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns2.example.com</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="tech">FIXED:MAK21</domain:contact>
          <domain:status s="clientHold" lang="en">Payment overdue.</domain:status>
          <domain:status s="clientUpdateProhibited"/>
        </domain:add>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:add>
          <secDNS:keyData>
            <secDNS:flags>0</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>5</secDNS:alg>
            <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
          </secDNS:keyData>
          <secDNS:keyData>
            <secDNS:flags>256</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>254</secDNS:alg>
            <secDNS:pubKey>841936717ae427ace63c28d04918569a841936717ae427ace63c28d0</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:add>
      </secDNS:update>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:contact>FIXED:MAK21</obj:contact>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0185819788</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain34.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns2.example.com</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="tech">FIXED:MAK21</domain:contact>
          <domain:status s="clientHold" lang="en">Payment overdue.</domain:status>
          <domain:status s="clientUpdateProhibited"/>
        </domain:add>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:add>
          <secDNS:keyData>
            <secDNS:flags>0</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>5</secDNS:alg>
            <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
          </secDNS:keyData>
          <secDNS:keyData>
            <secDNS:flags>256</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>254</secDNS:alg>
            <secDNS:pubKey>841936717ae427ace63c28d04918569a841936717ae427ace63c28d0</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:add>
      </secDNS:update>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7339654125</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain34.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns2.example.com</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="tech">FIXED:MAK21</domain:contact>
          <domain:status s="clientHold" lang="en">Payment overdue.</domain:status>
          <domain:status s="clientUpdateProhibited"/>
        </domain:add>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:add>
          <secDNS:keyData>
            <secDNS:flags>0</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>5</secDNS:alg>
            <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
          </secDNS:keyData>
          <secDNS:keyData>
            <secDNS:flags>256</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>254</secDNS:alg>
            <secDNS:pubKey>841936717ae427ace63c28d04918569a841936717ae427ace63c28d0</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:add>
      </secDNS:update>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2302">
      <msg lang="en">Nameserver already exists on this domain [hostname]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:hostAttr>ns1.example.com</obj:hostAttr>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Nameserver already exists on this domain [hostname]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:hostAttr>ns2.example.com</obj:hostAttr>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Contact already exists on this domain [contact_code_cache]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:contact>FIXED:MAK21</obj:contact>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Public key already exists [public_key]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</obj:pubKey>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Public key already exists [public_key]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:pubKey>841936717ae427ace63c28d04918569a841936717ae427ace63c28d0</obj:pubKey>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6624778799</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain updates domain with registrant change what triggers action pending  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain35.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns2.example.com</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="tech">FIXED:PENDINGMAK21</domain:contact>
          <domain:status s="clientHold" lang="en">Payment overdue.</domain:status>
          <domain:status s="clientUpdateProhibited"/>
        </domain:add>
        <domain:chg>
          <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:add>
          <secDNS:keyData>
            <secDNS:flags>0</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>5</secDNS:alg>
            <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
          </secDNS:keyData>
          <secDNS:keyData>
            <secDNS:flags>256</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>254</secDNS:alg>
            <secDNS:pubKey>841936717ae427ace63c28d04918569a841936717ae427ace63c28d0</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:add>
      </secDNS:update>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:contact>FIXED:PENDINGMAK21</obj:contact>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7793699132</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain35.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns2.example.com</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="tech">FIXED:PENDINGMAK21</domain:contact>
          <domain:status s="clientHold" lang="en">Payment overdue.</domain:status>
          <domain:status s="clientUpdateProhibited"/>
        </domain:add>
        <domain:chg>
          <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:add>
          <secDNS:keyData>
            <secDNS:flags>0</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>5</secDNS:alg>
            <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
          </secDNS:keyData>
          <secDNS:keyData>
            <secDNS:flags>256</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>254</secDNS:alg>
            <secDNS:pubKey>841936717ae427ace63c28d04918569a841936717ae427ace63c28d0</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:add>
      </secDNS:update>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1001">
      <msg>Command completed successfully; action pending</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6220298652</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not allow to edit statuses if policy forbids it  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain36.ee</domain:name>
        <domain:add>
          <domain:status s="clientHold" lang="en">Payment overdue.</domain:status>
          <domain:status s="clientUpdateProhibited"/>
        </domain:add>
      </domain:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Client-side object status management not supported: status [status]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3812706227</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain updates a domain and removes objects  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain37.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns2.example.com</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="tech">FIXED:CITIZEN_1234</domain:contact>
          <domain:status s="clientHold" lang="en">Payment overdue.</domain:status>
          <domain:status s="clientUpdateProhibited"/>
        </domain:add>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:add>
          <secDNS:keyData>
            <secDNS:flags>0</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>5</secDNS:alg>
            <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
          </secDNS:keyData>
          <secDNS:keyData>
            <secDNS:flags>256</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>254</secDNS:alg>
            <secDNS:pubKey>841936717ae427ace63c28d04918569a841936717ae427ace63c28d0</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:add>
      </secDNS:update>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4574619186</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain37.ee</domain:name>
        <domain:rem>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="tech">FIXED:CITIZEN_1234</domain:contact>
          <domain:status s="clientHold"/>
        </domain:rem>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:rem>
          <secDNS:keyData>
            <secDNS:flags>256</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>254</secDNS:alg>
            <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:rem>
      </secDNS:update>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4514059388</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain37.ee</domain:name>
        <domain:rem>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="tech">FIXED:CITIZEN_1234</domain:contact>
          <domain:status s="clientHold"/>
        </domain:rem>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:rem>
          <secDNS:keyData>
            <secDNS:flags>256</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>254</secDNS:alg>
            <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:rem>
      </secDNS:update>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Nameserver was not found</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:hostAttr>ns1.example.com</obj:hostAttr>
      </value>
    </result>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:contact>FIXED:CITIZEN_1234</obj:contact>
      </value>
    </result>
    <result code="2303">
      <msg lang="en">DS was not found</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:publicKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</obj:publicKey>
      </value>
    </result>
    <result code="2303">
      <msg lang="en">Status was not found</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:status>clientHold</obj:status>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1771470931</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not remove server statuses  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain38.ee</domain:name>
        <domain:rem>
          <domain:status s="serverHold"/>
        </domain:rem>
      </domain:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Status was not found</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:status>serverHold</obj:status>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3286599813</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not add duplicate objects to domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain39.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns.kozey114.ee</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="admin">FIXED:SH6021836789</domain:contact>
        </domain:add>
      </domain:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2765884157</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain39.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns.kozey114.ee</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="admin">FIXED:SH6021836789</domain:contact>
        </domain:add>
      </domain:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2302">
      <msg lang="en">Nameserver already exists on this domain [hostname]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:hostAttr>ns.kozey114.ee</obj:hostAttr>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Contact already exists on this domain [contact_code_cache]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:contact>FIXED:SH6021836789</obj:contact>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4475356063</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain cannot change registrant without legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain40.ee</domain:name>
        <domain:chg>
          <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: extension &gt; extdata &gt; legalDocument [legal_document]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8215552740</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not assign invalid status to domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain41.ee</domain:name>
        <domain:add>
          <domain:status s="invalidStatus"/>
        </domain:add>
      </domain:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}status', attribute 's': [facet 'enumeration'] The value 'invalidStatus' is not an element of the set {'clientDeleteProhibited', 'clientHold', 'clientRenewProhibited', 'clientTransferProhibited', 'clientUpdateProhibited', 'inactive', 'ok', 'pendingCreate', 'pendingDelete', 'pendingRenew', 'pendingTransfer', 'pendingUpdate', 'serverDeleteProhibited', 'serverHold', 'serverRenewProhibited', 'serverTransferProhibited', 'serverUpdateProhibited'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}status', attribute 's': 'invalidStatus' is not a valid value of the atomic type '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}statusValueType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7409966421</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain renews a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain42.ee</domain:name>
        <domain:curExpDate>2016-09-09</domain:curExpDate>
        <domain:period unit="y">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:renData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain42.ee</domain:name>
        <domain:exDate>2017-09-09T09:42:01Z</domain:exDate>
      </domain:renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2085073741</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain renews a domain when outzone_at or delete_date is nil for some reason  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain43.ee</domain:name>
        <domain:curExpDate>2016-09-09</domain:curExpDate>
        <domain:period unit="y">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:renData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain43.ee</domain:name>
        <domain:exDate>2017-09-09T09:42:01Z</domain:exDate>
      </domain:renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9655723066</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain renews a domain with no period specified  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain44.ee</domain:name>
        <domain:curExpDate>2016-09-09</domain:curExpDate>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:renData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain44.ee</domain:name>
        <domain:exDate>2017-09-09T09:42:01Z</domain:exDate>
      </domain:renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0687111218</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not renew domain with invalid period  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain45.ee</domain:name>
        <domain:curExpDate>2016-09-09</domain:curExpDate>
        <domain:period unit="">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': [facet 'enumeration'] The value '' is not an element of the set {'y', 'm', 'd'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': '' is not a valid value of the atomic type '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}pUnitType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4517707284</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain45.ee</domain:name>
        <domain:curExpDate>2016-09-09</domain:curExpDate>
        <domain:period unit="bla">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': [facet 'enumeration'] The value 'bla' is not an element of the set {'y', 'm', 'd'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': 'bla' is not a valid value of the atomic type '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}pUnitType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3485118472</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain renews a domain with 2 year period  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain46.ee</domain:name>
        <domain:curExpDate>2015-09-19</domain:curExpDate>
        <domain:period unit="d">730</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:renData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain46.ee</domain:name>
        <domain:exDate>2017-09-19T00:00:00Z</domain:exDate>
      </domain:renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2991421626</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain renews a domain with 3 year period  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain47.ee</domain:name>
        <domain:curExpDate>2015-09-19</domain:curExpDate>
        <domain:period unit="m">36</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:renData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain47.ee</domain:name>
        <domain:exDate>2018-09-19T00:00:00Z</domain:exDate>
      </domain:renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2260618497</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not renew a domain if credit balance low  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain48.ee</domain:name>
        <domain:curExpDate>2015-09-19</domain:curExpDate>
        <domain:period unit="y">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2104">
      <msg lang="en">Billing failure - credit balance low</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2378800127</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain returns an error when given and current exp dates do not match  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain49.ee</domain:name>
        <domain:curExpDate>2200-08-07</domain:curExpDate>
        <domain:period unit="y">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Given and current expire dates do not match</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:curExpDate>2200-08-07</obj:curExpDate>
      </value>
    </result>
    <result code="2105">
      <msg lang="en">Object is not eligible for renewal</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2331121575</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain returns an error when period is invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain50.ee</domain:name>
        <domain:curExpDate>2015-09-19</domain:curExpDate>
        <domain:period unit="y">4</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Period must add up to 1, 2 or 3 years [period]</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:period>4</obj:period>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7726725318</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not renew a domain unless less than 90 days till expiration  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain51.ee</domain:name>
        <domain:curExpDate>2015-12-08</domain:curExpDate>
        <domain:period unit="y">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2105">
      <msg lang="en">Object is not eligible for renewal</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1580437190</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain51.ee</domain:name>
        <domain:curExpDate>2015-12-07</domain:curExpDate>
        <domain:period unit="y">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:renData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain51.ee</domain:name>
        <domain:exDate>2016-12-07T00:00:00Z</domain:exDate>
      </domain:renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9456899838</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not renew a domain unless less than 90 days till expiration  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain52.ee</domain:name>
        <domain:curExpDate>2020-09-09</domain:curExpDate>
        <domain:period unit="y">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:renData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain52.ee</domain:name>
        <domain:exDate>2021-09-09T00:00:00Z</domain:exDate>
      </domain:renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6592601006</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not renew a domain if it is a delete candidate  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain53.ee</domain:name>
        <domain:curExpDate>2015-09-19</domain:curExpDate>
        <domain:period unit="y">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2105">
      <msg lang="en">Object is not eligible for renewal</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8298739488</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should renew a expired domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain54.ee</domain:name>
        <domain:curExpDate>2015-06-11</domain:curExpDate>
        <domain:period unit="y">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:renData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain54.ee</domain:name>
        <domain:exDate>2016-06-11T09:42:11Z</domain:exDate>
      </domain:renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5393210682</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not renew foreign domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6492993618</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain55.ee</domain:name>
        <domain:curExpDate>2016-09-09</domain:curExpDate>
        <domain:period unit="y">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1510037210</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3468594377</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain returns domain info  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain56.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:infData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain56.ee</domain:name>
        <domain:roid>EIS-69</domain:roid>
        <domain:status s="clientHold"/>
        <domain:registrant>FIXED:REGISTRANT6384423854</domain:registrant>
        <domain:contact type="tech">FIXED:SH46786741126</domain:contact>
        <domain:contact type="admin">FIXED:SH96052327125</domain:contact>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns.westkeebler168.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns.wuckert169.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns.runolfssoneffertz170.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns1.example.com</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
        </domain:ns>
        <domain:clID>registrar1</domain:clID>
        <domain:crDate>2015-09-09T09:42:12Z</domain:crDate>
        <domain:upDate>2015-09-09T09:42:12Z</domain:upDate>
        <domain:exDate>2016-09-09T09:42:12Z</domain:exDate>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:infData>
    </resData>
    <extension>
      <secDNS:infData xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:dsData>
          <secDNS:keyTag>123</secDNS:keyTag>
          <secDNS:alg>3</secDNS:alg>
          <secDNS:digestType>1</secDNS:digestType>
          <secDNS:digest>0D85A305D22FCB355BBE29AE9809363D697B64782B9CC73AE349350F8C2AE4BB</secDNS:digest>
          <secDNS:keyData>
            <secDNS:flags>257</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>3</secDNS:alg>
            <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:dsData>
        <secDNS:dsData>
          <secDNS:keyTag>123</secDNS:keyTag>
          <secDNS:alg>3</secDNS:alg>
          <secDNS:digestType>1</secDNS:digestType>
          <secDNS:digest>0D85A305D22FCB355BBE29AE9809363D697B64782B9CC73AE349350F8C2AE4BB</secDNS:digest>
          <secDNS:keyData>
            <secDNS:flags>0</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>5</secDNS:alg>
            <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:dsData>
      </secDNS:infData>
    </extension>
    <trID>
      <svTRID>ccReg-6549661457</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain56.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:infData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain56.ee</domain:name>
        <domain:roid>EIS-69</domain:roid>
        <domain:status s="clientHold"/>
        <domain:registrant>FIXED:REGISTRANT6384423854</domain:registrant>
        <domain:contact type="tech">FIXED:SH46786741126</domain:contact>
        <domain:contact type="admin">FIXED:SH96052327125</domain:contact>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns.westkeebler168.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns.wuckert169.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns.runolfssoneffertz170.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns1.example.com</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
        </domain:ns>
        <domain:clID>registrar1</domain:clID>
        <domain:crDate>2015-09-09T09:42:12Z</domain:crDate>
        <domain:upDate>2015-09-09T09:42:12Z</domain:upDate>
        <domain:exDate>2016-09-09T09:42:12Z</domain:exDate>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:infData>
    </resData>
    <extension>
      <secDNS:infData xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:dsData>
          <secDNS:keyTag>123</secDNS:keyTag>
          <secDNS:alg>3</secDNS:alg>
          <secDNS:digestType>1</secDNS:digestType>
          <secDNS:digest>0D85A305D22FCB355BBE29AE9809363D697B64782B9CC73AE349350F8C2AE4BB</secDNS:digest>
          <secDNS:keyData>
            <secDNS:flags>257</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>3</secDNS:alg>
            <secDNS:pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:dsData>
        <secDNS:dsData>
          <secDNS:keyTag>123</secDNS:keyTag>
          <secDNS:alg>3</secDNS:alg>
          <secDNS:digestType>1</secDNS:digestType>
          <secDNS:digest>0D85A305D22FCB355BBE29AE9809363D697B64782B9CC73AE349350F8C2AE4BB</secDNS:digest>
          <secDNS:keyData>
            <secDNS:flags>0</secDNS:flags>
            <secDNS:protocol>3</secDNS:protocol>
            <secDNS:alg>5</secDNS:alg>
            <secDNS:pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</secDNS:pubKey>
          </secDNS:keyData>
        </secDNS:dsData>
      </secDNS:infData>
    </extension>
    <trID>
      <svTRID>ccReg-4432758472</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain returns domain info with different nameservers  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="invalid">domain57.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}name', attribute 'hosts': [facet 'enumeration'] The value 'invalid' is not an element of the set {'all', 'del', 'none', 'sub'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}name', attribute 'hosts': 'invalid' is not a valid value of the atomic type '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}hostsType'.</msg>
    </result>
    <trID>
      <svTRID>ccReg-5433100814</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="sub">domain57.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:infData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain57.ee</domain:name>
        <domain:roid>EIS-70</domain:roid>
        <domain:status s="ok"/>
        <domain:registrant>FIXED:REGISTRANT9404702555</domain:registrant>
        <domain:contact type="tech">FIXED:SH84523822128</domain:contact>
        <domain:contact type="admin">FIXED:SH79263720127</domain:contact>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.domain57.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.domain57.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
        </domain:ns>
        <domain:clID>registrar1</domain:clID>
        <domain:crDate>2015-09-09T09:42:12Z</domain:crDate>
        <domain:upDate>2015-09-09T09:42:12Z</domain:upDate>
        <domain:exDate>2016-09-09T09:42:12Z</domain:exDate>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:infData>
    </resData>
    <trID>
      <svTRID>ccReg-5642602408</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="del">domain57.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:infData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain57.ee</domain:name>
        <domain:roid>EIS-70</domain:roid>
        <domain:status s="ok"/>
        <domain:registrant>FIXED:REGISTRANT9404702555</domain:registrant>
        <domain:contact type="tech">FIXED:SH84523822128</domain:contact>
        <domain:contact type="admin">FIXED:SH79263720127</domain:contact>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns3.test.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
        </domain:ns>
        <domain:clID>registrar1</domain:clID>
        <domain:crDate>2015-09-09T09:42:12Z</domain:crDate>
        <domain:upDate>2015-09-09T09:42:12Z</domain:upDate>
        <domain:exDate>2016-09-09T09:42:12Z</domain:exDate>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:infData>
    </resData>
    <trID>
      <svTRID>ccReg-1091123968</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="none">domain57.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:infData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain57.ee</domain:name>
        <domain:roid>EIS-70</domain:roid>
        <domain:status s="ok"/>
        <domain:registrant>FIXED:REGISTRANT9404702555</domain:registrant>
        <domain:contact type="tech">FIXED:SH84523822128</domain:contact>
        <domain:contact type="admin">FIXED:SH79263720127</domain:contact>
        <domain:clID>registrar1</domain:clID>
        <domain:crDate>2015-09-09T09:42:12Z</domain:crDate>
        <domain:upDate>2015-09-09T09:42:12Z</domain:upDate>
        <domain:exDate>2016-09-09T09:42:12Z</domain:exDate>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:infData>
    </resData>
    <trID>
      <svTRID>ccReg-5911112065</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain57.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:infData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain57.ee</domain:name>
        <domain:roid>EIS-70</domain:roid>
        <domain:status s="ok"/>
        <domain:registrant>FIXED:REGISTRANT9404702555</domain:registrant>
        <domain:contact type="tech">FIXED:SH84523822128</domain:contact>
        <domain:contact type="admin">FIXED:SH79263720127</domain:contact>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.domain57.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.domain57.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns3.test.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
            <domain:hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</domain:hostAddr>
          </domain:hostAttr>
        </domain:ns>
        <domain:clID>registrar1</domain:clID>
        <domain:crDate>2015-09-09T09:42:12Z</domain:crDate>
        <domain:upDate>2015-09-09T09:42:12Z</domain:upDate>
        <domain:exDate>2016-09-09T09:42:12Z</domain:exDate>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:infData>
    </resData>
    <trID>
      <svTRID>ccReg-9733821997</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain returns error when domain can not be found  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="all">test.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Domain not found</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:name>test.ee</obj:name>
      </value>
    </result>
    <trID>
      <svTRID>ccReg-7990551453</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain sets ok status by default  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain58.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:infData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain58.ee</domain:name>
        <domain:roid>EIS-71</domain:roid>
        <domain:status s="ok"/>
        <domain:registrant>FIXED:REGISTRANT3372736156</domain:registrant>
        <domain:contact type="tech">FIXED:SH22502984130</domain:contact>
        <domain:contact type="admin">FIXED:SH51743282129</domain:contact>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns.hane174.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns.tillmanschaden175.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns.ricedavis176.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
        </domain:ns>
        <domain:clID>registrar1</domain:clID>
        <domain:crDate>2015-09-09T09:42:13Z</domain:crDate>
        <domain:upDate>2015-09-09T09:42:13Z</domain:upDate>
        <domain:exDate>2016-09-09T09:42:13Z</domain:exDate>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:infData>
    </resData>
    <trID>
      <svTRID>ccReg-4224767517</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain can not see other registrar domains with invalid password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0894415238</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain59.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <svTRID>ccReg-0013577792</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6389973625</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain can see other registrar domains without password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6296627194</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain60.ee</domain:name>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:infData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain60.ee</domain:name>
        <domain:roid>EIS-73</domain:roid>
        <domain:status s="ok"/>
        <domain:registrant>FIXED:REGISTRANT8140342958</domain:registrant>
        <domain:contact type="tech">FIXED:SH84714532134</domain:contact>
        <domain:contact type="admin">FIXED:SH28327865133</domain:contact>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns.oconnell180.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns.collins181.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns.anderson182.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
        </domain:ns>
        <domain:clID>registrar1</domain:clID>
        <domain:crDate>2015-09-09T09:42:14Z</domain:crDate>
        <domain:upDate>2015-09-09T09:42:14Z</domain:upDate>
        <domain:exDate>2016-09-09T09:42:14Z</domain:exDate>
      </domain:infData>
    </resData>
    <trID>
      <svTRID>ccReg-0987360848</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1582100184</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain can see other registrar domains with correct password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6970657375</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain61.ee</domain:name>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:infData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain61.ee</domain:name>
        <domain:roid>EIS-74</domain:roid>
        <domain:status s="ok"/>
        <domain:registrant>FIXED:REGISTRANT3123511659</domain:registrant>
        <domain:contact type="tech">FIXED:SH44485073136</domain:contact>
        <domain:contact type="admin">FIXED:SH23208613135</domain:contact>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns.streichschaden183.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns.koepp184.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns.schroeder185.ee</domain:hostName>
            <domain:hostAddr ip="v4">192.168.1.1</domain:hostAddr>
          </domain:hostAttr>
        </domain:ns>
        <domain:clID>registrar1</domain:clID>
        <domain:crDate>2015-09-09T09:42:14Z</domain:crDate>
        <domain:upDate>2015-09-09T09:42:14Z</domain:upDate>
        <domain:exDate>2016-09-09T09:42:14Z</domain:exDate>
        <domain:authInfo>
          <domain:pw>98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:infData>
    </resData>
    <trID>
      <svTRID>ccReg-3040601155</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1708627262</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain deletes domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <delete>
      <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain62.ee</domain:name>
      </domain:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1001">
      <msg>Command completed successfully; action pending</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7164707187</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not delete domain with specific status  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <delete>
      <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain63.ee</domain:name>
      </domain:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Domain status prohibits operation</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6465404485</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not delete domain with pending delete  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <delete>
      <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain64.ee</domain:name>
      </domain:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
        <eis:legalDocument type="pdf">dGVzdCBmYWlsCg==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Object status prohibits operation</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4137188567</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not delete domain without legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <delete>
      <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example.ee</domain:name>
      </domain:delete>
    </delete>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: extension &gt; extdata &gt; legalDocument [legal_document]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7682509679</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain checks a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <check>
      <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>one.ee</domain:name>
      </domain:check>
    </check>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:chkData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:cd>
          <domain:name avail="1">one.ee</domain:name>
        </domain:cd>
      </domain:chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6767925994</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <check>
      <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain65.ee</domain:name>
      </domain:check>
    </check>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:chkData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:cd>
          <domain:name avail="0">domain65.ee</domain:name>
          <domain:reason>in use</domain:reason>
        </domain:cd>
      </domain:chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7766188963</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain checks multiple domains  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <check>
      <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>one.ee</domain:name>
        <domain:name>two.ee</domain:name>
        <domain:name>three.ee</domain:name>
      </domain:check>
    </check>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:chkData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:cd>
          <domain:name avail="1">one.ee</domain:name>
        </domain:cd>
        <domain:cd>
          <domain:name avail="1">two.ee</domain:name>
        </domain:cd>
        <domain:cd>
          <domain:name avail="1">three.ee</domain:name>
        </domain:cd>
      </domain:chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6281873987</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain checks invalid format domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <check>
      <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>one.ee</domain:name>
        <domain:name>notcorrectdomain</domain:name>
      </domain:check>
    </check>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <domain:chkData xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:cd>
          <domain:name avail="1">one.ee</domain:name>
        </domain:cd>
        <domain:cd>
          <domain:name avail="0">notcorrectdomain</domain:name>
          <domain:reason>invalid format</domain:reason>
        </domain:cd>
      </domain:chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5742590382</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should show force delete in poll  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="req"/>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="12" id="13">
      <qDate>2015-09-09T09:42:18Z</qDate>
      <msg>Force delete set on domain domain66.ee</msg>
    </msgQ>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0363451933</svTRID>
    </trID>
  </response>
</epp>
```

### Unread notification of contact update

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="req"/>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="3" id="481605495">
      <qDate>2018-09-19T19:03:21Z</qDate>
      <msg>Contact has been updated</msg>
    </msgQ>
    <extension>
      <changePoll:changeData xmlns:changePoll="https://epp.tld.ee/schema/changePoll-1.0.xsd">
        <changePoll:operation>update</changePoll:operation>
        <changePoll:date>2010-07-04T21:00:00Z</changePoll:date>
        <changePoll:svTRID>146211577</changePoll:svTRID>
        <changePoll:who>Registrant User</changePoll:who>
      </changePoll:changeData>
    </extension>
    <trID>
      <svTRID>ccReg-0684472903</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Helper in context of Domain generates valid transfer xml  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0491810813</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7781552814</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Poll returns no messages in poll  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="req"/>
    <clTRID>1441791745</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1300">
      <msg>Command completed successfully; no messages</msg>
    </result>
    <trID>
      <clTRID>1441791745</clTRID>
      <svTRID>ccReg-8212875654</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Poll queues and dequeues messages  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8884357311</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="req"/>
    <clTRID>1441791746</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1300">
      <msg>Command completed successfully; no messages</msg>
    </result>
    <trID>
      <clTRID>1441791746</clTRID>
      <svTRID>ccReg-1493255460</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6949658588</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="req"/>
    <clTRID>1441791746</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="1" id="1">
      <qDate>2015-09-09T09:42:25Z</qDate>
      <msg>Balance low.</msg>
    </msgQ>
    <trID>
      <clTRID>1441791746</clTRID>
      <svTRID>ccReg-1206089571</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar2</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8514886962</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="ack" msgID="1"/>
    <clTRID>1441791746</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Message was not found</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:msgID>1</obj:msgID>
      </value>
    </result>
    <trID>
      <clTRID>1441791746</clTRID>
      <svTRID>ccReg-3076787365</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>registrar1</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0637667733</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="ack" msgID="1"/>
    <clTRID>1441791746</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="0" id="1"/>
    <trID>
      <clTRID>1441791746</clTRID>
      <svTRID>ccReg-0737936544</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="ack" msgID="1"/>
    <clTRID>1441791746</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Message was not found</msg>
      <value xmlns:obj="urn:ietf:params:xml:ns:obj">
        <obj:msgID>1</obj:msgID>
      </value>
    </result>
    <trID>
      <clTRID>1441791746</clTRID>
      <svTRID>ccReg-4827930582</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Poll returns an error on incorrect op  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="bla"/>
    <clTRID>1441791748</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/epp-ee-1.0.xsd}poll', attribute 'op': [facet 'enumeration'] The value 'bla' is not an element of the set {'ack', 'req'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/epp-ee-1.0.xsd}poll', attribute 'op': 'bla' is not a valid value of the atomic type '{https://epp.tld.ee/schema/epp-ee-1.0.xsd}pollOpType'.</msg>
    </result>
    <trID>
      <clTRID>1441791748</clTRID>
      <svTRID>ccReg-8258113541</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Poll dequeues multiple messages  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="req"/>
    <clTRID>1441791749</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="3" id="4">
      <qDate>2015-09-09T09:42:29Z</qDate>
      <msg>Smth else.</msg>
    </msgQ>
    <trID>
      <clTRID>1441791749</clTRID>
      <svTRID>ccReg-2302586651</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="ack" msgID="4"/>
    <clTRID>1441791749</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="2" id="4"/>
    <trID>
      <clTRID>1441791749</clTRID>
      <svTRID>ccReg-0388222381</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="req"/>
    <clTRID>1441791749</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="2" id="3">
      <qDate>2015-09-09T09:42:29Z</qDate>
      <msg>Something.</msg>
    </msgQ>
    <trID>
      <clTRID>1441791749</clTRID>
      <svTRID>ccReg-7292888765</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="ack" msgID="3"/>
    <clTRID>1441791749</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="1" id="3"/>
    <trID>
      <clTRID>1441791749</clTRID>
      <svTRID>ccReg-7674943096</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="req"/>
    <clTRID>1441791749</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="1" id="2">
      <qDate>2015-09-09T09:42:29Z</qDate>
      <msg>Balance low.</msg>
    </msgQ>
    <trID>
      <clTRID>1441791749</clTRID>
      <svTRID>ccReg-2284569476</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="ack" msgID="2"/>
    <clTRID>1441791749</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="0" id="2"/>
    <trID>
      <clTRID>1441791749</clTRID>
      <svTRID>ccReg-9304359918</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <poll op="req"/>
    <clTRID>1441791749</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1300">
      <msg>Command completed successfully; no messages</msg>
    </result>
    <trID>
      <clTRID>1441791749</clTRID>
      <svTRID>ccReg-4724119935</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when not connected greets client upon connection  

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <greeting>
    <svID>EPP server (EIS)</svID>
    <svDate>2015-09-09T09:42:29Z</svDate>
    <svcMenu>
      <version>1.0</version>
      <lang>en</lang>
      <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
      <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
      <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
      <svcExtension>
        <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
        <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
      </svcExtension>
    </svcMenu>
    <dcp>
      <access>
        <all/>
      </access>
      <statement>
        <purpose>
          <admin/>
          <prov/>
        </purpose>
        <recipient>
          <public/>
        </recipient>
        <retention>
          <stated/>
        </retention>
      </statement>
    </dcp>
  </greeting>
</epp>
```

### EPP Session when connected does not log in with invalid user  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>wrong-user</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2501">
      <msg lang="en">Authentication error; server closing connection (API user not found)</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9639349458</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected does not log in with inactive user  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>inactive-user</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2501">
      <msg lang="en">Authentication error; server closing connection (API user is not active)</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9620879147</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected prohibits further actions unless logged in  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>test.ee</domain:name>
      </domain:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2002">
      <msg lang="en">You need to login first.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3457408099</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected should not have clTRID in response if client does not send it  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>wrong-user</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2501">
      <msg lang="en">Authentication error; server closing connection (API user not found)</msg>
    </result>
    <trID>
      <svTRID>ccReg-6572927796</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected should return latin only error  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>你好你好</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Allowed only Latin characters.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6876506234</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected with valid user logs in epp user  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>gitlab</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5728703803</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected with valid user does not log in twice  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>gitlab</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9589038046</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>gitlab</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2002">
      <msg lang="en">Already logged in. Use &lt;logout&gt; first.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9932531519</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected with valid user logs out epp user  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>gitlab</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6936147069</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <logout/>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1500">
      <msg>Command completed successfully; ending session</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8052021893</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected with valid user changes password and logs in  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>gitlab</clID>
      <pw>ghyt9e4fu</pw>
      <newPW>abcdefg</newPW>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3786533999</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected with valid user fails if new password is not valid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <command>
    <login>
      <clID>gitlab</clID>
      <pw>ghyt9e4fu</pw>
      <newPW/>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
        <objURI>https://epp.tld.ee/schema/contact-ee-1.1.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://epp.tld.ee/schema/eis-1.0.xsd</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="lib/schemas/epp-ee-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/epp-ee-1.0.xsd}newPW': [facet 'minLength'] The value has a length of '0'; this underruns the allowed minimum length of '6'.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/epp-ee-1.0.xsd}newPW': '' is not a valid value of the atomic type '{https://epp.tld.ee/schema/epp-ee-1.0.xsd}pwType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7925814977</svTRID>
    </trID>
  </response>
</epp>
```

