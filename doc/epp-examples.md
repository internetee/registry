# EPP REQUEST - RESPONSE EXAMPLES
GENERATED AT: 2015-01-22 12:53:27 +0200  
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
  <svTRID>ccReg-8181141830</svTRID>
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
  <svTRID>ccReg-5833531336</svTRID>
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
        <id>794f5d58</id>
        <crDate>2015-01-22 10:53:28 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0555033452</svTRID>
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
        <id>eac941ec</id>
        <crDate>2015-01-22 10:53:29 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9379802551</svTRID>
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
        <id>d3664a48</id>
        <crDate>2015-01-22 10:53:29 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2531954915</svTRID>
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
        <id>5d0d91f6</id>
        <crDate>2015-01-22 10:53:29 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2373702503</svTRID>
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
        <id>a122f0b4</id>
        <crDate>2015-01-22 10:53:30 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-5672868276</svTRID>
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
        <id>5d6d8ad1</id>
        <crDate>2015-01-22 10:53:30 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0841784334</svTRID>
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
  <svTRID>ccReg-9740755158</svTRID>
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
  <svTRID>ccReg-5073569029</svTRID>
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
        <crDate>2015-01-22 10:53:31 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2595118078</svTRID>
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
  <svTRID>ccReg-0108994148</svTRID>
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
        <crDate>2015-01-22 10:53:32 UTC</crDate>
      </creData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-1774843199</svTRID>
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
  <svTRID>ccReg-7171405895</svTRID>
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
  <svTRID>ccReg-1173234269</svTRID>
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
  <svTRID>ccReg-7223662758</svTRID>
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
  <svTRID>ccReg-7077660173</svTRID>
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
  <svTRID>ccReg-2357203919</svTRID>
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
  <svTRID>ccReg-1741352907</svTRID>
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
    <street>Tessie Ports</street>
    <city>Susanaland</city>
  </addr>
</postalInfo>
        <voice>+372.12345678</voice>
        <fax/>
        <email>gilbert_hand@hayes.info</email>
        <crDate>2015-01-22 10:53:35 UTC</crDate>
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
  <svTRID>ccReg-2590324936</svTRID>
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
  <svTRID>ccReg-4846228908</svTRID>
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
        <crDate>2015-01-22 10:53:36 UTC</crDate>
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
  <svTRID>ccReg-6813761952</svTRID>
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
    <street>Tessie Ports</street>
    <city>Susanaland</city>
  </addr>
</postalInfo>
        <voice>+372.12345678</voice>
        <fax/>
        <email>gilbert_hand@hayes.info</email>
        <crDate>2015-01-22 10:53:36 UTC</crDate>
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
  <svTRID>ccReg-4259304943</svTRID>
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
  <svTRID>ccReg-3838225664</svTRID>
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
  <svTRID>ccReg-4163455697</svTRID>
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
    <street>Tessie Ports</street>
    <city>Susanaland</city>
  </addr>
</postalInfo>
        <voice>+372.12345678</voice>
        <fax/>
        <email>gilbert_hand@hayes.info</email>
        <crDate>2015-01-22 10:53:37 UTC</crDate>
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
  <svTRID>ccReg-2423756106</svTRID>
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
  <name>Tracy Donnelly</name>
  <org/>
</postalInfo>
        <crDate>2015-01-22 10:53:38 UTC</crDate>
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
  <svTRID>ccReg-2851390480</svTRID>
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
  <svTRID>ccReg-4696226533</svTRID>
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
  <svTRID>ccReg-2761179117</svTRID>
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
  <svTRID>ccReg-3737354648</svTRID>
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
  <svTRID>ccReg-1224668858</svTRID>
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
      <msg lang="en">Required parameter missing: extension &gt; extdata &gt; legalDocument</msg>
    </result>
    <result code="2003">
      <msg lang="en">Required parameter missing: ns &gt; hostAttr</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2343207433</svTRID>
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
  <svTRID>ccReg-6357241747</svTRID>
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
  <svTRID>ccReg-0540310638</svTRID>
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
  <svTRID>ccReg-7227787786</svTRID>
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
  <svTRID>ccReg-7006508598</svTRID>
