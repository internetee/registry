## Domain related functions

Please study official Domain Name Mapping protocol:
http://tools.ietf.org/html/rfc5731

More info at http://en.wikipedia.org/wiki/Extensible_Provisioning_Protocol

Domain name mapping protocol short version:


### Domain create

    Field name                 Min-max  Field description
    -------------------------  -------  -----------------
    <create>                   1       
      <domain:create>          1        Attribute: xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd"
        <domain:name>          1        Domain name. Can contain unicode characters.
        <domain:period>        0-1      Registration period for domain. 
                                        Must add up to 1 / 2 / 3 years.
                                        Attribute: unit="y/m/d"
                                        Default is 1 year.
        <domain:ns>            0-1       
          <domain:hostAttr>    2-11    
            <domain:hostName>  1        Hostname of the nameserver
            <domain:hostAddr>  0-2      Required if nameserver is under domain zone. 
                                        Attribute ip="v4 / v6"
        <domain:registrant>    1        Contact reference to the registrant
        <domain:contact>       0-n      Contact reference. Admin contact is required if registrant is
                                        a juridical person. Attribute: type="admin / tech"
    <extension>                1       
      <secDNS:create>          0-1      Attribute: xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"
        <secDNS:keyData>       1-n     
          <secDNS:flags>       1        Allowed values: 0, 256, 257
          <secDNS:protocol>    1        Allowed values: 3
          <secDNS:alg>         1        Allowed values: 3, 5, 6, 7, 8, 10, 13, 14
          <secDNS:pubKey>      1        Public key
      <eis:extdata>            1        Attribute: xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd"
        <eis:legalDocument>    1        Base64 encoded document. 
                                          Attribute: type="pdf/bdoc/ddoc/zip/rar/gz/tar/7z"
        <eis:reserved>         0-1
          <eis:pw>             0-1      Required if registering a reserved or disputed domain
    <clTRID>                   0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-domain-with-citizen-as-a-registrant-creates-a-domain)

### Domain update

    Field name                   Min-max   Field description
    ------------------------     --------  -----------------
    <update>                     1        
      <domain:update>            1         Attribute: xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd"
        <domain:name>            1         Domain name. Can contain unicode characters.
        <domain:add>             0-1       Objects to add
          <domain:contact>       0-n       Contact reference. Attribute: type="admin / tech"
          <domain:status>        0-n       Status description. 
                                           Attribute: s="clientDeleteProhibited / clientHold / 
                                           clientRenewProhibited / clientTransferProhibited / 
                                           clientUpdateProhibited"
          <domain:ns>            0-1      
            <domain:hostAttr>    1        
              <domain:hostName>  1         Hostname of the nameserver
              <domain:hostAddr>  0-2       Required if nameserver is under domain zone. 
                                           Attribute ip="v4 / v6"
        <domain:rem>             0-1       Objects to remove
          <domain:contact>       0-n       Contact reference. Attribute: type="admin / tech"
          <domain:status>        0-n       Attribute: s="clientDeleteProhibited / clientHold / 
                                           clientRenewProhibited / clientTransferProhibited / 
                                           clientUpdateProhibited"
          <domain:ns>            0-1      
            <domain:hostAttr>    1        
              <domain:hostName>  1         Hostname of the nameserver
        <domain:chg>             0-1       Attributes to change
          <domain:registrant>    0-1       Contact reference to the registrant
                                             Optional attribute: verified="yes/no"
    <extension>                  0-1       Required if registrant is changing
      <secDNS:update>            0-1       Attribute: xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"
        <secDNS:rem>             0-1      
          <secDNS:keyData>       1-n      
            <secDNS:pubKey>      1         Public key
        <secDNS:add>             0-1      
          <secDNS:keyData>       1-n      
            <secDNS:flags>       1         Allowed values: 0, 256, 257
            <secDNS:protocol>    1         Allowed values: 3
            <secDNS:alg>         1         Allowed values: 3, 5, 6, 7, 8, 10, 13, 14
            <secDNS:pubKey>      1         Public key
      <eis:extdata>              0-1       Attribute: xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd"
        <eis:legalDocument>      0-1       Base64 encoded document. Required if registrant is changing. 
                                             Attribute: type="pdf/bdoc/ddoc/zip/rar/gz/tar/7z"
        <eis:reserved>           0-1
          <eis:pw>               0-1       Required if domain name is disputed
    <clTRID>                     0-1       Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-domain-with-valid-domain-updates-domain-and-adds-objects)

### Domain delete

    Field name               Min-max  Field description
    -----------------------  -------  -----------------
    <delete>                 1       
      <domain:delete>        1        Attribute: xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd"
                                        Optional attribute: verified="yes/no"
        <domain:name>        1        Domain name. Can contain unicode characters.
    <extension>              1       
      <eis:extdata>          1        Attribute: xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd"
        <eis:legalDocument>  1        Base64 encoded document. 
                                        Attribute: type="pdf/bdoc/ddoc/zip/rar/gz/tar/7z"
    <clTRID>                 0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-domain-with-valid-domain-deletes-domain)

### Domain info

    Field name               Min-max  Field description
    -----------------------  -------  -----------------
    <info>                   1       
      <domain:info>          1        Attribute: xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd"
        <domain:name>        1        Domain name. Can contain unicode characters. 
                                      Attribute: hosts="all / del / sub / none"
        <domain:authInfo>    0-1      Required if registrar is not the owner of the domain.
          <domain:pw>        1        Domain password. Attribute: roid="String"
    <clTRID>                 0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-domain-with-valid-domain-returns-domain-info)

### Domain renew

    Field name               Min-max  Field description
    -----------------------  -------  -----------------
    <renew>                  1       
      <domain:renew>         1        Attribute: xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd"
        <domain:name>        1        Domain name. Can contain unicode characters. 
        <domain:curExpDate>  1        Current expiry date (ISO8601 format)
        <domain:period>      0-1      Registration period for domain. 
                                      Must add up to 1 / 2 / 3 years. Attribute: unit="y/m/d"
                                      Default value is 1 year.
    <extension>              0-1     
      <eis:extdata>          0-1      Attribute: xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd"
        <eis:legalDocument>  0-1      Base64 encoded document. 
                                        Attribute: type="pdf/bdoc/ddoc/zip/rar/gz/tar/7z"
    <clTRID>                 0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-domain-with-valid-domain-renews-a-domain)

### Domain transfer

    Field name               Min-max  Field description
    -----------------------  -------  -----------------
    <transfer>               1        Attribute: op="request/query/approve/reject/cancel"
      <domain:transfer>      1        Attribute: xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd"
        <domain:name>        1        Domain name. Can contain unicode characters. 
        <domain:authInfo>    1       
          <domain:pw>        1        Domain password. Attribute: roid="String"
    <extension>              0-1     
      <eis:extdata>          0-1      Attribute: xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd"
        <eis:legalDocument>  0-1      Base64 encoded document.  
                                        Attribute: type="pdf/bdoc/ddoc/zip/rar/gz/tar/7z"
    <clTRID>                 0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-domain-with-valid-domain-transfers-a-domain)

### Domain check

    Field name               Min-max  Field description
    -----------------------  -------  -----------------
    <check>                  1       
      <domain:check>         1        Attribute: xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd"
        <domain:name>        1        Domain name. Can contain unicode characters. 
    <clTRID>                 0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-domain-with-valid-domain-checks-a-domain)
