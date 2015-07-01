# EPP REQUEST - RESPONSE EXAMPLES
GENERATED AT: 2015-06-16 14:45:11 UTC  
EXAMPLE COUNT: 168  

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
      <svTRID>ccReg-0628016030</svTRID>
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
      <svTRID>ccReg-4850323861</svTRID>
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
        <id>FIRST0:E6D21A5B</id>
        <crDate>2015-06-16T14:45:14Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8174523782</svTRID>
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
        <id>FIRST0:2991302F</id>
        <crDate>2015-06-16T14:45:14Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5902458408</svTRID>
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
        <id>FIRST0:939795FC</id>
        <crDate>2015-06-16T14:45:14Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7781355479</svTRID>
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
        <id>FIRST0:8F2D96DF</id>
        <crDate>2015-06-16T14:45:14Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9037049309</svTRID>
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
        <crDate>2015-06-16T14:45:14Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5231101974</svTRID>
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
        <crDate>2015-06-16T14:45:14Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6422793401</svTRID>
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
      <svTRID>ccReg-2948594360</svTRID>
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
      <svTRID>ccReg-5099683978</svTRID>
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
        <crDate>2015-06-16T14:45:16Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1644285201</svTRID>
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
        <crDate>2015-06-16T14:45:16Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9700239330</svTRID>
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
        <crDate>2015-06-16T14:45:17Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2521051245</svTRID>
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
        <crDate>2015-06-16T14:45:17Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0724862982</svTRID>
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
        <crDate>2015-06-16T14:45:17Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6737500376</svTRID>
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
        <id>FIRST0:83F0C8EE</id>
        <crDate>2015-06-16T14:45:17Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1953331836</svTRID>
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
        <id>FIRST0:89839115</id>
        <crDate>2015-06-16T14:45:17Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1961057833</svTRID>
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
      <svTRID>ccReg-7530778283</svTRID>
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
      <svTRID>ccReg-9380671496</svTRID>
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
      <svTRID>ccReg-3302729368</svTRID>
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
      <svTRID>ccReg-9700707144</svTRID>
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
        <crDate>2015-06-16T14:45:19Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3460954479</svTRID>
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
        <crDate>2015-06-16T14:45:19Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3321686496</svTRID>
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
      <svTRID>ccReg-1310720284</svTRID>
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
        <crDate>2015-06-16T14:45:19Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5319423932</svTRID>
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
      <svTRID>ccReg-8595538880</svTRID>
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
      <svTRID>ccReg-1546881965</svTRID>
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
      <svTRID>ccReg-2967153959</svTRID>
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
      <svTRID>ccReg-2076214878</svTRID>
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
      <svTRID>ccReg-0468202475</svTRID>
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
      <svTRID>ccReg-7942047636</svTRID>
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
      <svTRID>ccReg-9797329583</svTRID>
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
      <svTRID>ccReg-7526123941</svTRID>
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
      <svTRID>ccReg-4123279413</svTRID>
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
      <svTRID>ccReg-6929449846</svTRID>
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
        <crDate>2015-06-16T14:45:19Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1481668570</svTRID>
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
      <svTRID>ccReg-0260056975</svTRID>
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
        <crDate>2015-06-16T14:45:19Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9676737932</svTRID>
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
      <svTRID>ccReg-9359806010</svTRID>
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
      <svTRID>ccReg-5415478708</svTRID>
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
        <crDate>2015-06-16T14:45:19Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7303720395</svTRID>
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
        <crDate>2015-06-16T14:45:19Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8343028402</svTRID>
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
        <crDate>2015-06-16T14:45:19Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3396633434</svTRID>
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
        <crDate>2015-06-16T14:45:19Z</crDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2557605520</svTRID>
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
      <svTRID>ccReg-5903969239</svTRID>
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
      <svTRID>ccReg-4958556368</svTRID>
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
      <svTRID>ccReg-3948826508</svTRID>
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
      <svTRID>ccReg-6894400452</svTRID>
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
        <contact:id>FIRST0:SH660293943</contact:id>
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
      <svTRID>ccReg-3167684614</svTRID>
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
        <contact:id>FIRST0:SH918459854</contact:id>
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
      <svTRID>ccReg-4976622556</svTRID>
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
        <contact:id>FIRST0:SH479142985</contact:id>
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
      <svTRID>ccReg-5497436667</svTRID>
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
        <contact:id>FIRST0:SH948515446</contact:id>
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
      <svTRID>ccReg-5113374232</svTRID>
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
      <svTRID>ccReg-2787819683</svTRID>
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
        <contact:id>FIRST0:SH756528579</contact:id>
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
      <svTRID>ccReg-1059535053</svTRID>
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
      <svTRID>ccReg-9721519129</svTRID>
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
      <svTRID>ccReg-5463189772</svTRID>
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
        <contact:id>FIRST0:SH6727132410</contact:id>
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
      <svTRID>ccReg-0140635504</svTRID>
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
      <svTRID>ccReg-3361341345</svTRID>
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
      <svTRID>ccReg-2140366200</svTRID>
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
        <contact:id>FIRST0:SH6052359511</contact:id>
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
      <svTRID>ccReg-4307228004</svTRID>
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
      <svTRID>ccReg-9967906837</svTRID>
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
      <svTRID>ccReg-1546452843</svTRID>
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
      <svTRID>ccReg-5794718821</svTRID>
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
      <svTRID>ccReg-9107912155</svTRID>
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
      <svTRID>ccReg-0867319397</svTRID>
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
      <svTRID>ccReg-1035787772</svTRID>
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
        <email>litzy_kuvalis@pfannerstillhowe.org</email>
        <clID>fixed registrar</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-06-16T14:45:37Z</crDate>
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
      <svTRID>ccReg-8740910444</svTRID>
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
        <email>litzy_kuvalis@pfannerstillhowe.org</email>
        <clID>fixed registrar</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-06-16T14:45:37Z</crDate>
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
      <svTRID>ccReg-0768016805</svTRID>
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
        <email>litzy_kuvalis@pfannerstillhowe.org</email>
        <clID>registrar1</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-06-16T14:45:37Z</crDate>
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
      <svTRID>ccReg-1418789936</svTRID>
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
        <contact:id>FIRST0:SH168939920</contact:id>
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
        <id>FIRST0:SH168939920</id>
        <roid>EIS-1</roid>
        <status s="ok"/>
        <postalInfo type="int">
          <name>Tiana Cummerata0</name>
          <addr>
            <street>Short street 11</street>
            <city>Tallinn</city>
            <sp/>
            <pc>11111</pc>
            <cc>EE</cc>
          </addr>
        </postalInfo>
        <voice>+372.12345678</voice>
        <email>litzy_kuvalis@pfannerstillhowe.org</email>
        <clID>registrar1</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-06-16T14:45:13Z</crDate>
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
      <svTRID>ccReg-8270641025</svTRID>
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
          <name>Jarred Reichel15</name>
          <addr>
            <street>Short street 11</street>
            <city>Tallinn</city>
            <sp/>
            <pc>11111</pc>
            <cc>EE</cc>
          </addr>
        </postalInfo>
        <voice>+372.12345678</voice>
        <email>litzy_kuvalis@pfannerstillhowe.org</email>
        <clID>fixed registrar</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-06-16T14:45:37Z</crDate>
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
      <svTRID>ccReg-0424201637</svTRID>
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
      <svTRID>ccReg-6919284154</svTRID>
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
        <contact:id>FIRST0:SH168939920</contact:id>
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
        <id>FIRST0:SH168939920</id>
        <roid>EIS-1</roid>
        <status s="ok"/>
        <postalInfo type="int">
          <name>Tiana Cummerata0</name>
          <addr>
            <street>Short street 11</street>
            <city>Tallinn</city>
            <sp/>
            <pc>11111</pc>
            <cc>EE</cc>
          </addr>
        </postalInfo>
        <voice>+372.12345678</voice>
        <email>litzy_kuvalis@pfannerstillhowe.org</email>
        <clID>registrar1</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-06-16T14:45:13Z</crDate>
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
      <svTRID>ccReg-4155363959</svTRID>
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
      <svTRID>ccReg-9980678480</svTRID>
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
      <svTRID>ccReg-6386920424</svTRID>
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
        <contact:id>FIRST0:SH168939920</contact:id>
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
      <svTRID>ccReg-8614373807</svTRID>
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
      <svTRID>ccReg-9444940598</svTRID>
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
      <svTRID>ccReg-1099785761</svTRID>
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
        <contact:id>FIRST0:SH168939920</contact:id>
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
        <id>FIRST0:SH168939920</id>
        <roid>EIS-1</roid>
        <status s="ok"/>
        <postalInfo type="int">
          <name>Tiana Cummerata0</name>
        </postalInfo>
        <clID>registrar1</clID>
        <crID>TEST-CREATOR</crID>
        <crDate>2015-06-16T14:45:13Z</crDate>
      </infData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7660283209</svTRID>
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
      <svTRID>ccReg-8143425519</svTRID>
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
      <svTRID>ccReg-2175230306</svTRID>
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
        <domain:name>example51359824296846476.ee</domain:name>
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
      <svTRID>ccReg-6335804328</svTRID>
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
      <svTRID>ccReg-4990944724</svTRID>
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
        <domain:name>example18858770590752611.ee</domain:name>
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
        <name>example18858770590752611.ee</name>
        <crDate>2015-06-16T14:45:40Z</crDate>
        <exDate>2016-06-16T14:45:40Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0460679321</svTRID>
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
        <domain:name>example53637086732201506.ee</domain:name>
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
        <name>example53637086732201506.ee</name>
        <crDate>2015-06-16T14:45:40Z</crDate>
        <exDate>2016-06-16T14:45:40Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2657489548</svTRID>
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
        <domain:name>example55255947651220293.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example55255947651220293.ee</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example55255947651220293.ee</domain:hostName>
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
      <svTRID>ccReg-5446638954</svTRID>
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
      <svTRID>ccReg-2558205520</svTRID>
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
    <result code="2302">
      <msg lang="en">Domain name is reserved or restricted [name_dirty]</msg>
      <value>
        <name>1162.ee</name>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3241448329</svTRID>
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
        <domain:name>example79107476359960104.ee</domain:name>
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
      <svTRID>ccReg-2841149464</svTRID>
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
        <domain:name>example89212032300871964.ee</domain:name>
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
      <svTRID>ccReg-6780943188</svTRID>
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
        <domain:name>example83430684429956047.ee</domain:name>
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
      <svTRID>ccReg-2034075719</svTRID>
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
        <domain:name>example48749833529852102.ee</domain:name>
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
      <svTRID>ccReg-8625622303</svTRID>
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
        <domain:name>example62530771922904064.ee</domain:name>
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
      <svTRID>ccReg-9223003685</svTRID>
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
        <domain:name>example57855176106155885.ee</domain:name>
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
        <name>example57855176106155885.ee</name>
        <crDate>2015-06-16T14:45:49Z</crDate>
        <exDate>2016-06-16T14:45:49Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3987518347</svTRID>
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
        <domain:name>example36117415864684846.ee</domain:name>
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
      <svTRID>ccReg-8191386800</svTRID>
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
        <domain:name>example47616294102238590.ee</domain:name>
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
        <name>example47616294102238590.ee</name>
        <crDate>2015-06-16T14:45:50Z</crDate>
        <exDate>2016-06-16T14:45:50Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9254659589</svTRID>
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
        <domain:name>example59902259057282424.ee</domain:name>
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
      <svTRID>ccReg-5831577897</svTRID>
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
        <domain:name>example35799150293426379.ee</domain:name>
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
        <name>example35799150293426379.ee</name>
        <crDate>2015-06-16T14:45:52Z</crDate>
        <exDate>2016-06-16T14:45:52Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6805098026</svTRID>
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
        <domain:name>example77419485730565318.ee</domain:name>
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
      <svTRID>ccReg-5499891820</svTRID>
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
        <domain:name>example62893290773940803.ee</domain:name>
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
      <svTRID>ccReg-1606849858</svTRID>
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
        <domain:name>example89542634347493363.ee</domain:name>
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
      <svTRID>ccReg-0277146354</svTRID>
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
        <domain:name>example5611622315382730.ee</domain:name>
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
        <name>example5611622315382730.ee</name>
        <crDate>2015-06-16T14:45:55Z</crDate>
        <exDate>2016-06-16T14:45:55Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2786067157</svTRID>
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
        <domain:name>example28205147543381731.ee</domain:name>
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
        <name>example28205147543381731.ee</name>
        <crDate>2015-06-16T14:45:55Z</crDate>
        <exDate>2016-06-16T14:45:55Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3180633288</svTRID>
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
        <domain:name>example81689211125437444.ee</domain:name>
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
      <svTRID>ccReg-0596552578</svTRID>
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
        <domain:name>example16808329279089073.ee</domain:name>
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
      <svTRID>ccReg-3845103907</svTRID>
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
        <domain:name>example57773978303296424.ee</domain:name>
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
      <svTRID>ccReg-0236248171</svTRID>
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
        <domain:name>example82556663094409029.ee</domain:name>
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
        <name>example82556663094409029.ee</name>
        <crDate>2015-06-16T14:45:59Z</crDate>
        <exDate>2016-06-16T14:45:59Z</exDate>
      </creData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7792326836</svTRID>
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
        <domain:name>example61224688298392772.ee</domain:name>
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
      <svTRID>ccReg-4835312018</svTRID>
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
        <domain:name>example2482715006886939.ee</domain:name>
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
      <svTRID>ccReg-0994405489</svTRID>
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
      <svTRID>ccReg-9434443874</svTRID>
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
        <domain:name>domain1.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">cade780e81c248d9e6363fd303b523c3</domain:pw>
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
        <reDate>2015-06-16T14:46:02Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T14:46:02Z</acDate>
        <exDate>2016-06-16T14:46:02Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6107518806</svTRID>
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
      <svTRID>ccReg-9351177423</svTRID>
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
      <qDate>2015-06-16T14:46:02Z</qDate>
      <msg>Domain transfer was approved, associated contacts are: ["REGDOMAIN2:2E38C324", "REGDOMAIN2:30A5A03D"]</msg>
    </msgQ>
    <resData>
      <trnData>
        <name>domain1.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>REGDOMAIN2</reID>
        <reDate>2015-06-16T14:46:02Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T14:46:02Z</acDate>
        <exDate>2016-06-16T14:46:02Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5221788468</svTRID>
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
        <domain:name>domain1.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">e3b00963e2849df1654840a4805b8390</domain:pw>
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
        <reDate>2015-06-16T14:46:02Z</reDate>
        <acID>REGDOMAIN2</acID>
        <acDate>2015-06-16T15:46:02Z</acDate>
        <exDate>2016-06-16T14:46:02Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5943956125</svTRID>
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
        <domain:name>domain1.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">e3b00963e2849df1654840a4805b8390</domain:pw>
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
        <reDate>2015-06-16T14:46:02Z</reDate>
        <acID>REGDOMAIN2</acID>
        <acDate>2015-06-16T15:46:02Z</acDate>
        <exDate>2016-06-16T14:46:02Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0973430912</svTRID>
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
      <svTRID>ccReg-7808499308</svTRID>
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
      <qDate>2015-06-16T14:46:02Z</qDate>
      <msg>Transfer requested.</msg>
    </msgQ>
    <resData>
      <trnData>
        <name>domain1.ee</name>
        <trStatus>pending</trStatus>
        <reID>REGDOMAIN1</reID>
        <reDate>2015-06-16T14:46:02Z</reDate>
        <acID>REGDOMAIN2</acID>
        <acDate>2015-06-16T15:46:02Z</acDate>
        <exDate>2016-06-16T14:46:02Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7198000795</svTRID>
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
      <svTRID>ccReg-8981002307</svTRID>
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
      <svTRID>ccReg-0623446914</svTRID>
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
      <svTRID>ccReg-3648943159</svTRID>
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
      <svTRID>ccReg-5814325246</svTRID>
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
      <svTRID>ccReg-6044514213</svTRID>
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
        <domain:name>domain2.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">024bb6c14f1f351ff88bd3bdb24ec907</domain:pw>
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
        <reDate>2015-06-16T14:46:03Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T15:46:03Z</acDate>
        <exDate>2016-06-16T14:46:03Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6223906445</svTRID>
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
      <svTRID>ccReg-8746149187</svTRID>
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
      <svTRID>ccReg-7756736893</svTRID>
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
        <domain:name>domain2.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">024bb6c14f1f351ff88bd3bdb24ec907</domain:pw>
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
        <reDate>2015-06-16T14:46:03Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T15:46:03Z</acDate>
        <exDate>2016-06-16T14:46:03Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8545188045</svTRID>
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
      <svTRID>ccReg-2241555669</svTRID>
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
      <svTRID>ccReg-8460295410</svTRID>
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
        <domain:name>domain3.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">836af4fd51fcd5712120b17fe2fa2bb3</domain:pw>
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
        <reDate>2015-06-16T14:46:03Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T14:46:03Z</acDate>
        <exDate>2016-06-16T14:46:03Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8076619398</svTRID>
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
      <svTRID>ccReg-8851768239</svTRID>
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
      <svTRID>ccReg-9101345679</svTRID>
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
        <domain:name>domain4.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">c4191d5991d76be69de4c89c7d6332c6</domain:pw>
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
        <reDate>2015-06-16T14:46:04Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T14:46:04Z</acDate>
        <exDate>2016-06-16T14:46:04Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1271904293</svTRID>
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
      <svTRID>ccReg-3137087761</svTRID>
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
      <svTRID>ccReg-7273165678</svTRID>
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
        <domain:name>domain5.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">cb2a7321b5cbbbb3dde7a6810c9ed13f</domain:pw>
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
        <reDate>2015-06-16T14:46:04Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T14:46:04Z</acDate>
        <exDate>2016-06-16T14:46:04Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6138246266</svTRID>
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
      <svTRID>ccReg-0594521940</svTRID>
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
      <svTRID>ccReg-3903547157</svTRID>
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
        <domain:name>domain8.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">8ad5a1e3f0f5cfd3ac927eacd377d748</domain:pw>
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
        <reDate>2015-06-16T14:46:05Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T14:46:05Z</acDate>
        <exDate>2016-06-16T14:46:05Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6422274553</svTRID>
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
      <svTRID>ccReg-8513849853</svTRID>
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
      <svTRID>ccReg-0495664550</svTRID>
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
        <domain:name>domain9.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">ae0e9f8ad42aa43f5421e7825576d49b</domain:pw>
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
        <reDate>2015-06-16T14:46:05Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T14:46:05Z</acDate>
        <exDate>2016-06-16T14:46:05Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8327056615</svTRID>
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
      <svTRID>ccReg-4617980059</svTRID>
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
      <svTRID>ccReg-2829504560</svTRID>
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
        <domain:name>domain11.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">15fd8747240b3b76d7d629fdfb9933c2</domain:pw>
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
        <reDate>2015-06-16T14:46:06Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T14:46:06Z</acDate>
        <exDate>2016-06-16T14:46:06Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4652082139</svTRID>
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
      <svTRID>ccReg-7682673588</svTRID>
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
      <svTRID>ccReg-2956836704</svTRID>
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
        <domain:name>domain14.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">99528c913bd395947f46b320c600851e</domain:pw>
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
        <reDate>2015-06-16T14:46:07Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T14:46:07Z</acDate>
        <exDate>2016-06-16T14:46:06Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-2561775032</svTRID>
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
      <svTRID>ccReg-8704236801</svTRID>
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
      <svTRID>ccReg-5989893103</svTRID>
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
        <domain:name>domain15.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">ced325e25352a6d3ae454729c5a5f133</domain:pw>
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
        <reDate>2015-06-16T14:46:07Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T14:46:07Z</acDate>
        <exDate>2016-06-16T14:46:07Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-3303397389</svTRID>
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
      <svTRID>ccReg-3498869771</svTRID>
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
      <svTRID>ccReg-3004185742</svTRID>
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
      <svTRID>ccReg-0738799544</svTRID>
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
      <svTRID>ccReg-9100482752</svTRID>
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
          <domain:pw roid="citizen_1234-REP">d5649c7d29cea682a55405451a7b3e9f</domain:pw>
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
        <reDate>2015-06-16T14:46:08Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T14:46:08Z</acDate>
        <exDate>2016-06-16T14:46:08Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5630988802</svTRID>
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
      <svTRID>ccReg-1163667761</svTRID>
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
          <domain:pw roid="citizen_1234-REP">fe3d5081d9fa1723fec7ca2d3d197651</domain:pw>
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
      <svTRID>ccReg-6697616444</svTRID>
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
      <svTRID>ccReg-2557365838</svTRID>
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
          <domain:pw roid="citizen_1234-REP">fe3d5081d9fa1723fec7ca2d3d197651</domain:pw>
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
        <reDate>2015-06-16T14:46:08Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T14:46:08Z</acDate>
        <exDate>2016-06-16T14:46:08Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9330091112</svTRID>
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
      <svTRID>ccReg-4172750491</svTRID>
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
          <domain:pw roid="citizen_1234-REP">0220447ad7d651fac0dace38a5bcb106</domain:pw>
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
      <svTRID>ccReg-8617259540</svTRID>
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
      <svTRID>ccReg-7168292306</svTRID>
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
    <transfer op="query">
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
      <svTRID>ccReg-5705380145</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Domain with valid domain ignores transfer wha registrant registrar requests transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd">
        <domain:name>domain21.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">e736e5af0a5e47d84be0a8211eb1e97a</domain:pw>
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
      <svTRID>ccReg-0353546410</svTRID>
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
        <domain:name>example98439991603054778.ee</domain:name>
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
    <result code="2306">
      <msg lang="en">Attribute is invalid: op</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6980066531</svTRID>
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
      <svTRID>ccReg-6843014672</svTRID>
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
        <domain:name>domain22.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">008c062889e1dc19127c0636278263f4</domain:pw>
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
        <reDate>2015-06-16T14:46:13Z</reDate>
        <acID>REGDOMAIN1</acID>
        <acDate>2015-06-16T14:46:13Z</acDate>
        <exDate>2016-06-16T14:46:13Z</exDate>
      </trnData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-8542599190</svTRID>
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
        <domain:name>domain22.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="citizen_1234-REP">008c062889e1dc19127c0636278263f4</domain:pw>
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
      <svTRID>ccReg-0772545533</svTRID>
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
      <svTRID>ccReg-0922916710</svTRID>
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
          <domain:pw roid="citizen_1234-REP">8b267970556e6d4f52ac0e8cd5ec0533</domain:pw>
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
      <msg lang="en">Pending transfer was not found</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-0757072773</svTRID>
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
        <domain:name>domain24.ee</domain:name>
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
      <svTRID>ccReg-1524969701</svTRID>
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
        <domain:name>domain25.ee</domain:name>
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
      <svTRID>ccReg-7160661951</svTRID>
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
        <domain:name>domain26.ee</domain:name>
        <domain:rem>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns.morissette80.ee</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns.turnerwuckert79.ee</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns.shanahan78.ee</domain:hostName>
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
      <svTRID>ccReg-5838624706</svTRID>
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
    <result code="2004">
      <msg lang="en">Nameservers count must be between 2-11 [nameservers]</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-5253637768</svTRID>
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
        <domain:name>domain28.ee</domain:name>
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
      <svTRID>ccReg-6353980879</svTRID>
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
        <domain:name>domain29.ee</domain:name>
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
      <svTRID>ccReg-9385991613</svTRID>
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
        <domain:name>domain29.ee</domain:name>
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
      <svTRID>ccReg-5743092443</svTRID>
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
        <domain:name>domain29.ee</domain:name>
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
      <svTRID>ccReg-8404006394</svTRID>
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
        <domain:name>domain30.ee</domain:name>
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
      <svTRID>ccReg-4710508132</svTRID>
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
        <domain:name>domain30.ee</domain:name>
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
      <svTRID>ccReg-0418760365</svTRID>
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
        <domain:name>domain31.ee</domain:name>
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
      <svTRID>ccReg-6393659962</svTRID>
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
      <svTRID>ccReg-5765767170</svTRID>
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
      <svTRID>ccReg-7916696039</svTRID>
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
      <svTRID>ccReg-6312761543</svTRID>
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
        <domain:name>domain33.ee</domain:name>
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
      <svTRID>ccReg-4059845175</svTRID>
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
        <domain:name>domain34.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns.paucekcremin99.ee</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="admin">FIXED:SH2421352279</domain:contact>
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
      <svTRID>ccReg-6215676067</svTRID>
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
        <domain:add>
          <domain:ns>
            <domain:hostAttr>
              <domain:hostName>ns.paucekcremin99.ee</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="admin">FIXED:SH2421352279</domain:contact>
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
        <hostAttr>ns.paucekcremin99.ee</hostAttr>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Contact already exists on this domain [contact_code_cache]</msg>
      <value>
        <contact>FIXED:SH2421352279</contact>
      </value>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9116884956</svTRID>
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
        <domain:name>domain35.ee</domain:name>
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
      <svTRID>ccReg-7918261747</svTRID>
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
        <domain:name>domain36.ee</domain:name>
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
      <svTRID>ccReg-4823438244</svTRID>
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
        <domain:name>domain37.ee</domain:name>
        <domain:curExpDate>2015-06-26</domain:curExpDate>
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
        <name>domain37.ee</name>
        <exDate>2016-06-26T00:00:00Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6519525965</svTRID>
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
        <domain:name>domain38.ee</domain:name>
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
      <svTRID>ccReg-9192582359</svTRID>
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
        <domain:name>domain39.ee</domain:name>
        <domain:curExpDate>2015-06-26</domain:curExpDate>
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
      <svTRID>ccReg-9034050627</svTRID>
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
        <domain:name>domain40.ee</domain:name>
        <domain:curExpDate>2015-09-14</domain:curExpDate>
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
      <svTRID>ccReg-0329970059</svTRID>
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
        <domain:name>domain40.ee</domain:name>
        <domain:curExpDate>2015-09-13</domain:curExpDate>
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
        <exDate>2016-09-13T00:00:00Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-6696413266</svTRID>
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
        <domain:name>domain41.ee</domain:name>
        <domain:curExpDate>2020-06-16</domain:curExpDate>
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
        <exDate>2021-06-16T00:00:00Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1505326476</svTRID>
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
        <domain:name>domain42.ee</domain:name>
        <domain:curExpDate>2015-06-26</domain:curExpDate>
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
      <svTRID>ccReg-4127044027</svTRID>
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
        <domain:name>domain43.ee</domain:name>
        <domain:curExpDate>2015-04-27</domain:curExpDate>
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
        <name>domain43.ee</name>
        <exDate>2016-04-27T14:46:35Z</exDate>
      </renData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-9291103741</svTRID>
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
      <svTRID>ccReg-3538502070</svTRID>
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
        <domain:name>domain44.ee</domain:name>
        <domain:curExpDate>2016-06-16</domain:curExpDate>
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
      <svTRID>ccReg-5006977619</svTRID>
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
      <svTRID>ccReg-3666394551</svTRID>
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
        <domain:name hosts="all">domain45.ee</domain:name>
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
        <name>domain45.ee</name>
        <roid>EIS-53</roid>
        <status s="clientHold"/>
        <registrant>FIXED:REGISTRANT5034182443</registrant>
        <contact type="tech">FIXED:SH87553047104</contact>
        <contact type="admin">FIXED:SH60451564103</contact>
        <ns>
          <hostAttr>
            <hostName>ns.sipeskeeling135.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.denesikjaskolski136.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.johns137.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns1.example.com</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-06-16T14:46:36Z</crDate>
        <upDate>2015-06-16T14:46:36Z</upDate>
        <exDate>2016-06-16T14:46:36Z</exDate>
        <authInfo>
          <pw>7fc87d2ceabb4a21969a9a067aa03411</pw>
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
      <svTRID>ccReg-1180902357</svTRID>
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
        <domain:name hosts="all">domain45.ee</domain:name>
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
        <name>domain45.ee</name>
        <roid>EIS-53</roid>
        <status s="clientHold"/>
        <registrant>FIXED:REGISTRANT5034182443</registrant>
        <contact type="tech">FIXED:SH87553047104</contact>
        <contact type="admin">FIXED:SH60451564103</contact>
        <ns>
          <hostAttr>
            <hostName>ns.sipeskeeling135.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.denesikjaskolski136.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.johns137.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns1.example.com</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-06-16T14:46:36Z</crDate>
        <upDate>2015-06-16T14:46:36Z</upDate>
        <exDate>2016-06-16T14:46:36Z</exDate>
        <authInfo>
          <pw>7fc87d2ceabb4a21969a9a067aa03411</pw>
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
      <svTRID>ccReg-9928668202</svTRID>
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
        <domain:name hosts="invalid">domain46.ee</domain:name>
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
      <svTRID>ccReg-5780540561</svTRID>
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
        <domain:name hosts="sub">domain46.ee</domain:name>
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
        <name>domain46.ee</name>
        <roid>EIS-54</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT7386073344</registrant>
        <contact type="tech">FIXED:SH70911474106</contact>
        <contact type="admin">FIXED:SH83717810105</contact>
        <ns>
          <hostAttr>
            <hostName>ns1.domain46.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns2.domain46.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-06-16T14:46:36Z</crDate>
        <upDate>2015-06-16T14:46:36Z</upDate>
        <exDate>2016-06-16T14:46:36Z</exDate>
        <authInfo>
          <pw>04319f6bf003ebd8357d77a866f21a1d</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-9817465177</svTRID>
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
        <domain:name hosts="del">domain46.ee</domain:name>
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
        <name>domain46.ee</name>
        <roid>EIS-54</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT7386073344</registrant>
        <contact type="tech">FIXED:SH70911474106</contact>
        <contact type="admin">FIXED:SH83717810105</contact>
        <ns>
          <hostAttr>
            <hostName>ns3.test.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-06-16T14:46:36Z</crDate>
        <upDate>2015-06-16T14:46:36Z</upDate>
        <exDate>2016-06-16T14:46:36Z</exDate>
        <authInfo>
          <pw>04319f6bf003ebd8357d77a866f21a1d</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-1956126808</svTRID>
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
        <domain:name hosts="none">domain46.ee</domain:name>
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
        <name>domain46.ee</name>
        <roid>EIS-54</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT7386073344</registrant>
        <contact type="tech">FIXED:SH70911474106</contact>
        <contact type="admin">FIXED:SH83717810105</contact>
        <clID>registrar1</clID>
        <crDate>2015-06-16T14:46:36Z</crDate>
        <upDate>2015-06-16T14:46:36Z</upDate>
        <exDate>2016-06-16T14:46:36Z</exDate>
        <authInfo>
          <pw>04319f6bf003ebd8357d77a866f21a1d</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-4662877023</svTRID>
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
        <domain:name hosts="all">domain46.ee</domain:name>
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
        <name>domain46.ee</name>
        <roid>EIS-54</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT7386073344</registrant>
        <contact type="tech">FIXED:SH70911474106</contact>
        <contact type="admin">FIXED:SH83717810105</contact>
        <ns>
          <hostAttr>
            <hostName>ns1.domain46.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns2.domain46.ee</hostName>
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
        <crDate>2015-06-16T14:46:36Z</crDate>
        <upDate>2015-06-16T14:46:36Z</upDate>
        <exDate>2016-06-16T14:46:36Z</exDate>
        <authInfo>
          <pw>04319f6bf003ebd8357d77a866f21a1d</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-2430670023</svTRID>
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
      <svTRID>ccReg-5247973919</svTRID>
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
        <domain:name hosts="all">domain47.ee</domain:name>
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
        <name>domain47.ee</name>
        <roid>EIS-55</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT3737412845</registrant>
        <contact type="tech">FIXED:SH49038744108</contact>
        <contact type="admin">FIXED:SH06725299107</contact>
        <ns>
          <hostAttr>
            <hostName>ns.sanford141.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.sauer142.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.veum143.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-06-16T14:46:37Z</crDate>
        <upDate>2015-06-16T14:46:37Z</upDate>
        <exDate>2016-06-16T14:46:37Z</exDate>
        <authInfo>
          <pw>81c5f0a214cb0756ad4a5c553e80df90</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-6047154535</svTRID>
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
      <svTRID>ccReg-1083606006</svTRID>
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
        <domain:name hosts="all">domain48.ee</domain:name>
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
      <svTRID>ccReg-9393465490</svTRID>
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
      <svTRID>ccReg-0344532333</svTRID>
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
      <svTRID>ccReg-9663838605</svTRID>
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
        <domain:name hosts="all">domain49.ee</domain:name>
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
        <name>domain49.ee</name>
        <roid>EIS-57</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT1566943147</registrant>
        <contact type="tech">FIXED:SH39124150112</contact>
        <contact type="admin">FIXED:SH43742622111</contact>
        <ns>
          <hostAttr>
            <hostName>ns.kreiger147.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.hudson148.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.dare149.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-06-16T14:46:38Z</crDate>
        <upDate>2015-06-16T14:46:38Z</upDate>
        <exDate>2016-06-16T14:46:38Z</exDate>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-0003863495</svTRID>
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
      <svTRID>ccReg-9016819552</svTRID>
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
      <svTRID>ccReg-4480505409</svTRID>
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
          <domain:pw>f44d898ad1b9caa41023a0894a3d0801</domain:pw>
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
        <roid>EIS-58</roid>
        <status s="ok"/>
        <registrant>FIXED:REGISTRANT5610043948</registrant>
        <contact type="tech">FIXED:SH85839976114</contact>
        <contact type="admin">FIXED:SH72694104113</contact>
        <ns>
          <hostAttr>
            <hostName>ns.mann150.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.gutkowskibernier151.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.schinner152.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
        </ns>
        <clID>registrar1</clID>
        <crDate>2015-06-16T14:46:38Z</crDate>
        <upDate>2015-06-16T14:46:38Z</upDate>
        <exDate>2016-06-16T14:46:38Z</exDate>
        <authInfo>
          <pw>f44d898ad1b9caa41023a0894a3d0801</pw>
        </authInfo>
      </infData>
    </resData>
    <trID>
      <svTRID>ccReg-7074882802</svTRID>
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
      <svTRID>ccReg-2139213556</svTRID>
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
        <domain:name>domain51.ee</domain:name>
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
    <result code="2400">
      <msg lang="en">Internal error.</msg>
    </result>
    <trID>
      <svTRID>ccReg-0801639712</svTRID>
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
        <domain:name>domain52.ee</domain:name>
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
      <svTRID>ccReg-0908156344</svTRID>
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
        <domain:name>domain53.ee</domain:name>
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
      <svTRID>ccReg-5302487355</svTRID>
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
      <svTRID>ccReg-4445302239</svTRID>
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
      <svTRID>ccReg-6989281837</svTRID>
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
        <domain:name>domain54.ee</domain:name>
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
          <name avail="0">domain54.ee</name>
          <reason>in use</reason>
        </cd>
      </chkData>
    </resData>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-7241677214</svTRID>
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
      <svTRID>ccReg-2988756260</svTRID>
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
      <svTRID>ccReg-3861410540</svTRID>
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
      <svTRID>ccReg-9350463779</svTRID>
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
      <ext:name>domain55.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>606917876743fb9d65eb59fbf175c5bd</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1M13D</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1434466003</ext:clTRID>
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
        <name>domain55.ee</name>
      </value>
    </result>
    <trID>
      <clTRID>1434466003</clTRID>
      <svTRID>ccReg-7770421771</svTRID>
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
      <ext:name>domain55.ee</ext:name>
      <ext:keyData>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>606917876743fb9d65eb59fbf175c5bd</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>Invalid Expiry</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1434466004</ext:clTRID>
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
      <clTRID>1434466004</clTRID>
      <svTRID>ccReg-0081075985</svTRID>
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
      <ext:name>domain55.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>606917876743fb9d65eb59fbf175c5bd</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>Invalid Expiry</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1434466005</ext:clTRID>
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
      <clTRID>1434466005</clTRID>
      <svTRID>ccReg-6676809630</svTRID>
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
      <ext:name>domain55.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>606917876743fb9d65eb59fbf175c5bd</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:absolute>Invalid Absolute</ext:absolute>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1434466006</ext:clTRID>
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
      <clTRID>1434466006</clTRID>
      <svTRID>ccReg-8006484799</svTRID>
    </trID>
  </response>