</trID>
  </response>
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
        <crDate>2015-01-22 10:53:42 UTC</crDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9914284547</svTRID>
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
        <crDate>2015-01-22 10:53:42 UTC</crDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-3094000364</svTRID>
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
        <crDate>2015-01-22 10:53:43 UTC</crDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0277944501</svTRID>
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
  <svTRID>ccReg-1427275479</svTRID>
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
        <crDate>2015-01-22 10:53:44 UTC</crDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7816625604</svTRID>
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
  <svTRID>ccReg-6683839960</svTRID>
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
  <svTRID>ccReg-7938110438</svTRID>
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
  <svTRID>ccReg-8780676604</svTRID>
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
    <result code="2003">
      <msg lang="en">Required parameter missing: ns &gt; hostAttr</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9479110456</svTRID>
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
  <svTRID>ccReg-1858023349</svTRID>
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
        <hostAttr>invalid1-</hostAttr>
      </value>
    </result>
    <result code="2005">
      <msg lang="en">Hostname is invalid</msg>
      <value>
        <hostAttr>-invalid2</hostAttr>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0234127974</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with citizen as an owner checks hostAttr presence  

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
    <result code="2003">
      <msg lang="en">Required parameter missing: ns &gt; hostAttr</msg>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6355820695</svTRID>
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
        <crDate>2015-01-22 10:53:47 UTC</crDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7095302566</svTRID>
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
  <svTRID>ccReg-1857005181</svTRID>
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
        <crDate>2015-01-22 10:53:48 UTC</crDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0408430930</svTRID>
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
  <svTRID>ccReg-7421340430</svTRID>
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
        <crDate>2015-01-22 10:53:49 UTC</crDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9067064348</svTRID>
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
  <svTRID>ccReg-0690209292</svTRID>
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
  <svTRID>ccReg-4791921074</svTRID>
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
  <svTRID>ccReg-7632764259</svTRID>
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
        <crDate>2015-01-22 10:53:51 UTC</crDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7899397090</svTRID>
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
        <crDate>2015-01-22 10:53:51 UTC</crDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-1558878973</svTRID>
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
  <svTRID>ccReg-9987216404</svTRID>
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
  <svTRID>ccReg-6258573043</svTRID>
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
  <svTRID>ccReg-3319727275</svTRID>
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
        <crDate>2015-01-22 10:53:53 UTC</crDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </creData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-8303243773</svTRID>
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
  <svTRID>ccReg-5405889578</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with juridical persion as an owner cannot assign juridical person as admin contact  

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
        <domain:contact type="admin">jd1234</domain:contact>
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
      <msg lang="en">Admin contact can be only citizen</msg>
      <value>
        <contact>jd1234</contact>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-1985922130</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain transfers a domain  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">103c0e594f0891f567ce9503d8378140</domain:pw>
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
        <reDate>2015-01-22 10:53:55 UTC</reDate>
        <acID>12345678</acID>
        <acDate>2015-01-22 10:53:55 UTC</acDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0202347832</svTRID>
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
          <domain:pw roid="JD1234-REP">1810d0cac24ba7d034ca39a3440a9be4</domain:pw>
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
        <reDate>2015-01-22 10:53:55 UTC</reDate>
        <acID>123</acID>
        <acDate>2015-01-22 11:53:55 UTC</acDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0549416009</svTRID>
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
          <domain:pw roid="JD1234-REP">1810d0cac24ba7d034ca39a3440a9be4</domain:pw>
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
        <reDate>2015-01-22 10:53:55 UTC</reDate>
        <acID>123</acID>
        <acDate>2015-01-22 11:53:55 UTC</acDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9821872066</svTRID>
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
      <qDate>2015-01-22 10:53:55 UTC</qDate>
      <msg>Transfer requested.</msg>
    </msgQ>
    <resData>
      <trnData>
        <name>example.ee</name>
        <trStatus>pending</trStatus>
        <reID>12345678</reID>
        <reDate>2015-01-22 10:53:55 UTC</reDate>
        <acID>123</acID>
        <acDate>2015-01-22 11:53:55 UTC</acDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </trnData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6702001709</svTRID>
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
  <svTRID>ccReg-2174165939</svTRID>
