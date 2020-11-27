27.11.2020
* Refactored delete confirmation for interactors [#1753](https://github.com/internetee/registry/issues/1753)

24.11.2020
* Added subnet support for list of allowed IPs [#983](https://github.com/internetee/registry/issues/983)
* Added contact endpoint to Restful EPP API [#1580](https://github.com/internetee/registry/issues/1580)

20.11.2020
* Registrant confirmation over Registrant API [#1742](https://github.com/internetee/registry/pull/1742)
* Refactored forceDelete cancellation for interactors [#1743](https://github.com/internetee/registry/issues/1743)

19.11.2020
* Only sponsoring registrar has access to private contact's details [#1745](https://github.com/internetee/registry/issues/1745)
* Refactor ForceDelete [#1740](https://github.com/internetee/registry/issues/1740)

13.11.2020
* Fixed per registrar epp session limit [#729](https://github.com/internetee/registry/issues/729)
* Correct error code is returned on reaching session limit [#587](https://github.com/internetee/registry/issues/587)
* No logins within active session [#1313](https://github.com/internetee/registry/issues/1313)

06.11.2020
* Csv option to limit list of domains for bulk nameserver change in registrar portal [#1737](https://github.com/internetee/registry/issues/1737)
* New forceDelete email template for invalid contact data [#1178](https://github.com/internetee/registry/issues/1178)

05.11.2020
* Registrant API contact name update feature [#1724](https://github.com/internetee/registry/issues/1724)
* New email template for expired domains in forceDelete [#1725](https://github.com/internetee/registry/issues/1725)
* Cancelling forceDelete (FD) restores the state of the domain prior application of FD [#1136](https://github.com/internetee/registry/issues/1136)

04.11.2020
* Email notification templates for forceDelete are now automatically selected according to registrant type [#442](https://github.com/internetee/registry/issues/442)

03.11.2020
* Fixed registrant confirmation while forcedelete is set on a domain [#1729](https://github.com/internetee/registry/issues/1729)
* Fixed search in registrar domain view [#262](https://github.com/internetee/registry/issues/262)
* Fixed double status issue on setting forceDelete [#1135](https://github.com/internetee/registry/issues/1135)

28.10.2020
* Domain renew now canceles pending delete process [#1664](https://github.com/internetee/registry/issues/1664)
* Added multi-language support to whois disclaimer [#1703](https://github.com/internetee/registry/issues/1703)

27.10.2020
* Fixed 1 day delay in force delete for multi year registrations [#1720](https://github.com/internetee/registry/issues/1720)

20.10.2020
* ForceDelete mailer now respects option to not notify registrant [#1719](https://github.com/internetee/registry/pull/1719)

19.10.2020
* Improved logging for LHV-connect messages [#1712](https://github.com/internetee/registry/issues/1712)
* LHV-connect gem update to handle blank descriptions [#1714](https://github.com/internetee/registry/issues/1714)

16.10.2020
* Improved error handling for registrant API comapnies endpoint [#1713](https://github.com/internetee/registry/pull/1713)

15.10.2020
* Tara integration for registrant portal [#1698](https://github.com/internetee/registry/pull/1698)

14.10.2020
* Added company registration data query to regisrant API [#1708](https://github.com/internetee/registry/issues/1708)
* Fixed domain delete history records in admin [#1710](https://github.com/internetee/registry/issues/1710)

09.10.2020
* Fixed pendingUpdate release while forceDelete is set [#1705](https://github.com/internetee/registry/issues/1705)

08.10.2020
* Fixed serach in admin history [#1695](https://github.com/internetee/registry/issues/1695)

06.10.2020
* Updated Directo gem to fix vat codes for EU and non-EU clients [#1699](https://github.com/internetee/registry/pull/1699)
* Email validation level is now configurable [#1675](https://github.com/internetee/registry/pull/1675)

01.10.2020
* Fixed EPP authentication [#1697](https://github.com/internetee/registry/pull/1697)

30.09.2020
* Added Tara integration to registrar portal [#1680](https://github.com/internetee/registry/issues/1680)

28.09.2020
* Fixed data leakage with shared contacts [#1690](https://github.com/internetee/registry/issues/1690)
* RenewProhoboted status blocks renew [#1693](https://github.com/internetee/registry/issues/1693)

18.09.2020
* Updated testing documentation [#1285](https://github.com/internetee/registry/pull/1285)
* Removed mod-epp docs - replaced by epp-proxy [#1284](https://github.com/internetee/registry/pull/1284)
* Removed outdated diagrams [#1073](https://github.com/internetee/registry/pull/1073)
* Removed unused autodoc gems [#1358](https://github.com/internetee/registry/pull/1358)

16.09.2020
* Refactored orphaned contact archivation process [#956](https://github.com/internetee/registry/issues/956)
* Rails update to 6.0.3.3 [#1685](https://github.com/internetee/registry/pull/1685)
* E-invoice gem update to change the incoice total to 0 in case of prepaiment [#1684](https://github.com/internetee/registry/pull/1684)

15.09.2020
* Fixed e-invoice sending issue with QUE [#1683](https://github.com/internetee/registry/pull/1683)

14.09.2020
* Restored version logging for registry prices [#980](https://github.com/internetee/registry/pull/980)

11.09.2020
* Registrars can now top up their credit accounts without generating invoice in advance [#1101](https://github.com/internetee/registry/issues/1101)
* Fixed typo in admin settings [#371](https://github.com/internetee/registry/issues/371)

10.09.2020
* New registrar ref nr are now always created 7 digits long [#1679](https://github.com/internetee/registry/pull/1679)

08.09.2020
* Removed bank statement import option [#1674](https://github.com/internetee/registry/pull/1674)
* Fixed error with reference nr not being found in the transaction [#1677](https://github.com/internetee/registry/issues/1677)

04.09.2020
* Removed reduntant domains.registered_at db column [#1445](https://github.com/internetee/registry/pull/1445)
* Certificate revocation lists are now hanlded outside of the application code [#1662](https://github.com/internetee/registry/pull/1662)
* Monthly invoices are sent one by one to elliminate reply delay from accounting system [#1671](https://github.com/internetee/registry/pull/1671)
* Fixed poll request ip whitelist issue [#1672](https://github.com/internetee/registry/pull/1672)

03.09.2020
* Refactored session timeout management [#711](https://github.com/internetee/registry/issues/711)
* Improved error handling for epp requests without proper session [#1276](https://github.com/internetee/registry/pull/1276)
* Refactored legal document epp extension [#1451](https://github.com/internetee/registry/pull/1451)

01.09.2020
* Removed some unused settings from admin [#1668](https://github.com/internetee/registry/issues/1668)

27.08.2020
* Fixed internal error in domain history [#1663](https://github.com/internetee/registry/issues/1663)
* Second lvl zone records return now empty string for dnskey values [#1665](https://github.com/internetee/registry/issues/1665)

26.08.2020
* Fixed website url display issue in PDF invoices [#1188](https://github.com/internetee/registry/issues/1188)
* Added error logging for missing cert_path [#1420](https://github.com/internetee/registry/pull/1420)
* Refactored settings store mechanism [#1629](https://github.com/internetee/registry/issues/1629)
* Registrant API now returns users' business contacts [#1642](https://github.com/internetee/registry/issues/1642)

14.08.2020
* Added handling of second lvl zoness managed by the registry in whois records [#1661](https://github.com/internetee/registry/issues/1661)

13.08.2020
* Removed keystore gem and replaced LHV JKS with PKCS12 [#1645](https://github.com/internetee/registry/issues/1645)

11.08.2020
* Fixed postal address saving bug with disabled address processing [#1650](https://github.com/internetee/registry/issues/1650)

07.08.2020
* Restored creator and updator strings to contacts and related object records [#1636](https://github.com/internetee/registry/issues/1636)
* Security gem updates: sdoc to 1.1 and json to 2.3.1 [#1657](https://github.com/internetee/registry/pull/1657)

04.08.2020
* Fixed registrant verification for domain delete [#1631](https://github.com/internetee/registry/issues/1631)
* Fixed domain transfer issue when one person was present in the same role more than once (different objects) [#1651](https://github.com/internetee/registry/issues/1651)

03.08.2020
* Fixed 0 vat issue with invoices sent to Directo [#1647](https://github.com/internetee/registry/issues/1647)

17.07.2020
* Added turemail gem for validating email addresses syntactically and on MX record level [#297](https://github.com/internetee/registry/issues/297)

15.07.2020
* Reapplied race condition fix after fixing the data in prod env [#1612](https://github.com/internetee/registry/issues/1612)

07.07.2020
* Fixed legaldoc validation [#1634](https://github.com/internetee/registry/issues/1634)
* Disabled collection cashe versioning [#1637](https://github.com/internetee/registry/pull/1637)

03.07.2020
* 1-character domains are now valid but blocked by default [#1625](https://github.com/internetee/registry/issues/1625)

02.07.2020
* Adding legaldoc to domain:delete is now optional [#1624](https://github.com/internetee/registry/issues/1624)
* Setting to make legaldoc functionality optional [#1623](https://github.com/internetee/registry/issues/1623)

01.07.2020
* Reverted race condition fix due to data issues in production (#1612) [#1622](https://github.com/internetee/registry/pull/1622)
* Added legaldoc opt-out option for approved registrars [#1620](https://github.com/internetee/registry/issues/1620)

29.06.2020
* Bumped rack to 2.2.3 [#1618](https://github.com/internetee/registry/pull/1618)
* Actionpack security update to 6.0.3.2 [#1619](https://github.com/internetee/registry/pull/1619)

26.06.2020
* Fixed race condition in domain update by adding new db constratints [#1612](https://github.com/internetee/registry/issues/1612)
* Refactored contact validation [#1617](https://github.com/internetee/registry/pull/1617)

19.06.2020
* Regsitrant API returns now DNSSEC info [#1613](https://github.com/internetee/registry/pull/1613)
* Updated domain expiration email notification texts [#1614](https://github.com/internetee/registry/pull/1614)

15.06.2020
* Added contact email to registrant API [#1611](https://github.com/internetee/registry/pull/1611)

12.06.2020
* Extracted Xml deserializing from EPP Contact and Domain classes [#1601](https://github.com/internetee/registry/pull/1601)
* Fixed whois data update issue with child object updates [#1604](https://github.com/internetee/registry/issues/1604)

11.06.2020
* Auction API returns json on error [#1605](https://github.com/internetee/registry/issues/1605)
* Fixed account activity index in admin [#1606](https://github.com/internetee/registry/issues/1606)

08.06.2020
* Bumped websocket-extensions to 0.1.5 [#1602](https://github.com/internetee/registry/pull/1602)

04.06.2020
* Moved dev config to sample file [#1599](https://github.com/internetee/registry/pull/1599)
* Post Rails6 upgrade fixes [#1598](https://github.com/internetee/registry/pull/1598)

03.06.2020
* Upgraded Rails to 6.0.3 [#1593](https://github.com/internetee/registry/pull/1593)

02.06.2020
* Fixed registration deadline format for whois/restwhois [#1595](https://github.com/internetee/registry/pull/1595)

01.06.2020
* Improved error handling in case legal doc is not found for downloading [#1452](https://github.com/internetee/registry/issues/1452)

29.05.2020
* Bump kaminari to 1.2.1 [#1592](https://github.com/internetee/registry/pull/1592)

28.05.2020
* REPP returns list of disputed domains [#1588](https://github.com/internetee/registry/issues/1588)
* Updated Directo gem [#1590](https://github.com/internetee/registry/pull/1590)
* Updated LHV gem [#1591](https://github.com/internetee/registry/pull/1591)

25.05.2020
* Fixed registrant change verification bug for disputed domains [#1586](https://github.com/internetee/registry/issues/1586)

22.05.2020
* New solution for managing domains with effective dispute commitee decision [#269](https://github.com/internetee/registry/issues/269)
* Bump puma from 4.3.5 [#1585](https://github.com/internetee/registry/pull/1585)
* Run all CI tests [#1584](https://github.com/internetee/registry/pull/1584)

21.05.2020
* Fixed contact view access bug in registrant [#1527](https://github.com/internetee/registry/pull/1527)
* REPP returns list of domains currently at auction [#1582](https://github.com/internetee/registry/pull/1582)

18.05.2020
* REPP returns list of reserved and blocked domains [#1569](https://github.com/internetee/registry/issues/1569)

14.05.2020
* Deleted certificates are now revoked first [#952](https://github.com/internetee/registry/issues/952)

11.05.2020
* Auction process due dates are now available over whois and rest-whois [#1201](https://github.com/internetee/registry/issues/1201)

30.04.2020
* Fix for internal error on opening domain history with legacy id record [#1576](https://github.com/internetee/registry/issues/1576)

27.04.2020
* Downgrade SimpleCov to 0.17 due to incompatibiilty with CodeClimate [#1575](https://github.com/internetee/registry/pull/1575)

17.04.2020
* Webinterfaces have now clickable version string pointing to the latest deployed commit in github [#1345](https://github.com/internetee/registry/pull/1345)

15.04.2020
* Updated Rails to 5.2 and fixed acitionview security issue [#1568](https://github.com/internetee/registry/issues/1568) 

25.03.2020
* Implemented Directo gem [#1547](https://github.com/internetee/registry/pull/1547)

11.03.2020
* Fixed glue record issues when using 2nd level domain as host [#1562](https://github.com/internetee/registry/issues/1562)

10.03.2020
* Updated lhv, e-invoice & company_register gem due to security updates [#1564](https://github.com/internetee/registry/pull/1564)

06.03.2020
* Record payment method and failed payments [#1422](https://github.com/internetee/registry/issues/1422)

04.03.2020
* Bump Puma to 4.3.3 [#1557](https://github.com/internetee/registry/pull/1557)

03.03.2020
* Admin: fixed import of th6 bank statement [#1551](https://github.com/internetee/registry/issues/1551)

02.03.2020
* Registrar: fixed statuses based contact filtering [#1004](https://github.com/internetee/registry/issues/1004)

28.02.2020
* Registrar: fixed account switching [#1535](https://github.com/internetee/registry/issues/1535)

27.02.2020
* Registrar: fixed the verified checkbox bug that did not change the element value to yes in epp request [#1540](https://github.com/internetee/registry/issues/1540)
* Ruby version update to 2.6.5 [#1545](https://github.com/internetee/registry/pull/1545)

26.02.2020
* Registrar: added an option to remove clientHold status [#1481](https://github.com/internetee/registry/issues/1481)
* Admin: fixed domain status removal issue [#1543](https://github.com/internetee/registry/issues/1543)
* Implemented consistent and automated data migrations [#1298](https://github.com/internetee/registry/issues/1298)

20.02.2020
* E-invoice sending to Que to manage resending in case of an error [#1509](https://github.com/internetee/registry/issues/1509)
* Check to make sure all monthly invoices fit in available invoice number range [#277](https://github.com/internetee/registry/issues/277)
* Disabled aurbreak performance monitoring [#1534](https://github.com/internetee/registry/pull/1534)

14.02.2020
* Fixed Papertrail warnings [#1530](https://github.com/internetee/registry/issues/1530)

12.02.2020
* Fixed papertrails double recording issue [#1526](https://github.com/internetee/registry/issues/1526)
* Requests to Directo are now saved for both credit and monthly invoices [#344](https://github.com/internetee/registry/issues/344)

10.02.2020
* Resolved Money gem deprecation warning and silenced all warnings due plan to replace papertrail [#1522](https://github.com/internetee/registry/pull/1522)

06.02.2020
* Permit & turn ActiveController::Parameters to hash on domain create [#1516](https://github.com/internetee/registry/issues/1516)

05.02.2020
* Ruby version upgrade to 2.6.3 [#846](https://github.com/internetee/registry/issues/846)
* Added retries & raise to connect api to handle timeouts [#1474](https://github.com/internetee/registry/issues/1474)
* Added logging of XML if there is NoMethodError#text on xml data fields [#1475](https://github.com/internetee/registry/issues/1475)

04.02.2020
* Fixed bug that allowed bypassing blocked domain validation using punycode [#1142](https://github.com/internetee/registry/issues/1142)
* SimpleIDN gem update to 0.0.9 [#1508](https://github.com/internetee/registry/pull/1508)

31.01.2020
* Instant payments marks specific invoice as paid [#1500](https://github.com/internetee/registry/issues/1500)
* Sending invoice payment date to accounting [#1416](https://github.com/internetee/registry/issues/1416)

29.01.2020
* Fixed the invoice binding bug where process failed if registrar tried to load a sum that they have used before [#1496](https://github.com/internetee/registry/issues/1496)

28.01.2020
* Registrar: fixed sorting of domain view [#1461](https://github.com/internetee/registry/issues/1461)
* clientHold status is now set once instead of resetting it every time the job is run [#1480](https://github.com/internetee/registry/issues/1480)

27.01.2020
* Admin: fixed history view for domains with legacy id [#1489](https://github.com/internetee/registry/issues/1489)

23.01.2020
* Payment invoice matching by looking for ref nr in description field [#1415](https://github.com/internetee/registry/issues/1415)

22.01.2020
* ForceDelete poll messages with outzone and purge dates [#1478](https://github.com/internetee/registry/issues/1478)

21.01.2020
* Registrant change cancels automatically force delete process [#1479](https://github.com/internetee/registry/issues/1479)

20.01.2020
* ForceDelete email notifications are sent to all contacts + info and domain@domain [#1477](https://github.com/internetee/registry/issues/1477)

18.01.2020
* New ForceDelete procedure [#1428](https://github.com/internetee/registry/issues/1428)

16.01.2020
* Added tests for registrant verification [#1430](https://github.com/internetee/registry/pull/1430)

14.01.2020
* removed authinfo element from contact:info response for non-sponsoring registrars [#1446](https://github.com/internetee/registry/issues/1446)

13.01.2020
* resolved internal error on registrant confirmation [#1468](https://github.com/internetee/registry/issues/1468)

10.01.2020
* updated ForceDelete email templates according new regulation [#1466](https://github.com/internetee/registry/issues/1466) 
* regenerated WHOIS db schema [#1436](https://github.com/internetee/registry/pull/1436)

09.01.2020
* serverForceDelete status does not block removing clientHold status [#1462](https://github.com/internetee/registry/pull/1462) 

06.01.2020
* Updated e-invoice gem [#1456](https://github.com/internetee/registry/pull/1456)
* Bumped rack gem to 2.0.8 [#1448](https://github.com/internetee/registry/pull/1448)

03.01.2020
* Added an option for registrars to add and remove clientHold status on domains [#1454](https://github.com/internetee/registry/pull/1454)
* Fixed contact view internal error in admin [#1458](https://github.com/internetee/registry/issues/1458)

27.12.2019
* Records in registrant_verifications are now archived by PaperTrail [#1425](https://github.com/internetee/registry/issues/1425)

16.12.2019
* Bump puma from 4.2.1 to 4.3.1 [#1437](https://github.com/internetee/registry/pull/1437)
* Refactored API user management [#1435](https://github.com/internetee/registry/pull/1435)
* Ignoring legacy database columns at ActiveRecord level [#1377](https://github.com/internetee/registry/issues/1377)
* Removed Ruby version from Travis config and let it use .ruby-version [#1441](https://github.com/internetee/registry/pull/1441)
* Removed `fill_ident_country` postgresql function as unused [#1439](https://github.com/internetee/registry/pull/1439)

12.12.2019
* Updated e-invoice gem [#1429](https://github.com/internetee/registry/pull/1429)
* Upgraded bundler to 2.0.2 [#1433](https://github.com/internetee/registry/pull/1433)
* Set not null constraint on contact.name db column [#1417](https://github.com/internetee/registry/pull/1417)
* Removed domain name from registrant_verifications table [#1431](https://github.com/internetee/registry/pull/1431)

19.11.2019
* Updated Rails to 5.0.7 [#377](https://github.com/internetee/registry/issues/377)

15.11.2019
* Restored EPP exception logging to syslog [#1371](https://github.com/internetee/registry/issues/1371)

11.11.2019
* Removed code for displaying errors in nameserver and dnskey data as unused [#1411](https://github.com/internetee/registry/pull/1411)

07.11.2019
* Fixed domain details view in admin where admin and tech contacts were marked as invalid with Rails 5 [#1413](https://github.com/internetee/registry/pull/1413)

06.11.2019
* Fixed account activity form filter and csv download issues in admin and registrar [#1410](https://github.com/internetee/registry/pull/1410)

05.11.2019
* Moved gem extensions to proper directory and renamed the dirs to "moneky patces" to improve readability [#1406](https://github.com/internetee/registry/pull/1406)

04.11.2019
* Tuned kaminari gem to solve pagination issues [#1405](https://github.com/internetee/registry/pull/1405)

01.11.2019
* Typo fixes for #1352 [#1396](https://github.com/internetee/registry/pull/1396)
* Updated que gem to 0.14.3 and que-web gem to 0.7.2 [#1404](https://github.com/internetee/registry/pull/1404)

31.10.2019
* Updated domain_name gem to 0.5.20190701 [#1400](https://github.com/internetee/registry/pull/1400)
* Updated webmock gem to 3.7.6 [#1401](https://github.com/internetee/registry/pull/1401)
* Improved setup and seed [#1352](https://github.com/internetee/registry/pull/1352)
* Removed unimplemented keyrelay code [#715](https://github.com/internetee/registry/issues/715)
* Removed uuidtools gem [#1390](https://github.com/internetee/registry/pull/1390)
* Removed some unneeded code [#1397](https://github.com/internetee/registry/pull/1397)
* Removed eis_trusted_proxies setting [#1398](https://github.com/internetee/registry/pull/1398)

28.10.2019
* Updated kaminari gem to 1.1.1 [#1392](https://github.com/internetee/registry/pull/1392)
* Downgraded minitest to 5.10.3 due to incompatibility with Rails 5.0 [#1387](https://github.com/internetee/registry/pull/1387)
* New db constaints to invoices and invoice_items tables [#1388](https://github.com/internetee/registry/pull/1388)
* Removed buggy code for contact details' fast access in regitrar portal [#1386](https://github.com/internetee/registry/pull/1386) 

23.10.2019
* Updated haml gem to 5.1.2 (CVE-2017-1002201) [#1384](https://github.com/internetee/registry/pull/1384)
* Removed bullet gem [#378](https://github.com/internetee/registry/issues/378)
* Removed duplicate route from admin [#1375](https://github.com/internetee/registry/pull/1375)

21.10.2019
* Tuned PDFkit gem [#1367](https://github.com/internetee/registry/pull/1367)
* Removed some dead code [#1370](https://github.com/internetee/registry/pull/1370)

17.10.2019
* Implemented properl handling of contact transfer requests [#1363](https://github.com/internetee/registry/pull/1363)
* Test environment tuning [#1366](https://github.com/internetee/registry/pull/1366)

16.10.2019
* Contact and domain list download in portals changed - buttons in stead of dropdown [#1360](https://github.com/internetee/registry/pull/1360) 
* limited epp routes [#1364](https://github.com/internetee/registry/pull/1364)

11.10.2019
* Fixed mailer previews for couple email templates [#1342](https://github.com/internetee/registry/pull/1342)
* Updated ransack gem to 1.8 [#1357](https://github.com/internetee/registry/pull/1357)
* Removed old import rake task [#1355](https://github.com/internetee/registry/pull/1355)

10.10.2019
* Added DB constraints for reserved and blocked tables [#1338](https://github.com/internetee/registry/pull/1338)

08.10.2019
* Removed unused epp routes [#1335](https://github.com/internetee/registry/pull/1335)
* Removed Rspec and coverted specs to tests [#1336](https://github.com/internetee/registry/pull/1336)
* Added test for EPP hello request [#1337](https://github.com/internetee/registry/pull/1337)
* Removed unused csr and crt columns from user table [#264](https://github.com/internetee/registry/issues/264)
* Bump rubyzip from 1.2.2 to 1.3.0 [#1349](https://github.com/internetee/registry/pull/1349)

07.10.2019
* Clarified reference to proper phone nr format in EPP spec [#1343](https://github.com/internetee/registry/pull/1343)

20.09.2019
* Fixed error on domain transfer with invalid code [#686](https://github.com/internetee/registry/issues/686)
* EPP exceptions are now sent to Errbit [#539](https://github.com/internetee/registry/issues/539)
* Updated jquery-rails gem to 4.3.5 [#1322](https://github.com/internetee/registry/pull/1322)
* Added EPP renew tests [#1326](https://github.com/internetee/registry/pull/1326)

17.09.2019
* Fixed error messages on deletind deletecandidate domains [#718](https://github.com/internetee/registry/issues/718)
* Removed html2haml gem [#1316](https://github.com/internetee/registry/pull/1316)

16.09.2019
* Updated coffee-rails gem to 4.2 [#1320](https://github.com/internetee/registry/pull/1320)
* Updated data_migrate gem to 5.3.2 [#1321](https://github.com/internetee/registry/pull/1321)
* Replaced unused haml-rails gem with haml [#1315](https://github.com/internetee/registry/pull/1315)
* Hid some methods [#1318](https://github.com/internetee/registry/pull/1318)

13.09.2019
* Fixed bug where glue records were identified on partial string match with the domain name [#1291](https://github.com/internetee/registry/issues/1291)
* Removed 1 second delay on erroneous epp query responses [#1299](https://github.com/internetee/registry/pull/1299)
* Autoupdated Devise gem to 4.7.1 [#1304](https://github.com/internetee/registry/pull/1304)
* Updated Airbrake gem to 9.4.3 and tuned the configuration [#1297](https://github.com/internetee/registry/pull/1297)
* Updated cancancan gem to 3.0.1 [#1300](https://github.com/internetee/registry/pull/1300)
* Updated filenames to follow Ruby name convention [#1295](https://github.com/internetee/registry/pull/1295)
* Removed unused jbuilder gem [#1311](https://github.com/internetee/registry/pull/1311)
* Removed mod_epp specific X-EPP-Returncode EPP response header [#1301](https://github.com/internetee/registry/pull/1301)
* Removed a dublicate test [#1302](https://github.com/internetee/registry/pull/1302)
* Removed disabled and unnecessary CSRF protection [#1305](https://github.com/internetee/registry/pull/1305)
* Introduced modules [#1312](https://github.com/internetee/registry/pull/1312)

09.09.2019
* Upgrade Ruby to 2.4.7 [#1289](https://github.com/internetee/registry/pull/1289)

05.09.2019
* Update hashdiff gem to 1.0.0 [#1287](https://github.com/internetee/registry/pull/1287)

03.09.2019
* Updated Ruby to version 2.5.5 [#1273](https://github.com/internetee/registry/pull/1273)
* Figaro cleanup [#1272](https://github.com/internetee/registry/pull/1272)
* Removed deprecated testcase class [#1277](https://github.com/internetee/registry/pull/1277)

27.08.2019
* Added some new database constraints [#1265](https://github.com/internetee/registry/pull/1265)

26.08.2019
* Introduced automatic payment processing using LHV Connect [#1232](https://github.com/internetee/registry/issues/1232)
* removed unused script [#1261](https://github.com/internetee/registry/pull/1261)
* removed unused factory [#1262](https://github.com/internetee/registry/pull/1262)
* removed unused seller_it column from invoices db table [#1264](https://github.com/internetee/registry/pull/1264)
* removed unused rake tasks [#1268](https://github.com/internetee/registry/pull/1268)

21.08.2019
* Nokogiri update to 1.10.4 (CVE-2019-5477) [#1266](https://github.com/internetee/registry/pull/1266)

08.07.2019
* Invoices are not delivered to e-invoice provider when registrar has no billing email [#1255](https://github.com/internetee/registry/issues/1255)

28.06.2019
* E-invoicing with every generated invoice [#1222](https://github.com/internetee/registry/issues/1222)

27.06.2019
* Added ActionVersions to archive actions upon archival of a contact object [#1236](https://github.com/internetee/registry/pull/1236)

26.06.2019
* Enable to delete contacts that have records in actions table [#1239](https://github.com/internetee/registry/pull/1239)

25.06.2019
* Updated pdfkit gem to 0.8.4.1 [#1240](https://github.com/internetee/registry/pull/1240)
* Added ActionMailer TestCase inheritance [#1242](https://github.com/internetee/registry/pull/1242)

20.06.2019
* test improvements [#1237](https://github.com/internetee/registry/pull/1237)

19.06.2019
* Updated rails-settings-cached gem to 0.7.2 [#1228](https://github.com/internetee/registry/issues/1228)
* Removed unfinished and unused email template editing from admin [#1186](https://github.com/internetee/registry/pull/1186)
* Removed three unused DB tables [#1227](https://github.com/internetee/registry/pull/1227)

18.06.2019
* Added auto-invoicing and e-invoices integration to Omniva [#329](https://github.com/internetee/registry/issues/329)

13.06.2019
* Set Invoice.vat_rate in db to not null [#1205](https://github.com/internetee/registry/pull/1205)

12.06.2019
* Option to add regsitrar IBAN information to registrar portal and admin [#1203](https://github.com/internetee/registry/pull/1203)
* Allow running data_migration rake task specified in env variable in mina deploy job [#1213](https://github.com/internetee/registry/pull/1213)

07.06.2019
* Registrar: option to set default biling e-mail in profile view [#1202](https://github.com/internetee/registry/pull/1202)
* Updated Capybara gem to 3.22.0 [#1215](https://github.com/internetee/registry/pull/1215)
* Updated Webmock gem to 3.6.0 [#1216](https://github.com/internetee/registry/pull/1216)

21.05.2019
* Zip and State in registrar addresses are now optional [#1206](https://github.com/internetee/registry/issues/1206)
* Vat is now always applied - 0% vs NULL [#1031](https://github.com/internetee/registry/issues/1031)
* Updated Papertrail gem to 4.2.0 [#1094](https://github.com/internetee/registry/pull/1094)
* Converted some specs to tests [#1204](https://github.com/internetee/registry/pull/1204)
* Enhanced InvoiceItem methods [#1209](https://github.com/internetee/registry/pull/1209)

10.05.2019
* Domain deleted poll messages are being sent again [#1196](https://github.com/internetee/registry/issues/1196)
* Registrar address is now required on adding new registrar [#1195](https://github.com/internetee/registry/pull/1195)
* Registrar postal address is removed from WHOIS records in db [#1193](https://github.com/internetee/registry/issues/1193)

07.05.2019
* Set domains.delete_at column type to date [#1173](https://github.com/internetee/registry/pull/1173)
* Removed "html5_validators" gem [#367](https://github.com/internetee/registry/issues/367)

02.05.2019
* From address is now configurable for force delete auto email messages [#1164](https://github.com/internetee/registry/issues/1164)
* Encode domain part of email addresses to punycode [#1168](https://github.com/internetee/registry/pull/1168)
* Added auto-tests for domain:delete epp request [#1172](https://github.com/internetee/registry/pull/1172)

29.04.2019
* Nokogiri gem update to version 1.10.3 (CVE-2019-11068) [#1176](https://github.com/internetee/registry/pull/1176)
* Default email sender is now configurable [#243](https://github.com/internetee/registry/issues/243)
* Improved domain:release rake task and  fixed few test names [#1143](https://github.com/internetee/registry/pull/1143)
* Improved registrant change mailer [#1149](https://github.com/internetee/registry/pull/1149)
* improved domain mailer [#1166](https://github.com/internetee/registry/pull/1166)
* Improved domain delete mailer [#1156](https://github.com/internetee/registry/pull/1156)
* Improved contact mailer [#1160](https://github.com/internetee/registry/pull/1160)
* Contact email update notifications are only sent to registrants [#1161](https://github.com/internetee/registry/issues/1161) 
* Contact email update notifications are not sent if update fails [#1162](https://github.com/internetee/registry/pull/1162)
* Improved action_mailer config [#1151](https://github.com/internetee/registry/pull/1151)
* Added basic EPP contact tests [#1155](https://github.com/internetee/registry/pull/1155)
* Invoice PDF generation and delivery refactor [#1159](https://github.com/internetee/registry/pull/1159)
* Registrant: confirmation URL view refactor [#1150](https://github.com/internetee/registry/pull/1150)
* Set not null contraint on invoices.issue_date [#1008](https://github.com/internetee/registry/issues/1008)
* Moved tests [#1171](https://github.com/internetee/registry/pull/1171)
* Removed domain.reserved db column [#1112](https://github.com/internetee/registry/pull/1112)
* Removed unused columns from log_domains [#1169](https://github.com/internetee/registry/pull/1169)
* Removed que_mailer gem [#895](https://github.com/internetee/registry/issues/895)
* Removed legacy test emails [#1152](https://github.com/internetee/registry/pull/1152)
* Removed delivery_off method [#1165](https://github.com/internetee/registry/pull/1165)

08.04.2019
* Fixed forceDelete email messages [#1147](https://github.com/internetee/registry/pull/1147)
* Removed unused rake tasks [#1121](https://github.com/internetee/registry/pull/1121)
* Do not load the whole environment for rake tasks [#1122](https://github.com/internetee/registry/pull/1122)
* Removed delegations [#1131](https://github.com/internetee/registry/pull/1131)
* Convert specs to tests [#1144](https://github.com/internetee/registry/pull/1144)
* Comment update for extra legaldoc removal code [#1145](https://github.com/internetee/registry/pull/1145)

02.04.2019
* Fixed IDN domain handling for EPP domain check and create requests [#1140](https://github.com/internetee/registry/pull/1140)

01.04.2019
* Updated expire email for auction changes [#1127](https://github.com/internetee/registry/issues/1127)
* Force delete domains are being released again [#1119](https://github.com/internetee/registry/issues/1119)
* Auction API now creates WHOIS record if it happens to be missing for an auctioned domain [#1133](https://github.com/internetee/registry/issues/1133)
* Force delete date saved as date instead of datetime [#253](https://github.com/internetee/registry/issues/253)
* Fixed PDF invoice download in registrar and admin portals [#1128](https://github.com/internetee/registry/pull/1128)
* Fixed DeleteCandidate status setting issue for ForceDelete domains [#812](https://github.com/internetee/registry/issues/812)
* Autotest fix [#1138](https://github.com/internetee/registry/pull/1138)

26.03.2019
* Fixed invoice PDF download for admin and registrar portals [#1128](https://github.com/internetee/registry/pull/1128)

25.03.2019
* New API for domain auctions [#874](https://github.com/internetee/registry/issues/874)
* Improved EPP domain info and check request handling of reserved, blocked and auctioned domains [#597](https://github.com/internetee/registry/issues/597)
* WHOIS update for auction domains [#1097](https://github.com/internetee/registry/pull/1097)
* WHOIS regenerate update for auction domains [#1111](https://github.com/internetee/registry/issues/1111)
* WHOIS fix for auction domains [#1105](https://github.com/internetee/registry/issues/1105)
* Disabled auctions for reserved and blocked domains [#1020](https://github.com/internetee/registry/issues/1120)
* Support for Estonian 2018 ID-card version [#1047](https://github.com/internetee/registry/issues/1047)
* Fixed invoice reference number ganaration for numbers ending with 0 [#1071](https://github.com/internetee/registry/pull/1071)
* Refactored and improved invoice generation and management [#1013](https://github.com/internetee/registry/pull/1013)
* Covnerted specs to tests [#1098](https://github.com/internetee/registry/pull/1098)
* Fixed Äriregister test service access [#1077](https://github.com/internetee/registry/issues/1077)
* Estonian company register checks moved to separate gem [#1079](https://github.com/internetee/registry/issues/1079)
* Update Estonian comapny register queries to new API version [#916](https://github.com/internetee/registry/issues/916)
* Fixed issue in admin with contact updated using registrant API [#1059](https://github.com/internetee/registry/issues/1059)
* Fixed Regsitrant API contact id reference issue [#1090](https://github.com/internetee/registry/issues/1090)
* Fixed missing translation issue in admin with pendingUpdate and pendingDeleteConfirmation statuses [#1117](https://github.com/internetee/registry/issues/1117)
* Rails update to 2.4.11.1 [#1104](https://github.com/internetee/registry/pull/1104)
* Bootstrap-sass gem update to 3.4 (CVE-2019-8331) [#1085](https://github.com/internetee/registry/pull/1085)
* Devise gem update to 4.0 (CVE-2019-5421) [#1114](https://github.com/internetee/registry/pull/1114)
* Countries gem update to 3.0.0 [#1086](https://github.com/internetee/registry/pull/1086)
* Savon gem update to 2.12.0 [#1088](https://github.com/internetee/registry/pull/1088)
* Grape gem update to 1.2.3 [#1091](https://github.com/internetee/registry/pull/1091)
* Bundler version fix in Tracis config [#1110](https://github.com/internetee/registry/pull/1110)
* Puma gem update to 3.12.1 [#1116](https://github.com/internetee/registry/pull/1116)
* Fixtures' fix [#1096](https://github.com/internetee/registry/pull/1096)
* Fine-tuning simplecov gem and code climate [#1100](https://github.com/internetee/registry/pull/1100)
* Added .editconfig [#1074](https://github.com/internetee/registry/pull/1074)
* Typo fix [#1083](https://github.com/internetee/registry/pull/1083)
* Added clarifying comments to the code [#1089](https://github.com/internetee/registry/pull/1089)
* Fixed comment [#1095](https://github.com/internetee/registry/pull/1095)
* Removed duplicate translations [#1103](https://github.com/internetee/registry/pull/1103)

11.02.2019
* EPP: domain:check responds now with avail 0 for blocked domainnames and second level zones served by the registry and 1 for reserved domains [#1065](https://github.com/internetee/registry/pull/1065)
* REPP: Added contact data disclosing option for private registrants (will be available on new registrants' portal to be realeased in q1 2019) [#992](https://github.com/internetee/registry/issues/992)
* Autotests for domain:create added [#1066](https://github.com/internetee/registry/pull/1066)
* Updated check, create and info autotests for auction integration [#1062](https://github.com/internetee/registry/pull/1062)
* PW value for reserved domains is now required in DB level as well [#1063](https://github.com/internetee/registry/pull/1063)
* Switched tests to js content type [#1052](https://github.com/internetee/registry/pull/1052)
* Regenerated whois schema.rb [#1054](https://github.com/internetee/registry/pull/1054)
* Updated Codeclimate's eslint [#1068](https://github.com/internetee/registry/pull/1068)

06.12.2018
* Use Estonian reference number format instead of ISO 11649 [#998](https://github.com/internetee/registry/pull/998)
* Rails upgrade to 4.2.11 (CVE-2018-16476) [#1045](https://github.com/internetee/registry/pull/1045)
* Rack gem upgrade to 1.6.11 (CVE-2018-16471) [#1036](https://github.com/internetee/registry/pull/1036)
* Removed override that reset transfer_wait_time oparam on every reboot [#1041](https://github.com/internetee/registry/pull/1041)
* Regenerated structure.sql [#1014](https://github.com/internetee/registry/pull/1014)
* Improved WhoisRecord tests [#1039](https://github.com/internetee/registry/pull/1039)
* Deprecated custom test case for rake tasks [#1043](https://github.com/internetee/registry/pull/1043)
* Removed SyslogLogger gem [#1033](https://github.com/internetee/registry/pull/1033)
* Removed unused JSON key [#1038](https://github.com/internetee/registry/pull/1038)
* Removed unused `whois_records.body` DB column [#1037](https://github.com/internetee/registry/pull/1037)


05.11.2018
* Registrants contact update and new change poll messages [#849](https://github.com/internetee/registry/issues/849)
* Update Ruby to 2.4.5 [#1030](https://github.com/internetee/registry/pull/1030)
* Upgrade Loofah to 2.2.3 - CVE-2018-16468 [#1032](https://github.com/internetee/registry/pull/1032)
* BUG: mID auth now also works with IE11 [#982](https://github.com/internetee/registry/issues/982)
* BUG: Creating admin user works again after initial deploy [#1019](https://github.com/internetee/registry/issues/1019)
* Same serializer for all contact requests [#1034](https://github.com/internetee/registry/pull/1034)
* Added handling of OPTIONS request to /api namespace [#1010](https://github.com/internetee/registry/pull/1010)
* Return Access-Control-Allow-Origin for all requests [#1012](https://github.com/internetee/registry/pull/1012)
* Documentation fix [#1005](https://github.com/internetee/registry/pull/1005)
* Elliminate mystery guest [#1001](https://github.com/internetee/registry/pull/1001)
* Git-ignore assets [#1025](https://github.com/internetee/registry/pull/1025)
* Remove dead code [#1027](https://github.com/internetee/registry/pull/1027)

15.10.2018
* Nokogiri update 1.8.5 [#1007](https://github.com/internetee/registry/pull/1007)
* Registrant API: added admin, tech and registrar contacts to domain info response [#991](https://github.com/internetee/registry/issues/991)
* Registrant API: added nameserver and registrar details to domain info response [#1000](https://github.com/internetee/registry/issues/1000)
* Registrant API: added registry lock date to domain info response [#996](https://github.com/internetee/registry/issues/996)

02.10.2018
* EPP: datetime in poll messages is not UTC as required by RFC5730 [#948](https://github.com/internetee/registry/issues/948)
* BUG: user_session_timeout is now always respected [#966](https://github.com/internetee/registry/issues/966)
* BUG: fixed method name in registrar portal's billing [#971](https://github.com/internetee/registry/pull/971)
* RubyZip gem update to 1.2.2 (https://nvd.nist.gov/vuln/detail/CVE-2018-1000544) [#987](https://github.com/internetee/registry/pull/987)
* Rubocop gem update to 0.5.8 [#963](https://github.com/internetee/registry/pull/963)
* Money gem update to 6.12.0 [#968](https://github.com/internetee/registry/pull/968)
* Admin: Removing PKI certs revoke the cert first [#887](https://github.com/internetee/registry/issues/887)
* Admin: removed duplicate billing email field from registrar profile [#967](https://github.com/internetee/registry/issues/967)
* Removed duplicate require function [#979](https://github.com/internetee/registry/issues/979)
* Improved EPP poll tests [#943](https://github.com/internetee/registry/issues/943)
* Refactored EPP poll messages [#703](https://github.com/internetee/registry/issues/703)
* Registrant portal small improvements [#932](https://github.com/internetee/registry/issues/932)
* Fixed invoice mailer whitelist for staging env enablig invoice forwarding to an email [#989](https://github.com/internetee/registry/issues/989)
* Removed unused domain delete views [#951](https://github.com/internetee/registry/issues/951)
* Removed unused generator [#990](https://github.com/internetee/registry/issues/990)

12.09.2018
* Bug: user with billing access only can now login to the portal for Regsitrars [#973](https://github.com/internetee/registry/issues/973)

06.09.2018
* Bug: registrant confirmation does not require authentication any more [#969](https://github.com/internetee/registry/issues/969)
* Whois JSON tests order independent [#965](https://github.com/internetee/registry/issues/965) 

04.09.2018
* New registrant portal API [#902](https://github.com/internetee/registry/issues/902)
* Registry lock in Registrant API [#927](https://github.com/internetee/registry/issues/927)
* Password encryption for EPP [#914](https://github.com/internetee/registry/issues/914)
* Registrar: 0 amount invoices invalidated [#651](https://github.com/internetee/registry/issues/651)
* Ruby upgrade to 2.4 [#938](https://github.com/internetee/registry/issues/938)
* Admin: removig deleteCandidate status removes Que job as well [#790](https://github.com/internetee/registry/issues/790)
* Admin: Cancel force delete no possible with deleteCandidate status set [#791](https://github.com/internetee/registry/issues/791)
* Contact tests added [#930](https://github.com/internetee/registry/issues/930)
* Change test structure [#924](https://github.com/internetee/registry/issues/924)
* Grape gem update to 1.1.0 (CVE-2018-3769) [#934](https://github.com/internetee/registry/pull/934)
* Remove changelog from codeclimate analysis [#961](https://github.com/internetee/registry/issues/961)
* Remove dead code [#925](https://github.com/internetee/registry/issues/925)
* Quote value in fixture [#937](https://github.com/internetee/registry/issues/937)
* Generate <body> CSS class for every action [#939](https://github.com/internetee/registry/issues/939)
* Add TaskTestCase [#941](https://github.com/internetee/registry/issues/941)
* Set NOT NULL constraint for contact.email field [#936](https://github.com/internetee/registry/issues/936)
* Remove duplicate fixture [#946](https://github.com/internetee/registry/issues/946)

26.07.2018
* Grape (1.0.3), mustermann (1.0.2), multi_json (1.13.1) gem updates [#912](https://github.com/internetee/registry/issues/912)
* Capybara (3.3.1), mini_mime (0.1.3), nokogiri (1.8), rack (1.6.0), xpath (3.1) gem updates [#980](https://github.com/internetee/registry/issues/908)
* Webmock (3.4.2), addressable (2.5.2), hashdiff (0.3.7), public_suffix (3.0.2) gem updates [#907](https://github.com/internetee/registry/issues/907)
* fixed typo in assertions filename [#920](https://github.com/internetee/registry/issues/920)
* regenerate structure.sql [#915](https://github.com/internetee/registry/issues/915)

12.07.2018
* Implemented JavaScript testing framework to catch web UI problems [#900](https://github.com/internetee/registry/issues/900)

10.07.2018
* Nameserver bulk change returns list of affected doamins [#835](https://github.com/internetee/registry/issues/835)

26.06.2018
* Whois data is updated now on pendingUpdate status removal [#757](https://github.com/internetee/registry/issues/757)
* Portal for registrars displays control code for MID authentication [#893](https://github.com/internetee/registry/issues/893)
* Changed date format in Directo invoice XML [#890](https://github.com/internetee/registry/pull/890)
* Registrant portal UI improvements [#888](https://github.com/internetee/registry/issues/888)
* Removed unused mailer code [#882](https://github.com/internetee/registry/pull/882)
* Sprocets gem update to 3.7.2 [#892](https://github.com/internetee/registry/issues/892)
* Replased Warden test helpers with Devise [#889](https://github.com/internetee/registry/issues/889)
* Removed dev rake task [#872](https://github.com/internetee/registry/pull/872)
* Spring gem removed [#856](https://github.com/internetee/registry/issues/856)
* Dcker conf changes [#881](https://github.com/internetee/registry/pull/881)
* Fixed Estonia in the country drop-down [#877](https://github.com/internetee/registry/issues/877)
* Codeclimate conf improvements [#854](https://github.com/internetee/registry/pull/854)
* Removed codeclimate badge from README [#876](https://github.com/internetee/registry/issues/876)
* added UUID for contact objects [#873](https://github.com/internetee/registry/pull/873)
* backported Rails 5 API [#868](https://github.com/internetee/registry/issues/868)

20.06.2018
* Bulk change function for technical contact replacement [#662](https://github.com/internetee/registry/issues/662)
* Removed vatcode and totalvat elements from directo request in attempt to fix invoice sending issue [#844](https://github.com/internetee/registry/issues/844)
* Regsitrar: added credit card payment option - disabled at the moment due to contractual reaons [#419](https://github.com/internetee/registry/issues/419)
* Registrant: enabled WHOIS requests over RestWHOIS API [#852](https://github.com/internetee/registry/issues/852)
* Fixed rspec configuration that caused test failures [#858](https://github.com/internetee/registry/issues/858)
* Admin: refactored date selection in pricelist [#869](https://github.com/internetee/registry/issues/869)
* Added uglifier gem for es6 compression [#864](https://github.com/internetee/registry/issues/864)
* Removed lib folder from autoload path [#859](https://github.com/internetee/registry/issues/859)
* test environment config improvements [#860](https://github.com/internetee/registry/issues/860)
* translation fixes [#865](https://github.com/internetee/registry/issues/865)
* removed obsolete .agignore [#866](https://github.com/internetee/registry/issues/866)
* removed rubocop gem [#857](https://github.com/internetee/registry/issues/857)
* new invoice payment test fix [#863](https://github.com/internetee/registry/issues/863)
* get puma gem config from Rails 5 [#867](https://github.com/internetee/registry/issues/867)
* Rails5 API controller temporary backport [#868](https://github.com/internetee/registry/issues/868)

25.05.2018
* GDPR: updated whois templates with configurable disclaimer [#795](https://github.com/internetee/registry/issues/795)
* GDPR: email forwarding solution to contact private domain registrants without revealing their email addresses [#824](https://github.com/internetee/registry/issues/824)
* EPP: added support for additional digitally signed doc formats like asice, sce, asics, scs, edoc, adoc [#840](https://github.com/internetee/registry/issues/840)
* Registrar: removed handling of newlines from contact form street field [#836](https://github.com/internetee/registry/issues/836)
* Ruby upgrade to version 2.3.7 [#546](https://github.com/internetee/registry/issues/546)
* Devise upgrade to version 4.4.3 [#847](https://github.com/internetee/registry/pull/847)
* Added extra logging to debug Directo integration [#848](https://github.com/internetee/registry/pull/848)

30.04.2018
* Upgrade Ruby on Rails to version 4.2.10 [#826](https://github.com/internetee/registry/issues/826)
* BUG: Admin - fixed internal error in domain_versions and contact_versions views caused by removed db column [#830](https://github.com/internetee/registry/issues/830)

23.04.2018
* WHOIS: domains with deleteCandidate status do not return registration details as domains waiting to be deleted [#789](https://github.com/internetee/registry/issues/789)
* Security: Nokigiri gem update to version 1.8.2 [#823](https://github.com/internetee/registry/pull/823)
* Bug: fixed missing translation error in admin mail templates page [#818](https://github.com/internetee/registry/pull/818)
* Admin: VAT percentage info to registrar profile for setting tax rate for foreign non vat liable registrars [#623](https://github.com/internetee/registry/issues/623)
* Admin: deleteCandidate status is now stressed in domain details view [#792](https://github.com/internetee/registry/issues/792)
* Removed invoice_type from invoice db data as unused [#772](https://github.com/internetee/registry/issues/772)
* Removed valid_from from domain db data as duplicated and unused [#787](https://github.com/internetee/registry/issues/787)
* Set Not null constraint to valid_ti domain db data [#800](https://github.com/internetee/registry/issues/800)
* Removed unused methods [#797](https://github.com/internetee/registry/issues/797)
* Removed unused cron tasks [#782](https://github.com/internetee/registry/issues/782)
* Removed some monkey-patching for flash message logging [#231](https://github.com/internetee/registry/issues/231)
* Added Docker container support for dev and test environments [#821](https://github.com/internetee/registry/issues/821)
* Fix for Travis CI random test failures [#809](https://github.com/internetee/registry/pull/809)

03.04.2018
* BUG: Fixed bug with sometimes failing bank-link payments [#642](https://github.com/internetee/registry/issues/642)
* EPP: Domain and associated objects are now validated on domain renew [#678](https://github.com/internetee/registry/issues/678)
* Admin: drop uniqueness requirement from registrar's registry number field [#776](https://github.com/internetee/registry/issues/776)
* Security: Loofah gem update to 2.2.2 [#783](https://github.com/internetee/registry/pull/783)
* Disabled spellcheck for browsers to cleanup UI [#759](https://github.com/internetee/registry/issues/759)
* Admin: refactored registrar management [#770](https://github.com/internetee/registry/pull/770)
* Fix structure.sql [#796](https://github.com/internetee/registry/pull/796)

19.03.2018
* EPP transfer and REPP bulk transfer reuses contact objects [#746](https://github.com/internetee/registry/issues/746)
* Gems: Rack (1.6.9) and Rack-protection (1.5.5) update [#768](https://github.com/internetee/registry/issues/768)
* Removal of unused database tables [#756](https://github.com/internetee/registry/issues/756)
* Removal of unused date format [#764](https://github.com/internetee/registry/pull/764)
* Removal of billing postal address [#747](https://github.com/internetee/registry/issues/747)

06.03.2018
* BUG: Transfer poll message now returns affected domain name [#694](https://github.com/internetee/registry/issues/694)
* BUG: Successful REPP bulk transfer returns info about transfered domains [#693](https://github.com/internetee/registry/issues/693)
* BUG: Postal address data is not validated when address processing is disabled [#731](https://github.com/internetee/registry/issues/731)
* EPP: invalid country code message (code 2005) specifies invalid value [#733](https://github.com/internetee/registry/issues/733)
* REPP: new bulk nameserver change feature, also available on the portal for registars [#661](https://github.com/internetee/registry/issues/661)
* Admin: disable auto-email feature on setting force delete [#727](https://github.com/internetee/registry/issues/727)
* jQuery validation gem removed [#744](https://github.com/internetee/registry/issues/744)

22.02.2018
* BUG: Registrar: contact list export is not limited to 75 records any more [#721](https://github.com/internetee/registry/issues/721)
* BUG: EPP: domain and associated objects are not validated on domain delete [#707](https://github.com/internetee/registry/issues/707)
* EPP: improved session management (db constraints, model and db structure refactor, auto-tests) [#700](https://github.com/internetee/registry/issues/700)

11.02.2018
* BUG: Disable all object validations on domain transfer [#701](https://github.com/internetee/registry/issues/701)

06.02.2018
* BUG: EPP sessions get again unique session id preventing session mixups [#699](https://github.com/internetee/registry/pull/699)

06.02.2018
* BUG: Poral for registrants returns again domains that is associated with the user only through the role of registrant [#663](https://github.com/internetee/registry/issues/663)
* Registrar: bulk transfer and improved csv download for use as bulk transfer input [#660](https://github.com/internetee/registry/issues/660)
* Improved integration with CodeClimate, Simplecov gem update to 15.1 [#684](https://github.com/internetee/registry/pull/684)
* Improved applycation.yml sample [#664](https://github.com/internetee/registry/pull/664)

11.12.2017
* BUG: Whitelisted registrar is now automatically chosen on eID/mID login [#609](https://github.com/internetee/registry/issues/609)
* BUG: added directo_handle to registrar profile [#343](https://github.com/internetee/registry/issues/343)
* Refactored ident validations on contact updates [#569](https://github.com/internetee/registry/issues/569)
* Admin: Added registrar communication language setting [#640](https://github.com/internetee/registry/issues/640)
* Update rubocop to 0.49 [#605](https://github.com/internetee/registry/pull/605)
* Code cleanup:
  * remove test.rake [#376](https://github.com/internetee/registry/pull/376)
  * remove docker remnants [#614](https://github.com/internetee/registry/pull/614)
  * remove phantomjs, phantomjs-binaries and launchy gems [629](https://github.com/internetee/registry/pull/629)
  * remove eis_custom_active_model.rb, eis_custom_active_record.rb, eis_custom_flash.rb [#231](https://github.com/internetee/registry/issues/231)
  * remove autolable.rb [#407](https://github.com/internetee/registry/issues/407)
* migration from FactoryGirl to FactoryBot [#626](https://github.com/internetee/registry/pull/626)
  * remove FactoryGirl from dev.rake [#630](https://github.com/internetee/registry/pull/630)
* add rake todo list [#586](https://github.com/internetee/registry/pull/586)

13.10.2017
* BUG: week starts with Monday now in the date picker of the portal for registrars and admin interface [#590](https://github.com/internetee/registry/issues/590)
* BUG: Fixed error on zone file generation in the admin interface [#611](https://github.com/internetee/registry/issues/611)
* Improved expire email readability [#598](https://github.com/internetee/registry/pull/598)
* Improved registrar portal access denied page [#599](https://github.com/internetee/registry/pull/599)
* Admin interface uses base controller [#585](https://github.com/internetee/registry/pull/585)
* Admin interface settings refactored [#583](https://github.com/internetee/registry/pull/583)
* Nokogiri gem update 1.8.1 [#595](https://github.com/internetee/registry/pull/595)
* Mail gem update 2.6.6 [#596](https://github.com/internetee/registry/pull/596)
* Improved rubocop inspections [#579](https://github.com/internetee/registry/issues/579)
* Removed "restful_whois_url" config key [#494](https://github.com/internetee/registry/pull/494)
* Removed robot bin [#505](https://github.com/internetee/registry/pull/505)
* Configurabel session timeouts for dev and test environments [#588](https://github.com/internetee/registry/pull/588)
* Generators disabled [#606](https://github.com/internetee/registry/pull/606)

15.06.2017
* BUG: fixed incorrect error message on domain upate in case serverDeleteProhibited was set [#512](https://github.com/internetee/registry/issues/512)
* BUG: removed references to postal addresses from last email templates in case address processing is disabled [#480](https://github.com/internetee/registry/issues/480)
* Removed options to delete pricelist items and zones [#522](https://github.com/internetee/registry/issues/522)
* Improved registry database setup process [#503](https://github.com/internetee/registry/issues/503)
* Added dummy data generation rake task [#515](https://github.com/internetee/registry/issues/515)

02.05.2017
* Set default period value of domain create and renew operations to 1 year in the Registrar portal [#495](https://github.com/internetee/registry/issues/495)

01.05.2017
* Support for short and long regsitration periods - from 3m to 10y [#475](https://github.com/internetee/registry/issues/475)
* Improved race condition handling on domain renew [#430](https://github.com/internetee/registry/issues/430)

05.04.2017
* Fixed validation error on valid legaldocs in the portal for registrars [#432](https://github.com/internetee/registry/issues/432)
* Updated Ruby, nokogiri and variouse other dependent gems to fix security issues
* Template selection for setting ForceDelete status in admin interface and new template for deceased registrant [#268](https://github.com/internetee/registry/issues/268)

14.03.2017
* Improved phone number validation [#386](https://github.com/internetee/registry/issues/386)
* Dropped ddoc support from legaldocs in the portal for regsitrars [#270](https://github.com/internetee/registry/issues/270)
* Bug: Domain in exp pending list whithout the state present [#328](https://github.com/internetee/registry/issues/328)
* Base64 of legaldocs filtered out from syslogs [#314](https://github.com/internetee/registry/issues/314)

02.03.2017
* Domain list download (csv) functionality in the portal for registrars (#248)
* Readme updates (#273)
* Epp-examples.md update with contact create examples with postal address processing disabled (#326)
* Autotest improvements and updates

28.02.2017
* Add missing registrar's website field in UI

24.01.2017
* Disallow EPP domain:update/transfer/delete if a domain has "deleteCandidate" status

22.12.2016
* Return business registry code and country for 'org' type registrants in WHOIS and Rest-WHOIS

16.12.2016
* Allow contact address processing to be configurable via admin
* EPP XML schema namespace "urn:ietf:params:xml:ns:epp-1.0" replaced with "https://epp.tld.ee/schema/epp-ee-1.0.xsd"
* EPP XML schema contact-eis-1.0 replaced with contact-ee-1.1

18.11.2016 
* Domain expiration emails are now sent out to admin contacts as well. Sending bug is fixed.
* Include detailed registrar's contact info in emails

07.11.2016 
* Use app time zone when calculating valid_to, outzone_at and delete_at domain attributes
* Treat domains as expired when expire_time is set to current time
* Improve domain's outzone and delete logic

25.10.2016 
* Outdated specs removed, failing specs fixed, rspec config improved

20.10.2016
* Travis CI integration added, New Relic removed

19.10.2016
* BUG fix: Record current time for outzone on domain:delete EPP request
* ForceDelete automatic notice: fixed et and ee wording to reflect the date the domain is actually deleted.

9.09.2016
* Registry:
  * domains expire now at the beginning of the date followed by the date of regsitration. Expiration and redemption grace periods now follow domainregulations more correctly and delete date returned in whois matches the date the domain is actually deleted (129684535)

31.08.2016
* Admin interface:
  * contact id supports wildcard search with '%' (129124951)
* Registry:
  * BUG: whodunnit filled with incorrect user reference in case of pending request confirmations and rejections (115693873)
  * domain_cron.rb now searches for domains to be archived using the end of the day parameter allowing it to be run at any time during the day (113430903)
* EPP:
  * Invalid use of GET is now logged and replied with proper error message instead of internal error (128054415)
* Portal for registrars
  * BUG fix: invoices now dipslay description entered by registrar on invoice request

9.08.2016
* Admin interface:
  * actions are now clickable in domain and contact history and return the initial epp request sent to registry (117806281)
  * access to archived domain and contact objects under settings (108869472)
  * BUG: noaccess fixed for contacts with incomplete ident data (120093749)
* Registry:
  * BUG: adding contact do a domain generated unnecessary log records (116761157)
  * linked state for a contact is now dynamic (116761157)
* Portal for registrars:
  * improved dnssec data presentation in ds data interface mode (118007975)
  * BUG: now all the ident data is returned for contacts with incomplete set (120093749)
* EPP
  * BUG: invalid error 2304 "Object status prohibits operation" (118822101)
  * BUG: invalid error 2302 "Nameserver already exists on this domain" (118822101)

14.07.2016
* Registry:
  * whois records generation fix in contact.rb model (#117612931)
  * english translation fix for pending_update_notification_for_new_registrant automated registrant message

16.06.2016
* EPP
  * BUG: XML syntax error for poll and logout if optional clTRID is missing (#121580929)
  * support for glue records with ipv6 addresses only (#120095555)

15.06.2016
* Portal for registrants
  * Notice on login screen on limited access to Estonian electronic IDs (#120182999)
* Admin interface:
  * epp log view has now reference to the object name for better usability (#118912395)
  * BUG: dnssec data missing from domain history view (#115762063)
  * BUG: internal error in doamin history view in case some contact has been deleted (#118300251)
* Registry:
  * all values sent over epp are now trimmed of beginning and trailing spaces (#117690107)
  * typo and form fixes for automated e-mail messages sent to domain contacts
* EPP:
  * BUG: error 2005 on adding IDN nameservers (#114677695)
  * BUG: nameserver lable maximum 63 char length validation handled inproperly (#114677695) - support currently limited to Estonian IDN characters.
  * BUG: validation passes out of range ident_type values - now limited to org, priv and birthday (#111601356)
  * BUG: internal error on hello (#120828283)
  * BUG: internal error broken incoming frame (#121580929)
* Deploy:
  * BUG: incorrect version in commit message on deploy - config/deploy-example.rb (#120259603)

20.05.2016
* Portal for registrars
  * domain details view new displays contact name in addition to ID (#117226457)
  * added an option to set veryfied = "yes" parameter to GUI for registrant change and domain delete opertions (#116209751)
* Admin interface
  * BUG: fixed number of sorting issues on different views (#117350717)
  * BUG: internal error on filtered list sorting (#115043065)
  * BUG: account activities csv export messes up registrars (#117702653)
  * usability fixes to history view (#115762063)
* Registry
  * epp-xml gem reference updated to v 1.0.5 (#116209751)
  * epp-xml gem is now taken from local repo https://github.com/internetee/epp-xml/blob/master, the version in RubyGems is not updated any more (#116209751)
  * BUG: domains set to force delete were deleted a day ahead of time (#117131083)
  * BUG: QUE - undefined method `code' for nil:NilClass - if contact is removed before Que gets to it (#117612061)
  * BUG: Que - uninitialized constant RegenerateWhoisRecordJob (#117986917)
* EPP
  * BUG: poll message on domain delete does not validate against .ee xml schemas (#118827261)
  * BUG: internal error on domain delete (#118159567)
* RestWHOIS
  * BUG: statuses not in array for not registered reserved and blocked domains (#118911315)

...

21.09.2015
* eis-1.0.xsd schema file updated without a new version, please publish a new updated schema file to public.

17.09.2015
* deploy-example.rb has been updated with `@cron_group`.

11.08.2015

* Possible to add whitelist_emails_for_staging list at application.yml

21.07.2015

* Possible to define custom trusted proxies at application.yml

20.07.2015

* New syntax for setting webclient IP-s (see config/application-example.yml)
* Example mina/deploy.rb renamed to mina/deploy-example.rb in order to not overwrite local deploy scripts

14.07.2015

* Updated que init script doc example, now status and stop works faster
* Updated registry server cronjob with mina cron:setup

07.07.2015

* Before applyling 20150707104937_refactor_reserved_domains.rb migration, enable hstore extension in db

01.07.2015

* Added que init script example at doc/que directory, please setup que accornding to doc/que/README.md

26.06.2015

* Added new relic license key ta application-example.yml, please update application.yml

22.06.2015

* Update zonefile

16.06.2015

* Application time_zone should be defined at application.yml, updated application-exaple.yml 

15.06.2015

* Apache config update: now only TLSv1.2 allowed with whitelisted chipers, please review all SSL config parameters

08.06.2015

* Add sk service name to application.yml
* Renew zonefile procedure

02.06.2015

* Added possibility to overwrite legal document types at application.yml level.

01.06.2015

* Added separate data update, all data migration locate at db/data, more info 'rake -T data'

29.05.2015

* Removed old 'iptables_counter_update_command' and added 'iptables_counter_enabled'

26.05.2015

* Added separate data update, all data migration locate at db/data, more info 'rake -T data'

29.05.2015

* Removed old 'iptables_counter_update_command' and added 'iptables_counter_enabled'
* Updated deploy script, now staging comes from staging branch

25.05.2015

* Added iptables counter command to application-example.yml
* Add update application.yml with correct `sk_digi_doc_service_endpoint`

22.05.2015

* Add `RequestHeader set SSL_CLIENT_CERT "%{SSL_CLIENT_CERT}s` to apache config (see README for details)

20.05.2015

* Added documentation how to configure linux firewall about rate limits, scirpts and more info at doc/debian_build_doc.md

19.05.2015

* Added possibility to define NewRelic app_name at application.yml file with 'new_relic_app_name' attribute. 

18.05.2015

* Added Registrant database example file: config/database-example-registrant.yml

16.05.2015

* Security config update. Please replace all Location and RedirectMatch 
  in Admin, Registrar and Registrant Apache2 config. New one are in readme.

15.05.2015

* Refer to doc/certificates.md for ID card login, note that CRL files in Apache config are not paths to CRL directory. (SSLCARevocationFile -> SSLCARevocationPath)

15.05.2015

* Added instractions for apache2 reload without password for Registrant/Registrar, 
  more info at doc/certificates.md

14.05.2015

* Changed and added some new smtp enviroment variables. More info at application-example.yml

13.05.2015

* Added Registrant portal and apache config example
* Added mina deploy script for registrant
* Added new environment for EPP server: 'registrant_url'

12.05.2015

* Ruby version updated to 2.2.2

11.05.2015

* Registrar: only dev can skip pki login certificate, 
  please be sure all application.yml and apache conf is correctly setup for pki
* Updated Registrar Apache example: added user name directive example config

24.04.2015

* Update zonefile procedure

23.04.2015

* Add `bank_statement_import_dir: 'import/legal_documents'` to application.yml, run `mina setup`

22.04.2015

* Configure smtp (see application-example.yml)

22.04.2015

* Whois database schema updated. Please reset whois database and run `rake whois:schema:load`

21.04.2015

* Install packages for wkhtmltopdf (see readme)
* Add `bank_statement_import_dir: 'import/bank_statements'` to application.yml, run `mina setup`

15.04.2015

* Added whois tasks, more info with rake -T whois

02.04.2015

* Depricated DelayedJob, kill all running delayed jobs if needed

27.03.2015
 
* Integrated DEPP engine to Registrar. Please note new DEPP configuration in application-example.yml
* Patched mod_epp for larger frames, reinstall mod_epp with patches found in README and restart Apache.

25.03.2015

* Added new cronjob for destroying orphaned contacts. Update cron by running `mina cron:setup` in registry project

24.03.2015

* New Registrar virtualhost added. Please refer to readme for the configuration.
* Note the improved configuration for the registry virtualhost:

```
# Rewrite /login to /admin/login
RewriteEngine on
RewriteCond %{REQUEST_URI} ^/login [NC]
RewriteRule ^/(.*) /admin/$1 [PT,L,QSA]

<Location ~ "/.+/" >
  Deny from all
</Location>

<Location ~ "/(admin|assets)\/.+">
  Allow from all
</Location>
```

19.03.2015

* New REPP virtualhost added. Please refer to readme for the configuration.
* Choose new domain for REPP interface and reconfigure repp_url parameter in webclient's application.yml

16.03.2015

* ruby upgraded to version 2.2.1, added RBENV upgrade howto to debian doc at: doc/debian_build_doc.md

27.02.2015

* Simplified config/application-example.yml, 
  now system will check if all required settings are present in application.yml 

19.02.2015

* Cetrificate only enabled, please setup certificates following doc/certificate.md document.

20.01.2015

* Added dedicated mina cron:setup and mina cron:clear for manual cron management.
  Automatic management during deploy removed.
* Added mina config for epp: "mina eppst deploy" and "mina epppr deploy" 

19.01.2015

* Added application-exapmle.yml and removed application.yml from repo, please 
  add config/application.yml back when deploying:
  cp current/config/application-example.yml shared/config/application.yml # and edit it
* Removed config/initilizers/devise_secret.rb, use application.yml

16.01.2015

* Added new rake tasks: rake db:all:setup to setup all databases
  Find out more tasks for all databases with rake -T db:all

* Staging env added, please change apache conf in staging servers to "RailsEnv staging"
  Then you need to add or update staging section in
  --> config/database.yml
  --> config/secrets.yml
  --> config/application.yml

15.01.2015

* Registry api log and whois database added, please update your database.yml,
  you can view updated config at config/database-example.yml
* Upgraded to Rails 4.2 and ruby 2.2.0, be sure you have ruby 2.2.0 in your rbenv 
  NB! Update you passenger deb install, it should have recent fix for ruby 2.2.0

14.01.2015

* Update your Apache EPP conf file, add "EPPRawFrame raw_frame", inspect example file at Readme
  Otherwise new master EPP will not work.
