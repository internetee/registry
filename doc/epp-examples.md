# EPP REQUEST - RESPONSE EXAMPLES
GENERATED AT: 2015-03-31 16:25:27 +0300  
EXAMPLE COUNT: 122  

---

### EPP Contact with valid user create command fails if request xml is missing  

### EPP Contact with valid user create command successfully creates a contact  

### EPP Contact with valid user create command successfully saves ident type  

### EPP Contact with valid user create command successfully adds registrar  

### EPP Contact with valid user create command returns result data upon success  

### EPP Contact with valid user create command successfully saves custom code  

### EPP Contact with valid user create command should generate server id when id is empty  

### EPP Contact with valid user create command should generate server id when id is empty  

### EPP Contact with valid user create command should return parameter value policy error for org  

### EPP Contact with valid user create command should return parameter value policy error for fax  

### EPP Contact with valid user update command fails if request is invalid  

### EPP Contact with valid user update command returns error if obj doesnt exist  

### EPP Contact with valid user update command is succesful  

### EPP Contact with valid user update command fails with wrong authentication info  

### EPP Contact with valid user update command returns phone and email error  

### EPP Contact with valid user update command should not update code with custom string  

### EPP Contact with valid user update command should update ident  

### EPP Contact with valid user update command should return parameter value policy errror for org update  

### EPP Contact with valid user update command should return parameter value policy errror for fax update  

### EPP Contact with valid user update command does not allow to edit statuses if policy forbids it  

### EPP Contact with valid user delete command fails if request is invalid  

### EPP Contact with valid user delete command returns error if obj doesnt exist  

### EPP Contact with valid user delete command deletes contact  

### EPP Contact with valid user delete command fails if contact has associated domain  

### EPP Contact with valid user delete command fails with wrong authentication info  

### EPP Contact with valid user check command fails if request is invalid  

### EPP Contact with valid user check command returns info about contact availability  

### EPP Contact with valid user info command fails if request invalid  

### EPP Contact with valid user info command returns error when object does not exist  

### EPP Contact with valid user info command return info about contact  

### EPP Contact with valid user info command should return ident in extension  

### EPP Contact with valid user info command returns no authorization error for wrong password when owner  

### EPP Contact with valid user info command returns no authorization error for wrong user but correct pw  

### EPP Contact with valid user info command returns no authorization error for wrong user and wrong pw  

### EPP Contact with valid user renew command returns 2101-unimplemented command  

### EPP Domain returns error if contact does not exists  

### EPP Domain validates required parameters  

### EPP Domain with citizen as an owner creates a domain  

### EPP Domain with citizen as an owner creates a domain with legal document  

### EPP Domain with citizen as an owner validates nameserver ipv4 when in same zone as domain  

### EPP Domain with citizen as an owner does not create reserved domain  

### EPP Domain with citizen as an owner does not create domain without contacts and registrant  

### EPP Domain with citizen as an owner does not create domain without nameservers  

### EPP Domain with citizen as an owner does not create domain with too many nameservers  

### EPP Domain with citizen as an owner returns error when invalid nameservers are present  

### EPP Domain with citizen as an owner checks hostAttr presence  

### EPP Domain with citizen as an owner creates domain with nameservers with ips  

### EPP Domain with citizen as an owner returns error when nameserver has invalid ips  

### EPP Domain with citizen as an owner creates a domain with period in days  

### EPP Domain with citizen as an owner does not create a domain with invalid period  

### EPP Domain with citizen as an owner creates a domain with multiple dnskeys  

### EPP Domain with citizen as an owner does not create a domain when dnskeys are invalid  

### EPP Domain with citizen as an owner does not create a domain with two identical dnskeys  

### EPP Domain with citizen as an owner validated dnskeys count  

### EPP Domain with citizen as an owner creates domain with ds data  

### EPP Domain with citizen as an owner creates domain with ds data with key  

### EPP Domain with citizen as an owner prohibits dsData  

