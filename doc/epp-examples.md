# EPP REQUEST - RESPONSE EXAMPLES
GENERATED AT: 2015-01-21 12:29:38 +0200  
EXAMPLE COUNT: 103  

---

### EPP Contact with valid user create command fails if request xml is missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="urn:ietf:params:xml:ns:contact-1.0"/>
    </create>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2001">
      <msg lang="en">Command syntax error</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-4501361376</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user create command fails if request xml is missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:postalInfo>
          <contact:addr/>
        </contact:postalInfo>
      </contact:create>
    </create>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: name</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: city</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: cc</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: ident</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: voice</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: email</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-3301397139</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user create command successfully saves ident type  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
        <contact:ident type="birthday">1990-22-12</contact:ident>
      </contact:create>
    </create>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>0f9e4eed</id>
        <crDate>2015-01-21 10:29:40 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0551166792</svTRID>
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
      <contact:create xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
        <contact:ident type="op">37605030299</contact:ident>
      </contact:create>
    </create>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>4a2619b7</id>
        <crDate>2015-01-21 10:29:41 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7366701880</svTRID>
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
      <contact:create xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
        <contact:ident type="op">37605030299</contact:ident>
      </contact:create>
    </create>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>88fe61f4</id>
        <crDate>2015-01-21 10:29:41 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9638253560</svTRID>
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
      <contact:create xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
        <contact:ident type="op">37605030299</contact:ident>
      </contact:create>
    </create>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>0b66c137</id>
        <crDate>2015-01-21 10:29:42 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2602273716</svTRID>
</trID>
  </response>
</epp>
```

### EPP Contact with valid user create command creates disclosure data  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
        <contact:ident type="op">37605030299</contact:ident>
        <contact:disclose flag="1">
          <contact:voice/>
          <contact:addr/>
          <contact:name/>
          <contact:org_name/>
          <contact:email/>
          <contact:fax/>
        </contact:disclose>
      </contact:create>
    </create>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>b20268f5</id>
        <crDate>2015-01-21 10:29:42 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0644641237</svTRID>
</trID>
  </response>
</epp>
```

### EPP Contact with valid user create command creates disclosure data merging with defaults  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <contact:create xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:postalInfo>
          <contact:name>John Doe</contact:name>
          <contact:addr>
            <contact:street>123 Example</contact:street>
            <contact:city>Tallinn</contact:city>
            <contact:cc>EE</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+372.1234567</contact:voice>
        <contact:email>test@example.example</contact:email>
        <contact:ident type="op">37605030299</contact:ident>
        <contact:disclose flag="1">
          <contact:voice/>
          <contact:addr/>
        </contact:disclose>
      </contact:create>
    </create>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>304d4fbc</id>
        <crDate>2015-01-21 10:29:43 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9850567700</svTRID>
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
      <contact:update xmlns:contact="urn:ietf:params:xml:ns:contact-1.0"/>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: add, rem or chg</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: id</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0797369949</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user update command fails with wrong authentication info  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>sh8013</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
          <contact:voice>+372.7654321</contact:voice>
          <contact:email>edited@example.example</contact:email>
          <contact:disclose flag="0">
            <contact:voice/>
            <contact:email/>
          </contact:disclose>
        </contact:chg>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2298410935</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user update command is succesful  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>sh8013</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
          <contact:voice>+372.7654321</contact:voice>
          <contact:email>edited@example.example</contact:email>
          <contact:disclose flag="0">
            <contact:voice/>
            <contact:email/>
          </contact:disclose>
        </contact:chg>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>sh8013</id>
        <crDate>2015-01-21 10:29:44 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-1023185320</svTRID>
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
      <contact:update xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>sh8013</contact:id>
        <contact:authInfo>
          <contact:pw>password</contact:pw>
        </contact:authInfo>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
          <contact:voice>123213</contact:voice>
          <contact:email>aaa</contact:email>
          <contact:disclose flag="0">
            <contact:voice/>
            <contact:email/>
          </contact:disclose>
        </contact:chg>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Phone nr is invalid</msg>
    </result>
    <result code="2005">
      <msg lang="en">Email is invalid</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-5978776625</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user update command updates disclosure items  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <contact:update xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>sh8013</contact:id>
        <contact:authInfo>
          <contact:pw>2fooBAR</contact:pw>
        </contact:authInfo>
        <contact:chg>
          <contact:postalInfo>
            <contact:name>John Doe Edited</contact:name>
          </contact:postalInfo>
          <contact:voice>+372.7654321</contact:voice>
          <contact:email>edited@example.example</contact:email>
          <contact:disclose flag="0">
            <contact:voice/>
            <contact:email/>
          </contact:disclose>
        </contact:chg>
      </contact:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <id>sh8013</id>
        <crDate>2015-01-21 10:29:45 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2506903052</svTRID>
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
      <contact:delete xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:uid>23123</contact:uid>
      </contact:delete>
    </delete>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: id</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0395463983</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user delete command deletes contact  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <contact:delete xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>dwa1234</contact:id>
      </contact:delete>
    </delete>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9330149151</svTRID>
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
      <contact:delete xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>sh8012</contact:id>
      </contact:delete>
    </delete>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Object does not exist</msg>
      <value>
        <id>sh8012</id>
      </value>
    </result>
    <result code="2200">
      <msg lang="en">Authentication error</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-8189874530</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user delete command fails if contact has associated domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <contact:delete xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>dwa1234</contact:id>
      </contact:delete>
    </delete>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2305">
      <msg lang="en">Object association prohibits operation</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0461015300</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user check command fails if request is invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <check>
      <contact:check xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:uid>123asde</contact:uid>
      </contact:check>
    </check>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: id</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7483860404</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user check command returns info about contact availability  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
      <command>
        <check>
          <contact:check xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
            <contact:id>check-1234</contact:id>
            <contact:id>check-4321</contact:id>
          </contact:check>
        </check>
        <clTRID>ABC-12345</clTRID>
      </command>
    </epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <cd>
          <id avail="0">check-1234</id>
          <reason>in use</reason>
        </cd>
        <cd>
          <id avail="1">check-4321</id>
        </cd>
      </chkData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-5786454908</svTRID>
