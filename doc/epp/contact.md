## Contact related functions

Please study official Cantact Mapping protocol:
http://tools.ietf.org/html/rfc5733

More info at http://en.wikipedia.org/wiki/Extensible_Provisioning_Protocol

Contact Mapping protocol short version:

### Contact create

    Field name                 Min-max  Field description
    -----------------------    -------  -----------------
    <create>                   1     
      <contact:create>         1        Attribute: xmlns:contact="urn:ietf:params:xml:ns:contact-1.0"
        <contact:postalInfo>   1        Postal information container
          <contact:name>       1        Full name of the contact
          <contact:org>        0-1      Name of organization
          <contact:addr>       1        Address container
            <contact:street>   0-n      Street name
            <contact:city>     1        City name
            <contact:sp>       0-1      State or province
            <contact:pc>       0-1      Postal code
            <contact:cc>`      1        Country code, 2 letters uppercase 
        <contact:voice>        1        Phone number in format \+ddd.d+
        <contact:email>        1        E-mail
        <contact:Ident>        1        Contact identificator. 

    <extension>                0-1
      <eis:extdata>            0-1      Attribute: xmlns:eis="urn:ee:eis:xml:epp:eis-1.0"
        <eis:legalDocument>    1        Base64 encoded document. Attribute: type="pdf"
    <clTRID>                   0-1      Client transaction id

NB! Extension is not implemented yet!

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-contact-with-valid-user-create-command-successfully-creates-a-contact)

### Contact update

    Field name                  Min-max  Field description
    -----------------------     -------  -----------------
    <update>                    1     
      <contact:update>          1        Attribute: xmlns:contact="urn:ietf:params:xml:ns:contact-1.0"
        <contact:id>            1        contact id, required
        <contact:chg>           1        Change container
          <contact:postalInfo>  1        Postal information container
            <contact:name>      0-1      Full name of the contact
            <contact:org>       0-1      Name of organization
            <contact:addr>      0-1      Address container
              <contact:street>  0-n      Street name
              <contact:city>    0-1      City name
              <contact:sp>      0-1      State or province
              <contact:pc>      0-1      Postal code
              <contact:cc>      0-1      Country code
          <contact:voice>       0-1      Phone number in format \+ddd.d+
          <contact:email>       0-1      E-mail
          <contact:Ident>       1        Contact identificator. 
        <contact:authInfo>      0-1      Required if registrar is not the owner of the contact.
          <contact:pw>          1        Contact password. Attribute: roid="String"


[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-contact-with-valid-user-update-command-is-succesful)
