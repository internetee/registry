## Contact related functions

Please study official Contact Mapping protocol:
http://tools.ietf.org/html/rfc5733

More info at http://en.wikipedia.org/wiki/Extensible_Provisioning_Protocol

Contact Mapping protocol short version:

All values are limited to Unicode Latin characters if stricter limits are not specified. This includes unicode blocks
Basic Latin, Latin-1 Supplement, Latin Extended-A, Latin Extended-B, Latin Extended C, Latin Extended D, 
Latin Extended Additional, Diacritics.
More info: https://en.wikipedia.org/wiki/Latin_script_in_Unicode

### Contact create

    Field name                 Min-max  Field description
    -----------------------    -------  -----------------
    <create>                   1     
      <contact:create>         1        Attribute: xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd"
        <contact:id>           0-1      Contact id, optional, 
                                          string: ASCII letters, numbers, ':', '-' characters, no spaces,
                                          max 100 characters,
                                          generated automatically if missing.
        <contact:postalInfo>   1        Postal information container
          <contact:name>       1        Full name of the contact
          <contact:org>        0        Org is not supported and must be blank or missing
          <contact:addr>       0-1      Address container, optional
            <contact:street>   0-3      Street name
            <contact:city>     1        City name
            <contact:sp>       0-1      State or province
            <contact:pc>       0-1      Postal code
            <contact:cc>       1        Country code, 2 letters uppercase, in ISO_3166-1 alpha 2
        <contact:voice>        1        Phone number in format \+ddd.d+
        <contact:fax>          0        Fax is not supported and must be blank or missing
        <contact:email>        1        E-mail
    <extension>                1       
      <eis:extdata>            1        Attribute: xmlns:eis="https://epp.tld.ee/schema/ee-1.1.xsd"
        <eis:ident>            1        Contact identificator 
                                          Attribute: "type"
                                            "org"          # Business registry code
                                            "priv"         # National idendtification number
                                            "birthday"     # Birthday date in format in YYYY-MM-DD
                                          Attribute: "cc"
                                            "EE"           # Country code in ISO_3166-1 aplha 2
        <eis:legalDocument>    0-1      Base64 encoded document 
                                          Attribute: type="pdf/bdoc/zip/rar/gz/tar/7z"
    <clTRID>                   0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-contact-with-valid-user-create-command-successfully-creates-a-contact)

### Contact update

    Field name                  Min-max  Field description
    -----------------------     -------  -----------------
    <update>                    1     
      <contact:update>          1        Attribute: xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd"
        <contact:id>            1        Contact id, required
        <contact:chg>           1        Change container
          <contact:postalInfo>  1        Postal information container
            <contact:name>      0-1      Full name of the contact
            <contact:org>       0        Org is not supported and must be blank or missing
            <contact:addr>      0-1      Address container
              <contact:street>  0-3      Street name
              <contact:city>    1        City name
              <contact:sp>      0-1      State or province
              <contact:pc>      0-1      Postal code
              <contact:cc>      1        Country code, 2 letters uppercase, in ISO_3166-1 alpha 2
          <contact:voice>       0-1      Phone number in format \+ddd.d+
          <contact:fax>         0        Fax is not supported and must be blank or missing
          <contact:email>       0-1      E-mail
          <contact:authInfo>    0-1      Required if registrar is not the owner of the contact.
            <contact:pw>        1        Contact password. Attribute: roid="String"
    <extension>                 0-1       
      <eis:extdata>             0-1      Attribute: xmlns:eis="https://epp.tld.ee/schema/ee-1.1.xsd"
        <eis:ident>             0-1      Contact identificator 
                                          Attribute: "type"
                                            "org"          # Business registry code
                                            "priv"         # National idendtification number
                                            "birthday"     # Birthday date in format in YYYY-MM-DD
                                          Attribute: "cc"
                                            "EE"           # Country code in ISO_3166-1 aplha 2
        <eis:legalDocument>     0-1      Base64 encoded document. 
                                           Attribute: type="pdf/bdoc/zip/rar/gz/tar/7z"
    <clTRID>                    0-1      Client transaction id


[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-contact-with-valid-user-update-command-is-succesful)

### Contact delete

    Field name                Min-max  Field description
    -----------------------   -------  -----------------
    <delete>                  1       
      <contact:delete>        1        Attribute: xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd"
        <contact:id>          1        Contact id
        <contact:authInfo>    0-1      Required if registrar is not the owner of the contact.
          <contact:pw>        1        Contact password. Attribute: roid="String"
    <extension>               0-1       
      <eis:extdata>           0-1      Attribute: xmlns:eis="https://epp.tld.ee/schema/ee-1.1.xsd"
        <eis:legalDocument>   0-1      Base64 encoded document. 
                                         Attribute: type="pdf/bdoc/zip/rar/gz/tar/7z"
    <clTRID>                  0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-contact-with-valid-user-delete-command-deletes-contact)


### Contact check

    Field name               Min-max  Field description
    -----------------------  -------  -----------------
    <check>                  1       
      <contact:check>        1        Attribute: xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd"
        <contact:id>         1-n      Contact id 
    <clTRID>                 0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-contact-with-valid-user-check-command-returns-info-about-contact-availability)


### Contact info

    Field name               Min-max  Field description
    -----------------------  -------  -----------------
    <info>                   1       
      <contact:info>         1        Attribute: xmlns:contact="https://epp.tld.ee/schema/contact-ee-1.1.xsd"
        <contact:id>         1-n      Contact id 
        <contact:authInfo>   0-1      Required if registrar is not the owner of the contact.
          <contact:pw>       1        Contact password. Attribute: roid="String"
    <clTRID>                 0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-contact-with-valid-user-info-command-return-info-about-contact)