</trID>
  </response>
</epp>
```

### EPP Contact with valid user info command discloses items with wrong password when queried by owner  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>info-4444</contact:id>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <id>info-4444</id>
<postalInfo type="int">
  <name>Johnny Awesome</name>
  <org/>
  <addr>
    <street>Rodriguez Well</street>
    <city>Larissatown</city>
  </addr>
</postalInfo>
        <voice>+372.12345678</voice>
        <fax/>
        <email>gus_wiegand@watersmosciski.info</email>
        <crDate>2015-01-21 10:29:48 UTC</crDate>
        <ident type="op">37605030299</ident>
        <authInfo>
          <pw>asde</pw>
        </authInfo>
<disclose flag="0">
  <name/>
</disclose>
<disclose flag="1">
  <email/>
  <phone/>
  <address/>
  <org_name/>
  <fax/>
</disclose>
      </chkData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-8576213187</svTRID>
</trID>
  </response>
</epp>
```

### EPP Contact with valid user info command returns auth error for non-owner with wrong password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>info-4444</contact:id>
        <contact:authInfo>
          <contact:pw>asdesde</contact:pw>
        </contact:authInfo>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2200">
      <msg lang="en">Authentication error</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2753343096</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user info command doesn't disclose items to non-owner with right password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>info-4444</contact:id>
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <id>info-4444</id>
<postalInfo type="int">
  <org/>
</postalInfo>
        <crDate>2015-01-21 10:29:49 UTC</crDate>
        <ident type="op">37605030299</ident>
<disclose flag="0">
  <name/>
</disclose>
<disclose flag="1">
  <email/>
  <phone/>
  <address/>
  <org_name/>
  <fax/>
</disclose>
      </chkData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-5877293456</svTRID>
</trID>
  </response>
</epp>
```

### EPP Contact with valid user info command discloses items to owner  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>info-4444</contact:id>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <id>info-4444</id>
<postalInfo type="int">
  <name>Johnny Awesome</name>
  <org/>
  <addr>
    <street>Rodriguez Well</street>
    <city>Larissatown</city>
  </addr>
</postalInfo>
        <voice>+372.12345678</voice>
        <fax/>
        <email>gus_wiegand@watersmosciski.info</email>
        <crDate>2015-01-21 10:29:50 UTC</crDate>
        <ident type="op">37605030299</ident>
        <authInfo>
          <pw>password</pw>
        </authInfo>
<disclose flag="0">
  <name/>
</disclose>
<disclose flag="1">
  <email/>
  <phone/>
  <address/>
  <org_name/>
  <fax/>
</disclose>
      </chkData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-8230707815</svTRID>
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
      <contact:info xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:uid>123123</contact:uid>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: id</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-4597529491</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user info command returns error when object does not exist  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>info-4444</contact:id>
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Object does not exist</msg>
      <value>
        <id>info-4444</id>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-5481429992</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user info command returns info about contact  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>info-4444</contact:id>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <id>info-4444</id>
<postalInfo type="int">
  <name>Johnny Awesome</name>
  <org/>
  <addr>
    <street>Rodriguez Well</street>
    <city>Larissatown</city>
  </addr>
</postalInfo>
        <voice>+372.12345678</voice>
        <fax/>
        <email>gus_wiegand@watersmosciski.info</email>
        <crDate>2015-01-21 10:29:51 UTC</crDate>
        <ident type="op">37605030299</ident>
        <authInfo>
          <pw>ccds4324pok</pw>
        </authInfo>
<disclose flag="0">
</disclose>
<disclose flag="1">
  <name/>
  <email/>
  <phone/>
  <address/>
  <org_name/>
  <fax/>
</disclose>
      </chkData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6958827963</svTRID>
</trID>
  </response>
</epp>
```

### EPP Contact with valid user info command doesn't disclose private elements  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>info-4444</contact:id>
        <contact:authInfo>
          <contact:pw>2fooBAR</contact:pw>
        </contact:authInfo>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <id>info-4444</id>
<postalInfo type="int">
  <name>Mr. Arvid Volkman</name>
  <org/>
</postalInfo>
        <crDate>2015-01-21 10:29:51 UTC</crDate>
        <ident type="op">37605030299</ident>
