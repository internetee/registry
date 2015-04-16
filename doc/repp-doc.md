# REPP integration specification

REPP uses currently Basic Authentication (http://tools.ietf.org/html/rfc2617#section-2) with ssl certificate and key.
Credentials and certificate are issued by EIS (in an exchange for desired API username, CSR (where CN must match username) and IP).

Test API endpoint: https://repp.todo.ee/repp/v1  
Production API endpoint: https://repp.todo.ee/repp/v1

Main communication specification through Restful EPP (REPP):

[Contact related functions](repp/v1/contact.md)  
[Domain related functions](repp/v1/domain.md)  
[Account related functions](repp/v1/account.md)
