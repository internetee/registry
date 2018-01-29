## Keyrelay related functions

### Keyrelay

NB! Keyrelay not implemented.

    Field name             Min-max  Field description 
    ---------------------  -------  ----------------- 
    <ext:keyrelay>         1
      <ext:name>           1        Domain name 
      <ext:keyData>        1
        <secDNS:flags>     1        Allowed values: 0, 256, 257 
        <secDNS:protocol>  1        Allowed values: 3 
        <secDNS:alg>       1        Allowed values: 3, 5, 6, 7, 8, 10, 13, 14 
        <secDNS:pubKey>    1        Public key 
      <ext:authInfo>       1 
        <domain:pw>        1        Domain transfer code. Attribute: roid="String" 
      <ext:expiry>         1 
        <ext:relative>     0-1      Relative expiry duration (ISO8601). 
                                    Required if ext:absolute is not specified 
        <ext:absolute>     0-1      Absolute expiry date (ISO8601). 
                                    Required if ext:relative is not specified 
    <clTRID>               0-1      Client transaction id 

[EXAMPLE REQUEST AND RESPONSE](/doc/epp-examples.md#epp-keyrelay-makes-a-keyrelay-request)