<disclose flag="0">
  <email/>
  <phone/>
</disclose>
<disclose flag="1">
  <name/>
  <address/>
  <org_name/>
  <fax/>
</disclose>
      </chkData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-5835939247</svTRID>
</trID>
  </response>
</epp>
```

### EPP Contact with valid user info command doesn't display unassociated object without password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>info-4444</contact:id>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: pw</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0322703567</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user info command doesn't display unassociated object with wrong password  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <contact:info xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
        <contact:id>info-4444</contact:id>
        <contact:authInfo>
          <contact:pw>qwe321</contact:pw>
        </contact:authInfo>
      </contact:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2200">
      <msg lang="en">Authentication error</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-8290951401</svTRID>
</trID>
</epp>
```

### EPP Contact with valid user renew command returns 2101-unimplemented command  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
    <command>
      <renew>
        <contact:renew xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
          <contact:id>info-4444</contact:id>
          <contact:authInfo>
            <contact:pw>2fooBAR</contact:pw>
          </contact:authInfo>
       </contact:renew>
      </renew>
      <clTRID>ABC-12345</clTRID>
    </command>
  </epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2101">
      <msg lang="en">Unimplemented command</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6765703671</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user returns error if contact does not exists  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value>
        <contact>sh8013</contact>
      </value>
    </result>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value>
        <contact>sh801333</contact>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6614677095</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user validates required parameters  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>test.ee</domain:name>
      </domain:create>
    </create>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: ns</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: registrant</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: legalDocument</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2829503581</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user checks a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <check>
      <domain:check xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
      </domain:check>
    </check>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <cd>
          <name avail="1">example.ee</name>
        </cd>
      </chkData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0885246830</svTRID>
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
      <domain:check xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
      </domain:check>
    </check>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <chkData>
        <cd>
          <name avail="0">example.ee</name>
          <reason>in use</reason>
        </cd>
      </chkData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-3321852611</svTRID>
</trID>
  </response>
</epp>
```

### EPP Domain with valid user checks multiple domains  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <check>
      <domain:check xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
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
  <svTRID>ccReg-2685425461</svTRID>
</trID>
  </response>
</epp>
```

### EPP Domain with valid user checks invalid format domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <check>
      <domain:check xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
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
  <svTRID>ccReg-3850735872</svTRID>
</trID>
  </response>
</epp>
```

### EPP Domain with valid user with two epp users can not see other registrar domains  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name hosts="all">example.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2302">
      <msg lang="en">Domain exists but belongs to other registrar</msg>
      <value>
        <name>example.ee</name>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0097877977</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with two epp users transfers a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">387f50217dfd0f5775cead6f1eccdedb</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>example.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>123</reID>
        <reDate>2015-01-21 10:29:57 UTC</reDate>
        <acID>12345678</acID>
        <acDate>2015-01-21 10:29:57 UTC</acDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9830958341</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">38518219ab5a5b2cebfd4748bf3eda6f</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>example.ee</name>
        <trStatus>pending</trStatus>
        <reID>12345678</reID>
        <reDate>2015-01-21 10:29:57 UTC</reDate>
        <acID>123</acID>
        <acDate>2015-01-21 11:29:57 UTC</acDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2765396230</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">38518219ab5a5b2cebfd4748bf3eda6f</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>example.ee</name>
        <trStatus>pending</trStatus>
        <reID>12345678</reID>
        <reDate>2015-01-21 10:29:57 UTC</reDate>
        <acID>123</acID>
        <acDate>2015-01-21 11:29:57 UTC</acDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-1349071112</svTRID>
</trID>
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="1" id="1">
      <qDate>2015-01-21 10:29:57 UTC</qDate>
      <msg>Transfer requested.</msg>
    </msgQ>
    <resData>
      <trnData>
        <name>example.ee</name>
        <trStatus>pending</trStatus>
        <reID>12345678</reID>
        <reDate>2015-01-21 10:29:57 UTC</reDate>
        <acID>123</acID>
        <acDate>2015-01-21 11:29:57 UTC</acDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </trnData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-3758969507</svTRID>
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
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="0" id="1"/>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-3104454880</svTRID>
</trID>
  </response>
</epp>
```

