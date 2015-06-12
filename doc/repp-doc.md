# REPP integration specification

REPP uses currently Basic Authentication (http://tools.ietf.org/html/rfc2617#section-2) with ssl certificate and key.
Credentials and certificate are issued by EIS (in an exchange for desired API username, CSR (where CN must match username) and IP).

To quickly test the API, use curl:

    curl -q -k --cert user.crt.pem --key user.key.pem https://TBA/repp/v1/accounts/balance -u username:password

Test API endpoint: TBA  
Production API endpoint: TBA

Main communication specification through Restful EPP (REPP):

[Contact related functions](repp/v1/contact.md)  
[Domain related functions](repp/v1/domain.md)  
[Account related functions](repp/v1/account.md)
