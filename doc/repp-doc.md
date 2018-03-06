# REPP integration specification

REPP uses HTTP/1.1 protocol (http://tools.ietf.org/html/rfc2616) and 
Basic Authentication (http://tools.ietf.org/html/rfc2617#section-2) using 
Secure Transport (https://tools.ietf.org/html/rfc5246) with certificate and key (https://tools.ietf.org/html/rfc5280).

Credentials and certificate are issued by EIS (in an exchange for desired API username, CSR and IP).

To quickly test the API, use curl:

    curl -q -k --cert user.crt.pem --key user.key.pem https://TBA/repp/v1/accounts/balance -u username:password

Test API endpoint: https://testepp.internet.ee/repp/v1  
Production API endpoint: TBA

Main communication specification through Restful EPP (REPP):

[Contact related functions](repp/v1/contact.md)  
[Domain related functions](repp/v1/domain.md)  
[Domain transfers](repp/v1/domain_transfers.md)  
[Account related functions](repp/v1/account.md)  
[Nameservers](repp/v1/nameservers.md)  