### EPP Domain with valid user with two epp users prohibits wrong registrar from approving transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="approve">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">5c1ff5b0e90966530f37c7f8c411fd9d</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Transfer can be approved only by current domain registrar</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0201363674</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with two epp users approves the transfer request  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="approve">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">383c1c1c3353d81ce96b693aa14ffd16</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>example.ee</name>
        <trStatus>clientApproved</trStatus>
        <reID>123</reID>
        <reDate>2015-01-21 10:29:59 UTC</reDate>
        <acID>12345678</acID>
        <acDate>2015-01-21 10:29:59 UTC</acDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6235387040</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with two epp users does not transfer with invalid pw  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">test</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-1754073529</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with two epp users ignores transfer when owner registrar requests transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">d3a56768abdaedc545b8df3fdcd90645</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2002">
      <msg lang="en">Domain already belongs to the querying registrar</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9735284102</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with two epp users returns an error for incorrect op attribute  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="bla">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Attribute op is invalid</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2657494395</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with two epp users creates new pw after successful transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-1053801473</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">98oiewslkfkd</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2201">
      <msg lang="en">Authorization error</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6288024950</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with two epp users creates a domain transfer with legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">c570157229fd5a1bd7a7e9bf31ba4db2</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>example.ee</name>
        <trStatus>serverApproved</trStatus>
        <reID>123</reID>
        <reDate>2015-01-21 10:30:02 UTC</reDate>
        <acID>12345678</acID>
        <acDate>2015-01-21 10:30:02 UTC</acDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6313594099</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with two epp users creates a domain transfer with legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">47d61710660e41336d52bf8e1131080a</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>example.ee</name>
        <trStatus>pending</trStatus>
        <reID>123</reID>
        <reDate>2015-01-21 10:30:02 UTC</reDate>
        <acID>12345678</acID>
        <acDate>2015-01-21 11:30:02 UTC</acDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-4475565441</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">47d61710660e41336d52bf8e1131080a</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>example.ee</name>
        <trStatus>pending</trStatus>
        <reID>123</reID>
        <reDate>2015-01-21 10:30:02 UTC</reDate>
        <acID>12345678</acID>
        <acDate>2015-01-21 11:30:02 UTC</acDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-8380815020</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with two epp users rejects a domain transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="reject">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">70998e3012697937f21f0c0f22f346a6</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Transfer can be rejected only by current registrar</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7498348115</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="reject">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">70998e3012697937f21f0c0f22f346a6</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <trnData>
        <name>example.ee</name>
        <trStatus>clientRejected</trStatus>
        <reID>123</reID>
        <reDate>2015-01-21 10:30:03 UTC</reDate>
        <acID>12345678</acID>
        <acDate/>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-1063713828</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner creates a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example.ee</name>
        <crDate>2015-01-21 10:30:04 UTC</crDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-5215639689</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner creates a domain with legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example.ee</name>
        <crDate>2015-01-21 10:30:04 UTC</crDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6832738923</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner creates ria.ee with valid ds record  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>ria.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
      </domain:create>
    </create>
    <extension>
      <secDNS:create xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:keyData>
          <secDNS:flags>257</secDNS:flags>
          <secDNS:protocol>3</secDNS:protocol>
          <secDNS:alg>8</secDNS:alg>
          <secDNS:pubKey>AwEAAaOf5+lz3ftsL+0CCvfJbhUF/NVsNh8BKo61oYs5fXVbuWDiH872 LC8uKDO92TJy7Q4TF9XMAKMMlf1GMAxlRspD749SOCTN00sqfWx1OMTu a28L1PerwHq7665oDJDKqR71btcGqyLKhe2QDvCdA0mENimF1NudX1BJ DDFi6oOZ0xE/0CuveB64I3ree7nCrwLwNs56kXC4LYoX3XdkOMKiJLL/ MAhcxXa60CdZLoRtTEW3z8/oBq4hEAYMCNclpbd6y/exScwBxFTdUfFk KsdNcmvai1lyk9vna0WQrtpYpHKMXvY9LFHaJxCOLR4umfeQ42RuTd82 lqfU6ClMeXs=</secDNS:pubKey>
        </secDNS:keyData>
      </secDNS:create>
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>ria.ee</name>
        <crDate>2015-01-21 10:30:05 UTC</crDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6312166836</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner validates nameserver ipv4 when in same zone as domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>ns1.example.ee</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>ns2.example.ee</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">IPv4 is missing</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6137419157</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner does not create duplicate domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example.ee</name>
        <crDate>2015-01-21 10:30:06 UTC</crDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-3537224792</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2302">
      <msg lang="en">Domain name already exists</msg>
      <value>
        <name>example.ee</name>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9671674515</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner does not create reserved domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2302">
      <msg lang="en">Domain name is reserved or restricted</msg>
      <value>
        <name>1162.ee</name>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7466996313</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner does not create domain without contacts and registrant  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
        <domain:contacts/>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: registrant</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-5216540480</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner does not create domain without nameservers  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns/>
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: ns</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-5311304733</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner does not create domain with too many nameservers  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">Nameservers count must be between 2-11</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2795456597</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner returns error when invalid nameservers are present  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostAttr>
            <domain:hostName>invalid1-</domain:hostName>
          </domain:hostAttr>
          <domain:hostAttr>
            <domain:hostName>-invalid2</domain:hostName>
          </domain:hostAttr>
        </domain:ns>
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Hostname is invalid</msg>
      <value>
        <hostObj>invalid1-</hostObj>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Hostname is invalid</msg>
      <value>
        <hostObj>-invalid2</hostObj>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-4112378812</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner does not allow hostObj  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
          <domain:hostObj>ns1.example.ee</domain:hostObj>
          <domain:hostObj>ns2.example.ee</domain:hostObj>
        </domain:ns>
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">hostObj object is not allowed</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2662724544</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner creates domain with nameservers with ips  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example.ee</name>
        <crDate>2015-01-21 10:30:10 UTC</crDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-1461224129</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner returns error when nameserver has invalid ips  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:create>
    </create>
    <extension>
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">IPv4 is invalid</msg>
      <value>
        <hostAddr>192.0.2.2.invalid</hostAddr>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">IPv6 is invalid</msg>
      <value>
        <hostAddr>INVALID_IPV6</hostAddr>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-5799179566</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner creates a domain with period in days  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example.ee</name>
        <crDate>2015-01-21 10:30:11 UTC</crDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-3488238698</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner does not create a domain with invalid period  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">Period must add up to 1, 2 or 3 years</msg>
      <value>
        <period>367</period>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9637388295</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner creates a domain with multiple dnskeys  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example.ee</name>
        <crDate>2015-01-21 10:30:12 UTC</crDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7621148189</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner does not create a domain when dnskeys are invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Valid algorithms are: 3, 5, 6, 7, 8, 252, 253, 254, 255</msg>
      <value>
        <alg>9</alg>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid protocols are: 3</msg>
      <value>
        <protocol>4</protocol>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid flags are: 0, 256, 257</msg>
      <value>
        <flags>250</flags>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid algorithms are: 3, 5, 6, 7, 8, 252, 253, 254, 255</msg>
      <value>
        <alg>10</alg>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Valid flags are: 0, 256, 257</msg>
      <value>
        <flags>1</flags>
      </value>
    </result>
    <result code="2306">
      <msg lang="en">Public key is missing</msg>
    </result>
    <result code="2005">
      <msg lang="en">Valid protocols are: 3</msg>
      <value>
        <protocol>5</protocol>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0230100097</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner does not create a domain with two identical dnskeys  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2302">
      <msg lang="en">Public key already exists</msg>
      <value>
        <pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</pubKey>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-5657943049</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner validated dnskeys count  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">DNS keys count must be between 0-1</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6011706696</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner creates domain with ds data  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example.ee</name>
        <crDate>2015-01-21 10:30:14 UTC</crDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-3236204101</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner creates domain with ds data with key  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example.ee</name>
        <crDate>2015-01-21 10:30:15 UTC</crDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-4988862110</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner prohibits dsData with key  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">dsData object with key data is not allowed</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-3974220517</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner prohibits dsData  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">dsData object is not allowed</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-8365042433</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner prohibits keyData  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
        <domain:contact type="tech">sh8013</domain:contact>
        <domain:contact type="tech">sh801333</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">keyData object is not allowed</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-8809596505</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with juridical persion as an owner creates a domain with contacts  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="admin">sh8013</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <creData>
        <name>example.ee</name>
        <crDate>2015-01-21 10:30:17 UTC</crDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6634178121</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with juridical persion as an owner does not create a domain without admin contact  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
        <domain:registrant>jd1234</domain:registrant>
        <domain:contact type="tech">sh8013</domain:contact>
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
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">Admin contacts count must be between 1-10</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6052411567</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain renews a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:curExpDate>2016-01-21</domain:curExpDate>
        <domain:period unit="y">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <renData>
        <name>example.ee</name>
        <exDate>2017-01-21 00:00:00 UTC</exDate>
      </renData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7445464452</svTRID>
