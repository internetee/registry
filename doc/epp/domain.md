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
                                        Must add up to 3m, 6m, 9m, 1y, 2y, 3y, 4y, 5y, 6y, 7y, 8y, 9y, 10y.
                                        Attribute: unit="y/m/d"
                                        Default is 1 year.
        <domain:ns>            0-1
          <domain:hostAttr>    2-11
            <domain:hostName>  1        Hostname of the nameserver
            <domain:hostAddr>  0-2      Required if nameserver hostname is under the same domain.
                                        Attribute ip="v4 / v6"
        <domain:registrant>    1        Contact reference to the registrant
        <domain:contact>       0-n      Contact reference. Admin contact is required if registrant is
                                        a juridical person. Attribute: type="admin / tech"
        <domain:authInfo>      0-1
          <domain:pw>          1         Transfer code. Attribute: roid="String"
        </domain:authInfo>
    <extension>                1
      <secDNS:create>          0-1      Attribute: xmlns:secDNS="urn:ietf:params:xml:ns:secDNS-1.1"
        <secDNS:keyData>       1-n
          <secDNS:flags>       1        Allowed values: 0, 256, 257
          <secDNS:protocol>    1        Allowed values: 3
          <secDNS:alg>         1        Allowed values: 3, 5, 6, 7, 8, 10, 13, 14
          <secDNS:pubKey>      1        Public key
      <eis:extdata>            1        Attribute: xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd"
        <eis:legalDocument>    1        Base64 encoded document.
                                          Attribute: type="pdf/asice/sce/adoc/asics/scs/edoc/adoc/bdoc/ddoc/zip/rar/gz/tar/7z"
        <eis:reserved>         0-1
          <eis:pw>             0-1      Required if registering a reserved or won domain
                                        
    <clTRID>                   0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp_examples.md#epp-domain-with-citizen-as-a-registrant-creates-a-domain)

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
              <domain:hostAddr>  0-2       Required if nameserver hostname is under the same domain.
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
          <domain:authInfo>      0-1
            <domain:pw>          1         Transfer code. Attribute: roid="String"
          </domain:authInfo>
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
                                             Attribute: type="pdf/asice/sce/adoc/asics/scs/edoc/adoc/bdoc/ddoc/zip/rar/gz/tar/7z"
    <clTRID>                     0-1       Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp_examples.md#epp-domain-with-valid-domain-updates-domain-and-adds-objects)

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
                                        Attribute: type="pdf/asice/sce/adoc/asics/scs/edoc/adoc/bdoc/ddoc/zip/rar/gz/tar/7z"
    <clTRID>                 0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp_examples.md#epp-domain-with-valid-domain-deletes-domain)

### Domain info

    Field name               Min-max  Field description
    -----------------------  -------  -----------------
    <info>                   1
      <domain:info>          1        Attribute: xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd"
        <domain:name>        1        Domain name. Can contain unicode characters.
                                      Attribute: hosts="all / del / sub / none"
        <domain:authInfo>    0-1      Required if registrar is not the owner of the domain.
          <domain:pw>        1        Domain transfer code. Attribute: roid="String"
    <clTRID>                 0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp_examples.md#epp-domain-with-valid-domain-returns-domain-info)

### Domain renew

    Field name               Min-max  Field description
    -----------------------  -------  -----------------
    <renew>                  1
      <domain:renew>         1        Attribute: xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd"
        <domain:name>        1        Domain name. Can contain unicode characters.
        <domain:curExpDate>  1        Current expiry date (ISO8601 format)
        <domain:period>      0-1      Registration period for domain.
                                      Must add up to 3m, 6m, 9m, 1y, 2y, 3y, 4y, 5y, 6y, 7y, 8y, 9y, 10y.
                                        Attribute: unit="y/m/d"
                                      Default value is 1 year.
    <extension>              0-1
      <eis:extdata>          0-1      Attribute: xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd"
        <eis:legalDocument>  0-1      Base64 encoded document.
                                        Attribute: type="pdf/asice/sce/adoc/asics/scs/edoc/adoc/bdoc/ddoc/zip/rar/gz/tar/7z"
    <clTRID>                 0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp_examples.md#epp-domain-with-valid-domain-renews-a-domain)