</trID>
  </response>
</epp>
```

### EPP Domain with valid user with valid domain creates a domain transfer with legal document  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">813e680d2639bca3248d899c1be9d958</domain:pw>
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
        <reDate>2015-01-22 10:53:56 UTC</reDate>
        <acID>12345678</acID>
        <acDate>2015-01-22 11:53:56 UTC</acDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-5823124302</svTRID>
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
          <domain:pw roid="JD1234-REP">813e680d2639bca3248d899c1be9d958</domain:pw>
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
        <reDate>2015-01-22 10:53:56 UTC</reDate>
        <acID>12345678</acID>
        <acDate>2015-01-22 11:53:56 UTC</acDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-8158177650</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain approves the transfer request  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="approve">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">8065692a9060f5cc6ddd8183bd1e1289</domain:pw>
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
        <reDate>2015-01-22 10:53:56 UTC</reDate>
        <acID>12345678</acID>
        <acDate>2015-01-22 10:53:56 UTC</acDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-6442601367</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain rejects a domain transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="reject">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">333313d3e154296a645c81a6c5991430</domain:pw>
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
  <svTRID>ccReg-9083191318</svTRID>
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
          <domain:pw roid="JD1234-REP">333313d3e154296a645c81a6c5991430</domain:pw>
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
        <reDate>2015-01-22 10:53:57 UTC</reDate>
        <acID>12345678</acID>
        <acDate/>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
      </trnData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-2489729130</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain prohibits wrong registrar from approving transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="approve">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">87f64748cd6a8b0e35cdb79edf763d39</domain:pw>
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
  <svTRID>ccReg-1029920191</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain does not transfer with invalid pw  

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
  <svTRID>ccReg-4747011771</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain ignores transfer when owner registrar requests transfer  

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="query">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.ee</domain:name>
        <domain:authInfo>
          <domain:pw roid="JD1234-REP">fa1a4ba4dbe52df6ee56acf596af1c6e</domain:pw>
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
  <svTRID>ccReg-7779874842</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain returns an error for incorrect op attribute  

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
  <svTRID>ccReg-2732202504</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain creates new pw after successful transfer  

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
  <svTRID>ccReg-7911523676</svTRID>
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
  <svTRID>ccReg-7218956454</svTRID>
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
  <svTRID>ccReg-0489837548</svTRID>
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
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns2.example.com</domain:hostName>
            </domain:hostAttr>
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
  <svTRID>ccReg-5729719171</svTRID>
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
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns2.example.com</domain:hostName>
            </domain:hostAttr>
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
  <svTRID>ccReg-1534764288</svTRID>
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
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns2.example.com</domain:hostName>
            </domain:hostAttr>
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
        <hostAttr>ns1.example.com</hostAttr>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Nameserver already exists on this domain</msg>
      <value>
        <hostAttr>ns2.example.com</hostAttr>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Contact already exists on this domain</msg>
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
  <svTRID>ccReg-4172222483</svTRID>
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
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
              <domain:hostName>ns2.example.com</domain:hostName>
            </domain:hostAttr>
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
  <svTRID>ccReg-3126744781</svTRID>
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
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
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
  <svTRID>ccReg-0285376545</svTRID>
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
            <domain:hostAttr>
              <domain:hostName>ns1.example.com</domain:hostName>
            </domain:hostAttr>
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
        <hostAttr>ns1.example.com</hostAttr>
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
  <svTRID>ccReg-3863340776</svTRID>
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
  <svTRID>ccReg-9448362525</svTRID>
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
            <domain:hostAttr>
              <domain:hostName>ns.grimeswilderman45.ee</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="admin">sh0705</domain:contact>
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
        <hostAttr>ns.grimeswilderman45.ee</hostAttr>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Contact already exists on this domain</msg>
      <value>
        <contact>sh0705</contact>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0307065677</svTRID>
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
            <domain:hostAttr>
              <domain:hostName>ns.grimeswilderman45.ee</domain:hostName>
            </domain:hostAttr>
          </domain:ns>
          <domain:contact type="admin">sh0705</domain:contact>
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
        <hostAttr>ns.grimeswilderman45.ee</hostAttr>
      </value>
    </result>
    <result code="2302">
      <msg lang="en">Contact already exists on this domain</msg>
      <value>
        <contact>sh0705</contact>
      </value>
    </result>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-0487012328</svTRID>
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
  <svTRID>ccReg-5059687105</svTRID>
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
  <svTRID>ccReg-7306447041</svTRID>
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
        <domain:curExpDate>2016-01-22</domain:curExpDate>
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
        <exDate>2017-01-22 00:00:00 UTC</exDate>
      </renData>
    </resData>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-9246155327</svTRID>
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
  <svTRID>ccReg-2938567089</svTRID>
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
        <domain:curExpDate>2016-01-22</domain:curExpDate>
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
  <svTRID>ccReg-5577214205</svTRID>
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
        <registrant>sh4261</registrant>
        <contact type="tech">sh4261</contact>
        <contact type="admin">sh6872</contact>
        <ns>
          <hostAttr>
            <hostName>ns.abshire63.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.simonis64.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.larkinkoch65.ee</hostName>
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
        <crDate>2015-01-22 10:54:05 UTC</crDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
        <authInfo>
          <pw>dc6995ce1452c759265496a14c79bd01</pw>
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
  <svTRID>ccReg-0049084674</svTRID>
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
        <registrant>sh4261</registrant>
        <contact type="tech">sh4261</contact>
        <contact type="admin">sh6872</contact>
        <ns>
          <hostAttr>
            <hostName>ns.abshire63.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.simonis64.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.larkinkoch65.ee</hostName>
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
        <crDate>2015-01-22 10:54:05 UTC</crDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
        <upDate>2015-01-22 10:54:06 UTC</upDate>
        <authInfo>
          <pw>dc6995ce1452c759265496a14c79bd01</pw>
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
  <svTRID>ccReg-8080042694</svTRID>
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
  <svTRID>ccReg-1487539662</svTRID>
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
        <registrant>sh6802</registrant>
        <contact type="tech">sh6802</contact>
        <contact type="admin">sh1477</contact>
        <ns>
          <hostAttr>
            <hostName>ns.roobmcclure69.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.kovacek70.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
          <hostAttr>
            <hostName>ns.hillllindgren71.ee</hostName>
            <hostAddr ip="v4">192.168.1.1</hostAddr>
          </hostAttr>
        </ns>
        <clID>Registrar OÜ</clID>
        <crID>Registrar OÜ</crID>
        <crDate>2015-01-22 10:54:06 UTC</crDate>
        <exDate>2016-01-22 00:00:00 UTC</exDate>
        <authInfo>
          <pw>ed932d4e3211ffdb732e183afaa4a935</pw>
        </authInfo>
      </infData>
    </resData>
  </response>
<trID>
  <clTRID>ABC-12345</clTRID>
  <svTRID>ccReg-7866596060</svTRID>
</trID>
</epp>
```

