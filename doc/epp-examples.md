# EPP REQUEST - RESPONSE EXAMPLES
GENERATED AT: 2015-07-28 08:39:28 UTC  
EXAMPLE COUNT: 187  

---

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3999773216</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command fails if request xml is missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd"/>
    </create>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-eis-1.0.xsd}create': Missing child element(s). Expected is one of ( {https://epp.tld.ee/schema/contact-eis-1.0.xsd}id, {https://epp.tld.ee/schema/contact-eis-1.0.xsd}postalInfo ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5475530912</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command successfully creates a contact  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:6A469D40</id>
        <crDate>2015-07-28T08:39:31Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9419100913</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command successfully saves ident type with legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:9175FF51</id>
        <crDate>2015-07-28T08:39:31Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7112806347</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command successfully adds registrar  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:B0D47101</id>
        <crDate>2015-07-28T08:39:31Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3112027327</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command returns result data upon success  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:D97D17A8</id>
        <crDate>2015-07-28T08:39:31Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8158844070</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should add registrar prefix for code when missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:ABC12345</id>
        <crDate>2015-07-28T08:39:32Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6348378603</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should add registrar prefix for code when missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:ABC:ABC:12345</id>
        <crDate>2015-07-28T08:39:32Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6309817337</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should not allow spaces in custom code  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">is invalid [code]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3718665628</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should not strange characters in custom code  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">is invalid [code]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7046803120</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should not strange characters in custom code  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Contact code is too long, max 100 characters [code]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7830897117</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should not saves ident type with wrong country code  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/eis-1.0.xsd}ident', attribute 'cc': [facet 'maxLength'] The value 'WRONG' has a length of '5'; this exceeds the allowed maximum length of '2'.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/eis-1.0.xsd}ident', attribute 'cc': 'WRONG' is not a valid value of the atomic type '{https://epp.tld.ee/schema/eis-1.0.xsd}ccType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0585936448</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should return country missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/eis-1.0.xsd}ident': The attribute 'cc' is required but missing.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9395726958</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should return country missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/eis-1.0.xsd}ident': The attribute 'type' is required but missing.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/eis-1.0.xsd}ident': The attribute 'cc' is required but missing.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3003187201</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should add registrar prefix for code when legacy prefix present  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:CID:FIRST0:ABC:ABC:NEW:12345</id>
        <crDate>2015-07-28T08:39:38Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3792142117</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should not remove suffix CID  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:CID:FIRST0:ABC:CID:ABC:NEW:12345</id>
        <crDate>2015-07-28T08:39:38Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8833719931</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should not add registrar prefix for code when prefix present  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:ABC22</id>
        <crDate>2015-07-28T08:39:39Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9289988831</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should add registrar prefix for code does not match exactly to prefix  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:CID2:FIRST0:ABC:ABC:11111</id>
        <crDate>2015-07-28T08:39:39Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8383857357</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should ignore custom code when only contact prefix given  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:CID:FIRST0</id>
        <crDate>2015-07-28T08:39:39Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5997788919</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should generate server id when id is empty  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:87E70060</id>
        <crDate>2015-07-28T08:39:39Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9532742811</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should generate server id when id is empty  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:A74EABFE</id>
        <crDate>2015-07-28T08:39:39Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2995036796</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should return parameter value policy error for org  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Org must be blank: postalInfo &gt; org [org]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9068419905</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user create command should return parameter value policy error for fax  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Fax must be blank: fax [fax]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3667432897</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command fails if request is invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd"/>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-eis-1.0.xsd}update': Missing child element(s). Expected is ( {https://epp.tld.ee/schema/contact-eis-1.0.xsd}id ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8184249905</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command returns error if obj doesnt exist  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Object does not exist</msg>
      <value>
        <id>NOT-EXISTS</id>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7422710793</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command is succesful  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:SH8013</id>
        <crDate>2015-07-28T08:39:41Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4865022436</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command is succesful for own contact without password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:SH8013</id>
        <crDate>2015-07-28T08:39:41Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6633367984</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should update other contact with correct password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7530163933</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:SH8013</id>
        <crDate>2015-07-28T08:39:41Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4277646314</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4538846364</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should not update other contact without password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6831340132</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6564840615</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5442863323</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command returns phone and email error  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Phone nr is invalid [phone]</msg>
    </result>
    <result code="2005">
      <msg lang="en">Email is invalid [email]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8528718455</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should not update code with custom string  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-eis-1.0.xsd}id': This element is not expected.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4331200914</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should not be able to update ident  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Update of ident data not allowed [ident]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4397523800</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should return parameter value policy errror for org update  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Org must be blank: postalInfo &gt; org [org]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7928150587</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should return parameter value policy errror for fax update  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Fax must be blank: fax [fax]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3817458970</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command does not allow to edit statuses if policy forbids it  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Client-side object status management not supported: status [status]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3807652405</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should add value voice value  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:SH8013</id>
        <crDate>2015-07-28T08:39:41Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8133702938</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should return error when add attributes phone value is empty  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing - phone [phone]</msg>
    </result>
    <result code="2005">
      <msg lang="en">Phone nr is invalid [phone]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7011374408</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should honor chg value over add value when both changes same attribute  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:add>
          <contact:voice>+372.11111111111</contact:voice>
        </contact:add>
        <contact:chg>
          <contact:voice>+372.222222222222</contact:voice>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-eis-1.0.xsd}voice': This element is not expected. Expected is ( {https://epp.tld.ee/schema/contact-eis-1.0.xsd}status ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7610710976</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should not allow to remove required voice attribute  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing - phone [phone]</msg>
    </result>
    <result code="2005">
      <msg lang="en">Phone nr is invalid [phone]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6395479303</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should not allow to remove required attribute  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
        <contact:rem>
          <contact:voice>+372.7654321</contact:voice>
        </contact:rem>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-eis-1.0.xsd}authInfo': This element is not expected. Expected is one of ( {https://epp.tld.ee/schema/contact-eis-1.0.xsd}add, {https://epp.tld.ee/schema/contact-eis-1.0.xsd}rem, {https://epp.tld.ee/schema/contact-eis-1.0.xsd}chg ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7007003785</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should honor add over rem  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
        <contact:rem>
          <contact:voice>not important</contact:voice>
        </contact:rem>
        <contact:add>
          <contact:voice>+372.3333333</contact:voice>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-eis-1.0.xsd}authInfo': This element is not expected. Expected is one of ( {https://epp.tld.ee/schema/contact-eis-1.0.xsd}add, {https://epp.tld.ee/schema/contact-eis-1.0.xsd}rem, {https://epp.tld.ee/schema/contact-eis-1.0.xsd}chg ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8061878233</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should honor chg over rem  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
        <contact:rem>
          <contact:voice>not important</contact:voice>
        </contact:rem>
        <contact:chg>
          <contact:voice>+372.44444444</contact:voice>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-eis-1.0.xsd}authInfo': This element is not expected. Expected is one of ( {https://epp.tld.ee/schema/contact-eis-1.0.xsd}add, {https://epp.tld.ee/schema/contact-eis-1.0.xsd}rem, {https://epp.tld.ee/schema/contact-eis-1.0.xsd}chg ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3091851486</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should honor chg over rem and add  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
        <contact:chg>
          <contact:voice>+372.666666</contact:voice>
        </contact:chg>
        <contact:add>
          <contact:voice>+372.555555</contact:voice>
        </contact:add>
        <contact:rem>
          <contact:voice>not important</contact:voice>
        </contact:rem>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-eis-1.0.xsd}authInfo': This element is not expected. Expected is one of ( {https://epp.tld.ee/schema/contact-eis-1.0.xsd}add, {https://epp.tld.ee/schema/contact-eis-1.0.xsd}rem, {https://epp.tld.ee/schema/contact-eis-1.0.xsd}chg ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8609322144</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should not remove password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
        <contact:rem>
          <contact:authInfo>
            <contact:pw>password</contact:pw>
          </contact:authInfo>
        </contact:rem>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-eis-1.0.xsd}authInfo': This element is not expected. Expected is one of ( {https://epp.tld.ee/schema/contact-eis-1.0.xsd}add, {https://epp.tld.ee/schema/contact-eis-1.0.xsd}rem, {https://epp.tld.ee/schema/contact-eis-1.0.xsd}chg ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0582559112</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should return general policy error when removing org  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:chg>
          <contact:postalInfo>
            <contact:org/>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:SH8013</id>
        <crDate>2015-07-28T08:39:41Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8655942919</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user update command should return error when removing street  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
        <contact:rem>
          <contact:postalInfo>
            <contact:name>not important</contact:name>
          </contact:postalInfo>
        </contact:rem>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-eis-1.0.xsd}authInfo': This element is not expected. Expected is one of ( {https://epp.tld.ee/schema/contact-eis-1.0.xsd}add, {https://epp.tld.ee/schema/contact-eis-1.0.xsd}rem, {https://epp.tld.ee/schema/contact-eis-1.0.xsd}chg ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9481106190</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command fails if request is invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd"/>
    </delete>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-eis-1.0.xsd}delete': Missing child element(s). Expected is ( {https://epp.tld.ee/schema/contact-eis-1.0.xsd}id ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5578564225</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command returns error if obj doesnt exist  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Object does not exist</msg>
      <value>
        <id>NOT-EXISTS</id>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6663525094</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command deletes contact  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH231039313</contact:id>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3780043277</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command deletes own contact even with wrong password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH495814614</contact:id>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7212720521</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command deletes own contact even without password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH345416025</contact:id>
      </contact:delete>
    </delete>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6437000685</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command fails if contact has associated domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH527033126</contact:id>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2305">
      <msg lang="en">Object association prohibits operation [domains]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1807855170</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command should delete when not owner but with correct password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0288992099</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH031616179</contact:id>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4336841702</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8729288024</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command should not delete when not owner without password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6840346616</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH2297814310</contact:id>
      </contact:delete>
    </delete>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3383228806</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4682199982</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user delete command should not delete when not owner with wrong password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6469460670</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <contact:delete xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH3326380711</contact:id>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7404986506</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7294017342</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user check command fails if request is invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <check>
      <contact:check xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd"/>
    </check>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-eis-1.0.xsd}check': Missing child element(s). Expected is ( {https://epp.tld.ee/schema/contact-eis-1.0.xsd}id ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7052563758</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user check command returns info about contact availability  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
      <command>
        <check>
          <contact:check xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <cd>
          <id avail="0">FIXED:CHECK-1234</id>
          <reason>in use</reason>
        </cd>
        <cd>
          <id avail="1">check-4321</id>
        </cd>
      </chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9831020858</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user check command should support legacy CID farmat  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
      <command>
        <check>
          <contact:check xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <cd>
          <id avail="0">FIXED:CHECK-LEGACY</id>
          <reason>in use</reason>
        </cd>
        <cd>
          <id avail="1">CID:FIXED:CHECK-LEGACY</id>
        </cd>
      </chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3695978327</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command fails if request invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd"/>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/contact-eis-1.0.xsd}info': Missing child element(s). Expected is ( {https://epp.tld.ee/schema/contact-eis-1.0.xsd}id ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0977011305</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command returns error when object does not exist  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Object does not exist</msg>
      <value>
        <id>NO-CONTACT</id>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5298387301</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command return info about contact  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <id>FIXED:INFO-4444</id>
        <roid>EIS-29</roid>
        <status s="ok"/>
        <postalInfo type="int">
          <name>Johnny Awesome</name>
          <addr>
            <street>Short street 11</street>
            <city>Tallinn</city>
            <sp/>
            <pc>11111</pc>
            <cc>EE</cc>
          </addr>
        </postalInfo>
        <voice>+372.12345678</voice>
        <email>adaline.farrell@wilkinson.org</email>
        <clID>fixed registrar</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-28T08:40:06Z</crDate>
        <authInfo>
          <pw>password</pw>
        </authInfo>
      </infData>
    </resData>
    <extension>
      <extdata>
        <ident type="priv" cc="EE">37605030299</ident>
      </extdata>
    </extension>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5155368245</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command should add legacy CID format as append  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <id>FIXED:CID:FIXED:INFO-5555</id>
        <roid>EIS-30</roid>
        <status s="ok"/>
        <postalInfo type="int">
          <name>Johnny Awesome</name>
          <addr>
            <street>Short street 11</street>
            <city>Tallinn</city>
            <sp/>
            <pc>11111</pc>
            <cc>EE</cc>
          </addr>
        </postalInfo>
        <voice>+372.12345678</voice>
        <email>adaline.farrell@wilkinson.org</email>
        <clID>fixed registrar</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-28T08:40:06Z</crDate>
        <authInfo>
          <pw>password</pw>
        </authInfo>
      </infData>
    </resData>
    <extension>
      <extdata>
        <ident type="priv" cc="EE">37605030299</ident>
      </extdata>
    </extension>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5763471786</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command should return ident in extension  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <id>FIRST0:INFO-IDENT</id>
        <roid>EIS-31</roid>
        <status s="ok"/>
        <postalInfo type="int">
          <name>Johnny Awesome</name>
          <addr>
            <street>Short street 11</street>
            <city>Tallinn</city>
            <sp/>
            <pc>11111</pc>
            <cc>EE</cc>
          </addr>
        </postalInfo>
        <voice>+372.12345678</voice>
        <email>adaline.farrell@wilkinson.org</email>
        <clID>registrar1</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-28T08:40:06Z</crDate>
        <authInfo>
          <pw>password</pw>
        </authInfo>
      </infData>
    </resData>
    <extension>
      <extdata>
        <ident type="priv" cc="EE">37605030299</ident>
      </extdata>
    </extension>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1407507322</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command returns no authorization error for wrong password when registrant  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH401752550</contact:id>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <id>FIRST0:SH401752550</id>
        <roid>EIS-1</roid>
        <status s="ok"/>
        <postalInfo type="int">
          <name>Gloria Boyer MD0</name>
          <addr>
            <street>Short street 11</street>
            <city>Tallinn</city>
            <sp/>
            <pc>11111</pc>
            <cc>EE</cc>
          </addr>
        </postalInfo>
        <voice>+372.12345678</voice>
        <email>adaline.farrell@wilkinson.org</email>
        <clID>registrar1</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-28T08:39:30Z</crDate>
        <authInfo>
          <pw>password</pw>
        </authInfo>
      </infData>
    </resData>
    <extension>
      <extdata>
        <ident type="priv" cc="EE">37605030299</ident>
      </extdata>
    </extension>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6798027147</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command should honor new contact code format  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <id>FIXED:TEST:CUSTOM:CODE</id>
        <roid>EIS-32</roid>
        <status s="ok"/>
        <postalInfo type="int">
          <name>Mr. Brooks Crooks15</name>
          <addr>
            <street>Short street 11</street>
            <city>Tallinn</city>
            <sp/>
            <pc>11111</pc>
            <cc>EE</cc>
          </addr>
        </postalInfo>
        <voice>+372.12345678</voice>
        <email>adaline.farrell@wilkinson.org</email>
        <clID>fixed registrar</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-28T08:40:06Z</crDate>
        <authInfo>
          <pw>password</pw>
        </authInfo>
      </infData>
    </resData>
    <extension>
      <extdata>
        <ident type="priv" cc="EE">37605030299</ident>
      </extdata>
    </extension>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3521737420</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command returns no authorization error for wrong user but correct password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9495273454</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH401752550</contact:id>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <id>FIRST0:SH401752550</id>
        <roid>EIS-1</roid>
        <status s="ok"/>
        <postalInfo type="int">
          <name>Gloria Boyer MD0</name>
          <addr>
            <street>Short street 11</street>
            <city>Tallinn</city>
            <sp/>
            <pc>11111</pc>
            <cc>EE</cc>
          </addr>
        </postalInfo>
        <voice>+372.12345678</voice>
        <email>adaline.farrell@wilkinson.org</email>
        <clID>registrar1</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-28T08:39:30Z</crDate>
        <authInfo>
          <pw>password</pw>
        </authInfo>
      </infData>
    </resData>
    <extension>
      <extdata>
        <ident type="priv" cc="EE">37605030299</ident>
      </extdata>
    </extension>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7991464495</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4527051077</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command returns authorization error for wrong user and wrong password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0913409657</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH401752550</contact:id>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6286749211</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8291798513</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Contact with valid user info command returns no authorization error for wrong user and no password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5404035767</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="https://epp.tld.ee/schema/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH401752550</contact:id>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <id>FIRST0:SH401752550</id>
        <roid>EIS-1</roid>
        <status s="ok"/>
        <postalInfo type="int">
          <name>Gloria Boyer MD0</name>
        </postalInfo>
        <clID>registrar1</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-28T08:39:30Z</crDate>
      </infData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2003839888</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5982274752</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1309091299</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain should return error if balance low  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example92166977555993338.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2104">
      <msg lang="en">Billing failure - credit balance low</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0406877402</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain returns error if contact does not exists  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example81690264966073237.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value>
        <contact>sh1111</contact>
      </value>
    </result>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value>
        <contact>sh2222</contact>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7250362476</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain validates required parameters  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
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
      <svTRID>ccReg-0791690819</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example32543506110306742.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example32543506110306742.ee</name>
        <crDate>2015-07-28T08:40:12Z</crDate>
        <exDate>2016-07-28T08:40:12Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3409698461</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain with legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example36382345567850627.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example36382345567850627.ee</name>
        <crDate>2015-07-28T08:40:12Z</crDate>
        <exDate>2016-07-28T08:40:12Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4473161202</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant validates nameserver ipv4 when in same zone as domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example94744851802697081.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example94744851802697081.ee</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example94744851802697081.ee</domain:hostName>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">IPv4 is missing [ipv4]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0945142666</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create domain longer than 63 punicode characters  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Domain name is too long (maximum is 63 characters) [puny_label]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1975664747</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create reserved domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing; reserved&gt;pw element required for reserved domains</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1640127046</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2202">
      <msg lang="en">Invalid authorization information; invalid reserved&gt;pw value</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2908502858</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a reserved domain with correct auth info  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>1162.ee</name>
        <crDate>2015-07-28T08:40:17Z</crDate>
        <exDate>2016-07-28T08:40:17Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0275498048</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create blocked domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2302">
      <msg lang="en">Domain name is blocked [name_dirty]</msg>
      <value>
        <name>ftp.ee</name>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9470981751</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create domain without contacts and registrant  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example62168642411513599.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; registrant [registrant]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0968519360</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create domain without nameservers  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example71800352143417997.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; ns [ns]</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; ns &gt; hostAttr [host_attr]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7839854930</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create domain with too many nameservers  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example71680402331588779.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">Nameservers count must be between 2-11 [nameservers]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3550426764</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant returns error when invalid nameservers are present  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example68109979538689428.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Hostname is invalid [hostname]</msg>
      <value>
        <hostAttr>invalid1-</hostAttr>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Hostname is invalid [hostname]</msg>
      <value>
        <hostAttr>-invalid2</hostAttr>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3024443751</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant checks hostAttr presence  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example76831955690582435.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; ns &gt; hostAttr [host_attr]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6323264384</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates domain with nameservers with ips  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example32514723684684037.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example32514723684684037.ee</name>
        <crDate>2015-07-28T08:40:23Z</crDate>
        <exDate>2016-07-28T08:40:23Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5056598055</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant returns error when nameserver has invalid ips  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example40338285586899571.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">IPv4 is invalid [ipv4]</msg>
      <value>
        <hostAddr>192.0.2.2.invalid</hostAddr>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">IPv6 is invalid [ipv6]</msg>
      <value>
        <hostAddr>INVALID_IPV6</hostAddr>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0826897719</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain with period in days  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example66186778295502856.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example66186778295502856.ee</name>
        <crDate>2015-07-28T08:40:25Z</crDate>
        <exDate>2016-07-28T08:40:25Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1614664137</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain with longer periods  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example91954080942379032.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example91954080942379032.ee</name>
        <crDate>2015-07-28T08:40:25Z</crDate>
        <exDate>2017-07-28T08:40:25Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4703652719</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain with longer periods  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example30928593583996919.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example30928593583996919.ee</name>
        <crDate>2015-07-28T08:40:26Z</crDate>
        <exDate>2018-07-28T08:40:26Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7270105536</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain without period  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example46362933949869671.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example46362933949869671.ee</name>
        <crDate>2015-07-28T08:40:26Z</crDate>
        <exDate>2016-07-28T08:40:26Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1881376659</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create a domain with invalid period  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example11714535017331079.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Period must add up to 1, 2 or 3 years [period]</msg>
      <value>
        <period>367</period>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5484931345</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create a domain with invalid period unit  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example12063060146758107.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': [facet 'enumeration'] The value '' is not an element of the set {'y', 'm', 'd'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': '' is not a valid value of the atomic type '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}pUnitType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8109184091</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example22134060080142573.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': [facet 'enumeration'] The value 'bla' is not an element of the set {'y', 'm', 'd'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': 'bla' is not a valid value of the atomic type '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}pUnitType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6082364829</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates a domain with multiple dnskeys  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example81422504470924299.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example81422504470924299.ee</name>
        <crDate>2015-07-28T08:40:30Z</crDate>
        <exDate>2016-07-28T08:40:30Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1274053409</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create a domain when dnskeys are invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example52530934380418051.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{urn:ietf:params:xml:ns:secDNS-1.1}pubKey': [facet 'minLength'] The value has a length of '0'; this underruns the allowed minimum length of '1'.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{urn:ietf:params:xml:ns:secDNS-1.1}pubKey': '' is not a valid value of the atomic type '{urn:ietf:params:xml:ns:secDNS-1.1}keyType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0039779987</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example6111657126731846.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Valid algorithms are: 3, 5, 6, 7, 8, 252, 253, 254, 255 [alg]</msg>
      <value>
        <alg>9</alg>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid protocols are: 3 [protocol]</msg>
      <value>
        <protocol>4</protocol>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid flags are: 0, 256, 257 [flags]</msg>
      <value>
        <flags>250</flags>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid algorithms are: 3, 5, 6, 7, 8, 252, 253, 254, 255 [alg]</msg>
      <value>
        <alg>10</alg>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid flags are: 0, 256, 257 [flags]</msg>
      <value>
        <flags>1</flags>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid protocols are: 3 [protocol]</msg>
      <value>
        <protocol>5</protocol>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5415301002</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant does not create a domain with two identical dnskeys  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example59960668723180884.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2302">
      <msg lang="en">Public key already exists [public_key]</msg>
      <value>
        <pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</pubKey>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3029612280</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant validated dnskeys count  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example96012563680688440.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">DNS keys count must be between 0-1 [dnskeys]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0186058439</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates domain with ds data  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example76656279799751526.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example76656279799751526.ee</name>
        <crDate>2015-07-28T08:40:35Z</crDate>
        <exDate>2016-07-28T08:40:35Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2063281633</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant creates domain with ds data with key  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example70580501288966544.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example70580501288966544.ee</name>
        <crDate>2015-07-28T08:40:35Z</crDate>
        <exDate>2016-07-28T08:40:35Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4381859223</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant prohibits dsData  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example95275486168393163.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">dsData object is not allowed</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3354909144</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant prohibits keyData  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example97367469702829730.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">keyData object is not allowed</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8644792351</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with citizen as a registrant prohibits dsData and keyData when they exists together  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example70071198549943103.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{urn:ietf:params:xml:ns:secDNS-1.1}keyData': This element is not expected. Expected is ( {urn:ietf:params:xml:ns:secDNS-1.1}dsData ).</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8173091592</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with juridical persion as a registrant creates a domain with contacts  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example22431835510518513.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example22431835510518513.ee</name>
        <crDate>2015-07-28T08:40:39Z</crDate>
        <exDate>2016-07-28T08:40:39Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2819985278</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with juridical persion as a registrant does not create a domain without admin contact  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example59566819674530307.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">Admin contacts count must be between 1-10 [admin_domain_contacts]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6708083266</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with juridical persion as a registrant cannot assign juridical person as admin contact  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example72083543502407430.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Admin contact can be private person only</msg>
      <value>
        <contact>FIXED:JURIDICAL_1234</contact>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7325897703</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4047445422</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain1.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">512701cc6a8455e43612526cfd613ef1</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain1.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:42Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:40:42Z</acDate>
        <exDate>2016-07-28T08:40:41Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2882098037</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4020170558</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="req"/>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="1" id="1">
      <qDate>2015-07-28T08:40:42Z</qDate>
      <msg>Domain transfer was approved, associated contacts were: ["FIXED:SH0465812013", "FIXED:SH3835271712"] and registrant was FIXED:REGISTRANT779976690</msg>
    </msgQ>
    <resData>
      <trnData>
        <name>domain1.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:42Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:40:42Z</acDate>
        <exDate>2016-07-28T08:40:41Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2433533762</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain1.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">3c706b7554d122c07c3a96255b62f728</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain1.ee</name>
        <trStatus>pending</trStatus>
        <reID>REGDOMAIN1</reID>
        <reDate>2015-07-28T08:40:42Z</reDate>
        <acID>REGDOMAIN2</acID>
        <acDate>2015-07-28T09:40:42Z</acDate>
        <exDate>2016-07-28T08:40:41Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9163815770</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain1.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">3c706b7554d122c07c3a96255b62f728</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain1.ee</name>
        <trStatus>pending</trStatus>
        <reID>REGDOMAIN1</reID>
        <reDate>2015-07-28T08:40:42Z</reDate>
        <acID>REGDOMAIN2</acID>
        <acDate>2015-07-28T09:40:42Z</acDate>
        <exDate>2016-07-28T08:40:41Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1344906774</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2023826073</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="req"/>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="1" id="2">
      <qDate>2015-07-28T08:40:42Z</qDate>
      <msg>Transfer requested.</msg>
    </msgQ>
    <resData>
      <trnData>
        <name>domain1.ee</name>
        <trStatus>pending</trStatus>
        <reID>REGDOMAIN1</reID>
        <reDate>2015-07-28T08:40:42Z</reDate>
        <acID>REGDOMAIN2</acID>
        <acDate>2015-07-28T09:40:42Z</acDate>
        <exDate>2016-07-28T08:40:41Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1404467939</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8545555548</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8253885703</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="ack" msgID="2"/>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="0" id="2"/>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3483466836</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4285977126</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain creates a domain transfer with legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4057108889</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain2.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">5d98f2cbe11306469ce55447e995a1c4</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain2.ee</name>
        <trStatus>pending</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:43Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T09:40:43Z</acDate>
        <exDate>2016-07-28T08:40:43Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4612548825</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4051705615</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1410613698</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain2.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">5d98f2cbe11306469ce55447e995a1c4</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain2.ee</name>
        <trStatus>pending</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:43Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T09:40:43Z</acDate>
        <exDate>2016-07-28T08:40:43Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2313898331</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5075928895</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain creates transfer successfully without legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8432415801</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain3.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">d21cc5784da4f1cd0a69ebccd64ea825</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain3.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:44Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:40:44Z</acDate>
        <exDate>2016-07-28T08:40:44Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8319808701</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3709709960</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers domain with contacts  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7289638867</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain4.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">c542d3f99353e1d042716d824f6fec12</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain4.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:45Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:40:45Z</acDate>
        <exDate>2016-07-28T08:40:45Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6544417100</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9728924318</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers domain when registrant has more domains  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4703756087</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain5.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">d4bf9e0bc0fd09c7252541a194473cec</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain5.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:46Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:40:46Z</acDate>
        <exDate>2016-07-28T08:40:46Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1877217438</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3796353322</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers domain when registrant is admin or tech contact on some other domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3792624699</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain8.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">0bd19effb6079c4790d1475bd0199723</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain8.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:47Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:40:47Z</acDate>
        <exDate>2016-07-28T08:40:46Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2654465761</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9967282082</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers domain when domain contacts are some other domain contacts  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7212461778</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain9.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">10eadc71cf7e6f1e87e1bf54bc99e263</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain9.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:48Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:40:48Z</acDate>
        <exDate>2016-07-28T08:40:47Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1877104282</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6337086891</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers domain when multiple domain contacts are some other domain contacts  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0660234392</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain11.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">5d943994996a6a851e7247db3d2c1c4a</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain11.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:48Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:40:48Z</acDate>
        <exDate>2016-07-28T08:40:48Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9157975420</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6402981411</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain transfers domain and references exsisting registrant to domain contacts  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4407801058</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain14.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">75065639f9945045256b9c5fe2a8fadc</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain14.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:49Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:40:49Z</acDate>
        <exDate>2016-07-28T08:40:49Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9637117596</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0421936954</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not transfer contacts if they are already under new registrar  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8532719762</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain15.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">e6349b913cb0788975f93a02ba220510</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain15.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:50Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:40:50Z</acDate>
        <exDate>2016-07-28T08:40:50Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1495969172</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1225162463</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not creates transfer without password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5138326156</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain16.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">98oiewslkfkd</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9171426317</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2262790683</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain approves the transfer request  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="approve">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain17.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">d0d6f5f660ba9b1cb777074e05c9f9d5</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain17.ee</name>
        <trStatus>clientApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:51Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:40:51Z</acDate>
        <exDate>2016-07-28T08:40:51Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2925262739</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain rejects a domain transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2033369372</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="reject">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain18.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">f40c17f5451f5c80e562bf9250ccd4d2</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Transfer can be rejected only by current registrar</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7553628884</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8494729995</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="reject">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain18.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">f40c17f5451f5c80e562bf9250ccd4d2</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain18.ee</name>
        <trStatus>clientRejected</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:51Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:40:51Z</acDate>
        <exDate>2016-07-28T08:40:51Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0035055015</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain prohibits wrong registrar from approving transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8757184492</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="approve">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain19.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">619c6d2109ee1b2deca3674b73619fda</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Transfer can be approved only by current domain registrar</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4815280002</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2650484631</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not transfer with invalid pw  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain20.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">test</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1473008535</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain ignores transfer when domain already belongs to registrar  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain21.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">fd06d8982dbdecde7e39f41d7f278c7d</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2002">
      <msg lang="en">Domain already belongs to the querying registrar</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0989479481</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain returns an error for incorrect op attribute  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="bla">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>example44755290217170574.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">98oiewslkfkd</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{urn:ietf:params:xml:ns:epp-1.0}transfer', attribute 'op': [facet 'enumeration'] The value 'bla' is not an element of the set {'approve', 'cancel', 'query', 'reject', 'request'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{urn:ietf:params:xml:ns:epp-1.0}transfer', attribute 'op': 'bla' is not a valid value of the atomic type '{urn:ietf:params:xml:ns:epp-1.0}transferOpType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7927987439</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain creates new pw after successful transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2792059598</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain22.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">d7aa8aba40bf70cb78dfebc9474664b2</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain22.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:40:57Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:40:57Z</acDate>
        <exDate>2016-07-28T08:40:57Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0573122351</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain22.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">d7aa8aba40bf70cb78dfebc9474664b2</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0832624566</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8225650710</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should get an error when there is no pending transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="approve">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain23.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">2c47c46daf97e12ddc0d9fc80da511d0</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">No transfers found</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2025440519</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not return transfers when there are none  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain24.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">9bbf18edcc83fb42ddf249dc1f3e42af</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">No transfers found</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8629472751</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should allow querying domain transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7696022252</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain25.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">0935877a40fea9441ffd17fee6c0e7d8</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain25.ee</name>
        <trStatus>pending</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:41:00Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T09:41:00Z</acDate>
        <exDate>2016-07-28T08:41:00Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7042077941</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain25.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">0935877a40fea9441ffd17fee6c0e7d8</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain25.ee</name>
        <trStatus>pending</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:41:00Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T09:41:00Z</acDate>
        <exDate>2016-07-28T08:41:00Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4814615747</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6824308586</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="approve">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain25.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">0935877a40fea9441ffd17fee6c0e7d8</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain25.ee</name>
        <trStatus>clientApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:41:00Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:41:00Z</acDate>
        <exDate>2016-07-28T08:41:00Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2690846279</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain25.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">665baee3468e834243928ce917ecc3ef</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>domain25.ee</name>
        <trStatus>clientApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-28T08:41:00Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-28T08:41:00Z</acDate>
        <exDate>2016-07-28T08:41:00Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9400606855</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not transfer when period element is present  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1604970396</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain26.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">e0c3f74927da4bb3eee5667c66115352</domain:pw>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2307">
      <msg lang="en">Unimplemented object service</msg>
      <value>
        <period/>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8617519056</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1118050637</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should update right away without update pending status  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2670008628</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain updates a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1001">
      <msg>Command completed successfully; action pending</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8289277865</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not return action pending when changes are invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain29.ee</domain:name>
        <domain:rem>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns.bernhard89.ee</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns.effertzebert88.ee</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns.ondrickajakubowski87.ee</domain:hostName>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">Nameservers count must be between 2-11 [nameservers]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1648208045</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not return action pending when domain itself is already invaid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain30.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">Nameservers count must be between 2-11 [nameservers]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5575143855</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should not allow any update when status pending update  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Object status prohibits operation</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7420673440</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain updates domain and adds objects  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain32.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value>
        <contact>FIXED:MAK21</contact>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5413112744</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain32.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3340757346</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain32.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2302">
      <msg lang="en">Nameserver already exists on this domain [hostname]</msg>
      <value>
        <hostAttr>ns2.example.com</hostAttr>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Nameserver already exists on this domain [hostname]</msg>
      <value>
        <hostAttr>ns1.example.com</hostAttr>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Contact already exists on this domain [contact_code_cache]</msg>
      <value>
        <contact>FIXED:MAK21</contact>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Public key already exists [public_key]</msg>
      <value>
        <pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</pubKey>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Public key already exists [public_key]</msg>
      <value>
        <pubKey>841936717ae427ace63c28d04918569a841936717ae427ace63c28d0</pubKey>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2640140355</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain updates domain with registrant change what triggers action pending  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain33.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value>
        <contact>FIXED:PENDINGMAK21</contact>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7630828881</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain33.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1001">
      <msg>Command completed successfully; action pending</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4914897472</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not allow to edit statuses if policy forbids it  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain34.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Client-side object status management not supported: status [status]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1063100515</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain updates a domain and removes objects  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6247129672</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain35.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1536077793</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain35.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Nameserver was not found</msg>
      <value>
        <hostAttr>ns1.example.com</hostAttr>
      </value>
    </result>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value>
        <contact>FIXED:CITIZEN_1234</contact>
      </value>
    </result>
    <result code="2303">
      <msg lang="en">DS was not found</msg>
      <value>
        <publicKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</publicKey>
      </value>
    </result>
    <result code="2303">
      <msg lang="en">Status was not found</msg>
      <value>
        <status>clientHold</status>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9074810399</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not remove server statuses  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain36.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Status was not found</msg>
      <value>
        <status>serverHold</status>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6433694543</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not add duplicate objects to domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain37.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns.westemmerich108.ee</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="admin">FIXED:SH2488479285</domain:contact>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2752561257</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain37.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns.westemmerich108.ee</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="admin">FIXED:SH2488479285</domain:contact>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2302">
      <msg lang="en">Nameserver already exists on this domain [hostname]</msg>
      <value>
        <hostAttr>ns.westemmerich108.ee</hostAttr>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Contact already exists on this domain [contact_code_cache]</msg>
      <value>
        <contact>FIXED:SH2488479285</contact>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9298371804</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain cannot change registrant without legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain38.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: extension &gt; extdata &gt; legalDocument [legal_document]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4198817730</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not assign invalid status to domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain39.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}status', attribute 's': [facet 'enumeration'] The value 'invalidStatus' is not an element of the set {'clientDeleteProhibited', 'clientHold', 'clientRenewProhibited', 'clientTransferProhibited', 'clientUpdateProhibited', 'inactive', 'ok', 'pendingCreate', 'pendingDelete', 'pendingRenew', 'pendingTransfer', 'pendingUpdate', 'serverDeleteProhibited', 'serverHold', 'serverRenewProhibited', 'serverTransferProhibited', 'serverUpdateProhibited'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}status', attribute 's': 'invalidStatus' is not a valid value of the atomic type '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}statusValueType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8053378605</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain renews a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain40.ee</domain:name>
        <domain:curExpDate>2016-07-28</domain:curExpDate>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <renData>
        <name>domain40.ee</name>
        <exDate>2017-07-28T08:41:19Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2144233121</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain renews a domain when outzone_at or delete_at is nil for some reason  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain41.ee</domain:name>
        <domain:curExpDate>2016-07-28</domain:curExpDate>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <renData>
        <name>domain41.ee</name>
        <exDate>2017-07-28T08:41:20Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6734533900</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain renews a domain with no period specified  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain42.ee</domain:name>
        <domain:curExpDate>2016-07-28</domain:curExpDate>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <renData>
        <name>domain42.ee</name>
        <exDate>2017-07-28T08:41:20Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1952216525</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not renew domain with invalid period  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain43.ee</domain:name>
        <domain:curExpDate>2016-07-28</domain:curExpDate>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': [facet 'enumeration'] The value '' is not an element of the set {'y', 'm', 'd'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': '' is not a valid value of the atomic type '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}pUnitType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9450436889</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain43.ee</domain:name>
        <domain:curExpDate>2016-07-28</domain:curExpDate>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': [facet 'enumeration'] The value 'bla' is not an element of the set {'y', 'm', 'd'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}period', attribute 'unit': 'bla' is not a valid value of the atomic type '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}pUnitType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1447208589</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain renews a domain with 2 year period  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain44.ee</domain:name>
        <domain:curExpDate>2015-08-07</domain:curExpDate>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <renData>
        <name>domain44.ee</name>
        <exDate>2017-08-07T00:00:00Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8888058768</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain renews a domain with 3 year period  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain45.ee</domain:name>
        <domain:curExpDate>2015-08-07</domain:curExpDate>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <renData>
        <name>domain45.ee</name>
        <exDate>2018-08-07T00:00:00Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2368607304</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not renew a domain if credit balance low  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain46.ee</domain:name>
        <domain:curExpDate>2015-08-07</domain:curExpDate>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2104">
      <msg lang="en">Billing failure - credit balance low</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6821240882</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain returns an error when given and current exp dates do not match  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain47.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Given and current expire dates do not match</msg>
      <value>
        <curExpDate>2200-08-07</curExpDate>
      </value>
    </result>
    <result code="2105">
      <msg lang="en">Object is not eligible for renewal</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3646435252</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain returns an error when period is invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain48.ee</domain:name>
        <domain:curExpDate>2015-08-07</domain:curExpDate>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Period must add up to 1, 2 or 3 years [period]</msg>
      <value>
        <period>4</period>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6217040456</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not renew a domain unless less than 90 days till expiration  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain49.ee</domain:name>
        <domain:curExpDate>2015-10-26</domain:curExpDate>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2105">
      <msg lang="en">Object is not eligible for renewal</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8796521058</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain49.ee</domain:name>
        <domain:curExpDate>2015-10-25</domain:curExpDate>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <renData>
        <name>domain49.ee</name>
        <exDate>2016-10-25T00:00:00Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0448578516</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not renew a domain unless less than 90 days till expiration  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain50.ee</domain:name>
        <domain:curExpDate>2020-07-28</domain:curExpDate>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <renData>
        <name>domain50.ee</name>
        <exDate>2021-07-28T00:00:00Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5093886658</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not renew a domain if it is a delete candidate  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain51.ee</domain:name>
        <domain:curExpDate>2015-08-07</domain:curExpDate>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2105">
      <msg lang="en">Object is not eligible for renewal</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1090831490</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should renew a expired domain  