</trID>
  </response>
</epp>
```

### EPP Domain with valid user with valid domain returns an error when given and current exp dates do not match  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:curExpDate>2016-08-07</domain:curExpDate>
        <domain:period unit="y">1</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Given and current expire dates do not match</msg>
      <value>
        <curExpDate>2016-08-07</curExpDate>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2600212757</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain returns an error when period is invalid  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <renew>
      <domain:renew xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:curExpDate>2016-01-21</domain:curExpDate>
        <domain:period unit="y">4</domain:period>
      </domain:renew>
    </renew>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2004">
      <msg lang="en">Period must add up to 1, 2 or 3 years</msg>
      <value>
        <period>4</period>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-1319516698</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain sets ok status by default  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name hosts="all">example.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <name>example.ee</name>
        <status s="ok"/>
        <registrant>sh9456</registrant>
        <contact type="tech">sh9456</contact>
        <contact type="admin">sh9528</contact>
        <ns>
          <hostAttr>
            <hostName>ns.toy48.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.walsh49.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.hoppezulauf50.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
        </ns>
        <clID>Registrar OÜ</clID>
        <crID>Registrar OÜ</crID>
        <crDate>2015-01-21 10:30:19 UTC</crDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
        <authInfo>
          <pw>1f9c469d2b29fe11efcf4ff01f5d9bb2</pw>
        </authInfo>
      </infData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0380108725</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain returns domain info  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name hosts="all">Example.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <name>example.ee</name>
        <status s="clientHold">Payment overdue.</status>
        <registrant>sh0108</registrant>
        <contact type="tech">sh0108</contact>
        <contact type="admin">sh9929</contact>
        <ns>
          <hostAttr>
            <hostName>ns.kassulkedickens51.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.hansen52.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.durgan53.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns1.example.com</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>Registrar OÜ</clID>
        <crID>Registrar OÜ</crID>
        <crDate>2015-01-21 10:30:20 UTC</crDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
        <authInfo>
          <pw>08d150715c1bb62c7970714f43949042</pw>
        </authInfo>
      </infData>
    </resData>
  </response>
  <extension>
    <infData>
      <dsData>
        <keyTag>123</keyTag>
        <alg>3</alg>
        <digestType>1</digestType>
        <digest>abc</digest>
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
        <digest>abc</digest>
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
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-5405753681</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name hosts="all">example.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <resData>
      <infData>
        <name>example.ee</name>
        <status s="clientHold">Payment overdue.</status>
        <registrant>sh0108</registrant>
        <contact type="tech">sh0108</contact>
        <contact type="admin">sh9929</contact>
        <ns>
          <hostAttr>
            <hostName>ns.kassulkedickens51.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.hansen52.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.durgan53.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns1.example.com</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
            <hostAddr ip="v6">1080:0:0:0:8:800:200C:417A</hostAddr>
          </hostAttr>
        </ns>
        <clID>Registrar OÜ</clID>
        <crID>Registrar OÜ</crID>
        <crDate>2015-01-21 10:30:20 UTC</crDate>
        <exDate>2016-01-21 00:00:00 UTC</exDate>
        <upDate>2015-01-21 10:30:20 UTC</upDate>
        <authInfo>
          <pw>08d150715c1bb62c7970714f43949042</pw>
        </authInfo>
      </infData>
    </resData>
  </response>
  <extension>
    <infData>
      <dsData>
        <keyTag>123</keyTag>
        <alg>3</alg>
        <digestType>1</digestType>
        <digest>abc</digest>
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
        <digest>abc</digest>
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
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9379526485</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain returns error when domain can not be found  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <info>
      <domain:info xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name hosts="all">test.ee</domain:name>
        <domain:authInfo>
          <domain:pw>2fooBAR</domain:pw>
        </domain:authInfo>
      </domain:info>
    </info>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Domain not found</msg>
      <value>
        <name>test.ee</name>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0060008399</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain updates domain and adds objects  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostObj>ns1.example.com</domain:hostObj>
            <domain:hostObj>ns2.example.com</domain:hostObj>
          </domain:ns>
          <domain:contact type="tech">mak21</domain:contact>
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value>
        <contact>mak21</contact>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-3155641703</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostObj>ns1.example.com</domain:hostObj>
            <domain:hostObj>ns2.example.com</domain:hostObj>
          </domain:ns>
          <domain:contact type="tech">mak21</domain:contact>
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6366669084</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostObj>ns1.example.com</domain:hostObj>
            <domain:hostObj>ns2.example.com</domain:hostObj>
          </domain:ns>
          <domain:contact type="tech">mak21</domain:contact>
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2302">
      <msg lang="en">Nameserver already exists on this domain</msg>
      <value>
        <hostObj>ns1.example.com</hostObj>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Nameserver already exists on this domain</msg>
      <value>
        <hostObj>ns2.example.com</hostObj>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Contact already exists on this domain!</msg>
      <value>
        <contact>mak21</contact>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Status already exists on this domain</msg>
      <value>
        <status>clientHold</status>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Status already exists on this domain</msg>
      <value>
        <status>clientUpdateProhibited</status>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Public key already exists</msg>
      <value>
        <pubKey>700b97b591ed27ec2590d19f06f88bba700b97b591ed27ec2590d19f</pubKey>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Public key already exists</msg>
      <value>
        <pubKey>841936717ae427ace63c28d04918569a841936717ae427ace63c28d0</pubKey>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9869463114</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain updates a domain and removes objects  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostObj>ns1.example.com</domain:hostObj>
            <domain:hostObj>ns2.example.com</domain:hostObj>
          </domain:ns>
          <domain:contact type="tech">mak21</domain:contact>
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6327616059</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:rem>
          <domain:ns>
            <domain:hostObj>ns1.example.com</domain:hostObj>
          </domain:ns>
          <domain:contact type="tech">mak21</domain:contact>
          <domain:status s="clientHold"/>
        </domain:rem>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:rem>
          <secDNS:keyData>
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7934790338</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:rem>
          <domain:ns>
            <domain:hostObj>ns1.example.com</domain:hostObj>
          </domain:ns>
          <domain:contact type="tech">mak21</domain:contact>
          <domain:status s="clientHold"/>
        </domain:rem>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1">
        <secDNS:rem>
          <secDNS:keyData>
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Contact was not found</msg>
      <value>
        <contact>mak21</contact>
      </value>
    </result>
    <result code="2303">
      <msg lang="en">Nameserver was not found</msg>
      <value>
        <hostObj>ns1.example.com</hostObj>
      </value>
    </result>
    <result code="2303">
      <msg lang="en">Status was not found</msg>
      <value>
        <status>clientHold</status>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0231483814</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain does not remove server statuses  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Status was not found</msg>
      <value>
        <status>serverHold</status>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-3935468334</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain does not add duplicate objects to domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostObj>ns1.example.com</domain:hostObj>
          </domain:ns>
        </domain:add>
      </domain:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-4958951872</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:add>
          <domain:ns>
            <domain:hostObj>ns1.example.com</domain:hostObj>
          </domain:ns>
        </domain:add>
      </domain:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2302">
      <msg lang="en">Nameserver already exists on this domain</msg>
      <value>
        <hostObj>ns1.example.com</hostObj>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-1011626231</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain cannot change registrant without legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:chg>
          <domain:registrant>mak21</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: legalDocument</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9743302727</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain updates a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:chg>
          <domain:registrant>mak21</domain:registrant>
        </domain:chg>
      </domain:update>
    </update>
    <extension>
      <secDNS:update xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"/>
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-4151408787</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain does not assign invalid status to domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <update>
      <domain:update xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Status was not found</msg>
      <value>
        <status>invalidStatus</status>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-4576752535</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain deletes domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <domain:delete xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
      </domain:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-3919038536</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain does not delete domain with specific status  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <domain:delete xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
      </domain:delete>
    </delete>
    <extension>
      <eis:extdata xmlns:eis="urn:ee:eis:xml:epp:eis-1.0">
        <eis:legalDocument type="pdf">JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==</eis:legalDocument>
      </eis:extdata>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2304">
      <msg lang="en">Domain status prohibits operation</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-4602022297</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain does not delete domain without legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <delete>
      <domain:delete xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
      </domain:delete>
    </delete>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: legalDocument</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7492617073</svTRID>
</trID>
</epp>
```