### EPP Domain with valid user with valid domain can not see other registrar domains  

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
  <svTRID>ccReg-0368282298</svTRID>
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
  <svTRID>ccReg-5040989978</svTRID>
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
  <svTRID>ccReg-0776919224</svTRID>
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
  <svTRID>ccReg-4019599154</svTRID>
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
        <domain:pw>a4098d7d024712ac1bdc0157d97a69cc</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1M13D</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1421924049</ext:clTRID>
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
  <clTRID>1421924049</clTRID>
  <svTRID>ccReg-4569531786</svTRID>
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
        <domain:pw>c65f2c94959ebc7d8ebdddf2b4f6cc62</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>Invalid Expiry</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1421924050</ext:clTRID>
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
  <clTRID>1421924050</clTRID>
  <svTRID>ccReg-5537307460</svTRID>
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
        <domain:pw>bc622aa1ad097e322ec1fdd537bce10c</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>Invalid Expiry</ext:relative>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1421924050</ext:clTRID>
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
  <clTRID>1421924050</clTRID>
  <svTRID>ccReg-4994897192</svTRID>
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
        <domain:pw>be1827f16612f4aa4e7a459483f26624</domain:pw>
      </ext:authInfo>
      <ext:expiry>
        <ext:relative>P1D</ext:relative>
        <ext:absolute>2014-12-23</ext:absolute>
      </ext:expiry>
    </ext:keyrelay>
    <ext:clTRID>1421924050</ext:clTRID>
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
  <clTRID>1421924050</clTRID>
  <svTRID>ccReg-5038193284</svTRID>
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
    <clTRID>1421924051</clTRID>
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
  <clTRID>1421924051</clTRID>
  <svTRID>ccReg-2693326370</svTRID>
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
    <clTRID>1421924051</clTRID>
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
  <clTRID>1421924051</clTRID>
  <svTRID>ccReg-6627109021</svTRID>
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
    <clTRID>1421924051</clTRID>
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
      <qDate>2015-01-22 10:54:11 UTC</qDate>
      <msg>Balance low.</msg>
    </msgQ>
