31.07.2025
* Poll messages for registry admin initiated domain status changes https://github.com/internetee/registry/issues/2823

30.07.2025
* Fixed domain history presentation offset in admin https://github.com/internetee/registry/issues/2822

29.07.2025
* Added extra test coverage for validate_dnssec_job https://github.com/internetee/registry/pull/2811
* Added new tests for zones_controller https://github.com/internetee/registry/pull/2813
* Updated test coverage/api users controller https://github.com/internetee/registry/pull/2819
* Added new test for model models/concerns/contact/archivable https://github.com/internetee/registry/pull/2820
* Added extra test coverage for accreditation_center/base_controller https://github.com/internetee/registry/pull/2821

18.07.2025
* Update actions/upload-artifact action to v4.6.2 https://github.com/internetee/registry/pull/2800
* Added extra test coverage for LhvConnectTransactionsController https://github.com/internetee/registry/pull/2815
* Updated set_test_date_to_api_user method on api_users_controller https://github.com/internetee/registry/issues/2816

06.06.2025
* Improvments to ent-to-end id processing https://github.com/internetee/registry/pull/2796
* Fix stale data in Whois update job https://github.com/internetee/registry/pull/2808

03.06.2025
* removed build_deploy_staging.yml from workflow as deprecated https://github.com/internetee/registry/issues/2797

30.05.2025
* Improvements for daily FD domains report https://github.com/internetee/registry/issues/2781
* Fixed duplicate domain history records in admin: https://github.com/internetee/registry/issues/2792

02.05.2025
* ForceDelete is not lifted with any contact update any more https://github.com/internetee/registry/issues/2782

25.04.2025
* Certificate generation feature for users https://github.com/internetee/registry/pull/2756

24.04.2025
* Fixed admin contact validation error handling https://github.com/internetee/registry/issues/2783

04.04.2025
* Daily report of domains with ForceDelete statuses https://github.com/internetee/registry/issues/2772

02.04.2025
* option to skip buiness registry validation for test environments https://github.com/internetee/registry/pull/2775

31.03.2025
* Fixed local part validation of email addresses https://github.com/internetee/registry/issues/2747

28.03.2025
* IPv6 address range support for access whitelisting https://github.com/internetee/registry/issues/2769

21.03.2025
* force admin cotact age restriction https://github.com/internetee/registry/issues/2750

20.03.2025
* fixed registrant transfer issue with disputed domains https://github.com/internetee/registry/issues/2594

07.03.2025
* fixed logging and notificaiton issues with business regsitry validation https://github.com/internetee/registry/issues/2754
* fixed http timeout in phone nr validation https://github.com/internetee/registry/pull/2762

21.02.2025
* nomethod error fix for cases without forceDelete set date https://github.com/internetee/registry/pull/2758

20.02.2025
* Fixes for FOrceDelete status handling and notifications https://github.com/internetee/registry/pull/2755

19.02.2025
* Fixed set clientHold job from resetting the status after removal by client https://github.com/internetee/registry/issues/2742

12.02.2025
* Re-enabled org validation against Est business registry https://github.com/internetee/registry/pull/2723

03.02.2025
* Added nil check for registrant in phone checker job https://github.com/internetee/registry/pull/2746

31.01.2025
* Added birthday ident verification https://github.com/internetee/registry/pull/2740
* Business Registry gem update https://github.com/internetee/registry/pull/2741
* Admin contact required conditions https://github.com/internetee/registry/pull/2743

28.01.2025
* Adding technical contact is now optional https://github.com/internetee/registry/issues/2701
* Adding admin contact is now optional for private regsitrants https://github.com/internetee/registry/issues/2702

15.01.2025
* Removed Russian transaltios from the automated email templates https://github.com/internetee/registry/issues/2690
* Improved verification email translations https://github.com/internetee/registry/pull/2737

31.12.2024
* Fix for expired status in domain history https://github.com/internetee/registry/issues/2665
* Fix for lifting ForceDelete https://github.com/internetee/registry/pull/2670
* Poll message fix for ForceDelete messages https://github.com/internetee/registry/issues/2714
* Admin notification about newly set ForceDelete statuses https://github.com/internetee/registry/issues/2716

19.11.2024
* contact verification with eeID for the registrar portal https://github.com/internetee/registry/pull/2696

08.11.2024
* update for business registry verification https://github.com/internetee/registry/pull/2693

21.10.2024
* Show 2nd level zones as blocked in whois https://github.com/internetee/registry/pull/2700

17.10.2024
* Fix for handling db relationships for poll messages https://github.com/internetee/registry/pull/2698

04.09.2024
* Fixed force delete removal issue when e-mail address is fixed https://github.com/internetee/registry/issues/2634

29.08.2024
* Set 255 char limit to contact name length https://github.com/internetee/registry/issues/2682

06.02.2024
* Updated request for getting reference data https://github.com/internetee/registry/pull/2625
* Force Delete process end is triggered by email update https://github.com/internetee/registry/issues/2634

26.01.2024
* Fix for auction race condition on domain registration deadline https://github.com/internetee/registry/issues/2641

18.01.2024
* Fix for vat on monthly invoices from December '23 https://github.com/internetee/registry/issues/2639 

22.12.2023
* Improvements for statistics queries https://github.com/internetee/registry/pull/2632

21.12.2023
* Registrar statistics calculation refactor https://github.com/internetee/registry/pull/2629

23.08.2023
* Fix for forceDeleteLift job https://github.com/internetee/registry/issues/2607
* Punycode email support for EPP contact create and update API requests https://github.com/internetee/registry/pull/2609

15.08.2023
* api user certificate validation improvements https://github.com/internetee/registry/pull/2602

12.07.2023
* Improved IP allow list management in admin https://github.com/internetee/registry/pull/2597

03.07.2023
* REPP API endpoint for csr upload and cert download https://github.com/internetee/registry/pull/2589

09.06.2023
* Downgrade Apipie-rails to version 0.6.0 https://github.com/internetee/registry/pull/2591

07.06.2023
* IP address allow-list and user management improvements https://github.com/internetee/registry/pull/2584
* Update dependency apipie-rails to v1 https://github.com/internetee/registry/pull/2566
* Update dependency data_migrate to v10 https://github.com/internetee/registry/pull/2586
* Updated sidekiq version to v7 https://github.com/internetee/registry/pull/2587
* Refactored parsed response for dnskey https://github.com/internetee/registry/pull/2588