### EPP Helper in context of Domain generates valid transfer xml  

### EPP Keyrelay with valid user makes a keyrelay request  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="urn:ietf:params:xml:ns:domain-1.0" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>example.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>7aca517daf5b52b59037a56ab3238056</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1M13D</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1421836228</ext:clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
  </response>
<trID>
  <clTRID>1421836228</clTRID>
  <svTRID>ccReg-7856423141</svTRID>
</trID>
</epp>
```

### EPP Keyrelay with valid user returns an error when parameters are missing  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="urn:ietf:params:xml:ns:domain-1.0" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>example.ee</ext:name>
      <ext:keyData>
        <secDNS:flags/>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>8890cf7fdaa40de573f3c0997482bc52</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>Invalid Expiry</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1421836228</ext:clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Required parameter missing: flags</msg>
    </result>
  </response>
<trID>
  <clTRID>1421836228</clTRID>
  <svTRID>ccReg-9893241800</svTRID>
</trID>
</epp>
```

### EPP Keyrelay with valid user returns an error on invalid relative expiry  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="urn:ietf:params:xml:ns:domain-1.0" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>example.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>46699c06a52c5e273373d8272f3f06c3</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>Invalid Expiry</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1421836229</ext:clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2005">
      <msg lang="en">Expiry relative must be compatible to ISO 8601</msg>
      <value>
        <relative>Invalid Expiry</relative>
      </value>
    </result>
  </response>
