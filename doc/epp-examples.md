# EPP REQUEST - RESPONSE EXAMPLES
GENERATED AT: 2015-07-13 08:09:38 UTC  
EXAMPLE COUNT: 177  

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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-0618295689</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd"/>
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
      <msg lang="en">Required parameter missing: create &gt; create &gt; postalInfo &gt; name [name]</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; postalInfo &gt; addr &gt; street [street]</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; postalInfo &gt; addr &gt; city [city]</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; postalInfo &gt; addr &gt; pc [pc]</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; postalInfo &gt; addr &gt; cc [cc]</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; voice [voice]</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: create &gt; create &gt; email [email]</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: extension &gt; extdata &gt; ident [ident]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2870310688</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <id>FIRST0:39FDCF9F</id>
        <crDate>2015-07-13T08:09:40Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5460080031</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <id>FIRST0:D94B3B80</id>
        <crDate>2015-07-13T08:09:40Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1701802241</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <id>FIRST0:8EB9FF1C</id>
        <crDate>2015-07-13T08:09:40Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4899452053</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <id>FIRST0:CC224814</id>
        <crDate>2015-07-13T08:09:40Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4861590993</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <crDate>2015-07-13T08:09:40Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5935450848</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <crDate>2015-07-13T08:09:40Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2686282727</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-8146651939</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
    <result code="2005">
      <msg lang="en">Ident country code is not valid, should be in ISO_3166-1 alpha 2 format [ident]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5581241527</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <crDate>2015-07-13T08:09:43Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7844818405</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <crDate>2015-07-13T08:09:43Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9977379702</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <crDate>2015-07-13T08:09:43Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5280988354</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <crDate>2015-07-13T08:09:43Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2496065899</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <crDate>2015-07-13T08:09:43Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6105084302</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <id>FIRST0:BD65CE88</id>
        <crDate>2015-07-13T08:09:43Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7730845183</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <id>FIRST0:32CC6124</id>
        <crDate>2015-07-13T08:09:43Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5965537420</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-6428920407</svTRID>
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
      <contact:create xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-7656849449</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd"/>
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
      <msg lang="en">Required parameter missing: add, rem or chg</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: update &gt; update &gt; id [id]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2056150890</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-1334382115</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <crDate>2015-07-13T08:09:45Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2833711488</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
        <crDate>2015-07-13T08:09:45Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2702640931</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9141239618</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <crDate>2015-07-13T08:09:45Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9170655194</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9045686845</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-3102023477</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <svTRID>ccReg-5108760843</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-8619274236</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-4679507984</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <id>FIRST0:SH8013NOTPOSSIBLETOUPDATE</id>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1149916612</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-3709656481</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-7193966819</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-8289884012</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:add>
          <contact:status s="clientHold" lang="en">Payment overdue.</contact:status>
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
      <svTRID>ccReg-5602755069</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
        <crDate>2015-07-13T08:09:45Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9494548866</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <svTRID>ccReg-3793177760</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:SH8013</id>
        <crDate>2015-07-13T08:09:45Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9626068041</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <svTRID>ccReg-9232532819</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
    <result code="2003">
      <msg lang="en">Required parameter missing - phone [phone]</msg>
    </result>
    <result code="2005">
      <msg lang="en">Phone nr is invalid [phone]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9780958644</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:SH8013</id>
        <crDate>2015-07-13T08:09:45Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9339539428</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:SH8013</id>
        <crDate>2015-07-13T08:09:45Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1811284213</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:SH8013</id>
        <crDate>2015-07-13T08:09:45Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7287677937</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>FIRST0:SH8013</id>
        <crDate>2015-07-13T08:09:45Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3365372793</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH8013</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
        <contact:rem>
          <contact:postalInfo>
            <contact:org>not important</contact:org>
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
    <result code="2306">
      <msg lang="en">Parameter value policy error. Org must be blank: postalInfo &gt; org [org]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1219827368</svTRID>
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
      <contact:update xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
    <result code="2003">
      <msg lang="en">Required parameter missing - name [name]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3971655755</svTRID>
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
      <contact:delete xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd"/>
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
      <msg lang="en">Required parameter missing: delete &gt; delete &gt; id [id]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8754962923</svTRID>
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
      <contact:delete xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>not-exists</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-9819373260</svTRID>
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
      <contact:delete xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH510454133</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-7214487869</svTRID>
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
      <contact:delete xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH503034294</contact:id>
        <contact:authInfo>
          <contact:pw>wrong password</contact:pw>
        </contact:authInfo>
      </contact:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-3122380030</svTRID>
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
      <contact:delete xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH673355085</contact:id>
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
      <svTRID>ccReg-1862227156</svTRID>
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
      <contact:delete xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH268059126</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-2654739015</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-7333416442</svTRID>
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
      <contact:delete xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH909522549</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
      </contact:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-0590479812</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-5714766005</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-8540093009</svTRID>
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
      <contact:delete xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH9262555410</contact:id>
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
      <svTRID>ccReg-9788975407</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-0232934407</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-1649878002</svTRID>
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
      <contact:delete xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH6216347011</contact:id>
        <contact:authInfo>
          <contact:pw>wrong password</contact:pw>
        </contact:authInfo>
      </contact:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-8638671941</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-0461625368</svTRID>
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
      <contact:check xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd"/>
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
    <result code="2003">
      <msg lang="en">Required parameter missing: check &gt; check &gt; id [id]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7185406208</svTRID>
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
          <contact:check xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <svTRID>ccReg-1361275825</svTRID>
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
          <contact:check xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <svTRID>ccReg-5807230391</svTRID>
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
      <contact:info xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd"/>
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
    <result code="2003">
      <msg lang="en">Required parameter missing: info &gt; info &gt; id [id]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9534409035</svTRID>
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
      <contact:info xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
      <svTRID>ccReg-0503118697</svTRID>
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
      <contact:info xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
        <email>mikel_schmidt@daugherty.biz</email>
        <clID>fixed registrar</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-13T08:10:04Z</crDate>
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
      <svTRID>ccReg-8819586690</svTRID>
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
      <contact:info xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
        <email>mikel_schmidt@daugherty.biz</email>
        <clID>fixed registrar</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-13T08:10:04Z</crDate>
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
      <svTRID>ccReg-0635458096</svTRID>
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
      <contact:info xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
        <email>mikel_schmidt@daugherty.biz</email>
        <clID>registrar1</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-13T08:10:04Z</crDate>
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
      <svTRID>ccReg-6424655076</svTRID>
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
      <contact:info xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH282362170</contact:id>
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
        <id>FIRST0:SH282362170</id>
        <roid>EIS-1</roid>
        <status s="ok"/>
        <postalInfo type="int">
          <name>Brandon Gutkowski0</name>
          <addr>
            <street>Short street 11</street>
            <city>Tallinn</city>
            <sp/>
            <pc>11111</pc>
            <cc>EE</cc>
          </addr>
        </postalInfo>
        <voice>+372.12345678</voice>
        <email>mikel_schmidt@daugherty.biz</email>
        <clID>registrar1</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-13T08:09:39Z</crDate>
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
      <svTRID>ccReg-6150961261</svTRID>
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
      <contact:info xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
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
          <name>Hans Dooley15</name>
          <addr>
            <street>Short street 11</street>
            <city>Tallinn</city>
            <sp/>
            <pc>11111</pc>
            <cc>EE</cc>
          </addr>
        </postalInfo>
        <voice>+372.12345678</voice>
        <email>mikel_schmidt@daugherty.biz</email>
        <clID>fixed registrar</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-13T08:10:04Z</crDate>
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
      <svTRID>ccReg-5948603765</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9055288154</svTRID>
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
      <contact:info xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH282362170</contact:id>
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
        <id>FIRST0:SH282362170</id>
        <roid>EIS-1</roid>
        <status s="ok"/>
        <postalInfo type="int">
          <name>Brandon Gutkowski0</name>
          <addr>
            <street>Short street 11</street>
            <city>Tallinn</city>
            <sp/>
            <pc>11111</pc>
            <cc>EE</cc>
          </addr>
        </postalInfo>
        <voice>+372.12345678</voice>
        <email>mikel_schmidt@daugherty.biz</email>
        <clID>registrar1</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-13T08:09:39Z</crDate>
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
      <svTRID>ccReg-3649803181</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-1933675184</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-5420323891</svTRID>
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
      <contact:info xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH282362170</contact:id>
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
      <svTRID>ccReg-4827213455</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-7118835839</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9117613031</svTRID>
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
      <contact:info xmlns:contact="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd">
        <contact:id>FIRST0:SH282362170</contact:id>
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
        <id>FIRST0:SH282362170</id>
        <roid>EIS-1</roid>
        <status s="ok"/>
        <postalInfo type="int">
          <name>Brandon Gutkowski0</name>
        </postalInfo>
        <clID>registrar1</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-07-13T08:09:39Z</crDate>
      </infData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1234334129</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-2736288018</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9795814246</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example8141781761361142.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-5775792464</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example25336679785374406.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-1869400002</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <svTRID>ccReg-3527497563</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example49861011752583930.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <name>example49861011752583930.ee</name>
        <crDate>2015-07-13T08:10:08Z</crDate>
        <exDate>2016-07-13T08:10:08Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2908644272</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example52367797551189787.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <name>example52367797551189787.ee</name>
        <crDate>2015-07-13T08:10:09Z</crDate>
        <exDate>2016-07-13T08:10:09Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7361617669</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example95532387633828733.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example95532387633828733.ee</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example95532387633828733.ee</domain:hostName>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-9261817668</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-6772570562</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-3733065800</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-7112576450</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <crDate>2015-07-13T08:10:13Z</crDate>
        <exDate>2016-07-13T08:10:13Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5049259745</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-0819724563</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example66869374929851351.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-1539701883</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example46569369919922504.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-6017666451</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example9775945649237234.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-2484227692</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example25543970040464568.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-0271766119</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example83419576189614996.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-7801167272</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example78746795673349410.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <name>example78746795673349410.ee</name>
        <crDate>2015-07-13T08:10:20Z</crDate>
        <exDate>2016-07-13T08:10:20Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7812759820</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example86459993736024103.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-0770361263</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example77378499664954502.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <name>example77378499664954502.ee</name>
        <crDate>2015-07-13T08:10:22Z</crDate>
        <exDate>2016-07-13T08:10:22Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2279305615</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example91344146443917444.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <name>example91344146443917444.ee</name>
        <crDate>2015-07-13T08:10:22Z</crDate>
        <exDate>2017-07-13T08:10:22Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7948856904</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example37678434336097153.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <name>example37678434336097153.ee</name>
        <crDate>2015-07-13T08:10:22Z</crDate>
        <exDate>2018-07-13T08:10:22Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0923978415</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example16191991725339317.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-3982837408</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example40866032952252613.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <name>example40866032952252613.ee</name>
        <crDate>2015-07-13T08:10:23Z</crDate>
        <exDate>2016-07-13T08:10:23Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9573434963</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example9781392118411734.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
    <result code="2306">
      <msg lang="en">Public key is missing [public_key]</msg>
    </result>
    <result code="2005">
      <msg lang="en">Valid protocols are: 3 [protocol]</msg>
      <value>
        <protocol>5</protocol>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6068485630</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example82547809365634736.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-6743869283</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example24299031431104455.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-4538001040</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example86624189051768810.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <name>example86624189051768810.ee</name>
        <crDate>2015-07-13T08:10:27Z</crDate>
        <exDate>2016-07-13T08:10:27Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4356869009</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example70522154515526376.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <name>example70522154515526376.ee</name>
        <crDate>2015-07-13T08:10:27Z</crDate>
        <exDate>2016-07-13T08:10:27Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0834839872</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example11125999187215251.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-4189398038</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example58593539019684182.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-1718210348</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example83982312915963874.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <msg lang="en">Mutually exclusive parameters: extension &gt; create &gt; keyData, extension &gt; create &gt; dsData</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2950027969</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example46238990207964440.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <name>example46238990207964440.ee</name>
        <crDate>2015-07-13T08:10:31Z</crDate>
        <exDate>2016-07-13T08:10:31Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0620001088</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example88328132023816416.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-4854981199</svTRID>
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
      <domain:create xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example63410537948779137.ee</domain:name>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-1289788540</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9947034870</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain1.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">a6c1a37f9466f510bc45a6f9b9d0095e</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <reDate>2015-07-13T08:10:33Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:33Z</acDate>
        <exDate>2016-07-13T08:10:33Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7553127734</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-0227567769</svTRID>
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
      <qDate>2015-07-13T08:10:33Z</qDate>
      <msg>Domain transfer was approved, associated contacts were: ["FIXED:SH2458466313", "FIXED:SH6857426112"] and registrant was FIXED:REGISTRANT240360470</msg>
    </msgQ>
    <resData>
      <trnData>
        <name>domain1.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-07-13T08:10:33Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:33Z</acDate>
        <exDate>2016-07-13T08:10:33Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5437902047</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain1.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">a79127ff7dc2919c88c697cdfbdf0b08</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <reDate>2015-07-13T08:10:34Z</reDate>
        <acID>REGDOMAIN2</acID>
        <acDate>2015-07-13T09:10:34Z</acDate>
        <exDate>2016-07-13T08:10:33Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7214241560</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain1.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">a79127ff7dc2919c88c697cdfbdf0b08</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <reDate>2015-07-13T08:10:34Z</reDate>
        <acID>REGDOMAIN2</acID>
        <acDate>2015-07-13T09:10:34Z</acDate>
        <exDate>2016-07-13T08:10:33Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6123955551</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-6308918955</svTRID>
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
      <qDate>2015-07-13T08:10:34Z</qDate>
      <msg>Transfer requested.</msg>
    </msgQ>
    <resData>
      <trnData>
        <name>domain1.ee</name>
        <trStatus>pending</trStatus>
        <reID>REGDOMAIN1</reID>
        <reDate>2015-07-13T08:10:34Z</reDate>
        <acID>REGDOMAIN2</acID>
        <acDate>2015-07-13T09:10:34Z</acDate>
        <exDate>2016-07-13T08:10:33Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9560017151</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9032834985</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9332036940</svTRID>
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
      <svTRID>ccReg-8727580885</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-4349221001</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-5525442277</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain2.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">55293c4e006ab91a8bb56ad2c3b542e8</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <reDate>2015-07-13T08:10:34Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T09:10:34Z</acDate>
        <exDate>2016-07-13T08:10:34Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3032166853</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-0266707351</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9904220818</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain2.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">55293c4e006ab91a8bb56ad2c3b542e8</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <reDate>2015-07-13T08:10:34Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T09:10:34Z</acDate>
        <exDate>2016-07-13T08:10:34Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4891125991</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-6334747073</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-8881009763</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain3.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">0eb7555f7484fec80ed502a2b3ba5be9</domain:pw>
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
        <reDate>2015-07-13T08:10:35Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:35Z</acDate>
        <exDate>2016-07-13T08:10:35Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0400376668</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-0112443198</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9031704497</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain4.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">04edcd706724ed5d0de9642788995eee</domain:pw>
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
        <reDate>2015-07-13T08:10:35Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:35Z</acDate>
        <exDate>2016-07-13T08:10:35Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8391034505</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-7638487821</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-4526950665</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain5.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">9d0219c5b0c128c86608c85c44f11e55</domain:pw>
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
        <reDate>2015-07-13T08:10:36Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:36Z</acDate>
        <exDate>2016-07-13T08:10:36Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5537786370</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-8635372653</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-2387752429</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain8.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">97a9ceb244b35347929aa1561ead4c8b</domain:pw>
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
        <reDate>2015-07-13T08:10:36Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:36Z</acDate>
        <exDate>2016-07-13T08:10:36Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0632987427</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9801073653</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-5308734025</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain9.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">5a41b6437a25e0d9411403c06c18f33c</domain:pw>
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
        <reDate>2015-07-13T08:10:37Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:37Z</acDate>
        <exDate>2016-07-13T08:10:37Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1676191553</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-3121793274</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-7602205334</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain11.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">6a9bfed8e96b212f1de718bd4979b39a</domain:pw>
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
        <reDate>2015-07-13T08:10:37Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:37Z</acDate>
        <exDate>2016-07-13T08:10:37Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7258212831</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-1615959934</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-4400024318</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain14.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">5d5ba19df5b5411f99236a493ef22a5c</domain:pw>
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
        <reDate>2015-07-13T08:10:38Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:38Z</acDate>
        <exDate>2016-07-13T08:10:38Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9169504885</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-8687650026</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-8275992139</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain15.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">0a63b7c0a6d070aba600c1233b74780e</domain:pw>
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
        <reDate>2015-07-13T08:10:39Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:39Z</acDate>
        <exDate>2016-07-13T08:10:38Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7177786070</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9291043231</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-1485507026</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <svTRID>ccReg-0431836855</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-4670728995</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain17.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">78a5ec49ace3acba7d9f00f07b42843b</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <reDate>2015-07-13T08:10:39Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:39Z</acDate>
        <exDate>2016-07-13T08:10:39Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7636473741</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-6002706539</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain18.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">36db07e5d50c74825a890736522b8ff5</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-8962204090</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-4895590684</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain18.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">36db07e5d50c74825a890736522b8ff5</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <reDate>2015-07-13T08:10:39Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:39Z</acDate>
        <exDate>2016-07-13T08:10:39Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2744955362</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-6291768376</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain19.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">ab440e4d641fdb8309ee06212014f08c</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-1456367772</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-3133112737</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain20.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">test</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-9979904031</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain21.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">fec6806502193b6797015e58f6720cd6</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-8875125353</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>example59798550307607834.ee</domain:name>
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
    <result code="2004">
      <msg lang="en">Parameter value range error: op</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7685901733</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-5540138016</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain22.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">5c974420af9eaed0828c12290a1982ad</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <reDate>2015-07-13T08:10:44Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:44Z</acDate>
        <exDate>2016-07-13T08:10:44Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4135314212</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain22.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">5c974420af9eaed0828c12290a1982ad</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-9874991967</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-5290054570</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain23.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">f147990f98219469538d22370f6678db</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-5805802380</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain24.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">b37a01669b03f47168dc04d231f58e10</domain:pw>
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
      <svTRID>ccReg-3524664626</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-5541426382</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain25.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">51ae1a97a223f79283c466efa66d9f29</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <reDate>2015-07-13T08:10:47Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T09:10:47Z</acDate>
        <exDate>2016-07-13T08:10:47Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7762900615</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain25.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">51ae1a97a223f79283c466efa66d9f29</domain:pw>
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
        <reDate>2015-07-13T08:10:47Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T09:10:47Z</acDate>
        <exDate>2016-07-13T08:10:47Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6766932145</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-6659036116</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain25.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">51ae1a97a223f79283c466efa66d9f29</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
        <reDate>2015-07-13T08:10:47Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:48Z</acDate>
        <exDate>2016-07-13T08:10:47Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0997071800</svTRID>
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
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain25.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">2b13bca2ffba6d50141100fd2a6d2cfb</domain:pw>
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
        <reDate>2015-07-13T08:10:47Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-07-13T08:10:48Z</acDate>
        <exDate>2016-07-13T08:10:47Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0170230306</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain26.ee</domain:name>
        <domain:chg>
          <domain:registrant verified="yes">FIXED:CITIZEN_1234</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-4927090089</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain27.ee</domain:name>
        <domain:chg>
          <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-5939193255</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain28.ee</domain:name>
        <domain:rem>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns.lowe86.ee</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns.von85.ee</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns.mayert84.ee</domain:hostName>
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-1902697655</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain29.ee</domain:name>
        <domain:chg>
          <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-3416538565</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain30.ee</domain:name>
        <domain:chg>
          <domain:registrant>FIXED:CITIZEN_1234</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-8628956364</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain31.ee</domain:name>
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
      <svTRID>ccReg-1167119793</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain31.ee</domain:name>
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
      <svTRID>ccReg-2401442001</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain31.ee</domain:name>
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
        <pubKey>841936717ae427ace63c28d04918569a841936717ae427ace63c28d0</pubKey>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Public key already exists [public_key]</msg>
      <value>
        <pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</pubKey>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3219643667</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-9234642721</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-1807566212</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain33.ee</domain:name>
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
      <svTRID>ccReg-7613379343</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <svTRID>ccReg-3729650879</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain34.ee</domain:name>
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
      <svTRID>ccReg-6699726145</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain34.ee</domain:name>
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
      <svTRID>ccReg-8491953228</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain35.ee</domain:name>
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
      <svTRID>ccReg-8239034275</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain36.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns.lockman105.ee</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="admin">FIXED:SH1552152183</domain:contact>
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
      <svTRID>ccReg-5647276544</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain36.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns.lockman105.ee</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="admin">FIXED:SH1552152183</domain:contact>
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
        <hostAttr>ns.lockman105.ee</hostAttr>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Contact already exists on this domain [contact_code_cache]</msg>
      <value>
        <contact>FIXED:SH1552152183</contact>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7429213220</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain37.ee</domain:name>
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
      <svTRID>ccReg-6346019419</svTRID>
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
      <domain:update xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain38.ee</domain:name>
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
    <result code="2303">
      <msg lang="en">Status was not found</msg>
      <value>
        <status>invalidStatus</status>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9819005325</svTRID>
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
      <domain:renew xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain39.ee</domain:name>
        <domain:curExpDate>2015-07-23</domain:curExpDate>
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
        <name>domain39.ee</name>
        <exDate>2016-07-23T00:00:00Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7220541028</svTRID>
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
      <domain:renew xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain40.ee</domain:name>
        <domain:curExpDate>2015-07-23</domain:curExpDate>
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
        <name>domain40.ee</name>
        <exDate>2017-07-23T00:00:00Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6857657669</svTRID>
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
      <domain:renew xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain41.ee</domain:name>
        <domain:curExpDate>2015-07-23</domain:curExpDate>
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
        <name>domain41.ee</name>
        <exDate>2018-07-23T00:00:00Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1769374464</svTRID>
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
      <domain:renew xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain42.ee</domain:name>
        <domain:curExpDate>2015-07-23</domain:curExpDate>
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
      <svTRID>ccReg-4109711014</svTRID>
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
      <domain:renew xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain43.ee</domain:name>
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
      <svTRID>ccReg-2628108471</svTRID>
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
      <domain:renew xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain44.ee</domain:name>
        <domain:curExpDate>2015-07-23</domain:curExpDate>
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
      <svTRID>ccReg-2767217341</svTRID>
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
      <domain:renew xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain45.ee</domain:name>
        <domain:curExpDate>2015-10-11</domain:curExpDate>
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
      <svTRID>ccReg-1810374134</svTRID>
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
      <domain:renew xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain45.ee</domain:name>
        <domain:curExpDate>2015-10-10</domain:curExpDate>
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
        <name>domain45.ee</name>
        <exDate>2016-10-10T00:00:00Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0911571437</svTRID>
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
      <domain:renew xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain46.ee</domain:name>
        <domain:curExpDate>2020-07-13</domain:curExpDate>
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
        <name>domain46.ee</name>
        <exDate>2021-07-13T00:00:00Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2422169680</svTRID>
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
      <domain:renew xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain47.ee</domain:name>
        <domain:curExpDate>2015-07-23</domain:curExpDate>
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
      <svTRID>ccReg-0194027285</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain should renew a expired domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain48.ee</domain:name>
        <domain:curExpDate>2015-05-24</domain:curExpDate>
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
        <name>domain48.ee</name>
        <exDate>2016-05-24T08:11:10Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2793752469</svTRID>
    </trID>
  </response>
