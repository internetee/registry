# REPP integration specification

REPP uses HTTP/1.1 protocol (http://www.ietf.org/rfc/rfc2616.txt) and 
Basic Authentication (http://tools.ietf.org/html/rfc2617#section-2) using 
Secure Transport (https://tools.ietf.org/html/rfc5246) with certificate and key (https://tools.ietf.org/html/rfc5280).

Credentials and certificate are issued by EIS (in an exchange for desired API username, CSR and IP).

To quickly test the API, use curl:

    curl -q -k --cert user.crt.pem --key user.key.pem https://TBA/repp/v1/accounts/balance -u username:password

Test API endpoint: TBA  
Production API endpoint: TBA

Main communication specification through Restful EPP (REPP):

[Contact related functions](repp/v1/contact.md)  
[Domain related functions](repp/v1/domain.md)  
[Account related functions](repp/v1/account.md)