<trID>
  <clTRID>1421836229</clTRID>
  <svTRID>ccReg-3255734550</svTRID>
</trID>
</epp>
```

### EPP Keyrelay with valid user does not allow both relative and absolute  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1" xmlns:domain="urn:ietf:params:xml:ns:domain-1.0" xmlns:ext="urn:ietf:params:xml:ns:keyrelay-1.0">
  <command>
    <ext:keyrelay>
      <ext:name>example.ee</ext:name>
      <ext:keyData>
        <secDNS:flags>256</secDNS:flags>
        <secDNS:protocol>3</secDNS:protocol>
        <secDNS:alg>8</secDNS:alg>
        <secDNS:pubKey>cmlraXN0aGViZXN0</secDNS:pubKey>
      </ext:keyData>
      <ext:authInfo>
        <domain:pw>13190eab5d6e8d1cf4a12aff982d3cc1</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1D</ext:relative>
        <ext:absolute>2014-12-23</ext:absolute>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1421836230</ext:clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2003">
      <msg lang="en">Only one parameter allowed: relative or absolute</msg>
    </result>
  </response>
<trID>
  <clTRID>1421836230</clTRID>
  <svTRID>ccReg-4132958619</svTRID>
</trID>
</epp>
```

### EPP Poll with valid user returns no messages in poll  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="req"/>
    <clTRID>1421836230</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1300">
      <msg>Command completed successfully; no messages</msg>
    </result>
<trID>
  <clTRID>1421836230</clTRID>
  <svTRID>ccReg-5358036383</svTRID>
</trID>
  </response>
</epp>
```

### EPP Poll with valid user queues and dequeues messages  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="req"/>
    <clTRID>1421836230</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1300">
      <msg>Command completed successfully; no messages</msg>
    </result>
<trID>
  <clTRID>1421836230</clTRID>
  <svTRID>ccReg-6157589123</svTRID>
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
    <clTRID>1421836231</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="1" id="1">
      <qDate>2015-01-21 10:30:30 UTC</qDate>
      <msg>Balance low.</msg>
    </msgQ>
<trID>
  <clTRID>1421836231</clTRID>
  <svTRID>ccReg-5225682272</svTRID>
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
    <clTRID>1421836231</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Message was not found</msg>
      <value>
        <msgID>1</msgID>
      </value>
    </result>
  </response>
<trID>
  <clTRID>1421836231</clTRID>
  <svTRID>ccReg-8230579619</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="ack" msgID="1"/>
    <clTRID>1421836231</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="0" id="1"/>
<trID>
  <clTRID>1421836231</clTRID>
  <svTRID>ccReg-2476512517</svTRID>
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
    <clTRID>1421836231</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2303">
      <msg lang="en">Message was not found</msg>
      <value>
        <msgID>1</msgID>
      </value>
    </result>
  </response>
<trID>
  <clTRID>1421836231</clTRID>
  <svTRID>ccReg-8821752012</svTRID>
</trID>
</epp>
```