18.05.2023
* Fixed ForceDelete conflicting statuses and excessive log issue https://github.com/internetee/registry/issues/2561
* Csv export option for registrar user and ip data in admin ui https://github.com/internetee/registry/issues/2567
* Fixed epp logs sorting https://github.com/internetee/registry/issues/2568
* VAT no added to the credit invoices https://github.com/internetee/registry/issues/2569
* English auctions trigger whois updates https://github.com/internetee/registry/issues/2577

05.05.2023
* Removed payment check verification https://github.com/internetee/registry/pull/2572

04.05.2023
* Fixed sync invoice statuses with billing https://github.com/internetee/registry/issues/2570

20.04.2023
* Sync invoice statuses with billing https://github.com/internetee/registry/pull/2531

18.04.2023
* Added child object info to admin domain view csv downloads https://github.com/internetee/registry/issues/2553
* Added option for excact match searching to admin https://github.com/internetee/registry/issues/2554
* Fixed period param for accreditation center https://github.com/internetee/registry/pull/2560

06.04.2023
* Bump rack from 2.2.6.2 to 2.2.6.4 https://github.com/internetee/registry/pull/2551

29.03.2023
* Fixed Domain_versions filter in admin that gave no results for create action https://github.com/internetee/registry/issues/2510

08.02.2023
* Bumped rack from 2.2.4 to 2.2.6.2 https://github.com/internetee/registry/pull/2543
* Bumped globalid from 0.5.2 to 1.0.1 https://github.com/internetee/registry/pull/2544

07.02.2023
* REPP support for . in the object codes https://github.com/internetee/registry/issues/2539

19.01.2023
* apipie gem downgrade to 0.6.0 to fix nil value repp error https://github.com/internetee/registry/pull/2537

17.01.2023
* removed unnecessary db migrations https://github.com/internetee/registry/issues/2534
* admin view fix for long domain names https://github.com/internetee/registry/issues/2520
* enable use of passwords with special characters in Registrar portal https://github.com/internetee/registry/pull/2526

09.01.2023
* authInfo code is reset on registrant change https://github.com/internetee/registry/pull/2519
* DB migrations to revert conversion from json to jsonb in log_domains https://github.com/internetee/registry/pull/2518

20.12.2022
* Fixed migrations and modified object data type of log_domains table https://github.com/internetee/registry/pull/2515

14.12.2022
* additional features for the XML console feature in registrar portal https://github.com/internetee/registry/pull/2509
* poll ack for XML console https://github.com/internetee/registry/pull/2511
* removed postal addresses from XML console samples https://github.com/internetee/registry/pull/2512

13.12.2022
* Refactored market share distributiond request for stats https://github.com/internetee/registry/pull/2498

07.12.2022
* return contact detaisl with authinfo pw of linked domain https://github.com/internetee/registry/issues/2492
* fixed disputed status removal https://github.com/internetee/registry/issues/2503

06.12.2022
* save status notes to domain history https://github.com/internetee/registry/issues/2484

02.12.2022
* registrant force delete notifications in case of multi-year registrations https://github.com/internetee/registry/issues/2467 

01.12.2022
* Fixed empty validation result reason in the logs https://github.com/internetee/registry/issues/2490
* Reduced unnecessary logging from email validation logs https://github.com/internetee/registry/issues/2491
* Added handling of canceled monthly invoices https://github.com/internetee/registry/pull/2458

30.11.2022
* Validator for incoming disclosed attributes https://github.com/internetee/registry/issues/2486
* Endpoint for registrar xml console feature https://github.com/internetee/registry/pull/2483

29.11.2022
* Fixed pantom statuse issue in REPP https://github.com/internetee/registry/issues/2470

24.11.2022
* Overwrite feature to SendMonthlyInvoicesJob https://github.com/internetee/registry/pull/2485

23.11.2022
* outzone rake task for invalid email domains by @OlegPhenomenon in https://github.com/internetee/registry/pull/2437
* Update dependency paper_trail to v13 by @renovate in https://github.com/internetee/registry/pull/2419
* Bump omniauth from 1.9.1 to 1.9.2 by @dependabot in https://github.com/internetee/registry/pull/2429
* Update dependency pdfkit to v0.8.7.2 [SECURITY] by @renovate in https://github.com/internetee/registry/pull/2472
* Bump google-protobuf from 3.19.4 to 3.21.9 by @dependabot in https://github.com/internetee/registry/pull/2477
* Fix domain contacts repp by @maricavor in https://github.com/internetee/registry/pull/2475
* Update dependency pg to v1.4.5 by @renovate in https://github.com/internetee/registry/pull/2481
* Fixed dates for yearly domains in monthly invoices by @maricavor in https://github.com/internetee/registry/pull/2482

02.11.2022
* outzone rake task for invalid email domains by @OlegPhenomenon in https://github.com/internetee/registry/pull/2437

28.10.2022
* Add request throttling by @yulgolem in https://github.com/internetee/registry/pull/2028

26.10.2022
* Update actions/download-artifact action to v3.0.1 by @renovate in https://github.com/internetee/registry/pull/2464
* Update actions/upload-artifact action to v3.1.1 by @renovate in https://github.com/internetee/registry/pull/2465
* assign the limit of validation records by @OlegPhenomenon in https://github.com/internetee/registry/pull/2466

20.10.2022
* added exception for auctions with no-bids and registred-domains statuses by @OlegPhenomenon in https://github.com/internetee/registry/pull/2403
* assign auction type for nil value rake task by @OlegPhenomenon in https://github.com/internetee/registry/pull/2404

17.10.2022
* Remove registrar portal by @thiagoyoussef in https://github.com/internetee/registry/pull/2434
* Update dependency pg to v1.4.4 by @renovate in https://github.com/internetee/registry/pull/2459
* fix check force delete lift poll messages by @thiagoyoussef in https://github.com/internetee/registry/pull/2461

12.10.2022
* Created regex only email validation domain list by @maricavor in https://github.com/internetee/registry/pull/2401
* Fix check force delete lift bug by @thiagoyoussef in https://github.com/internetee/registry/pull/2418
* Refactored monthly invoice generation job by @maricavor in https://github.com/internetee/registry/pull/2456

07.10.2022
* Enable trimming for dnskey and email values by @thiagoyoussef in https://github.com/internetee/registry/pull/2453