### EPP Domain with valid domain does not renew foreign domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0660211759</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain53.ee</domain:name>
        <domain:curExpDate>2016-07-28</domain:curExpDate>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9082042804</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0461998559</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain returns domain info  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain54.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <name>domain54.ee</name>
        <roid>EIS-66</roid>
        <status s="clientHold"/>
        <registrant>FIXED:REGISTRANT3821775852</registrant>
        <contact type="tech">FIXED:SH92766468122</contact>
        <contact type="admin">FIXED:SH95283245121</contact>
        <ns>
          <hostAttr>
            <hostName>ns.halvorsonkeeling162.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.cummings163.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.dibbert164.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns1.example.com</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-28T08:41:31Z</crDate>
        <upDate>2015-07-28T08:41:31Z</upDate>
        <exDate>2016-07-28T08:41:31Z</exDate>
        <authInfo>
          <pw>7bde3f39e40a68635bf5a69098169cc5</pw>
        </authInfo>
      </infData>
    </resData>
    <extension>
      <infData>
        <dsData>
          <keyTag>123</keyTag>
          <alg>3</alg>
          <digestType>1</digestType>
          <digest>0D85A305D22FCB355BBE29AE9809363D697B64782B9CC73AE349350F8C2AE4BB</digest>
          <keyData>
            <flags>257</flags>
            <protocol>3</protocol>
            <alg>3</alg>
            <pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</pubKey>
          </keyData>
        </dsData>
        <dsData>
          <keyTag>123</keyTag>
          <alg>3</alg>
          <digestType>1</digestType>
          <digest>0D85A305D22FCB355BBE29AE9809363D697B64782B9CC73AE349350F8C2AE4BB</digest>
          <keyData>
            <flags>0</flags>
            <protocol>3</protocol>
            <alg>5</alg>
            <pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</pubKey>
          </keyData>
        </dsData>
      </infData>
    </extension>
    <trID>
      <svTRID>ccReg-6011078959</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain54.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <name>domain54.ee</name>
        <roid>EIS-66</roid>
        <status s="clientHold"/>
        <registrant>FIXED:REGISTRANT3821775852</registrant>
        <contact type="tech">FIXED:SH92766468122</contact>
        <contact type="admin">FIXED:SH95283245121</contact>
        <ns>
          <hostAttr>
            <hostName>ns.halvorsonkeeling162.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.cummings163.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.dibbert164.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns1.example.com</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-28T08:41:31Z</crDate>
        <upDate>2015-07-28T08:41:31Z</upDate>
        <exDate>2016-07-28T08:41:31Z</exDate>
        <authInfo>
          <pw>7bde3f39e40a68635bf5a69098169cc5</pw>
        </authInfo>
      </infData>
    </resData>
    <extension>
      <infData>
        <dsData>
          <keyTag>123</keyTag>
          <alg>3</alg>
          <digestType>1</digestType>
          <digest>0D85A305D22FCB355BBE29AE9809363D697B64782B9CC73AE349350F8C2AE4BB</digest>
          <keyData>
            <flags>257</flags>
            <protocol>3</protocol>
            <alg>3</alg>
            <pubKey>AwEAAddt2AkLfYGKgiEZB5SmIF8EvrjxNMH6HtxWEA4RJ9Ao6LCWheg8</pubKey>
          </keyData>
        </dsData>
        <dsData>
          <keyTag>123</keyTag>
          <alg>3</alg>
          <digestType>1</digestType>
          <digest>0D85A305D22FCB355BBE29AE9809363D697B64782B9CC73AE349350F8C2AE4BB</digest>
          <keyData>
            <flags>0</flags>
            <protocol>3</protocol>
            <alg>5</alg>
            <pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</pubKey>
          </keyData>
        </dsData>
      </infData>
    </extension>
    <trID>
      <svTRID>ccReg-9484163738</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain returns domain info with different nameservers  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="invalid">domain55.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}name', attribute 'hosts': [facet 'enumeration'] The value 'invalid' is not an element of the set {'all', 'del', 'none', 'sub'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}name', attribute 'hosts': 'invalid' is not a valid value of the atomic type '{https://epp.tld.ee/schema/domain-eis-1.0.xsd}hostsType'.</msg>
    </result>
    <trID>
      <svTRID>ccReg-6664642362</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="sub">domain55.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <name>domain55.ee</name>
        <roid>EIS-67</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT0861566953</registrant>
        <contact type="tech">FIXED:SH41938455124</contact>
        <contact type="admin">FIXED:SH51239690123</contact>
        <ns>
          <hostAttr>
            <hostName>ns1.domain55.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns2.domain55.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-28T08:41:31Z</crDate>
        <upDate>2015-07-28T08:41:31Z</upDate>
        <exDate>2016-07-28T08:41:31Z</exDate>
        <authInfo>
          <pw>1f00f9c3dd3137349c89cb6122fd2087</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-4706656698</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="del">domain55.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <name>domain55.ee</name>
        <roid>EIS-67</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT0861566953</registrant>
        <contact type="tech">FIXED:SH41938455124</contact>
        <contact type="admin">FIXED:SH51239690123</contact>
        <ns>
          <hostAttr>
            <hostName>ns3.test.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-28T08:41:31Z</crDate>
        <upDate>2015-07-28T08:41:31Z</upDate>
        <exDate>2016-07-28T08:41:31Z</exDate>
        <authInfo>
          <pw>1f00f9c3dd3137349c89cb6122fd2087</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-6524782384</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="none">domain55.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <name>domain55.ee</name>
        <roid>EIS-67</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT0861566953</registrant>
        <contact type="tech">FIXED:SH41938455124</contact>
        <contact type="admin">FIXED:SH51239690123</contact>
        <clID>registrar1</clID>
        <crDate>2015-07-28T08:41:31Z</crDate>
        <upDate>2015-07-28T08:41:31Z</upDate>
        <exDate>2016-07-28T08:41:31Z</exDate>
        <authInfo>
          <pw>1f00f9c3dd3137349c89cb6122fd2087</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-6513443999</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain55.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <name>domain55.ee</name>
        <roid>EIS-67</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT0861566953</registrant>
        <contact type="tech">FIXED:SH41938455124</contact>
        <contact type="admin">FIXED:SH51239690123</contact>
        <ns>
          <hostAttr>
            <hostName>ns1.domain55.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns2.domain55.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns3.test.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-28T08:41:31Z</crDate>
        <upDate>2015-07-28T08:41:31Z</upDate>
        <exDate>2016-07-28T08:41:31Z</exDate>
        <authInfo>
          <pw>1f00f9c3dd3137349c89cb6122fd2087</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-4393101167</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain returns error when domain can not be found  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Domain not found</msg>
      <value>
        <name>test.ee</name>
      </value>
    </result>
    <trID>
      <svTRID>ccReg-7830292127</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain sets ok status by default  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <name>domain56.ee</name>
        <roid>EIS-68</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT8926104554</registrant>
        <contact type="tech">FIXED:SH54896149126</contact>
        <contact type="admin">FIXED:SH80337499125</contact>
        <ns>
          <hostAttr>
            <hostName>ns.conroy168.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.bahringer169.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.kochhyatt170.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-28T08:41:33Z</crDate>
        <upDate>2015-07-28T08:41:33Z</upDate>
        <exDate>2016-07-28T08:41:33Z</exDate>
        <authInfo>
          <pw>da322dc86ce37e526f9c2dedc0f5c9f4</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-0824891046</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain can not see other registrar domains with invalid password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7661910824</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
    <trID>
      <svTRID>ccReg-8708797571</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2730417805</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain can see other registrar domains without password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0152975550</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain58.ee</domain:name>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <name>domain58.ee</name>
        <roid>EIS-70</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT2923781556</registrant>
        <contact type="tech">FIXED:SH74442662130</contact>
        <contact type="admin">FIXED:SH98223564129</contact>
        <ns>
          <hostAttr>
            <hostName>ns.wizastanton174.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.hermann175.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.mrazhintz176.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-28T08:41:33Z</crDate>
        <upDate>2015-07-28T08:41:33Z</upDate>
        <exDate>2016-07-28T08:41:33Z</exDate>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-5496759020</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5839948259</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain can see other registrar domains with correct password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9962481595</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain59.ee</domain:name>
        <domain:authInfo>
          <domain:pw>d1a0c13cf710ce60125dda34bc047357</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <name>domain59.ee</name>
        <roid>EIS-71</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT9338146457</registrant>
        <contact type="tech">FIXED:SH08033657132</contact>
        <contact type="admin">FIXED:SH95760244131</contact>
        <ns>
          <hostAttr>
            <hostName>ns.hansen177.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.bechtelar178.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.ryan179.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-28T08:41:34Z</crDate>
        <upDate>2015-07-28T08:41:34Z</upDate>
        <exDate>2016-07-28T08:41:34Z</exDate>
        <authInfo>
          <pw>d1a0c13cf710ce60125dda34bc047357</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-5565279418</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1086178421</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain deletes domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain60.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1001">
      <msg>Command completed successfully; action pending</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6748161709</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not delete domain with specific status  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <domain:delete xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain61.ee</domain:name>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Domain status prohibits operation</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3721491187</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not delete domain with pending delete  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Object status prohibits operation</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8985283918</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain does not delete domain without legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: extension &gt; extdata &gt; legalDocument [legal_document]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6341995809</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain checks a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <cd>
          <name avail="1">one.ee</name>
        </cd>
      </chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5323793544</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <check>
      <domain:check xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd">
        <domain:name>domain63.ee</domain:name>
      </domain:check>
    </check>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <cd>
          <name avail="0">domain63.ee</name>
          <reason>in use</reason>
        </cd>
      </chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9376664446</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain checks multiple domains  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <cd>
          <name avail="1">one.ee</name>
        </cd>
        <cd>
          <name avail="1">two.ee</name>
        </cd>
        <cd>
          <name avail="1">three.ee</name>
        </cd>
      </chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8665354623</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain checks invalid format domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <cd>
          <name avail="1">one.ee</name>
        </cd>
        <cd>
          <name avail="0">notcorrectdomain</name>
          <reason>invalid format</reason>
        </cd>
      </chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0776655399</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Helper in context of Domain generates valid transfer xml  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6119482698</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Keyrelay makes a keyrelay request  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>domain64.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>5a561b9d331c998c4f0383c7c67837be</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1M13D</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1438072899</ext:clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2307">
      <msg lang="en">Unimplemented object service</msg>
      <value>
        <name>domain64.ee</name>
      </value>
    </result>
    <trID>
      <clTRID>1438072899</clTRID>
      <svTRID>ccReg-0546548236</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Keyrelay returns an error when parameters are missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>domain64.ee</ext:name>
      <ext:keyData>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>5a561b9d331c998c4f0383c7c67837be</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>Invalid Expiry</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1438072900</ext:clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: keyrelay &gt; keyData &gt; flags [flags]</msg>
    </result>
    <result code="2005">
      <msg lang="en">Expiry relative must be compatible to ISO 8601</msg>
      <value>
        <relative>Invalid Expiry</relative>
      </value>
    </result>
    <trID>
      <clTRID>1438072900</clTRID>
      <svTRID>ccReg-6339589638</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Keyrelay returns an error on invalid relative expiry  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>domain64.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>5a561b9d331c998c4f0383c7c67837be</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>Invalid Expiry</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1438072901</ext:clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Expiry relative must be compatible to ISO 8601</msg>
      <value>
        <relative>Invalid Expiry</relative>
      </value>
    </result>
    <trID>
      <clTRID>1438072901</clTRID>
      <svTRID>ccReg-5588050715</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Keyrelay returns an error on invalid absolute expiry  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>domain64.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>5a561b9d331c998c4f0383c7c67837be</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:absolute>Invalid Absolute</ext:absolute>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1438072902</ext:clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Expiry absolute must be compatible to ISO 8601</msg>
      <value>
        <absolute>Invalid Absolute</absolute>
      </value>
    </result>
    <trID>
      <clTRID>1438072902</clTRID>
      <svTRID>ccReg-3072813596</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Keyrelay saves legal document with keyrelay  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>domain64.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>5a561b9d331c998c4f0383c7c67837be</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1D</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
      <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
    </eis:extdata>
    <ext:clTRID>1438072903</ext:clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2307">
      <msg lang="en">Unimplemented object service</msg>
      <value>
        <name>domain64.ee</name>
      </value>
    </result>
    <trID>
      <clTRID>1438072903</clTRID>
      <svTRID>ccReg-8005218060</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Keyrelay validates legal document types  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>domain64.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>5a561b9d331c998c4f0383c7c67837be</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1D</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <eis:extdata xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd">
      <eis:legalDocument type="jpg">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
    </eis:extdata>
    <ext:clTRID>1438072904</ext:clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Attribute is invalid: type</msg>
    </result>
    <trID>
      <clTRID>1438072904</clTRID>
      <svTRID>ccReg-7669723424</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7183215230</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Poll returns no messages in poll  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="req"/>
    <clTRID>1438072906</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1300">
      <msg>Command completed successfully; no messages</msg>
    </result>
    <trID>
      <clTRID>1438072906</clTRID>
      <svTRID>ccReg-0904688053</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Poll queues and dequeues messages  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9330176861</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="req"/>
    <clTRID>1438072906</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1300">
      <msg>Command completed successfully; no messages</msg>
    </result>
    <trID>
      <clTRID>1438072906</clTRID>
      <svTRID>ccReg-9666096812</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2827332510</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="req"/>
    <clTRID>1438072906</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="1" id="1">
      <qDate>2015-07-28T08:41:46Z</qDate>
      <msg>Balance low.</msg>
    </msgQ>
    <trID>
      <clTRID>1438072906</clTRID>
      <svTRID>ccReg-8105139529</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4202898264</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="ack" msgID="1"/>
    <clTRID>1438072906</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Message was not found</msg>
      <value>
        <msgID>1</msgID>
      </value>
    </result>
    <trID>
      <clTRID>1438072906</clTRID>
      <svTRID>ccReg-6713795149</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8383726441</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="ack" msgID="1"/>
    <clTRID>1438072906</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="0" id="1"/>
    <trID>
      <clTRID>1438072906</clTRID>
      <svTRID>ccReg-9660232901</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="ack" msgID="1"/>
    <clTRID>1438072906</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Message was not found</msg>
      <value>
        <msgID>1</msgID>
      </value>
    </result>
    <trID>
      <clTRID>1438072906</clTRID>
      <svTRID>ccReg-8436895537</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Poll returns an error on incorrect op  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="bla"/>
    <clTRID>1438072909</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{urn:ietf:params:xml:ns:epp-1.0}poll', attribute 'op': [facet 'enumeration'] The value 'bla' is not an element of the set {'ack', 'req'}.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{urn:ietf:params:xml:ns:epp-1.0}poll', attribute 'op': 'bla' is not a valid value of the atomic type '{urn:ietf:params:xml:ns:epp-1.0}pollOpType'.</msg>
    </result>
    <trID>
      <clTRID>1438072909</clTRID>
      <svTRID>ccReg-0720048091</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Poll dequeues multiple messages  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="req"/>
    <clTRID>1438072910</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="3" id="4">
      <qDate>2015-07-28T08:41:50Z</qDate>
      <msg>Smth else.</msg>
    </msgQ>
    <trID>
      <clTRID>1438072910</clTRID>
      <svTRID>ccReg-4999056673</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="ack" msgID="4"/>
    <clTRID>1438072910</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="2" id="4"/>
    <trID>
      <clTRID>1438072910</clTRID>
      <svTRID>ccReg-2484759210</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="req"/>
    <clTRID>1438072910</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="2" id="3">
      <qDate>2015-07-28T08:41:50Z</qDate>
      <msg>Something.</msg>
    </msgQ>
    <trID>
      <clTRID>1438072910</clTRID>
      <svTRID>ccReg-8852256138</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="ack" msgID="3"/>
    <clTRID>1438072910</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="1" id="3"/>
    <trID>
      <clTRID>1438072910</clTRID>
      <svTRID>ccReg-4857662573</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="req"/>
    <clTRID>1438072910</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="1" id="2">
      <qDate>2015-07-28T08:41:50Z</qDate>
      <msg>Balance low.</msg>
    </msgQ>
    <trID>
      <clTRID>1438072910</clTRID>
      <svTRID>ccReg-7845130069</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="ack" msgID="2"/>
    <clTRID>1438072910</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="0" id="2"/>
    <trID>
      <clTRID>1438072910</clTRID>
      <svTRID>ccReg-5213820888</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="req"/>
    <clTRID>1438072910</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1300">
      <msg>Command completed successfully; no messages</msg>
    </result>
    <trID>
      <clTRID>1438072910</clTRID>
      <svTRID>ccReg-5526530522</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when not connected greets client upon connection  

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <greeting>
    <svID>EPP server (EIS)</svID>
    <svDate>2015-07-28T08:41:50Z</svDate>
    <svcMenu>
      <version>1.0</version>
      <lang>en</lang>
      <objURI>https://epp.tld.ee/schema/domain-eis-1.0.xsd</objURI>
      <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
      <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
      <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2501">
      <msg lang="en">Authentication error; server closing connection (API user not found)</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3357021379</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected does not log in with inactive user  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2501">
      <msg lang="en">Authentication error; server closing connection (API user is not active)</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7648731033</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected prohibits further actions unless logged in  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2002">
      <msg lang="en">You need to login first.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9110727237</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected should not have clTRID in response if client does not send it  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2501">
      <msg lang="en">Authentication error; server closing connection (API user not found)</msg>
    </result>
    <trID>
      <svTRID>ccReg-3560736149</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected should return latin only error  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Parameter value policy error. Allowed only Latin characters.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9604669451</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected with valid user logs in epp user  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2841249388</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected with valid user does not log in twice  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7967943283</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2002">
      <msg lang="en">Already logged in. Use &lt;logout&gt; first.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8815596190</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected with valid user logs out epp user  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3572848696</svTRID>
    </trID>
  </response>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <logout/>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1500">
      <msg>Command completed successfully; ending session</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9539000551</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected with valid user changes password and logs in  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6256430973</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Session when connected with valid user fails if new password is not valid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
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
        <objURI>https://epp.tld.ee/schema/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
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
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Element '{urn:ietf:params:xml:ns:epp-1.0}newPW': [facet 'minLength'] The value has a length of '0'; this underruns the allowed minimum length of '6'.</msg>
    </result>
    <result code="2001">
      <msg lang="en">Element '{urn:ietf:params:xml:ns:epp-1.0}newPW': '' is not a valid value of the atomic type '{urn:ietf:params:xml:ns:epp-1.0}pwType'.</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6382004519</svTRID>
    </trID>
  </response>
</epp>
```