### EPP Poll with valid user returns an error on incorrect op  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="bla"/>
    <clTRID>1421836231</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2306">
      <msg lang="en">Attribute op is invalid</msg>
    </result>
  </response>
<trID>
  <clTRID>1421836231</clTRID>
  <svTRID>ccReg-4427626533</svTRID>
</trID>
</epp>
```

### EPP Poll with valid user dequeues multiple messages  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="req"/>
    <clTRID>1421836232</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="3" id="3">
      <qDate>2015-01-21 10:30:32 UTC</qDate>
      <msg>Smth else.</msg>
    </msgQ>
<trID>
  <clTRID>1421836232</clTRID>
  <svTRID>ccReg-6932166712</svTRID>
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
    <clTRID>1421836232</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="2" id="3"/>
<trID>
  <clTRID>1421836232</clTRID>
  <svTRID>ccReg-9666400030</svTRID>
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
    <clTRID>1421836232</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="2" id="2">
      <qDate>2015-01-21 10:30:32 UTC</qDate>
      <msg>Something.</msg>
    </msgQ>
<trID>
  <clTRID>1421836232</clTRID>
  <svTRID>ccReg-2376562097</svTRID>
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
    <clTRID>1421836232</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="1" id="2"/>
<trID>
  <clTRID>1421836232</clTRID>
  <svTRID>ccReg-7755816407</svTRID>
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
    <clTRID>1421836232</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1301">
      <msg>Command completed successfully; ack to dequeue</msg>
    </result>
    <msgQ count="1" id="1">
      <qDate>2015-01-21 10:30:32 UTC</qDate>
      <msg>Balance low.</msg>
    </msgQ>
<trID>
  <clTRID>1421836232</clTRID>
  <svTRID>ccReg-3013313986</svTRID>
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
    <clTRID>1421836232</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
    <msgQ count="0" id="1"/>
<trID>
  <clTRID>1421836232</clTRID>
  <svTRID>ccReg-0651604210</svTRID>
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
    <clTRID>1421836232</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1300">
      <msg>Command completed successfully; no messages</msg>
    </result>
<trID>
  <clTRID>1421836232</clTRID>
  <svTRID>ccReg-9205005995</svTRID>
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
    <svDate>2015-01-21T10:30:33Z</svDate>
    <svcMenu>
      <version>1.0</version>
      <lang>en</lang>
      <objURI>urn:ietf:params:xml:ns:domain-1.0</objURI>
      <objURI>urn:ietf:params:xml:ns:contact-1.0</objURI>
      <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
      <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
      <svcExtension>
        <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
        <extURI>urn:ee:eis:xml:epp:eis-1.0</extURI>
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
      <clID>gitlab</clID>
      <pw>ghyt9e4fu</pw>
      <options>
        <version>1.0</version>
        <lang>en</lang>
      </options>
      <svcs>
        <objURI>urn:ietf:params:xml:ns:domain-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:contact-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>urn:ee:eis:xml:epp:eis-1.0</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2501">
      <msg>Authentication error; server closing connection</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-8091571303</svTRID>
</trID>
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
        <objURI>urn:ietf:params:xml:ns:domain-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:contact-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>urn:ee:eis:xml:epp:eis-1.0</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2501">
      <msg>Authentication error; server closing connection</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7127564335</svTRID>
</trID>
</epp>
```

### EPP Session when connected prohibits further actions unless logged in  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0"/>
    </create>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2002">
      <msg lang="en">You need to login first.</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0708017445</svTRID>
</trID>
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
        <objURI>urn:ietf:params:xml:ns:domain-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:contact-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>urn:ee:eis:xml:epp:eis-1.0</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-8862134897</svTRID>
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
        <objURI>urn:ietf:params:xml:ns:domain-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:contact-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>urn:ee:eis:xml:epp:eis-1.0</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-1704064402</svTRID>
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
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1500">
      <msg>Command completed successfully; ending session</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6220365602</svTRID>
</trID>
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
        <objURI>urn:ietf:params:xml:ns:domain-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:contact-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>urn:ee:eis:xml:epp:eis-1.0</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="1000">
      <msg>Command completed successfully</msg>
    </result>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7496958864</svTRID>
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
        <objURI>urn:ietf:params:xml:ns:domain-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:contact-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:host-1.0</objURI>
        <objURI>urn:ietf:params:xml:ns:keyrelay-1.0</objURI>
        <svcExtension>
          <extURI>urn:ietf:params:xml:ns:secDNS-1.1</extURI>
          <extURI>urn:ee:eis:xml:epp:eis-1.0</extURI>
        </svcExtension>
      </svcs>
    </login>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
```

RESPONSE:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <response>
    <result code="2002">
      <msg lang="en">Already logged in. Use &lt;logout&gt; first.</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-4967730499</svTRID>
</trID>
</epp>
```