06.10.2022
* Update dependency pdfkit to v0.8.7 [SECURITY] by @renovate in https://github.com/internetee/registry/pull/2452
* Admin: option to delete auction record by @thiagoyoussef in https://github.com/internetee/registry/pull/2449
* Add monthly invoice email description by @thiagoyoussef in https://github.com/internetee/registry/pull/2442

03.10.2022
* fixed zeitwerk load file issue by @OlegPhenomenon in https://github.com/internetee/registry/pull/2448
* added sidekiq link to admin view by @OlegPhenomenon in https://github.com/internetee/registry/pull/2447
* protected public method account activity create by @OlegPhenomenon in https://github.com/internetee/registry/pull/2443

29.09.2022
* Update dependency haml to v6 by @renovate in https://github.com/internetee/registry/pull/2444
* added endpoints to demo registry for accr results by @OlegPhenomenon in https://github.com/internetee/registry/pull/2237
* Refactor: remove legacy que by @thiagoyoussef in https://github.com/internetee/registry/pull/2337
* fixed type of auction for next rounds by @OlegPhenomenon in https://github.com/internetee/registry/pull/2393
* Admin: download pdf with domain data on show by @thiagoyoussef in https://github.com/internetee/registry/pull/2396
* Increase notification text field length on database by @thiagoyoussef in https://github.com/internetee/registry/pull/2397

20.09.2022
* Created market share chart data endpoint by @maricavor in https://github.com/internetee/registry/pull/2426

16.09.2022
* Removed 200 limit of records if nil by @maricavor in https://github.com/internetee/registry/pull/2440
* fixed legal doc issue output by @OlegPhenomenon in https://github.com/internetee/registry/pull/2410
* extended csv domain export by @OlegPhenomenon in https://github.com/internetee/registry/pull/2407
* remove fixed top registrar navbar css class by @OlegPhenomenon in https://github.com/internetee/registry/pull/2406

13.09.2022
* Ignore statuses update if invoice already paid by @OlegPhenomenon in https://github.com/internetee/registry/pull/2438
* remove eis-billing feature toggle by @OlegPhenomenon in https://github.com/internetee/registry/pull/2433

