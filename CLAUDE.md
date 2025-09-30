# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Domain Registry** application - a full-stack top-level domain (TLD) management system built with Ruby on Rails 6.1. It handles domain registration, EPP (Extensible Provisioning Protocol) operations, billing, and WHOIS management for domain registries.

## Environment Constraints

**IMPORTANT**: This project runs in Docker containers. Do NOT attempt to run commands locally. All project operations must be executed through Docker.

## Development Commands

### Docker-Based Development

All development should be done through docker-compose from the [docker-images repository](https://github.com/internetee/docker-images):

```bash
# Run tests
docker-compose run registry bundle exec rake RAILS_ENV=test COVERAGE=true

# Run single test
docker-compose run registry bundle exec rails test <path_to_test> RAILS_ENV=test COVERAGE=true

# Rails console
docker-compose run registry bundle exec rails console

# Database operations
docker-compose run registry bundle exec rake db:setup:all RAILS_ENV=test
```

### Testing

- Default test command: `rake` (runs basic tests without EPP tests)
- With coverage: `RAILS_ENV=test rake COVERAGE=true`
- Test framework: Minitest with Capybara for system tests
- Browser automation: Selenium WebDriver with headless Chrome
- System tests use DatabaseCleaner with truncation strategy

### Database Management

The application uses **three separate PostgreSQL databases**:
- Main database: Domain and registrar data
- `api_log`: API request logging
- `whois`: WHOIS query data

```bash
# Setup all databases
rake db:setup:all    # Creates all databases, loads schemas, and runs seeds

# Schema operations
rake db:schema:load:all    # Load schemas for all databases
rake db:schema:dump:all    # Dump schemas for all databases
```

Database schema is stored in SQL format (`config.active_record.schema_format = :sql`).

## Architecture

### High-Level Structure

This is a **multi-interface domain registry system** with three main client interfaces:
1. **EPP Interface** - Extensible Provisioning Protocol for registrars (port 700)
2. **REPP Interface** - RESTful EPP over HTTPS for registrars
3. **Admin Interface** - Web-based administration portal (port 443)

Additionally supports:
- **Registrar Portal** - Separate web interface for registrar operations
- **Registrant Portal** - Domain owner self-service interface

### EPP (Extensible Provisioning Protocol) Implementation

EPP is the core protocol for domain operations. The system implements:

**RFCs Supported:**
- RFC5730 (EPP), RFC5731 (Domain Mapping), RFC5733 (Contact Mapping)
- RFC5734 (Transport over TCP), RFC5910 (DNSSEC Mapping)
- RFC8590 (Change Poll)

**EPP Controllers** (`app/controllers/epp/`):
- `SessionsController` - Authentication (hello, login, logout)
- `DomainsController` - Domain operations (create, update, info, check, transfer, renew, delete)
- `ContactsController` - Contact operations (same operations as domains)
- `PollsController` - Message polling for asynchronous updates
- `ErrorsController` - XML schema validation errors

**EPP Routing**: Uses custom `EppConstraint` class to route requests based on XML schema validation. All EPP requests go through schema validation before controller dispatch.

**XML Schemas**: Located in `lib/schemas/` with both standard and `.ee`-specific extensions.

### Core Domain Models

**Domain Model** (`app/models/domain.rb`):
- Heavily modularized using concerns (15+ included modules)
- Key concerns: `Expirable`, `Activatable`, `ForceDelete`, `Transferable`, `RegistryLockable`, `Releasable`, `Disputable`
- Relationships: belongs to registrar and registrant, has many contacts (admin/tech), nameservers, DNSSEC records
- Tracks complex state including force delete procedures, disputes, registry locks

**Contact Model**: Represents domain contacts (registrant, admin, tech)
- Includes email verification through `EmailVerifiable` concern
- Validation against Estonian business registry for legal entities

**Registrar Model**: Manages registrar accounts and API access
- Includes `BookKeeping` concern for billing integration
- Certificate-based authentication via SSL client certificates

### Concerns Architecture

The codebase extensively uses Rails concerns to separate domain logic:
- `app/models/concerns/domain/` - 12 domain-specific concerns
- `app/models/concerns/` - Shared concerns like `Versions`, `UserEvents`, `EppErrors`, `Roids`
- Common pattern: Include `UserEvents` for audit trail, `Versions` for versioning with PaperTrail

### Background Jobs

Uses Sidekiq (`config.active_job.queue_adapter = :sidekiq`) for background processing:
- Domain lifecycle jobs (delete confirmation, expiration)
- Billing integration (Directo, e-invoice forwarding)
- External API synchronization (company register status checks)
- Email notifications and bounced email cleanup

Jobs are in `app/jobs/` and scheduled via Whenever gem (cron jobs defined in `config/schedule.rb`).

### Business Logic Layer

**Services** (`app/services/`):
- Domain services: nameserver validation, registrant changes
- Billing services: invoice processing, payment gateway integration
- AI integration: `AiReportGenerator`, `ReportRunner` for automated reporting

**Interactions** (`app/interactions/`):
- Uses `active_interaction` gem for command pattern
- Encapsulates complex business operations with validation

### Authentication & Authorization

- **Admin users**: Devise authentication
- **API users**: Certificate-based (SSL client certificates) for EPP/REPP
- **Authorization**: CanCanCan with ability definitions in `app/models/ability.rb`
- **TARA integration**: Estonian e-identity via `omniauth-tara` gem

### Estonian-Specific Integrations

This registry has deep integration with Estonian infrastructure:
- **Company Register** (`company_register` gem): Business validation
- **Isikukood** gem: Estonian personal ID validation
- **TARA**: Estonian e-identity authentication
- **DigiDoc**: Digital signature validation
- **LHV Bank**: Payment processing via LHV Connect
- **Directo**: Accounting system integration
- **E-Invoice**: Estonian e-invoicing system

### Key Configuration

- Application config: `config/application.yml` (use `config/application.yml.sample` as template)
- Database config: `config/database.yml` (use `config/database.yml.sample` as template)
- Time zone: Europe/Tallinn
- Multi-database setup requires careful connection handling
- Eager load paths: `lib/validators`, `app/lib`

### API & External Interfaces

**REPP (RESTful EPP)** - `namespace :repp do`:
- JSON API for registrar operations
- Mounted at `/repp/v1/`
- Certificate-based authentication
- Resources: contacts, domains, accounts, invoices, nameservers

**EIS Billing** - `namespace :eis_billing do`:
- Payment status callbacks
- Directo accounting integration
- E-invoice response handling
- LHV bank transaction processing

**Admin namespace** - `namespace :admin do`:
- Full administrative interface
- Mounted at `/admin`

### Testing Structure

Tests in `test/` directory:
- `fixtures/` - Test data
- `integration/` - Controller integration tests
- `models/` - Model unit tests
- `jobs/` - Background job tests
- `interactions/` - Business logic tests
- `services/` - Service object tests

System tests use `JavaScriptApplicationSystemTestCase` base class with headless Chrome.

## Important Development Notes

1. **Multi-database complexity**: Always be aware of which database connection is active. Some operations switch connections.

2. **EPP XML validation**: All EPP operations are schema-validated. Check `lib/schemas/` for valid request formats.

3. **Strong Migrations**: Uses `strong_migrations` gem - review migration safety before running.

4. **Data Migrations**: Separate from schema migrations, located in `db/data/` via `data_migrate` gem.

5. **Version tracking**: Most models use PaperTrail (`paper_trail` gem) for audit trails.

6. **Money handling**: Uses `money-rails` gem for currency operations.

7. **DNS operations**: `dnsruby` gem for DNS validation and DNSSEC operations.

8. **Internationalization**: Supports multiple locales via `config/locales/` subdirectories.

9. **Certificate authentication**: EPP/REPP require SSL client certificates configured in Apache/web server.

10. **Seed data**: Demo data in `db/seeds.rb` for development environment.

## External Documentation

- [EPP Documentation](/doc/epp)
- [EPP Request-Response Examples](/doc/epp_examples.md)
- [REPP API Documentation](https://internetee.github.io/repp-apidoc/)
- [Application Build and Update](/doc/application_build_doc.md)
- [Certificates Setup](/doc/certificates.md)