### EPP Domain with citizen as an owner prohibits keyData  

### EPP Domain with citizen as an owner prohibits dsData and keyData when they exists together  

### EPP Domain with juridical persion as an owner creates a domain with contacts  

### EPP Domain with juridical persion as an owner does not create a domain without admin contact  

### EPP Domain with juridical persion as an owner cannot assign juridical person as admin contact  

### EPP Domain with valid domain transfers a domain  

### EPP Domain with valid domain creates a domain transfer with legal document  

### EPP Domain with valid domain creates transfer successfully without legal document  

### EPP Domain with valid domain transfers domain with contacts  

### EPP Domain with valid domain transfers domain when registrant has more domains  

### EPP Domain with valid domain transfers domain when registrant is admin or tech contact on some other domain  

### EPP Domain with valid domain transfers domain when domain contacts are some other domain contacts  

### EPP Domain with valid domain transfers domain when multiple domain contacts are some other domain contacts  

### EPP Domain with valid domain transfers domain and references exsisting owner contact to domain contacts  

### EPP Domain with valid domain does not transfer contacts if they are already under new registrar  

### EPP Domain with valid domain should not creates transfer without password  

### EPP Domain with valid domain approves the transfer request  

### EPP Domain with valid domain rejects a domain transfer  

### EPP Domain with valid domain prohibits wrong registrar from approving transfer  

### EPP Domain with valid domain does not transfer with invalid pw  

### EPP Domain with valid domain ignores transfer when owner registrar requests transfer  

### EPP Domain with valid domain returns an error for incorrect op attribute  

### EPP Domain with valid domain creates new pw after successful transfer  

### EPP Domain with valid domain should get an error when there is no pending transfer  

### EPP Domain with valid domain updates a domain  

### EPP Domain with valid domain updates domain and adds objects  

### EPP Domain with valid domain does not allow to edit statuses if policy forbids it  

### EPP Domain with valid domain updates a domain and removes objects  

### EPP Domain with valid domain does not remove server statuses  

### EPP Domain with valid domain does not add duplicate objects to domain  

### EPP Domain with valid domain cannot change registrant without legal document  

### EPP Domain with valid domain does not assign invalid status to domain  

### EPP Domain with valid domain renews a domain  

### EPP Domain with valid domain returns an error when given and current exp dates do not match  

### EPP Domain with valid domain returns an error when period is invalid  

### EPP Domain with valid domain returns domain info  

### EPP Domain with valid domain returns domain info with different nameservers  

### EPP Domain with valid domain returns error when domain can not be found  

### EPP Domain with valid domain sets ok status by default  

### EPP Domain with valid domain can not see other registrar domains  

### EPP Domain with valid domain deletes domain  

### EPP Domain with valid domain does not delete domain with specific status  

### EPP Domain with valid domain does not delete domain without legal document  

### EPP Domain with valid domain checks a domain  

### EPP Domain with valid domain checks multiple domains  

### EPP Domain with valid domain checks invalid format domain  

### EPP Helper in context of Domain generates valid transfer xml  

### EPP Keyrelay makes a keyrelay request  

### EPP Keyrelay returns an error when parameters are missing  

### EPP Keyrelay returns an error on invalid relative expiry  

### EPP Keyrelay returns an error on invalid absolute expiry  

### EPP Keyrelay does not allow both relative and absolute  

### EPP Keyrelay saves legal document with keyrelay  

### EPP Keyrelay validates legal document types  

### EPP Poll returns no messages in poll  

### EPP Poll queues and dequeues messages  

### EPP Poll returns an error on incorrect op  

### EPP Poll dequeues multiple messages  

### EPP Session when not connected greets client upon connection  

### EPP Session when connected does not log in with invalid user  

### EPP Session when connected does not log in with inactive user  

### EPP Session when connected prohibits further actions unless logged in  

### EPP Session when connected with valid user logs in epp user  

### EPP Session when connected with valid user does not log in twice  

### EPP Session when connected with valid user logs out epp user  