08.09.2022
* Fixed template error for multi-year registered domains in force delete process [#2435](https://github.com/internetee/registry/issues/2435)

02.09.2022
* Update invoice status on payment order payments [#2427](https://github.com/internetee/registry/pull/2427)

01.09.2022
* Monthly invoice payment status fix [#2428](https://github.com/internetee/registry/issues/2428)

31.08.2022
* new fully automated process for registrar monthly invoices [#2424](https://github.com/internetee/registry/pull/2424)

25.08.2022
* Contact creation fix to not require postal addresses in Registrar portal [#2421](https://github.com/internetee/registry/pull/2421)

23.08.2022
* REPP update to fix search by registrant in Registrar portal [#2425](https://github.com/internetee/registry/pull/2425)

21.07.2022
* Removed deprecated statuses_before_force_delete field [#2363](https://github.com/internetee/registry/issues/2363)

15.07.2022
* REPP api update for new registrar portal [#2387](https://github.com/internetee/registry/pull/2387)

4.07.2022
* Update apipie-rails to 0.8.0 [#2383](https://github.com/internetee/registry/pull/2383)
* Bump jmespath to 1.6.1 [#2388](https://github.com/internetee/registry/pull/2388)

1.07.2022
* Update pg to 1.4.1 [#2394](https://github.com/internetee/registry/pull/2394)
* Update rack to 2.2.4 [#2398](https://github.com/internetee/registry/pull/2398)

21.06.2022
* Update pg to 1.4.0 [#2392](https://github.com/internetee/registry/pull/2392)

02.06.2022
* fix for force delete check query [#2380](https://github.com/internetee/registry/pull/2380)
* Integration with the billing service [#2266](https://github.com/internetee/registry/pull/2266)

25.05.2022
* Fixed looping validation issue [#2377](https://github.com/internetee/registry/pull/2377)
* ForceDelete query fix [#2380](https://github.com/internetee/registry/pull/2380)

19.05.2022
* Process to remove expired validation event records [#2236](https://github.com/internetee/registry/issues/2236)

17.05.2022
* removed unnecessary contact validation on contact create [#2376](https://github.com/internetee/registry/pull/2376)
* Refactored email validation job [#2369](https://github.com/internetee/registry/pull/2369)
* Job for deprecated validation events removal [#2374](https://github.com/internetee/registry/issues/2374)

09.05.2022
* test for auction view [#2373](https://github.com/internetee/registry/pull/2373)

06.05.2022
* refactored out the contact_code_cache from domain_contacts model [#2370](https://github.com/internetee/registry/issues/2370)

28.04.2022
* Fixed ns and dnssec validation error messages [#2296](https://github.com/internetee/registry/issues/2296)
* Added status notes to REPP domain info output [#2331](https://github.com/internetee/registry/issues/2331)
* Added auction list view to admin for improved ahandling of upcoming enlgish auction feature [#2341](https://github.com/internetee/registry/pull/2341)

27.04.2022
* Refactored email validation - reducing dns requests [#2364](https://github.com/internetee/registry/issues/2364)

21.04.2022
* Delay renovate Ruby version updates for 60 days [#2361](https://github.com/internetee/registry/issues/2361)

20.04.2022
* Contacts with disclosed attributes can now be updated [#2340](https://github.com/internetee/registry/issues/2340)
* Legacy code fix [#2360](https://github.com/internetee/registry/pull/2360)

19.04.2022
* Rolled back ruby version to 3.0.3 [#2358](https://github.com/internetee/registry/pull/2358) 

18.04.2022
* Fixed error 2005 epp syntax issue [#2338](https://github.com/internetee/registry/issues/2338)
* Fixed poll issue with email validations [#2343](https://github.com/internetee/registry/issues/2343)
* Removed registrant portal code from registry project [#2350](https://github.com/internetee/registry/issues/2350) 

14.04.2022
* Removed legacy email verification code [#2349](https://github.com/internetee/registry/issues/2349)

06.04.2022
* Contact email validation on domain update [#2213](https://github.com/internetee/registry/issues/2213)

05.04.2022
* Automatic contact name update poll messages are now grouped together into one change poll message [#2307](https://github.com/internetee/registry/issues/2307)
* Status notes are now added to status elements of epp xml [#2211](https://github.com/internetee/registry/issues/2211)
* Admin: Wildcard search improvements [#499](https://github.com/internetee/registry/issues/499)
* Admin: CSV download fix for history view [#2275](https://github.com/internetee/registry/issues/2275)
* Admin: CSV output fix for diman, contact, invoices and account views [2303](https://github.com/internetee/registry/issues/2303)
* Admin: registrar dropdown is searchable in invoice creation view [#2313](https://github.com/internetee/registry/issues/2313)
* Admin: Refactored CSV generation [#2321](https://github.com/internetee/registry/issues/2321)
* Removed legacy migration jobs [#2090](https://github.com/internetee/registry/issues/2090)

04.04.2022
* Upload-artifact update to 3.0.0 [#2301](https://github.com/internetee/registry/pull/2301)
* data_migrate update to 8.0 [#2302](https://github.com/internetee/registry/pull/2302)

01.04.2022
* Pg update to 1.3.5 [#2328](https://github.com/internetee/registry/pull/2328)
* Puma update to 5.6.4 [#2327](https://github.com/internetee/registry/pull/2327)

31.03.2022
* Sidekiq update to 6.4.1 [#2322](https://github.com/internetee/registry/pull/2322)

25.03.2022
* Bulk change of business contacts' names requires now user confirmation [#2309](https://github.com/internetee/registry/pull/2309)

23.02.2022
* FD notes are updated when basis for FD changes [#2216](https://github.com/internetee/registry/issues/2216)
* Admin: date filter end date in domain hostory is now inclusive [#2274](https://github.com/internetee/registry/issues/2274)
* Job for finding and removing disputed statuses from the domains that should not have it [#2281](https://github.com/internetee/registry/issues/2281)

09.02.2022
* DNSSEC key validation [#1897](https://github.com/internetee/registry/issues/1897)

14.01.2022
* Fixed issue with missing error message on invalid phone number update [#2239](https://github.com/internetee/registry/issues/2239)

13.01.2022
* Added accreditation expiry notifications [#2212](https://github.com/internetee/registry/pull/2212)

12.01.2022
* Fixed double history entries on admin atatus changes [#2263](https://github.com/internetee/registry/pull/2263)

10.01.2022
* Fixed bulk action in registrar portal [#2251](https://github.com/internetee/registry/issues/2251)

07.01.2022
* Implemented nameserver validation [#2202](https://github.com/internetee/registry/issues/2202)

29.12.2021
* User test env is renamed to demo to remove naming conflict with autotest env [#2238](https://github.com/internetee/registry/pull/2238)
* imporved mx level email validation for contact create and update [#2246](https://github.com/internetee/registry/issues/2246)
* improved tests for account_activities [#2255](https://github.com/internetee/registry/pull/2255)
* Bump Ruby to 3.1.0 [#2249](https://github.com/internetee/registry/pull/2249)
* Bump Ransack to 2.5.0 [#2248](https://github.com/internetee/registry/pull/2248)

27.12.2021
* Improved mx level checks for email validation [#2244](https://github.com/internetee/registry/issues/2244)
* fixed support for idn domains in email validation [#2250](https://github.com/internetee/registry/issues/2250)

20.12.2021
* delete prohibited can be set to domains in force delete [#2218](https://github.com/internetee/registry/issues/2218)

17.12.2021
* invalid emails with mx and smtp failures are now rechecked on every run until linked to any domain [#2231](https://github.com/internetee/registry/pull/2231)

14.12.2021
* Added Truemail validation to contact create and contact update [#2184](https://github.com/internetee/registry/issues/2184)

29.11.2021
* Performance optimation for email validation task [#2226](https://github.com/internetee/registry/pull/2226)
* Removed obj and extension update prohibited toggle feature [#2229](https://github.com/internetee/registry/pull/2229)

26.11.2021
* Removed pghero from produdction deployment pipeline [#2225](https://github.com/internetee/registry/pull/2225)

25.11.2021
* Added newrelic gem for monitoring in dev [#2222](https://github.com/internetee/registry/pull/2222)

19.11.2021
* Fix for registrant portal not returning privatly owned domains [#2214](https://github.com/internetee/registry/issues/2214)
* optimized email validation background process [#2201](https://github.com/internetee/registry/pull/2201)

10.11.2021
* Org contact name is now updated according to info received form business registry: [#2199](https://github.com/internetee/registry/pull/2199)
* New API endpoint for accreditation center login: [#2105](https://github.com/internetee/registry/pull/2105)

25.10.2021
* Setting and removing ForceDelete does not affect registry lock [#2195](https://github.com/internetee/registry/issues/2195)
* Renew does not cancel admin set serverHold [#2186](https://github.com/internetee/registry/issues/2186)

22.10.2021
* Disputed domains not in registry now appear in whois as disputed [#2191](https://github.com/internetee/registry/issues/2191)
* 5 failure threshold for email validation on MX level [#2185](https://github.com/internetee/registry/issues/2185)
* Removal of unused code [#2188](https://github.com/internetee/registry/pull/2188)

21.10.2021 
* Fixed registry lock applying to domains with forceDelete status set [#2167](https://github.com/internetee/registry/pull/2167)
* Bump puma to 5.5.1 [#2182](https://github.com/internetee/registry/pull/2182)

14.10.2021
* fixed whois record update for disputed domains [#2173](https://github.com/internetee/registry/issues/2173) 
* fixed cert signing bug in admin [#2177](https://github.com/internetee/registry/issues/2177)
* Bump nokogiri to 1.12.5 [#2171](https://github.com/internetee/registry/pull/2171)

08.10.2021
* E-mail validator logging and option to use unlimited mx lvl validations [#2059](https://github.com/internetee/registry/issues/2059)
* Fix for dnssec key update with serverObjUpdateProhibited status [#2174](https://github.com/internetee/registry/issues/2174)

06.10.2021
* Fixed invoice sorting in admin [#2165](https://github.com/internetee/registry/issues/2165)

29.09.2021
* Added bulk add option for bulk nameserver change [#2158](https://github.com/internetee/registry/issues/2158)

28.09.2021
* Fixed disputed domain registration [#2169](https://github.com/internetee/registry/issues/2169)

23.09.2021
* Fixed registrant portal link in expiration email templates [#2168](https://github.com/internetee/registry/pull/2168)
* extensionProhibited option for registry lock [#2164](https://github.com/internetee/registry/pull/2164)
* job and tests for updating regsitry lock update orhibited statuses [#2163](https://github.com/internetee/registry/pull/2163)

21.09.2021
* Registry lock: new serverObjUpdateProhibited status replaces serverUpdateProhibited [#2162](https://github.com/internetee/registry/pull/2162)

16.09.2021
* Admin: improved active/inactive registrar fileter [#2156](https://github.com/internetee/registry/issues/2156)
* Admin: date filter for domain and contact history views [#2157](https://github.com/internetee/registry/issues/2157)

14.09.2021
* New epp statuses to better control registry lock and enable dnssec on locked domains (currently disabled on production) [#2143](https://github.com/internetee/registry/issues/2143)
* Replaced deprecated search method with ransac gem [#2151](https://github.com/internetee/registry/pull/2151)

13.09.2021
* Upgrade Ruby to 3.0.2 [#2152](https://github.com/internetee/registry/pull/2152)

06.09.2021
* Updgrade Ruby to 2.7.4 [#2148](https://github.com/internetee/registry/pull/2148)
* Replace dependabot with renovate [#2144](https://github.com/internetee/registry/pull/2144)

31.08.2021
* Fix for multiplied renew issue [#2135](https://github.com/internetee/registry/issues/2135)
* Admin: filtering and search options for the invoices view [#2124](https://github.com/internetee/registry/issues/2124)
* Admin: certificate filenames are now unique [#2125](https://github.com/internetee/registry/issues/2125)
* Admin: filter to select show active and inactive registrars [#2127](https://github.com/internetee/registry/issues/2127)
* Admin: fixed epp log loading issue with high number of log records [#2133](https://github.com/internetee/registry/issues/2133)
* Bump paper-trail to 12.1.0 [#2138](https://github.com/internetee/registry/pull/2138)
* Bump bootsnap to 1.8.1 [#2139](https://github.com/internetee/registry/pull/2139)
* Bump nokogiri to 1.12.4 [#2140](https://github.com/internetee/registry/pull/2140)

25.08.2021
* Admin: added option to update registrar credit balance [#714](https://github.com/internetee/registry/issues/714)
* Bump webdriver to 4.6.1 [#2128](https://github.com/internetee/registry/pull/2128)
* Bump sidekiq to 6.2.2 [#2129](https://github.com/internetee/registry/pull/2129)
* Bump truemail to 2.4.9 [#2130](https://github.com/internetee/registry/pull/2130)
* Bump rails to 6.1.4.1 [#2131](https://github.com/internetee/registry/pull/2131)

24.08.2021
* Fixed bulk transfer internal error [#2123](https://github.com/internetee/registry/issues/2123)

18.08.2021
* Added csv export functionality to admin [#500](https://github.com/internetee/registry/issues/500)
* Admin domain list csv is now compatible with bulk transfer [#670](https://github.com/internetee/registry/issues/670)
* Bump truemail to 2.4.8 [#2121](https://github.com/internetee/registry/pull/2121)
* Bump nokogiri to 1.12.3 [#2122](https://github.com/internetee/registry/pull/2122)

11.08.2021
* Registrar filters as dropdown in admin [#501](https://github.com/internetee/registry/issues/501)
* Created at filter added to domain listing in admin [#502](https://github.com/internetee/registry/issues/502)
* UI fix to fit long email addresses in admin [#523](https://github.com/internetee/registry/issues/523)
* Fixed manual invoice binding in admin [#2095](https://github.com/internetee/registry/issues/2095)
* Bump webmock to 3.14.0 [#2118](https://github.com/internetee/registry/pull/2118)
* Bump nokogiri to 1.12.2 [#2119](https://github.com/internetee/registry/pull/2119)

03.08.2021
* Added missing pagination options to admin [#339](https://github.com/internetee/registry/issues/339)
* Bump haml to 5.2.2 [#2110](https://github.com/internetee/registry/pull/2110)
* Bump aws-sdk-sesv2 to 1.19.0 [#2111](https://github.com/internetee/registry/pull/2111)
* Bump nokogiri to 1.12.0 [#2112](https://github.com/internetee/registry/pull/2112)
* Bump puma to 5.4.0 [#2113](https://github.com/internetee/registry/pull/2113)
* Bump bootsnap to 1.7.7 [#2114](https://github.com/internetee/registry/pull/2114)

28.07.2021
* limited contact name validation only for private registrants [#2102](https://github.com/internetee/registry/pull/2102)
* fixed REPP boolean value bug [#2098](https://github.com/internetee/registry/pull/2098)
* fixed bank transaction binding in admin [#1788](https://github.com/internetee/registry/issues/1788)
* Registrar: fiex ui issue with contact ident data update [#1797](https://github.com/internetee/registry/issues/1797)
* Registrar: removed delete option for domains already in pendingDelete state [#1798](https://github.com/internetee/registry/issues/1798)
* Registrar: improved birtdate validation [#1796](https://github.com/internetee/registry/issues/1796)
* improved status storing for improved status managment with setting and removing status sets like forceDelete and registry lock [#2080](https://github.com/internetee/registry/issues/2080)
* reverted orphaned poll message autodeque [#2092](https://github.com/internetee/registry/pull/2092)
* Bump bootsnap to 1.7.6 [#2104](https://github.com/internetee/registry/pull/2104)
* Bump apipie-rails to 0.5.19 [#2103](https://github.com/internetee/registry/pull/2103)
* Bump countries to 4.0.1 [#2100](https://github.com/internetee/registry/pull/2100)
* Bump addressable to 2.8.0 [#2085](https://github.com/internetee/registry/pull/2085)
* Bump data_migrate to 7.0.2 [#2086](https://github.com/internetee/registry/pull/2086)
* Bump active_interaction to 4.0.5 [#2087](https://github.com/internetee/registry/pull/2087)
* Bump truemail to 2.4.6 [#2088](https://github.com/internetee/registry/pull/2088)

08.07.2021
* improved contact name validation [#1795](https://github.com/internetee/registry/issues/1795)
* orphaned poll messages are automatically dequed [#2026](https://github.com/internetee/registry/issues/2026)
* fixed registrant change with force delete set [#2077](https://github.com/internetee/registry/issues/2077)

06.07.2021
* admin dropdown filter ui fix [#2065](https://github.com/internetee/registry/issues/2065)
* Bump truemail to 2.4.4 [#2071](https://github.com/internetee/registry/pull/2071)
* Bump active_interaction to 4.0.4 [#2072](https://github.com/internetee/registry/pull/2072)
* Bump mime-types.data to 3.2021.0704 [#2073](https://github.com/internetee/registry/pull/2073)

29.06.2021
* Bump active_interaction to 4.0.3 [#2066](https://github.com/internetee/registry/pull/2066)
* Bump rails to 6.1.4 [#2067](https://github.com/internetee/registry/pull/2067)

28.06.2021
* Registrar: fixed invoice colum title in billing view [#2062](https://github.com/internetee/registry/issues/2062)
* Improved support for multiple schema versions [#2058](https://github.com/internetee/registry/issues/2058)

25.06.2021
* Malformed csv files cause hard fail to the request to avoid unwanted results [#1813](https://github.com/internetee/registry/issues/1813)
* e-invoice gem update to 312cac1 [#2052](https://github.com/internetee/registry/pull/2052)
* Bump bindata to 2.4.10 [#2060](https://github.com/internetee/registry/pull/2060)

22.06.2021
* quickfix for supporting multiple schemas in epp responses [#2046](https://github.com/internetee/registry/issues/2046)
* optimisation for busines reg open data scanner [#2049](https://github.com/internetee/registry/issues/2049)
* bump cancancan to 3.3.0 [#2051](https://github.com/internetee/registry/pull/2051)
* bump truemail to 2.4.3 [#2053](https://github.com/internetee/registry/pull/2053)
* bump actions/download-artifact to 2.0.10 [#2054](https://github.com/internetee/registry/pull/2054)
* bump actions/upload-artifact to 2.2.4 [#2055](https://github.com/internetee/registry/pull/2055)

21.06.2021
* fixed error message for unsupported algorithms [#2033](https://github.com/internetee/registry/issues/2033)
* enabled suport for 2 additional dnssec algorithms - 15 (Ed25519) and 16 (Ed448) [#2034](https://github.com/internetee/registry/issues/2034)
* fixed dnssec rem all bug in epp [#2035](https://github.com/internetee/registry/issues/2035)
* punycode support for csync [#2036](https://github.com/internetee/registry/issues/2036)

18.06.2021
* Fixed domain update bug in registrar [#2041](https://github.com/internetee/registry/issues/2041)
* Added Business registry open data validator [#1851](https://github.com/internetee/registry/issues/1851)

17.06.2021
* Automatic response validation against epp schemas [#1930](https://github.com/internetee/registry/issues/1930)

16.06.2021
* New domain and all-ee schema versions for serverReleaseProhibited status [#2004](https://github.com/internetee/registry/issues/2004)
* Support for multiple schema versions [#2030](https://github.com/internetee/registry/issues/2030)

14.06.2021
* Task for scanning trhough email addresses and assess the data quality in the registry [#2029](https://github.com/internetee/registry/pull/2029)
* Bump countries to 4.0.0 [#2031](https://github.com/internetee/registry/pull/2031)

11.06.2021
* Csync fix for invalid dns records [#2024](https://github.com/internetee/registry/issues/2024)

08.06.2021
* Fixed e-invoices sending on auto-topup [#2022](https://github.com/internetee/registry/issues/2022)
* Bump nokogiri to 1.11.7 [#2021](https://github.com/internetee/registry/pull/2021)

01.06.2021
* Fix unpaiable invoices - setting receipt date and sending e-invoice [#2009](https://github.com/internetee/registry/issues/2009)
* Added check to make sure domain is not in acution before adding it [#2015](https://github.com/internetee/registry/pull/2015)

31.05.2021
* Bump nokogiri to 1.11.6 [#2012](https://github.com/internetee/registry/pull/2012)
* Bump cancancan to 3.2.2 [#2013](https://github.com/internetee/registry/pull/2013)
* Bump e_invoice to 7832ef6 [#2010](https://github.com/internetee/registry/pull/2014)
* Bump active_interaction to 4.0.1 [#2015](https://github.com/internetee/registry/pull/2015)

28.05.2021
* fix for legacy contact object errors in admin [#2010](https://github.com/internetee/registry/pull/2010)

27.05.2021
* fixed error handling on invalid date format for epp contact create [#2006](https://github.com/internetee/registry/issues/2006)
* csync input file with puycode values [#2003](https://github.com/internetee/registry/issues/2003)
* autoloading newest db schema file versions [#1976](https://github.com/internetee/registry/issues/1976)
* ForceDelete notes are updated with additionally found email addresses [#1913](https://github.com/internetee/registry/issues/1913)

24.05.2021
* Bump puma to 5.3.2 [#1999](https://github.com/internetee/registry/pull/1999)
* Bump nokogiri to 1.11.5 [#2000](https://github.com/internetee/registry/pull/2000)
* BUmp truemail to 2.4.2 [#2001](https://github.com/internetee/registry/pull/2001)

21.05.2021
* Tech contacts do not receive expiration emails any more [#1996](https://github.com/internetee/registry/issues/1996)

20.05.2021
* Moved data migrations from whois project to registry [#1928](https://github.com/internetee/registry/issues/1928)

19.05.2021
* Fix for contact update via registrant portal [#1968](https://github.com/internetee/registry/pull/1968)
* REPP is returning domain count with domain list for improved pagination handling [#1969](https://github.com/internetee/registry/pull/1969)
* Fix for registrant change confirmation broken link [#1994](https://github.com/internetee/registry/issues/1994)

18.05.2021
* Added serverReleaseProhibited status [#1885](https://github.com/internetee/registry/issues/1885)
* Fixed internal error on contact creation with duplicate contact id [#1987](https://github.com/internetee/registry/issues/1987)
* Fixed internal error on accessing contact details in admin portal [#1990](https://github.com/internetee/registry/issues/1990)
* Fixed payment processing with numeric non regerence value in description [#1991](https://github.com/internetee/registry/issues/1991)

17.05.2021
* Bump webmock to 3.13.0 [#1979](https://github.com/internetee/registry/pull/1979)
* Bump Nokogiri to 1.11.4 [#1980](https://github.com/internetee/registry/pull/1980)
* Bump airbrake to 11.0.3 [#1981](https://github.com/internetee/registry/pull/1981)
* Bump puma to 5.3.1 [#1982](https://github.com/internetee/registry/pull/1982)
* Bump data_migrate to 7.0.1 [#1983](https://github.com/internetee/registry/pull/1983)
* Removed activerecord_import gem [#1984](https://github.com/internetee/registry/pull/1984)

10.05.2021
* Domain update confirmation fix [#1975](https://github.com/internetee/registry/pull/1975)
* Bump bootsnap to 1.7.5 [#1970](https://github.com/internetee/registry/pull/1970)
* Bump truemail to 2.4.1 [#1971](https://github.com/internetee/registry/pull/1971)
* Bump devise to 4.8.0 [#1972](https://github.com/internetee/registry/pull/1972)
* Bump iso8601 to 0.13.0 [#1973](https://github.com/internetee/registry/pull/1973)
* Bump puma to 5.3.0 [#1974](https://github.com/internetee/registry/pull/1974)

06.05.2021
* List all unread polls option for REPP [#1936](https://github.com/internetee/registry/pull/1936)
* Bump Rails to 6.1.3.1 [#1962](https://github.com/internetee/registry/pull/1962)
* Bump mimemagic to 0.4.3 [](https://github.com/internetee/registry/pull/1960)

03.05.2021
* Imporved error handling on invalid XML over EPP [#1952](https://github.com/internetee/registry/pull/1952)
* Bump bootsnap to 1.7.4 [#1963](https://github.com/internetee/registry/pull/1963)
* Bump truemail to 2.4.0 [#1964](https://github.com/internetee/registry/pull/1964)

30.04.2021
* Fixed error message on oversized legaldocs [#1880](https://github.com/internetee/registry/issues/1880)

29.04.2021
* Admin is able to cancel invoice payments [#1937](https://github.com/internetee/registry/issues/1937)
* Bump nokogiri to 1.11.3 [#1920](https://github.com/internetee/registry/pull/1920)

26.04.2021
* Disputed status is removed on registrant change and status added to schema [#1927](https://github.com/internetee/registry/issues/1927)
* Bounce list record is removed one there are no active contacts with the address [#1912](https://github.com/internetee/registry/issues/1912)
* Bump data_migrate to 7.0.0 [#1946](https://github.com/internetee/registry/pull/1946)
* Bump selectize-rails to 0.12.6 [#1947](https://github.com/internetee/registry/pull/1947)
* Bump active_interaction to 4.0.0 [#1948](https://github.com/internetee/registry/pull/1948)
* Bump rexml to 3.2.5 [#1949](https://github.com/internetee/registry/pull/1949)
* Syslog support to staging.rb [#1951](https://github.com/internetee/registry/pull/1951)
* Explicit rails versioning to migrations [#1953](https://github.com/internetee/registry/pull/1953)
* Fixed Sidekiq web,session_secret warning [#1940](https://github.com/internetee/registry/issues/1940)

19.04.2021
* Bump truemail to 2.3.4 [#1931](https://github.com/internetee/registry/pull/1931)
* Bump pry to 0.14.1 [#1932](https://github.com/internetee/registry/pull/1932)
* Bump pg to 1.2.3 [#1933](https://github.com/internetee/registry/pull/1933)
* Bump sidekiq to 6.2.1 [#1934](https://github.com/internetee/registry/pull/1934)
* Bump jquery-ui-rails to 6.0.1 [#1935](https://github.com/internetee/registry/pull/1935)

14.04.2021
* REPP documentation update with github pages styled doc [#1896](https://github.com/internetee/registry/issues/1896)

13.04.2021
* Bounce list invalidates all contacts with the address [#1837](https://github.com/internetee/registry/issues/1837)

12.04.2021
* Que replaced by Sidekiq and set handling for failing email jobs [#645](https://github.com/internetee/registry/issues/645)
* Bump coderay to 1.1.3 [#1918](https://github.com/internetee/registry/pull/1918)
* Bump webmock to 3.12.2 [#1919](https://github.com/internetee/registry/pull/1919)
* Bump whenever to 1.0.0 [#1921](https://github.com/internetee/registry/pull/1921)

08.04.2021
* Registry lock does not affect statuses set by system or admin [#1900](https://github.com/internetee/registry/issues/1900)
* Invalid email address is added to the forcedelete notes in admin with starting ForceDelete process [#1899](https://github.com/internetee/registry/issues/1899)

07.04.2021
* Bump donwload-artifact to 2.0.9 [#1904](https://github.com/internetee/registry/pull/1904)
* Bump upload-artifact to 2.2.3 [#1905](https://github.com/internetee/registry/pull/1905)
* Bump select2-rails to 4.0.13 [#1906](https://github.com/internetee/registry/pull/1906)
* Bump pry to 0.14.0 [#1907](https://github.com/internetee/registry/pull/1907)
* Bump truemail to 2.2.3 [#1908](https://github.com/internetee/registry/pull/1908)
* Bump paper_trail to 12.0.0 [#1909](https://github.com/internetee/registry/pull/1909)

06.04.2021
* Replacing invalid email cancels force delete [#1898](https://github.com/internetee/registry/issues/1898)

08.04.2021
* Fixed registry locking issue if any of the satuses were removed separately [#1884](https://github.com/internetee/registry/issues/1884)

31.03.2021
* Implemented child to parent syncronisation (csync) for cdnskeys [#658](https://github.com/internetee/registry/issues/658)

29.03.2021
* Full EPP functionality to REPP API [#1756](https://github.com/internetee/registry/issues/1756)

25.03.2021
* Gem Security updates [#1892](https://github.com/internetee/registry/pull/1892)

23.03.2021
* Expiration mailer ignores bounced addresses and send each email separately [#1888](https://github.com/internetee/registry/issues/1888)

22.03.2021
* Bounced emails trigger soft ForceDelete procedure [#1838](https://github.com/internetee/registry/issues/1838)

18.03.2021
* Added tests for renew and domain status management [#1886](https://github.com/internetee/registry/pull/1886)

12.03.2021
* Removed old classnames from notifications [#1878](https://github.com/internetee/registry/pull/1878)
* improved test coverage [#1860](https://github.com/internetee/registry/pull/1860)
* added test for whois record delete [#1811](https://github.com/internetee/registry/pull/1811)

11.03.2021
* Account activity in registrar and REPP now return balance with each record [#1819](https://github.com/internetee/registry/issues/1819)
* Fixed CookieOverflow error with large authentication service keys [#1879](https://github.com/internetee/registry/pull/1879)

10.03.2021
* Registrant API returns full contact details for admin contacts [#1876](https://github.com/internetee/registry/pull/1876)

09.03.2021
* AWS message id saving over API [#1877](https://github.com/internetee/registry/pull/1877)
* Enabled Zeitwerk autoloader [#1872](https://github.com/internetee/registry/issues/1872)

04.03.2021
* Removed old registrant portal from the project [#1826](https://github.com/internetee/registry/issues/1826)

03.03.2021
* Email notification is sent in case of pendingupdate expiry [#897](https://github.com/internetee/registry/issues/897)

26.02.2021
* Domain delete is not affected by updateProhibited [#1844](https://github.com/internetee/registry/issues/1844)
* Registrant API fix for handling eidas personal identificators [#1864](https://github.com/internetee/registry/pull/1864)

23.02.2021
* UpdateProhibited status affects bulk actions in REPP [#1818](https://github.com/internetee/registry/issues/1818)
* Registrant api domain request now excludes tech only domains by default [#1836](https://github.com/internetee/registry/pull/1836)

22.02.2021
* serverDeleteProhibited prohibts delete action [#1849](https://github.com/internetee/registry/issues/1849)

19.02.2021
* Update prohibited staatus is kept after renew [#1843](https://github.com/internetee/registry/issues/1843)
* Fixed clientHold and serverManualInzone status conflict issue [#1845](https://github.com/internetee/registry/issues/1845)
* Replacing registrant object with another that has the same ident data set does not require registrant verification [#1852](https://github.com/internetee/registry/issues/1852)

11.02.2021
* Poll messages on locking and unlocking a domain [#1828](https://github.com/internetee/registry/issues/1828)
* Registrar's prefix is now checked and added to contact id for info and check requests [#1832](https://github.com/internetee/registry/issues/1832)

10.02.2021
* Admin contact bulk change option for registrars [#1764](https://github.com/internetee/registry/issues/1764)
* Option to remove email addresses from AWS SES Supression list [#1839](https://github.com/internetee/registry/issues/1839)
* Added separate key for bounce API [#1842](https://github.com/internetee/registry/pull/1842)

09.02.2021
* Added new endpoint for WHOIS contact requests [#1794](https://github.com/internetee/registry/pull/1794)

05.02.2021
* Fixed IPv4 empty string issue in case of IPv6 only entries for IP whitelist [#1833](https://github.com/internetee/registry/issues/1833)

02.02.2021
* Fixed updateProhibited status not affecting bulk tech contact change operation [#1820](https://github.com/internetee/registry/pull/1820)

01.02.2021
* Improved tests for admin interface [#1805](https://github.com/internetee/registry/pull/1805)

28.01.2021
* Fixed transfer with shared admin and tech contacts [#1808](https://github.com/internetee/registry/issues/1808)
* Improved error handling with double admin/tech contacts [#1758](https://github.com/internetee/registry/issues/1758)
* Added CSV export option to admin [#1775](https://github.com/internetee/registry/issues/1775)
* Improved DNSSEC key validation for illegal characters [#1790](https://github.com/internetee/registry/issues/1790)
* Fix for whois record creation issue on releasing domain to auction [#1139](https://github.com/internetee/registry/issues/1139)
* Fix for handling malformed request frames [#1825](https://github.com/internetee/registry/issues/1825)
* Improved registrar account activity tests [#1824](https://github.com/internetee/registry/pull/1824)

27.01.2021
* Figaro update to 1.2.0 [#1823](https://github.com/internetee/registry/pull/1823)

26.01.2021
* Ruby update to 2.7 [#1791](https://github.com/internetee/registry/issues/1791)

21.01.2021
* Registrant API: optimised contact linking [#1807](https://github.com/internetee/registry/pull/1807)

20.01.2021
* Fixed legaldoc assignment issue on registrant confirmation [#1806](https://github.com/internetee/registry/pull/1806)

14.01.2021
* Fixed IDN and punycode support for REPP domain transfer_info request [#1801](https://github.com/internetee/registry/issues/1801)

06.01.2021
* IMproved tests whois update for bulk nameserver change [#1739](https://github.com/internetee/registry/issues/1739)
* Bulk ForceDelete funcionality in admin [#1177](https://github.com/internetee/registry/issues/1177)
* Reverted Nokogiri bump due to dependency conflicts in production [#1787](https://github.com/internetee/registry/pull/1787)

05.01.2021
* Fixed ok/inactive bug together with disclosed contact attribute handling [#1786](https://github.com/internetee/registry/pull/1786)
* Ident data to simplified domain list in registrant API to help with sorting and filtering [#1783](https://github.com/internetee/registry/pull/1783)
* Bumped Nokogiri to 1.11.0 [#1785](https://github.com/internetee/registry/pull/1785)

23.12.2020
* fix for REPP logging and registrar portal communication [#1782](https://github.com/internetee/registry/pull/1782)

22.12.2020
* SSL CA verification fix for Bulk renew [#1778](https://github.com/internetee/registry/pull/1778)

21.12.2020
* Bulk renew for REPP and registrar [#1763](https://github.com/internetee/registry/issues/1763)

17.12.2020
* New API for registering bounced emails [#1687](https://github.com/internetee/registry/pull/1687)

16.12.2020
* Refactored domain delete confirmation for interactors [#1769](https://github.com/internetee/registry/issues/1769)

15.12.2020
* Improved logic for domain list request in registrant API [#1750](https://github.com/internetee/registry/pull/1750)
* Refactored Whois update job for interactors [#1771](https://github.com/internetee/registry/issues/1771)

14.12.2020
* Refactored domain cron jobs for interactors [#1767](https://github.com/internetee/registry/issues/1767)

09.12.2020
* Refactored domain update confirm for interactors [#1760](https://github.com/internetee/registry/issues/1760)

08.12.2020
* Replaced Travis-CI with GitHub Actions [#1746](https://github.com/internetee/registry/pull/1746)
* Refactored domain delete for interactors [#1755](https://github.com/internetee/registry/issues/1755)

01.12.2020
* Refactored clientHold for interactors [#1751](https://github.com/internetee/registry/issues/1751)
* Fixed internal error on removing clientHold status when not present [#1766](https://github.com/internetee/registry/issues/1766)

30.11.2020
* Refactor - interactors moved to domain space [#1762](https://github.com/internetee/registry/pull/1762)

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