<trID>
  <clTRID>1421924051</clTRID>
  <svTRID>ccReg-9051812146</svTRID>
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
    <clTRID>1421924051</clTRID>
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
  <clTRID>1421924051</clTRID>
  <svTRID>ccReg-3340054002</svTRID>
</trID>
</epp>
```

REQUEST:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="ack" msgID="1"/>
    <clTRID>1421924051</clTRID>
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
  <clTRID>1421924051</clTRID>
  <svTRID>ccReg-9157978267</svTRID>
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
    <clTRID>1421924051</clTRID>
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
  <clTRID>1421924051</clTRID>
  <svTRID>ccReg-1507914198</svTRID>
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
    <clTRID>1421924052</clTRID>
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
  <clTRID>1421924052</clTRID>
  <svTRID>ccReg-9605009033</svTRID>
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
    <clTRID>1421924052</clTRID>
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
      <qDate>2015-01-22 10:54:12 UTC</qDate>
      <msg>Smth else.</msg>
    </msgQ>
<trID>
  <clTRID>1421924052</clTRID>
  <svTRID>ccReg-1329594539</svTRID>
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
    <clTRID>1421924052</clTRID>
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
  <clTRID>1421924052</clTRID>
  <svTRID>ccReg-4376592741</svTRID>
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
    <clTRID>1421924052</clTRID>
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
      <qDate>2015-01-22 10:54:12 UTC</qDate>
      <msg>Something.</msg>
    </msgQ>
<trID>
  <clTRID>1421924052</clTRID>
  <svTRID>ccReg-5620333678</svTRID>
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
    <clTRID>1421924052</clTRID>
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
  <clTRID>1421924052</clTRID>
  <svTRID>ccReg-8697411498</svTRID>
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
    <clTRID>1421924053</clTRID>
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
      <qDate>2015-01-22 10:54:12 UTC</qDate>
      <msg>Balance low.</msg>
    </msgQ>
<trID>
  <clTRID>1421924053</clTRID>
  <svTRID>ccReg-7193257898</svTRID>
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
    <clTRID>1421924053</clTRID>
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
  <clTRID>1421924053</clTRID>
  <svTRID>ccReg-0663525231</svTRID>
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
    <clTRID>1421924053</clTRID>
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
  <clTRID>1421924053</clTRID>
  <svTRID>ccReg-1808498081</svTRID>
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
    <svDate>2015-01-22T10:54:13Z</svDate>
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
  <svTRID>ccReg-6027560481</svTRID>
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
  <svTRID>ccReg-8044658201</svTRID>
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
  <svTRID>ccReg-3983606443</svTRID>
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