</epp>
```

### EPP Keyrelay does not allow both relative and absolute  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/domain-eis-1.0.xsd" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>domain55.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>606917876743fb9d65eb59fbf175c5bd</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1D</ext:relative>
        <ext:absolute>2014-12-23</ext:absolute>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1434466007</ext:clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Exactly one parameter required: keyrelay &gt; expiry &gt; relative OR keyrelay &gt; expiry &gt; absolute</msg>
    </result>
    <trID>
      <clTRID>1434466007</clTRID>
      <svTRID>ccReg-6196744977</svTRID>
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
      <ext:name>domain55.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>606917876743fb9d65eb59fbf175c5bd</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1D</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
      <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
    </eis:extdata>
    <ext:clTRID>1434466008</ext:clTRID>
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
        <name>domain55.ee</name>
      </value>
    </result>
    <trID>
      <clTRID>1434466008</clTRID>
      <svTRID>ccReg-8880766111</svTRID>
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
      <ext:name>domain55.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>606917876743fb9d65eb59fbf175c5bd</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1D</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <eis:extdata xmlns:eis="https://raw.githubusercontent.com/internetee/registry/alpha/doc/schemas/eis-1.0.xsd">
      <eis:legalDocument type="jpg">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
    </eis:extdata>
    <ext:clTRID>1434466009</ext:clTRID>
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
      <clTRID>1434466009</clTRID>
      <svTRID>ccReg-5896300316</svTRID>
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
      <svTRID>ccReg-6744406564</svTRID>
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
    <clTRID>1434466011</clTRID>
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
      <clTRID>1434466011</clTRID>
      <svTRID>ccReg-7079179755</svTRID>
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
      <svTRID>ccReg-5443416105</svTRID>
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
    <clTRID>1434466011</clTRID>
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
      <clTRID>1434466011</clTRID>
      <svTRID>ccReg-6783686315</svTRID>
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
      <svTRID>ccReg-5004171706</svTRID>
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
    <clTRID>1434466011</clTRID>
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
      <qDate>2015-06-16T14:46:51Z</qDate>
      <msg>Balance low.</msg>
    </msgQ>
    <trID>
      <clTRID>1434466011</clTRID>
      <svTRID>ccReg-4253494053</svTRID>
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
      <svTRID>ccReg-4918171501</svTRID>
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
    <clTRID>1434466011</clTRID>
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
      <clTRID>1434466011</clTRID>
      <svTRID>ccReg-5948146323</svTRID>
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
      <svTRID>ccReg-0602722237</svTRID>
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
    <clTRID>1434466011</clTRID>
  </command>
</epp>
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
      <clTRID>1434466011</clTRID>
      <svTRID>ccReg-6653908143</svTRID>
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
    <clTRID>1434466011</clTRID>
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
      <clTRID>1434466011</clTRID>
      <svTRID>ccReg-4030904109</svTRID>
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
    <clTRID>1434466013</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Attribute is invalid: op</msg>
    </result>
    <trID>
      <clTRID>1434466013</clTRID>
      <svTRID>ccReg-1337274768</svTRID>
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
    <clTRID>1434466014</clTRID>
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
      <qDate>2015-06-16T14:46:54Z</qDate>
      <msg>Smth else.</msg>
    </msgQ>
    <trID>
      <clTRID>1434466014</clTRID>
      <svTRID>ccReg-0133258887</svTRID>
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
    <clTRID>1434466014</clTRID>
  </command>
</epp>
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
      <clTRID>1434466014</clTRID>
      <svTRID>ccReg-7865881696</svTRID>
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
    <clTRID>1434466014</clTRID>
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
      <qDate>2015-06-16T14:46:54Z</qDate>
      <msg>Something.</msg>
    </msgQ>
    <trID>
      <clTRID>1434466014</clTRID>
      <svTRID>ccReg-2990701289</svTRID>
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
    <clTRID>1434466014</clTRID>
  </command>
</epp>
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
      <clTRID>1434466014</clTRID>
      <svTRID>ccReg-5225046181</svTRID>
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
    <clTRID>1434466014</clTRID>
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
      <qDate>2015-06-16T14:46:54Z</qDate>
      <msg>Balance low.</msg>
    </msgQ>
    <trID>
      <clTRID>1434466014</clTRID>
      <svTRID>ccReg-6707896691</svTRID>
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
    <clTRID>1434466014</clTRID>
  </command>
</epp>
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
      <clTRID>1434466014</clTRID>
      <svTRID>ccReg-8174947053</svTRID>
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
    <clTRID>1434466015</clTRID>
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
      <clTRID>1434466015</clTRID>
      <svTRID>ccReg-0858483195</svTRID>
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
    <svDate>2015-06-16T14:46:55Z</svDate>
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
      <msg>Authentication error; server closing connection</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-4597363742</svTRID>
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
      <msg>Authentication error; server closing connection</msg>
    </result>
    <trID>
      <clTRID>ABC-12345</clTRID>
      <svTRID>ccReg-1428657257</svTRID>
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
      <svTRID>ccReg-3082305327</svTRID>
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
      <msg>Authentication error; server closing connection</msg>
    </result>
    <trID>
      <svTRID>ccReg-3565992149</svTRID>
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
      <svTRID>ccReg-0832089091</svTRID>
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
      <svTRID>ccReg-1535717609</svTRID>
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
      <svTRID>ccReg-5055971923</svTRID>
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
      <svTRID>ccReg-0729496396</svTRID>
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
      <svTRID>ccReg-7311985652</svTRID>
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
      <svTRID>ccReg-7387239733</svTRID>
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
      <svTRID>ccReg-9506918430</svTRID>
    </trID>
  </response>
</epp>
```
