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