### Domain transfer

    Field name               Min-max  Field description
    -----------------------  -------  -----------------
    <transfer>               1        Attribute: op="request/query/approve/reject/cancel"
      <domain:transfer>      1        Attribute: xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd"
        <domain:name>        1        Domain name. Can contain unicode characters.
        <domain:authInfo>    1
          <domain:pw>        1        Domain transfer code. Attribute: roid="String"
    <extension>              0-1
      <eis:extdata>          0-1      Attribute: xmlns:eis="https://epp.tld.ee/schema/eis-1.0.xsd"
        <eis:legalDocument>  0-1      Base64 encoded document.
                                        Attribute: type="pdf/asice/sce/adoc/asics/scs/edoc/adoc/bdoc/ddoc/zip/rar/gz/tar/7z"
    <clTRID>                 0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp_examples.md#epp-domain-with-valid-domain-transfers-a-domain)

### Domain check

    Field name               Min-max  Field description
    -----------------------  -------  -----------------
    <check>                  1
      <domain:check>         1        Attribute: xmlns:domain="https://epp.tld.ee/schema/domain-eis-1.0.xsd"
        <domain:name>        1        Domain name. Can contain unicode characters.
    <clTRID>                 0-1      Client transaction id

[EXAMPLE REQUEST AND RESPONSE](/doc/epp_examples.md#epp-domain-with-valid-domain-checks-a-domain)

### Automatic renewal and registry grace period

The optional [autoRenew-ee-1.0 schema](/lib/schemas/autoRenew-ee-1.0.xsd) uses
`https://epp.tld.ee/schema/autoRenew-ee-1.0.xsd`. The sponsoring registrar can opt
in during domain creation or change the preference with domain update. An omitted
preference defaults to false on create and leaves the current value unchanged on
update. Enabling requires automatic renewal to be available at the registry.

Put the extension next to any secDNS or EIS elements inside the command's single
`<extension>` wrapper. The following create fragment enables automatic renewal:

```xml
<extension>
  <autoRenew:create xmlns:autoRenew="https://epp.tld.ee/schema/autoRenew-ee-1.0.xsd">
    <autoRenew:enabled>true</autoRenew:enabled>
  </autoRenew:create>
</extension>
```

The update fragment changes future renewal preference. The accepted boolean
values are `true`, `false`, `1`, and `0`.

```xml
<extension>
  <autoRenew:update xmlns:autoRenew="https://epp.tld.ee/schema/autoRenew-ee-1.0.xsd">
    <autoRenew:enabled>false</autoRenew:enabled>
  </autoRenew:update>
</extension>
```

Automatic renewal purchases one year from the original expiry. A paid renewal
has a cancellation deadline 15 calendar days after the original expiry in the
registry time zone. Plain disable prevents future automatic renewals and cancels
an unpaid funding retry; it does not refund a paid renewal. To reverse a paid
renewal before its deadline, submit that cycle's ID instead of `enabled`:

```xml
<extension>
  <autoRenew:update xmlns:autoRenew="https://epp.tld.ee/schema/autoRenew-ee-1.0.xsd">
    <autoRenew:reverse cycleId="3f7c2a5e-0000-0000-0000-000000000000"/>
  </autoRenew:update>
</extension>
```

Reversal disables the preference, removes the automatically purchased year, and
refunds the original charge. The domain remains registered and follows its
ordinary expiry lifecycle if it is expired. Repeating a successful reversal with
the same cycle ID succeeds without another refund. Preference changes and
reversals remain sponsor-only even when another registrar has domain authInfo.
A failed reversal fails the entire update, including nameserver, DNSSEC, contact,
and registrant changes in that command. Automatic renewal is applied immediately
when combined with a registrant change awaiting verification; the verification
replay does not repeat the automatic-renewal operation.

Response extensions require the relevant URI in the session's login
`svcExtension/extURI` list; see [session negotiation](session.md#automatic-renewal-extension-negotiation).
When the create/update command carried this extension, successful responses carry
`creData`/`updData` with the effective preference. For example, a reversal returns:

```xml
<extension>
  <autoRenew:updData xmlns:autoRenew="https://epp.tld.ee/schema/autoRenew-ee-1.0.xsd">
    <autoRenew:enabled>false</autoRenew:enabled>
    <autoRenew:reversed cycleId="3f7c2a5e-0000-0000-0000-000000000000"
      exDate="2027-03-01T00:00:00+02:00" refund="12.00" currency="EUR" repeated="false"/>
  </autoRenew:updData>
</extension>
```

Domain info returns the preference and most recent cycle only to the sponsor.
During active paid grace, anyone authorized to request domain info can also
receive the [RFC 3915](https://www.rfc-editor.org/rfc/rfc3915) RGP status. Both
extensions are independent of DNSSEC and share one wrapper when present:

```xml
<extension>
  <rgp:infData xmlns:rgp="urn:ietf:params:xml:ns:rgp-1.0">
    <rgp:rgpStatus s="autoRenewPeriod"/>
  </rgp:infData>
  <autoRenew:infData xmlns:autoRenew="https://epp.tld.ee/schema/autoRenew-ee-1.0.xsd">
    <autoRenew:enabled>true</autoRenew:enabled>
    <autoRenew:cycle id="3f7c2a5e-0000-0000-0000-000000000000" state="autoRenewPeriod"
      originalExDate="2027-03-01T00:00:00+02:00" exDate="2028-03-01T00:00:00+02:00"
      cancelUntil="2027-03-16T00:00:00+02:00" attempts="1"/>
  </autoRenew:infData>
</extension>
```

Cycle states are `fundingRetry`, `autoRenewPeriod`, `completed`, `reversed`,
`failed`, and `cancelled`. `exDate` is absent until a renewal succeeds.
`cycle` is absent when the domain has no renewal history. RGP `autoRenewPeriod`
is never an ordinary `domain:status`; it disappears at the cancellation deadline,
even if background processing has not closed the cycle yet.

Unpaid or blocked renewals stay in `fundingRetry` and are retried once a day
until the cancellation deadline. The first attempt happens when the cycle opens
at expiry. A late success enters `autoRenewPeriod` with only the remaining
cancellation window: success two days after expiry leaves 13 calendar days to
reverse, and the deadline stays 15 calendar days after the original expiry.

At the deadline an unpaid or still blocked cycle becomes terminal state `failed`
and sends exactly one `renewalFailed` poll explaining the reason. Attempts for
that expiry stop, while the preference stays enabled for future expiries, for
example after a manual renewal. A later top-up or re-enabling the preference does
not reopen the failed cycle. Enabling the preference at or after the cancellation
deadline opens no cycle for that expiry.

| Code | Automatic renewal error |
| --- | --- |
| 2001 | Duplicate extension blocks, conflicting operations, or malformed structure. |
| 2003 | Missing enabled/reverse operation or missing reversal cycle ID. |
| 2005 | Invalid boolean value. |
| 2201 | Requesting registrar is not the domain sponsor. |
| 2303 | Unknown cycle ID or a cycle belonging to another domain. |
| 2304 | Cycle cannot be reversed, including an elapsed cancellation deadline. |
| 2306 | Automatic renewal is unavailable for opt-in, or reversal was requested on create. |

Disabling and reversal remain available when new opt-ins are disabled. Registrar
commands do not create automatic-renewal poll notifications. Transfer completion
disables the preference; a paid year remains registered without a refund or a
charge to the gaining registrar.
