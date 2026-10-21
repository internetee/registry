## Session related functions
Here are functions like login, logout, hello, poll

### Hello request

    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
      <hello/>
    </epp>

[EXAMPLE RESPONSE](/doc/epp_examples.md#epp-session-when-not-connected-greets-client-upon-connection)

### Login request

    Field name               Min-max  Field description 
    -----------------------  -------  ----------------- 
    <login>                  1        
      <clID>                 1        Username      
      <pw>                   1        Password      
      <newPW>                0-1      Optional new password for EPP user
      <options>              0-1            
        <version>            0-1      1.0      
        <lang>               0-1      en      
      <svcs>                 0-1            
        <objURI>             0-n      Object URI that is going to be used in current connection. 
        <svcExtension>       0-1     
        <extURI>             0-n      Extension URI that is going to be used in current connection. 
    <clTRID>                 0-1      Client transaction id 

[EXAMPLE REQUEST AND RESPONSE](/doc/epp_examples.md#epp-session-when-connected-with-valid-user-logs-in-epp-user)

### Logout request

    Field name              Min-max  Field description 
    ----------------------- -------  ----------------- 
    <logout>                1        
    <clTRID>                0-1      Client transaction id 

[EXAMPLE REQUEST AND RESPONSE](/doc/epp_examples.md#epp-session-when-connected-with-valid-user-logs-out-epp-user)

### Poll request

    Field name               Min-max  Field description 
    -----------------------  -------  ----------------- 
    <poll>                   1        Rec for receiving messages, ack for dequeuing 
                                      Attribute: op="req / ack"  
    <clTRID>                 0-1      Client transaction id 

[EXAMPLE REQUEST AND RESPONSE](/doc/epp_examples.md#epp-poll-queues-and-dequeues-messages)

### Automatic renewal extension negotiation

The greeting advertises both extension URIs:

- `https://epp.tld.ee/schema/autoRenew-ee-1.0.xsd`
- `urn:ietf:params:xml:ns:rgp-1.0`

Include each desired URI in the EPP login `svcs/svcExtension` list. The registry
stores this selection for the session and emits each new response extension only
when its URI was requested. Commands containing the automatic-renewal extension
are accepted even without negotiation, but their responses then omit its data.
Existing sessions without these URIs continue receiving their usual responses.

```xml
<svcs xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
  <objURI>https://epp.tld.ee/schema/domain-ee-1.2.xsd</objURI>
  <svcExtension>
    <extURI>https://epp.tld.ee/schema/autoRenew-ee-1.0.xsd</extURI>
    <extURI>urn:ietf:params:xml:ns:rgp-1.0</extURI>
  </svcExtension>
</svcs>
```

See [domain automatic renewal](domain.md#automatic-renewal-and-registry-grace-period)
for create, update, reversal, info, and error-code details.

### Automatic renewal poll messages

Background automatic-renewal events always produce ordinary human-readable poll
text. Sessions negotiating the automatic-renewal URI also receive
`autoRenew:pollData` in the response extension, without `resData`:

```xml
<extension>
  <autoRenew:pollData xmlns:autoRenew="https://epp.tld.ee/schema/autoRenew-ee-1.0.xsd" event="renewed">
    <autoRenew:name>example.ee</autoRenew:name>
    <autoRenew:cycle id="3f7c2a5e-0000-0000-0000-000000000000" state="autoRenewPeriod"
      originalExDate="2027-03-01T00:00:00+02:00" exDate="2028-03-01T00:00:00+02:00"
      cancelUntil="2027-03-16T00:00:00+02:00" attempts="1"/>
  </autoRenew:pollData>
</extension>
```

`event` is `renewed`, `fundingWarning`, `renewProhibited`, or `fundingFailed`.
A funding warning indicates insufficient funds; renew-prohibited includes blocking
statuses or missing renewal pricing. An unpaid cycle has no `exDate`. If funding
has still failed at the cancellation deadline, automatic renewal is disabled and
the registrar receives `fundingFailed`. The attached cycle shows its current
state when the message is read. Acknowledge these messages with the usual poll
`ack` command. Normal grace expiry and registrar-requested preference changes or
reversals do not create these notifications.