</epp>
```

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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9025280022</svTRID>
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
      <domain:renew xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain49.ee</domain:name>
        <domain:curExpDate>2016-07-13</domain:curExpDate>
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
      <svTRID>ccReg-6272603612</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-7742341031</svTRID>
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
      <domain:info xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain50.ee</domain:name>
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
        <name>domain50.ee</name>
        <roid>EIS-61</roid>
        <status s="clientHold"/>
        <registrant>FIXED:REGISTRANT6482132848</registrant>
        <contact type="tech">FIXED:SH09572943114</contact>
        <contact type="admin">FIXED:SH87989459113</contact>
        <ns>
          <hostAttr>
            <hostName>ns.mann150.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.gibson151.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.bergnaum152.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns1.example.com</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-13T08:11:11Z</crDate>
        <upDate>2015-07-13T08:11:11Z</upDate>
        <exDate>2016-07-13T08:11:11Z</exDate>
        <authInfo>
          <pw>5957310332b7a7eecb8ba4514ec2b500</pw>
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
      <svTRID>ccReg-8376341695</svTRID>
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
      <domain:info xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain50.ee</domain:name>
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
        <name>domain50.ee</name>
        <roid>EIS-61</roid>
        <status s="clientHold"/>
        <registrant>FIXED:REGISTRANT6482132848</registrant>
        <contact type="tech">FIXED:SH09572943114</contact>
        <contact type="admin">FIXED:SH87989459113</contact>
        <ns>
          <hostAttr>
            <hostName>ns.mann150.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.gibson151.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.bergnaum152.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns1.example.com</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-13T08:11:11Z</crDate>
        <upDate>2015-07-13T08:11:11Z</upDate>
        <exDate>2016-07-13T08:11:11Z</exDate>
        <authInfo>
          <pw>5957310332b7a7eecb8ba4514ec2b500</pw>
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
      <svTRID>ccReg-3233264315</svTRID>
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
      <domain:info xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name hosts="invalid">domain51.ee</domain:name>
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
    <result code="2306">
      <msg lang="en">Attribute is invalid: hosts</msg>
    </result>
    <trID>
      <svTRID>ccReg-8690139061</svTRID>
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
      <domain:info xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name hosts="sub">domain51.ee</domain:name>
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
        <name>domain51.ee</name>
        <roid>EIS-62</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT2667536449</registrant>
        <contact type="tech">FIXED:SH94654914116</contact>
        <contact type="admin">FIXED:SH61833805115</contact>
        <ns>
          <hostAttr>
            <hostName>ns1.domain51.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns2.domain51.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-13T08:11:11Z</crDate>
        <upDate>2015-07-13T08:11:11Z</upDate>
        <exDate>2016-07-13T08:11:11Z</exDate>
        <authInfo>
          <pw>9d30e698ec98687e28804e22d659af30</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-6365400804</svTRID>
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
      <domain:info xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name hosts="del">domain51.ee</domain:name>
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
        <name>domain51.ee</name>
        <roid>EIS-62</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT2667536449</registrant>
        <contact type="tech">FIXED:SH94654914116</contact>
        <contact type="admin">FIXED:SH61833805115</contact>
        <ns>
          <hostAttr>
            <hostName>ns3.test.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-13T08:11:11Z</crDate>
        <upDate>2015-07-13T08:11:11Z</upDate>
        <exDate>2016-07-13T08:11:11Z</exDate>
        <authInfo>
          <pw>9d30e698ec98687e28804e22d659af30</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-9998409461</svTRID>
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
      <domain:info xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name hosts="none">domain51.ee</domain:name>
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
        <name>domain51.ee</name>
        <roid>EIS-62</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT2667536449</registrant>
        <contact type="tech">FIXED:SH94654914116</contact>
        <contact type="admin">FIXED:SH61833805115</contact>
        <clID>registrar1</clID>
        <crDate>2015-07-13T08:11:11Z</crDate>
        <upDate>2015-07-13T08:11:11Z</upDate>
        <exDate>2016-07-13T08:11:11Z</exDate>
        <authInfo>
          <pw>9d30e698ec98687e28804e22d659af30</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-1755029994</svTRID>
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
      <domain:info xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain51.ee</domain:name>
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
        <name>domain51.ee</name>
        <roid>EIS-62</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT2667536449</registrant>
        <contact type="tech">FIXED:SH94654914116</contact>
        <contact type="admin">FIXED:SH61833805115</contact>
        <ns>
          <hostAttr>
            <hostName>ns1.domain51.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns2.domain51.ee</hostName>
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
        <crDate>2015-07-13T08:11:11Z</crDate>
        <upDate>2015-07-13T08:11:11Z</upDate>
        <exDate>2016-07-13T08:11:11Z</exDate>
        <authInfo>
          <pw>9d30e698ec98687e28804e22d659af30</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-3118580746</svTRID>
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
      <domain:info xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <svTRID>ccReg-1733768523</svTRID>
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
      <domain:info xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain52.ee</domain:name>
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
        <name>domain52.ee</name>
        <roid>EIS-63</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT2342249650</registrant>
        <contact type="tech">FIXED:SH20249682118</contact>
        <contact type="admin">FIXED:SH18642279117</contact>
        <ns>
          <hostAttr>
            <hostName>ns.lakin156.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.hartmann157.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.kuhicemmerich158.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-13T08:11:13Z</crDate>
        <upDate>2015-07-13T08:11:13Z</upDate>
        <exDate>2016-07-13T08:11:13Z</exDate>
        <authInfo>
          <pw>1461c4b264196cd03804c940733dc38a</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-3963429650</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-3669004177</svTRID>
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
      <domain:info xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain53.ee</domain:name>
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
      <svTRID>ccReg-7057482646</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-3127374780</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-0437688297</svTRID>
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
      <domain:info xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain54.ee</domain:name>
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
        <roid>EIS-65</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT3313756852</registrant>
        <contact type="tech">FIXED:SH50852734122</contact>
        <contact type="admin">FIXED:SH63024484121</contact>
        <ns>
          <hostAttr>
            <hostName>ns.harber162.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.gutmanngrady163.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.block164.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-13T08:11:13Z</crDate>
        <upDate>2015-07-13T08:11:13Z</upDate>
        <exDate>2016-07-13T08:11:13Z</exDate>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-5268249056</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-2996369133</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-2348926042</svTRID>
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
      <domain:info xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name hosts="all">domain55.ee</domain:name>
        <domain:authInfo>
          <domain:pw>70fdd52cf30cb84607b091c211508b3e</domain:pw>
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
        <roid>EIS-66</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT4048132253</registrant>
        <contact type="tech">FIXED:SH48069556124</contact>
        <contact type="admin">FIXED:SH18507922123</contact>
        <ns>
          <hostAttr>
            <hostName>ns.kuhlman165.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.howe166.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.bradtkehyatt167.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-07-13T08:11:13Z</crDate>
        <upDate>2015-07-13T08:11:13Z</upDate>
        <exDate>2016-07-13T08:11:13Z</exDate>
        <authInfo>
          <pw>70fdd52cf30cb84607b091c211508b3e</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-1792551087</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-6746329954</svTRID>
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
      <domain:delete xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain56.ee</domain:name>
      </domain:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-4342498296</svTRID>
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
      <domain:delete xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain57.ee</domain:name>
      </domain:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-7883262615</svTRID>
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
      <domain:delete xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain58.ee</domain:name>
      </domain:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
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
      <svTRID>ccReg-0920548662</svTRID>
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
      <domain:delete xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <svTRID>ccReg-0781777028</svTRID>
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
      <domain:check xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <svTRID>ccReg-3611796311</svTRID>
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
      <domain:check xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain59.ee</domain:name>
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
          <name avail="0">domain59.ee</name>
          <reason>in use</reason>
        </cd>
      </chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3334019851</svTRID>
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
      <domain:check xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <svTRID>ccReg-0064719758</svTRID>
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
      <domain:check xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <svTRID>ccReg-0603882179</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-0885284769</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Keyrelay makes a keyrelay request  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>domain60.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>fabc7a8ebef505abcb469833f145e84c</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1M13D</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1436775078</ext:clTRID>
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
        <name>domain60.ee</name>
      </value>
    </result>
    <trID>
      <clTRID>1436775078</clTRID>
      <svTRID>ccReg-9036054194</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Keyrelay returns an error when parameters are missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>domain60.ee</ext:name>
      <ext:keyData>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>fabc7a8ebef505abcb469833f145e84c</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>Invalid Expiry</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1436775079</ext:clTRID>
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
      <clTRID>1436775079</clTRID>
      <svTRID>ccReg-0012228718</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Keyrelay returns an error on invalid relative expiry  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>domain60.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>fabc7a8ebef505abcb469833f145e84c</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>Invalid Expiry</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1436775081</ext:clTRID>
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
      <clTRID>1436775081</clTRID>
      <svTRID>ccReg-3299050163</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Keyrelay returns an error on invalid absolute expiry  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>domain60.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>fabc7a8ebef505abcb469833f145e84c</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:absolute>Invalid Absolute</ext:absolute>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1436775082</ext:clTRID>
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
      <clTRID>1436775082</clTRID>
      <svTRID>ccReg-5674703725</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Keyrelay saves legal document with keyrelay  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>domain60.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>fabc7a8ebef505abcb469833f145e84c</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1D</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
      <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
    </eis:extdata>
    <ext:clTRID>1436775083</ext:clTRID>
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
        <name>domain60.ee</name>
      </value>
    </result>
    <trID>
      <clTRID>1436775083</clTRID>
      <svTRID>ccReg-4889072298</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Keyrelay validates legal document types  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>domain60.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>fabc7a8ebef505abcb469833f145e84c</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1D</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
      <eis:legalDocument type="jpg">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
    </eis:extdata>
    <ext:clTRID>1436775084</ext:clTRID>
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
      <clTRID>1436775084</clTRID>
      <svTRID>ccReg-3763435235</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-8391468842</svTRID>
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
    <clTRID>1436775085</clTRID>
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
      <clTRID>1436775085</clTRID>
      <svTRID>ccReg-5223012602</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-1644113251</svTRID>
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
    <clTRID>1436775085</clTRID>
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
      <clTRID>1436775085</clTRID>
      <svTRID>ccReg-7422031286</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9135374868</svTRID>
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
    <clTRID>1436775085</clTRID>
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
      <qDate>2015-07-13T08:11:25Z</qDate>
      <msg>Balance low.</msg>
    </msgQ>
    <trID>
      <clTRID>1436775085</clTRID>
      <svTRID>ccReg-0576977561</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-9969074675</svTRID>
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
    <clTRID>1436775085</clTRID>
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
      <clTRID>1436775085</clTRID>
      <svTRID>ccReg-4944273043</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-1529649635</svTRID>
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
    <clTRID>1436775085</clTRID>
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
      <clTRID>1436775085</clTRID>
      <svTRID>ccReg-9499020661</svTRID>
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
    <clTRID>1436775085</clTRID>
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
      <clTRID>1436775085</clTRID>
      <svTRID>ccReg-3165481294</svTRID>
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
    <clTRID>1436775088</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">Parameter value range error: op</msg>
    </result>
    <trID>
      <clTRID>1436775088</clTRID>
      <svTRID>ccReg-3390618149</svTRID>
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
    <clTRID>1436775089</clTRID>
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
      <qDate>2015-07-13T08:11:29Z</qDate>
      <msg>Smth else.</msg>
    </msgQ>
    <trID>
      <clTRID>1436775089</clTRID>
      <svTRID>ccReg-1784449840</svTRID>
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
    <clTRID>1436775089</clTRID>
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
      <clTRID>1436775089</clTRID>
      <svTRID>ccReg-9604708191</svTRID>
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
    <clTRID>1436775089</clTRID>
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
      <qDate>2015-07-13T08:11:29Z</qDate>
      <msg>Something.</msg>
    </msgQ>
    <trID>
      <clTRID>1436775089</clTRID>
      <svTRID>ccReg-1957177353</svTRID>
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
    <clTRID>1436775089</clTRID>
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
      <clTRID>1436775089</clTRID>
      <svTRID>ccReg-6685502756</svTRID>
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
    <clTRID>1436775089</clTRID>
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
      <qDate>2015-07-13T08:11:29Z</qDate>
      <msg>Balance low.</msg>
    </msgQ>
    <trID>
      <clTRID>1436775089</clTRID>
      <svTRID>ccReg-8768039298</svTRID>
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
    <clTRID>1436775089</clTRID>
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
      <clTRID>1436775089</clTRID>
      <svTRID>ccReg-1482529320</svTRID>
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
    <clTRID>1436775089</clTRID>
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
      <clTRID>1436775089</clTRID>
      <svTRID>ccReg-1495533817</svTRID>
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
    <svDate>2015-07-13T08:11:30Z</svDate>
    <svcMenu>
      <version>1.0</version>
      <lang>en</lang>
      <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
      <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
      <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
      <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
      <svcExtension>
        <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
        <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <msg>Authentication error; server closing connection (API user not found)</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4962773185</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <msg>Authentication error; server closing connection (API user is not active)</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5095764492</svTRID>
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
      <domain:info xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
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
      <svTRID>ccReg-5738565184</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <msg>Authentication error; server closing connection (API user not found)</msg>
    </result>
    <trID>
      <svTRID>ccReg-5622270256</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-0289669237</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-0488458615</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-3342389163</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-0540678286</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-6032986990</svTRID>
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
      <svTRID>ccReg-1481291484</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <svTRID>ccReg-3765095362</svTRID>
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
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd</objURI>
        <objURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/contact-eis-1.0.xsd</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd</extURI>
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
      <msg lang="en">Password is missing [password]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0096989953</svTRID>
    </trID>
  </response>
</epp>
```

