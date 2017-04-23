--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

--
-- Name: fill_ident_country(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fill_ident_country() RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
      DECLARE
        changed     BOOLEAN;
        multiplier  INT [];
        multiplier2 INT [];
        multiplier3 INT [];
        multiplier4 INT [];
        r           RECORD;
        control     TEXT;
        total       INT;
        i           INT;
        mod         INT;
        counter     INT;
      BEGIN

        multiplier  := ARRAY [1, 2, 3, 4, 5, 6, 7, 8, 9, 1];
        multiplier2 := ARRAY [3, 4, 5, 6, 7, 8, 9, 1, 2, 3];
        multiplier3 := ARRAY [1, 2, 3, 4, 5, 6, 7];
        multiplier4 := ARRAY [3, 4, 5, 6, 7, 8, 9];

        FOR r IN SELECT id, ident FROM contacts WHERE ident_type = 'priv' AND ident_country_code IS NULL
        LOOP
          IF (length(r.ident) = 11 AND (r.ident ~ '^[0-9]+$') AND (substring(r.ident, 1, 1) = '3' OR substring(r.ident, 1, 1) = '4' OR substring(r.ident, 1, 1) = '5' OR substring(r.ident, 1, 1) = '6'))
          THEN
            total := 0;
            counter := 1;
            FOREACH i IN ARRAY multiplier
            LOOP
              total := (total + (i * to_number(substring(r.ident, counter, 1), '9')));
              counter := (counter + 1);
            END LOOP;
            mod := (total % 11);
            counter := 1;
            IF (mod >= 10)
            THEN
              total = 0;
              FOREACH i IN ARRAY multiplier2
              LOOP
                total := (total + (i *  to_number(substring(r.ident, counter, 1), '9')));
                counter := (counter + 1);
              END LOOP;
              mod := (total % 11);
            END IF;
            IF (mod = 10)
              THEN
              mod := 0;
            END IF;
            IF (substring(r.ident, 11, 1) = to_char(mod, 'FM999MI'))
              THEN
                UPDATE contacts SET ident_country_code = 'EE' WHERE id = r.id;
            END IF;
            total := 0;
          END IF;
        END LOOP;

        FOR r IN SELECT id, ident FROM contacts WHERE ident_type = 'org' AND ident_country_code IS NULL
        LOOP
          IF (length(r.ident) = 8 AND (r.ident ~ '^[0-9]+$') AND (substring(r.ident, 1, 1) = '1' OR substring(r.ident, 1, 1) = '8' OR substring(r.ident, 1, 1) = '9'))
          THEN
            total := 0;
            counter := 1;
            FOREACH i IN ARRAY multiplier3
            LOOP
              total := (total + (i * to_number(substring(r.ident, counter, 1), '9')));
              counter := (counter + 1);
            END LOOP;
            mod := total % 11;
            total := 0;
            counter := 1;
            IF (mod >= 10)
            THEN
              total = 0;
              FOREACH i IN ARRAY multiplier4
              LOOP
                total := (total + (i *  to_number(substring(r.ident, counter, 1), '9')));
                counter := (counter + 1);
              END LOOP;
              mod := (total % 11);
            END IF;
            IF (mod = 10)
            THEN
              mod := 0;
            END IF;
            IF (substring(r.ident, 8, 1) = to_char(mod, 'FM999MI'))
            THEN
              UPDATE contacts SET ident_country_code = 'EE' WHERE id = r.id;
            END IF;
          END IF;
        END LOOP;
      RETURN changed;
      END;
      $_$;


--
-- Name: generate_zonefile(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION generate_zonefile(i_origin character varying) RETURNS text
    LANGUAGE plpgsql
    AS $_$
      DECLARE
        zone_header text := concat('$ORIGIN ', i_origin, '.');
        serial_num varchar;
        include_filter varchar := '';
        exclude_filter varchar := '';
        tmp_var text;
        ret text;
      BEGIN
        -- define filters
        include_filter = '%.' || i_origin;

        -- for %.%.%
        IF i_origin ~ '.' THEN
          exclude_filter := '';
        -- for %.%
        ELSE
          exclude_filter := '%.%.' || i_origin;
        END IF;

        SELECT ROUND(extract(epoch from now() at time zone 'utc')) INTO serial_num;

        -- zonefile header
        SELECT concat(
          format('%-10s', '$ORIGIN .'), chr(10),
          format('%-10s', '$TTL'), zf.ttl, chr(10), chr(10),
          format('%-10s', i_origin || '.'), 'IN SOA ', zf.master_nameserver, '. ', zf.email, '. (', chr(10),
          format('%-17s', ''), format('%-12s', serial_num), '; serial number', chr(10),
          format('%-17s', ''), format('%-12s', zf.refresh), '; refresh, seconds', chr(10),
          format('%-17s', ''), format('%-12s', zf.retry), '; retry, seconds', chr(10),
          format('%-17s', ''), format('%-12s', zf.expire), '; expire, seconds', chr(10),
          format('%-17s', ''), format('%-12s', zf.minimum_ttl), '; minimum TTL, seconds', chr(10),
          format('%-17s', ''), ')'
        ) FROM zones zf WHERE i_origin = zf.origin INTO tmp_var;

        ret = concat(tmp_var, chr(10), chr(10));

        -- origin ns records
        SELECT ns_records FROM zones zf WHERE i_origin = zf.origin INTO tmp_var;
        ret := concat(ret, '; Zone NS Records', chr(10), tmp_var, chr(10));

        -- ns records
        SELECT array_to_string(
          array(
            SELECT concat(d.name_puny, '. IN NS ', coalesce(ns.hostname_puny, ns.hostname), '.')
            FROM domains d
            JOIN nameservers ns ON ns.domain_id = d.id
            WHERE d.name LIKE include_filter AND d.name NOT LIKE exclude_filter
            AND NOT ('{serverHold,clientHold,inactive}' && d.statuses)
            ORDER BY d.name
          ),
          chr(10)
        ) INTO tmp_var;

        ret := concat(ret, tmp_var, chr(10), chr(10));

        -- origin a glue records
        SELECT a_records FROM zones zf WHERE i_origin = zf.origin INTO tmp_var;
        ret := concat(ret, '; Zone A Records', chr(10), tmp_var, chr(10));

        -- a glue records for other nameservers
        SELECT array_to_string(
          array(
            SELECT concat(coalesce(ns.hostname_puny, ns.hostname), '. IN A ', unnest(ns.ipv4))
            FROM nameservers ns
            JOIN domains d ON d.id = ns.domain_id
            WHERE d.name LIKE include_filter AND d.name NOT LIKE exclude_filter
            AND ns.hostname LIKE '%.' || d.name
            AND d.name <> i_origin
            AND ns.ipv4 IS NOT NULL AND ns.ipv4 <> '{}'
            AND NOT ('{serverHold,clientHold,inactive}' && d.statuses)
          ), chr(10)
        ) INTO tmp_var;

        ret := concat(ret, tmp_var, chr(10), chr(10));

        -- origin aaaa glue records
        SELECT a4_records FROM zones zf WHERE i_origin = zf.origin INTO tmp_var;
        ret := concat(ret, '; Zone AAAA Records', chr(10), tmp_var, chr(10));

        -- aaaa glue records for other nameservers
        SELECT array_to_string(
          array(
            SELECT concat(coalesce(ns.hostname_puny, ns.hostname), '. IN AAAA ', unnest(ns.ipv6))
            FROM nameservers ns
            JOIN domains d ON d.id = ns.domain_id
            WHERE d.name LIKE include_filter AND d.name NOT LIKE exclude_filter
            AND ns.hostname LIKE '%.' || d.name
            AND d.name <> i_origin
            AND ns.ipv6 IS NOT NULL AND ns.ipv6 <> '{}'
            AND NOT ('{serverHold,clientHold,inactive}' && d.statuses)
          ), chr(10)
        ) INTO tmp_var;

        ret := concat(ret, tmp_var, chr(10), chr(10));

        -- ds records
        SELECT array_to_string(
          array(
            SELECT concat(
              d.name_puny, '. 3600 IN DS ', dk.ds_key_tag, ' ',
              dk.ds_alg, ' ', dk.ds_digest_type, ' ', dk.ds_digest
            )
            FROM domains d
            JOIN dnskeys dk ON dk.domain_id = d.id
            WHERE d.name LIKE include_filter AND d.name NOT LIKE exclude_filter AND dk.flags = 257
            AND NOT ('{serverHold,clientHold,inactive}' && d.statuses)
            ),
          chr(10)
        ) INTO tmp_var;

        ret := concat(ret, '; Zone DS Records', chr(10), tmp_var, chr(10));

        RETURN ret;
      END;
      $_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_activities (
    id integer NOT NULL,
    account_id integer,
    invoice_id integer,
    sum numeric(10,2),
    currency character varying,
    bank_transaction_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description character varying,
    creator_str character varying,
    updator_str character varying,
    activity_type character varying,
    log_pricelist_id integer
);


--
-- Name: account_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_activities_id_seq OWNED BY account_activities.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    registrar_id integer,
    account_type character varying,
    balance numeric(10,2) DEFAULT 0.0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    currency character varying,
    creator_str character varying,
    updator_str character varying
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE addresses (
    id integer NOT NULL,
    contact_id integer,
    city character varying,
    street character varying,
    zip character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    street2 character varying,
    street3 character varying,
    creator_str character varying,
    updator_str character varying,
    country_code character varying,
    state character varying,
    legacy_contact_id integer
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE addresses_id_seq OWNED BY addresses.id;


--
-- Name: api_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE api_users (
    id integer NOT NULL,
    registrar_id integer,
    username character varying,
    password character varying,
    active boolean DEFAULT false,
    csr text,
    crt text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying
);


--
-- Name: api_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE api_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE api_users_id_seq OWNED BY api_users.id;


--
-- Name: bank_statements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bank_statements (
    id integer NOT NULL,
    bank_code character varying,
    iban character varying,
    import_file_path character varying,
    queried_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying
);


--
-- Name: bank_statements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bank_statements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_statements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bank_statements_id_seq OWNED BY bank_statements.id;


--
-- Name: bank_transactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bank_transactions (
    id integer NOT NULL,
    bank_statement_id integer,
    bank_reference character varying,
    iban character varying,
    currency character varying,
    buyer_bank_code character varying,
    buyer_iban character varying,
    buyer_name character varying,
    document_no character varying,
    description character varying,
    sum numeric(10,2),
    reference_no character varying,
    paid_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying,
    in_directo boolean DEFAULT false
);


--
-- Name: bank_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bank_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bank_transactions_id_seq OWNED BY bank_transactions.id;


--
-- Name: banklink_transactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE banklink_transactions (
    id integer NOT NULL,
    vk_service character varying,
    vk_version character varying,
    vk_snd_id character varying,
    vk_rec_id character varying,
    vk_stamp character varying,
    vk_t_no character varying,
    vk_amount numeric(10,2),
    vk_curr character varying,
    vk_rec_acc character varying,
    vk_rec_name character varying,
    vk_snd_acc character varying,
    vk_snd_name character varying,
    vk_ref character varying,
    vk_msg character varying,
    vk_t_datetime timestamp without time zone,
    vk_mac character varying,
    vk_encoding character varying,
    vk_lang character varying,
    vk_auto character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: banklink_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE banklink_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: banklink_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE banklink_transactions_id_seq OWNED BY banklink_transactions.id;


--
-- Name: blocked_domains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE blocked_domains (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying,
    name character varying
);


--
-- Name: blocked_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE blocked_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blocked_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE blocked_domains_id_seq OWNED BY blocked_domains.id;


--
-- Name: business_registry_caches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE business_registry_caches (
    id integer NOT NULL,
    ident character varying,
    ident_country_code character varying,
    retrieved_on timestamp without time zone,
    associated_businesses character varying[],
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: business_registry_caches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE business_registry_caches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: business_registry_caches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE business_registry_caches_id_seq OWNED BY business_registry_caches.id;


--
-- Name: cached_nameservers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cached_nameservers (
    hostname character varying(255),
    ipv4 character varying(255),
    ipv6 character varying(255)
);


--
-- Name: certificates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE certificates (
    id integer NOT NULL,
    api_user_id integer,
    csr text,
    crt text,
    creator_str character varying,
    updator_str character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    common_name character varying,
    md5 character varying,
    interface character varying
);


--
-- Name: certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE certificates_id_seq OWNED BY certificates.id;


--
-- Name: contact_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contact_statuses (
    id integer NOT NULL,
    value character varying,
    description character varying,
    contact_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying
);


--
-- Name: contact_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contact_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contact_statuses_id_seq OWNED BY contact_statuses.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contacts (
    id integer NOT NULL,
    code character varying,
    phone character varying,
    email character varying,
    fax character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ident character varying,
    ident_type character varying,
    auth_info character varying,
    name character varying,
    org_name character varying,
    registrar_id integer,
    creator_str character varying,
    updator_str character varying,
    ident_country_code character varying,
    city character varying,
    street text,
    zip character varying,
    country_code character varying,
    state character varying,
    legacy_id integer,
    statuses character varying[] DEFAULT '{}'::character varying[],
    status_notes hstore,
    legacy_history_id integer,
    copy_from_id integer,
    ident_updated_at timestamp without time zone,
    upid integer,
    up_date timestamp without time zone
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    iso character varying,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


--
-- Name: data_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE data_migrations (
    version character varying NOT NULL
);


--
-- Name: delegation_signers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delegation_signers (
    id integer NOT NULL,
    domain_id integer,
    key_tag character varying,
    alg integer,
    digest_type integer,
    digest character varying
);


--
-- Name: delegation_signers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delegation_signers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delegation_signers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delegation_signers_id_seq OWNED BY delegation_signers.id;


--
-- Name: depricated_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE depricated_versions (
    id integer NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: depricated_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE depricated_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: depricated_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE depricated_versions_id_seq OWNED BY depricated_versions.id;


--
-- Name: directos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE directos (
    id integer NOT NULL,
    item_id integer,
    item_type character varying,
    response json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    invoice_number character varying,
    request text
);


--
-- Name: directos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE directos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: directos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE directos_id_seq OWNED BY directos.id;


--
-- Name: dnskeys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE dnskeys (
    id integer NOT NULL,
    domain_id integer,
    flags integer,
    protocol integer,
    alg integer,
    public_key text,
    delegation_signer_id integer,
    ds_key_tag character varying,
    ds_alg integer,
    ds_digest_type integer,
    ds_digest character varying,
    creator_str character varying,
    updator_str character varying,
    legacy_domain_id integer,
    updated_at timestamp without time zone
);


--
-- Name: dnskeys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dnskeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dnskeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dnskeys_id_seq OWNED BY dnskeys.id;


--
-- Name: domain_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE domain_contacts (
    id integer NOT NULL,
    contact_id integer,
    domain_id integer,
    contact_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    contact_code_cache character varying,
    creator_str character varying,
    updator_str character varying,
    type character varying,
    legacy_domain_id integer,
    legacy_contact_id integer
);


--
-- Name: domain_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE domain_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: domain_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE domain_contacts_id_seq OWNED BY domain_contacts.id;


--
-- Name: domain_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE domain_statuses (
    id integer NOT NULL,
    domain_id integer,
    description character varying,
    value character varying,
    creator_str character varying,
    updator_str character varying,
    legacy_domain_id integer
);


--
-- Name: domain_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE domain_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: domain_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE domain_statuses_id_seq OWNED BY domain_statuses.id;


--
-- Name: domain_transfers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE domain_transfers (
    id integer NOT NULL,
    domain_id integer,
    status character varying,
    transfer_requested_at timestamp without time zone,
    transferred_at timestamp without time zone,
    transfer_from_id integer,
    transfer_to_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    wait_until timestamp without time zone,
    creator_str character varying,
    updator_str character varying
);


--
-- Name: domain_transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE domain_transfers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: domain_transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE domain_transfers_id_seq OWNED BY domain_transfers.id;


--
-- Name: domains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE domains (
    id integer NOT NULL,
    name character varying,
    registrar_id integer,
    registered_at timestamp without time zone,
    status character varying,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    registrant_id integer,
    auth_info character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name_dirty character varying,
    name_puny character varying,
    period integer,
    period_unit character varying(1),
    creator_str character varying,
    updator_str character varying,
    legacy_id integer,
    legacy_registrar_id integer,
    legacy_registrant_id integer,
    outzone_at timestamp without time zone,
    delete_at timestamp without time zone,
    registrant_verification_asked_at timestamp without time zone,
    registrant_verification_token character varying,
    pending_json json,
    force_delete_at timestamp without time zone,
    statuses character varying[],
    reserved boolean DEFAULT false,
    status_notes hstore,
    statuses_backup character varying[] DEFAULT '{}'::character varying[],
    upid integer,
    up_date timestamp without time zone
);


--
-- Name: domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE domains_id_seq OWNED BY domains.id;


--
-- Name: epp_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE epp_sessions (
    id integer NOT NULL,
    session_id character varying,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    registrar_id integer
);


--
-- Name: epp_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE epp_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: epp_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE epp_sessions_id_seq OWNED BY epp_sessions.id;


--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE invoice_items (
    id integer NOT NULL,
    invoice_id integer,
    description character varying NOT NULL,
    unit character varying,
    amount integer,
    price numeric(10,2),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying
);


--
-- Name: invoice_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE invoice_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE invoice_items_id_seq OWNED BY invoice_items.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE invoices (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    invoice_type character varying NOT NULL,
    due_date timestamp without time zone NOT NULL,
    payment_term character varying,
    currency character varying NOT NULL,
    description character varying,
    reference_no character varying,
    vat_prc numeric(10,2) NOT NULL,
    paid_at timestamp without time zone,
    seller_id integer,
    seller_name character varying NOT NULL,
    seller_reg_no character varying,
    seller_iban character varying NOT NULL,
    seller_bank character varying,
    seller_swift character varying,
    seller_vat_no character varying,
    seller_country_code character varying,
    seller_state character varying,
    seller_street character varying,
    seller_city character varying,
    seller_zip character varying,
    seller_phone character varying,
    seller_url character varying,
    seller_email character varying,
    seller_contact_name character varying,
    buyer_id integer,
    buyer_name character varying NOT NULL,
    buyer_reg_no character varying,
    buyer_country_code character varying,
    buyer_state character varying,
    buyer_street character varying,
    buyer_city character varying,
    buyer_zip character varying,
    buyer_phone character varying,
    buyer_url character varying,
    buyer_email character varying,
    creator_str character varying,
    updator_str character varying,
    number integer,
    cancelled_at timestamp without time zone,
    sum_cache numeric(10,2),
    in_directo boolean DEFAULT false
);


--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE invoices_id_seq OWNED BY invoices.id;


--
-- Name: keyrelays; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE keyrelays (
    id integer NOT NULL,
    domain_id integer,
    pa_date timestamp without time zone,
    key_data_flags character varying,
    key_data_protocol character varying,
    key_data_alg character varying,
    key_data_public_key text,
    auth_info_pw character varying,
    expiry_relative character varying,
    expiry_absolute timestamp without time zone,
    requester_id integer,
    accepter_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying
);


--
-- Name: keyrelays_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE keyrelays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: keyrelays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE keyrelays_id_seq OWNED BY keyrelays.id;


--
-- Name: legal_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE legal_documents (
    id integer NOT NULL,
    document_type character varying,
    documentable_id integer,
    documentable_type character varying,
    created_at timestamp without time zone,
    creator_str character varying,
    path character varying,
    checksum character varying
);


--
-- Name: legal_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE legal_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: legal_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE legal_documents_id_seq OWNED BY legal_documents.id;


--
-- Name: log_account_activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_account_activities (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_account_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_account_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_account_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_account_activities_id_seq OWNED BY log_account_activities.id;


--
-- Name: log_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_accounts (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_accounts_id_seq OWNED BY log_accounts.id;


--
-- Name: log_addresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_addresses (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_addresses_id_seq OWNED BY log_addresses.id;


--
-- Name: log_api_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_api_users (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_api_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_api_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_api_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_api_users_id_seq OWNED BY log_api_users.id;


--
-- Name: log_bank_statements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_bank_statements (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_bank_statements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_bank_statements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_bank_statements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_bank_statements_id_seq OWNED BY log_bank_statements.id;


--
-- Name: log_bank_transactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_bank_transactions (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_bank_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_bank_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_bank_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_bank_transactions_id_seq OWNED BY log_bank_transactions.id;


--
-- Name: log_blocked_domains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_blocked_domains (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_blocked_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_blocked_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_blocked_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_blocked_domains_id_seq OWNED BY log_blocked_domains.id;


--
-- Name: log_certificates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_certificates (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_certificates_id_seq OWNED BY log_certificates.id;


--
-- Name: log_contact_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_contact_statuses (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_contact_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_contact_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_contact_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_contact_statuses_id_seq OWNED BY log_contact_statuses.id;


--
-- Name: log_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_contacts (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object jsonb,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    ident_updated_at timestamp without time zone,
    uuid character varying
);


--
-- Name: log_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_contacts_id_seq OWNED BY log_contacts.id;


--
-- Name: log_countries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_countries (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_countries_id_seq OWNED BY log_countries.id;


--
-- Name: log_dnskeys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_dnskeys (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object jsonb,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_dnskeys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_dnskeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_dnskeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_dnskeys_id_seq OWNED BY log_dnskeys.id;


--
-- Name: log_domain_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_domain_contacts (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_domain_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_domain_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_domain_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_domain_contacts_id_seq OWNED BY log_domain_contacts.id;


--
-- Name: log_domain_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_domain_statuses (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_domain_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_domain_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_domain_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_domain_statuses_id_seq OWNED BY log_domain_statuses.id;


--
-- Name: log_domain_transfers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_domain_transfers (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_domain_transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_domain_transfers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_domain_transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_domain_transfers_id_seq OWNED BY log_domain_transfers.id;


--
-- Name: log_domains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_domains (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object jsonb,
    object_changes json,
    created_at timestamp without time zone,
    nameserver_ids text[] DEFAULT '{}'::text[],
    tech_contact_ids text[] DEFAULT '{}'::text[],
    admin_contact_ids text[] DEFAULT '{}'::text[],
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_domains_id_seq OWNED BY log_domains.id;


--
-- Name: log_invoice_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_invoice_items (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_invoice_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_invoice_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_invoice_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_invoice_items_id_seq OWNED BY log_invoice_items.id;


--
-- Name: log_invoices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_invoices (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_invoices_id_seq OWNED BY log_invoices.id;


--
-- Name: log_keyrelays; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_keyrelays (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_keyrelays_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_keyrelays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_keyrelays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_keyrelays_id_seq OWNED BY log_keyrelays.id;


--
-- Name: log_messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_messages (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_messages_id_seq OWNED BY log_messages.id;


--
-- Name: log_nameservers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_nameservers (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object jsonb,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_nameservers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_nameservers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_nameservers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_nameservers_id_seq OWNED BY log_nameservers.id;


--
-- Name: log_pricelists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_pricelists (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    uuid character varying
);


--
-- Name: log_pricelists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_pricelists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_pricelists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_pricelists_id_seq OWNED BY log_pricelists.id;


--
-- Name: log_registrars; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_registrars (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_registrars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_registrars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_registrars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_registrars_id_seq OWNED BY log_registrars.id;


--
-- Name: log_reserved_domains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_reserved_domains (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_reserved_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_reserved_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_reserved_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_reserved_domains_id_seq OWNED BY log_reserved_domains.id;


--
-- Name: log_settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_settings (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_settings_id_seq OWNED BY log_settings.id;


--
-- Name: log_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_users (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_users_id_seq OWNED BY log_users.id;


--
-- Name: log_white_ips; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_white_ips (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object json,
    object_changes json,
    created_at timestamp without time zone,
    session character varying,
    children json,
    uuid character varying
);


--
-- Name: log_white_ips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_white_ips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_white_ips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_white_ips_id_seq OWNED BY log_white_ips.id;


--
-- Name: mail_templates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mail_templates (
    id integer NOT NULL,
    name character varying NOT NULL,
    subject character varying,
    "from" character varying,
    bcc character varying,
    cc character varying,
    body text NOT NULL,
    text_body text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: mail_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mail_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mail_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mail_templates_id_seq OWNED BY mail_templates.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE messages (
    id integer NOT NULL,
    registrar_id integer,
    body character varying,
    attached_obj_type character varying,
    attached_obj_id character varying,
    queued boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: nameservers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nameservers (
    id integer NOT NULL,
    hostname character varying,
    ipv4 character varying[] DEFAULT '{}'::character varying[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ipv6 character varying[] DEFAULT '{}'::character varying[],
    domain_id integer,
    creator_str character varying,
    updator_str character varying,
    legacy_domain_id integer,
    hostname_puny character varying
);


--
-- Name: nameservers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nameservers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nameservers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nameservers_id_seq OWNED BY nameservers.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE people (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE people_id_seq OWNED BY people.id;


--
-- Name: pricelists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pricelists (
    id integer NOT NULL,
    "desc" character varying,
    category character varying,
    price_cents numeric(10,2) DEFAULT 0.0 NOT NULL,
    price_currency character varying DEFAULT 'EUR'::character varying NOT NULL,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    creator_str character varying,
    updator_str character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    duration interval,
    operation_category character varying
);


--
-- Name: pricelists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pricelists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pricelists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pricelists_id_seq OWNED BY pricelists.id;


--
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE que_jobs (
    priority smallint DEFAULT 100 NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    job_id bigint NOT NULL,
    job_class text NOT NULL,
    args json DEFAULT '[]'::json NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    last_error text,
    queue text DEFAULT ''::text NOT NULL
);


--
-- Name: TABLE que_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE que_jobs IS '3';


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE que_jobs_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE que_jobs_job_id_seq OWNED BY que_jobs.job_id;


--
-- Name: registrant_verifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE registrant_verifications (
    id integer NOT NULL,
    domain_name character varying,
    verification_token character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    action character varying,
    domain_id integer,
    action_type character varying
);


--
-- Name: registrant_verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE registrant_verifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registrant_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE registrant_verifications_id_seq OWNED BY registrant_verifications.id;


--
-- Name: registrars; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE registrars (
    id integer NOT NULL,
    name character varying,
    reg_no character varying,
    vat_no character varying,
    billing_address character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying,
    phone character varying,
    email character varying,
    billing_email character varying,
    country_code character varying,
    state character varying,
    city character varying,
    street character varying,
    zip character varying,
    code character varying,
    website character varying,
    directo_handle character varying,
    vat boolean,
    legacy_id integer,
    reference_no character varying,
    exclude_in_monthly_directo boolean DEFAULT false,
    test_registrar boolean DEFAULT false
);


--
-- Name: registrars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE registrars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registrars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE registrars_id_seq OWNED BY registrars.id;


--
-- Name: reserved_domains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reserved_domains (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying,
    legacy_id integer,
    name character varying,
    password character varying
);


--
-- Name: reserved_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reserved_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reserved_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reserved_domains_id_seq OWNED BY reserved_domains.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    var character varying NOT NULL,
    value text,
    thing_id integer,
    thing_type character varying(30),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    username character varying,
    password character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    email character varying,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    identity_code character varying,
    roles character varying[],
    creator_str character varying,
    updator_str character varying,
    country_code character varying,
    registrar_id integer,
    active boolean,
    csr text,
    crt text,
    type character varying,
    registrant_ident character varying,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    remember_created_at timestamp without time zone,
    failed_attempts integer DEFAULT 0 NOT NULL,
    locked_at timestamp without time zone,
    legacy_id integer
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    depricated_table_but_somehow_paper_trail_tests_fails_without_it text
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: white_ips; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE white_ips (
    id integer NOT NULL,
    registrar_id integer,
    ipv4 character varying,
    ipv6 character varying,
    interfaces character varying[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying
);


--
-- Name: white_ips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE white_ips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: white_ips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE white_ips_id_seq OWNED BY white_ips.id;


--
-- Name: whois_records; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE whois_records (
    id integer NOT NULL,
    domain_id integer,
    name character varying,
    body text,
    json json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    registrar_id integer
);


--
-- Name: whois_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE whois_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: whois_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE whois_records_id_seq OWNED BY whois_records.id;


--
-- Name: zones; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zones (
    id integer NOT NULL,
    origin character varying,
    ttl integer,
    refresh integer,
    retry integer,
    expire integer,
    minimum_ttl integer,
    email character varying,
    master_nameserver character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying,
    ns_records text,
    a_records text,
    a4_records text
);


--
-- Name: zones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE zones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE zones_id_seq OWNED BY zones.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_activities ALTER COLUMN id SET DEFAULT nextval('account_activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses ALTER COLUMN id SET DEFAULT nextval('addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_users ALTER COLUMN id SET DEFAULT nextval('api_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bank_statements ALTER COLUMN id SET DEFAULT nextval('bank_statements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bank_transactions ALTER COLUMN id SET DEFAULT nextval('bank_transactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY banklink_transactions ALTER COLUMN id SET DEFAULT nextval('banklink_transactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY blocked_domains ALTER COLUMN id SET DEFAULT nextval('blocked_domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY business_registry_caches ALTER COLUMN id SET DEFAULT nextval('business_registry_caches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY certificates ALTER COLUMN id SET DEFAULT nextval('certificates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_statuses ALTER COLUMN id SET DEFAULT nextval('contact_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation_signers ALTER COLUMN id SET DEFAULT nextval('delegation_signers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY depricated_versions ALTER COLUMN id SET DEFAULT nextval('depricated_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY directos ALTER COLUMN id SET DEFAULT nextval('directos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dnskeys ALTER COLUMN id SET DEFAULT nextval('dnskeys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY domain_contacts ALTER COLUMN id SET DEFAULT nextval('domain_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY domain_statuses ALTER COLUMN id SET DEFAULT nextval('domain_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY domain_transfers ALTER COLUMN id SET DEFAULT nextval('domain_transfers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY domains ALTER COLUMN id SET DEFAULT nextval('domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY epp_sessions ALTER COLUMN id SET DEFAULT nextval('epp_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invoice_items ALTER COLUMN id SET DEFAULT nextval('invoice_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invoices ALTER COLUMN id SET DEFAULT nextval('invoices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY keyrelays ALTER COLUMN id SET DEFAULT nextval('keyrelays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY legal_documents ALTER COLUMN id SET DEFAULT nextval('legal_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_account_activities ALTER COLUMN id SET DEFAULT nextval('log_account_activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_accounts ALTER COLUMN id SET DEFAULT nextval('log_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_addresses ALTER COLUMN id SET DEFAULT nextval('log_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_api_users ALTER COLUMN id SET DEFAULT nextval('log_api_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_bank_statements ALTER COLUMN id SET DEFAULT nextval('log_bank_statements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_bank_transactions ALTER COLUMN id SET DEFAULT nextval('log_bank_transactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_blocked_domains ALTER COLUMN id SET DEFAULT nextval('log_blocked_domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_certificates ALTER COLUMN id SET DEFAULT nextval('log_certificates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_contact_statuses ALTER COLUMN id SET DEFAULT nextval('log_contact_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_contacts ALTER COLUMN id SET DEFAULT nextval('log_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_countries ALTER COLUMN id SET DEFAULT nextval('log_countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_dnskeys ALTER COLUMN id SET DEFAULT nextval('log_dnskeys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_domain_contacts ALTER COLUMN id SET DEFAULT nextval('log_domain_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_domain_statuses ALTER COLUMN id SET DEFAULT nextval('log_domain_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_domain_transfers ALTER COLUMN id SET DEFAULT nextval('log_domain_transfers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_domains ALTER COLUMN id SET DEFAULT nextval('log_domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_invoice_items ALTER COLUMN id SET DEFAULT nextval('log_invoice_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_invoices ALTER COLUMN id SET DEFAULT nextval('log_invoices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_keyrelays ALTER COLUMN id SET DEFAULT nextval('log_keyrelays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_messages ALTER COLUMN id SET DEFAULT nextval('log_messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_nameservers ALTER COLUMN id SET DEFAULT nextval('log_nameservers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_pricelists ALTER COLUMN id SET DEFAULT nextval('log_pricelists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_registrars ALTER COLUMN id SET DEFAULT nextval('log_registrars_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_reserved_domains ALTER COLUMN id SET DEFAULT nextval('log_reserved_domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_settings ALTER COLUMN id SET DEFAULT nextval('log_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_users ALTER COLUMN id SET DEFAULT nextval('log_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_white_ips ALTER COLUMN id SET DEFAULT nextval('log_white_ips_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mail_templates ALTER COLUMN id SET DEFAULT nextval('mail_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nameservers ALTER COLUMN id SET DEFAULT nextval('nameservers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pricelists ALTER COLUMN id SET DEFAULT nextval('pricelists_id_seq'::regclass);


--
-- Name: job_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs ALTER COLUMN job_id SET DEFAULT nextval('que_jobs_job_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY registrant_verifications ALTER COLUMN id SET DEFAULT nextval('registrant_verifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY registrars ALTER COLUMN id SET DEFAULT nextval('registrars_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reserved_domains ALTER COLUMN id SET DEFAULT nextval('reserved_domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY white_ips ALTER COLUMN id SET DEFAULT nextval('white_ips_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY whois_records ALTER COLUMN id SET DEFAULT nextval('whois_records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY zones ALTER COLUMN id SET DEFAULT nextval('zones_id_seq'::regclass);


--
-- Name: account_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_activities
    ADD CONSTRAINT account_activities_pkey PRIMARY KEY (id);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: api_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_users
    ADD CONSTRAINT api_users_pkey PRIMARY KEY (id);


--
-- Name: bank_statements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bank_statements
    ADD CONSTRAINT bank_statements_pkey PRIMARY KEY (id);


--
-- Name: bank_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bank_transactions
    ADD CONSTRAINT bank_transactions_pkey PRIMARY KEY (id);


--
-- Name: banklink_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY banklink_transactions
    ADD CONSTRAINT banklink_transactions_pkey PRIMARY KEY (id);


--
-- Name: blocked_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY blocked_domains
    ADD CONSTRAINT blocked_domains_pkey PRIMARY KEY (id);


--
-- Name: business_registry_caches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY business_registry_caches
    ADD CONSTRAINT business_registry_caches_pkey PRIMARY KEY (id);


--
-- Name: certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);


--
-- Name: contact_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contact_statuses
    ADD CONSTRAINT contact_statuses_pkey PRIMARY KEY (id);


--
-- Name: contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: delegation_signers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delegation_signers
    ADD CONSTRAINT delegation_signers_pkey PRIMARY KEY (id);


--
-- Name: depricated_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY depricated_versions
    ADD CONSTRAINT depricated_versions_pkey PRIMARY KEY (id);


--
-- Name: directos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY directos
    ADD CONSTRAINT directos_pkey PRIMARY KEY (id);


--
-- Name: dnskeys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dnskeys
    ADD CONSTRAINT dnskeys_pkey PRIMARY KEY (id);


--
-- Name: domain_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY domain_contacts
    ADD CONSTRAINT domain_contacts_pkey PRIMARY KEY (id);


--
-- Name: domain_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY domain_statuses
    ADD CONSTRAINT domain_statuses_pkey PRIMARY KEY (id);


--
-- Name: domain_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY domain_transfers
    ADD CONSTRAINT domain_transfers_pkey PRIMARY KEY (id);


--
-- Name: domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY domains
    ADD CONSTRAINT domains_pkey PRIMARY KEY (id);


--
-- Name: epp_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY epp_sessions
    ADD CONSTRAINT epp_sessions_pkey PRIMARY KEY (id);


--
-- Name: invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: keyrelays_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY keyrelays
    ADD CONSTRAINT keyrelays_pkey PRIMARY KEY (id);


--
-- Name: legal_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY legal_documents
    ADD CONSTRAINT legal_documents_pkey PRIMARY KEY (id);


--
-- Name: log_account_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_account_activities
    ADD CONSTRAINT log_account_activities_pkey PRIMARY KEY (id);


--
-- Name: log_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_accounts
    ADD CONSTRAINT log_accounts_pkey PRIMARY KEY (id);


--
-- Name: log_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_addresses
    ADD CONSTRAINT log_addresses_pkey PRIMARY KEY (id);


--
-- Name: log_api_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_api_users
    ADD CONSTRAINT log_api_users_pkey PRIMARY KEY (id);


--
-- Name: log_bank_statements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_bank_statements
    ADD CONSTRAINT log_bank_statements_pkey PRIMARY KEY (id);


--
-- Name: log_bank_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_bank_transactions
    ADD CONSTRAINT log_bank_transactions_pkey PRIMARY KEY (id);


--
-- Name: log_blocked_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_blocked_domains
    ADD CONSTRAINT log_blocked_domains_pkey PRIMARY KEY (id);


--
-- Name: log_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_certificates
    ADD CONSTRAINT log_certificates_pkey PRIMARY KEY (id);


--
-- Name: log_contact_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_contact_statuses
    ADD CONSTRAINT log_contact_statuses_pkey PRIMARY KEY (id);


--
-- Name: log_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_contacts
    ADD CONSTRAINT log_contacts_pkey PRIMARY KEY (id);


--
-- Name: log_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_countries
    ADD CONSTRAINT log_countries_pkey PRIMARY KEY (id);


--
-- Name: log_dnskeys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_dnskeys
    ADD CONSTRAINT log_dnskeys_pkey PRIMARY KEY (id);


--
-- Name: log_domain_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_domain_contacts
    ADD CONSTRAINT log_domain_contacts_pkey PRIMARY KEY (id);


--
-- Name: log_domain_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_domain_statuses
    ADD CONSTRAINT log_domain_statuses_pkey PRIMARY KEY (id);


--
-- Name: log_domain_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_domain_transfers
    ADD CONSTRAINT log_domain_transfers_pkey PRIMARY KEY (id);


--
-- Name: log_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_domains
    ADD CONSTRAINT log_domains_pkey PRIMARY KEY (id);


--
-- Name: log_invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_invoice_items
    ADD CONSTRAINT log_invoice_items_pkey PRIMARY KEY (id);


--
-- Name: log_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_invoices
    ADD CONSTRAINT log_invoices_pkey PRIMARY KEY (id);


--
-- Name: log_keyrelays_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_keyrelays
    ADD CONSTRAINT log_keyrelays_pkey PRIMARY KEY (id);


--
-- Name: log_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_messages
    ADD CONSTRAINT log_messages_pkey PRIMARY KEY (id);


--
-- Name: log_nameservers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_nameservers
    ADD CONSTRAINT log_nameservers_pkey PRIMARY KEY (id);


--
-- Name: log_pricelists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_pricelists
    ADD CONSTRAINT log_pricelists_pkey PRIMARY KEY (id);


--
-- Name: log_registrars_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_registrars
    ADD CONSTRAINT log_registrars_pkey PRIMARY KEY (id);


--
-- Name: log_reserved_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_reserved_domains
    ADD CONSTRAINT log_reserved_domains_pkey PRIMARY KEY (id);


--
-- Name: log_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_settings
    ADD CONSTRAINT log_settings_pkey PRIMARY KEY (id);


--
-- Name: log_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_users
    ADD CONSTRAINT log_users_pkey PRIMARY KEY (id);


--
-- Name: log_white_ips_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_white_ips
    ADD CONSTRAINT log_white_ips_pkey PRIMARY KEY (id);


--
-- Name: mail_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mail_templates
    ADD CONSTRAINT mail_templates_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: nameservers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nameservers
    ADD CONSTRAINT nameservers_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: pricelists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pricelists
    ADD CONSTRAINT pricelists_pkey PRIMARY KEY (id);


--
-- Name: que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (queue, priority, run_at, job_id);


--
-- Name: registrant_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY registrant_verifications
    ADD CONSTRAINT registrant_verifications_pkey PRIMARY KEY (id);


--
-- Name: registrars_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY registrars
    ADD CONSTRAINT registrars_pkey PRIMARY KEY (id);


--
-- Name: reserved_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reserved_domains
    ADD CONSTRAINT reserved_domains_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: white_ips_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY white_ips
    ADD CONSTRAINT white_ips_pkey PRIMARY KEY (id);


--
-- Name: whois_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY whois_records
    ADD CONSTRAINT whois_records_pkey PRIMARY KEY (id);


--
-- Name: zones_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY zones
    ADD CONSTRAINT zones_pkey PRIMARY KEY (id);


--
-- Name: index_account_activities_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_activities_on_account_id ON account_activities USING btree (account_id);


--
-- Name: index_account_activities_on_bank_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_activities_on_bank_transaction_id ON account_activities USING btree (bank_transaction_id);


--
-- Name: index_account_activities_on_invoice_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_activities_on_invoice_id ON account_activities USING btree (invoice_id);


--
-- Name: index_accounts_on_registrar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_registrar_id ON accounts USING btree (registrar_id);


--
-- Name: index_api_users_on_registrar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_api_users_on_registrar_id ON api_users USING btree (registrar_id);


--
-- Name: index_blocked_domains_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_blocked_domains_on_name ON blocked_domains USING btree (name);


--
-- Name: index_business_registry_caches_on_ident; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_business_registry_caches_on_ident ON business_registry_caches USING btree (ident);


--
-- Name: index_cached_nameservers_on_hostname_and_ipv4_and_ipv6; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_cached_nameservers_on_hostname_and_ipv4_and_ipv6 ON cached_nameservers USING btree (hostname, ipv4, ipv6);


--
-- Name: index_certificates_on_api_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_certificates_on_api_user_id ON certificates USING btree (api_user_id);


--
-- Name: index_contact_statuses_on_contact_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contact_statuses_on_contact_id ON contact_statuses USING btree (contact_id);


--
-- Name: index_contacts_on_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_code ON contacts USING btree (code);


--
-- Name: index_contacts_on_registrar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_registrar_id ON contacts USING btree (registrar_id);


--
-- Name: index_contacts_on_registrar_id_and_ident_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_registrar_id_and_ident_type ON contacts USING btree (registrar_id, ident_type);


--
-- Name: index_delegation_signers_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_delegation_signers_on_domain_id ON delegation_signers USING btree (domain_id);


--
-- Name: index_directos_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_directos_on_item_type_and_item_id ON directos USING btree (item_type, item_id);


--
-- Name: index_dnskeys_on_delegation_signer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dnskeys_on_delegation_signer_id ON dnskeys USING btree (delegation_signer_id);


--
-- Name: index_dnskeys_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dnskeys_on_domain_id ON dnskeys USING btree (domain_id);


--
-- Name: index_dnskeys_on_legacy_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dnskeys_on_legacy_domain_id ON dnskeys USING btree (legacy_domain_id);


--
-- Name: index_domain_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domain_contacts_on_contact_id ON domain_contacts USING btree (contact_id);


--
-- Name: index_domain_contacts_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domain_contacts_on_domain_id ON domain_contacts USING btree (domain_id);


--
-- Name: index_domain_statuses_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domain_statuses_on_domain_id ON domain_statuses USING btree (domain_id);


--
-- Name: index_domain_transfers_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domain_transfers_on_domain_id ON domain_transfers USING btree (domain_id);


--
-- Name: index_domains_on_delete_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_delete_at ON domains USING btree (delete_at);


--
-- Name: index_domains_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_domains_on_name ON domains USING btree (name);


--
-- Name: index_domains_on_outzone_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_outzone_at ON domains USING btree (outzone_at);


--
-- Name: index_domains_on_registrant_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_registrant_id ON domains USING btree (registrant_id);


--
-- Name: index_domains_on_registrant_verification_asked_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_registrant_verification_asked_at ON domains USING btree (registrant_verification_asked_at);


--
-- Name: index_domains_on_registrant_verification_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_registrant_verification_token ON domains USING btree (registrant_verification_token);


--
-- Name: index_domains_on_registrar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_registrar_id ON domains USING btree (registrar_id);


--
-- Name: index_domains_on_statuses; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_statuses ON domains USING gin (statuses);


--
-- Name: index_epp_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_epp_sessions_on_session_id ON epp_sessions USING btree (session_id);


--
-- Name: index_epp_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_epp_sessions_on_updated_at ON epp_sessions USING btree (updated_at);


--
-- Name: index_invoice_items_on_invoice_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invoice_items_on_invoice_id ON invoice_items USING btree (invoice_id);


--
-- Name: index_invoices_on_buyer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invoices_on_buyer_id ON invoices USING btree (buyer_id);


--
-- Name: index_invoices_on_seller_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invoices_on_seller_id ON invoices USING btree (seller_id);


--
-- Name: index_keyrelays_on_accepter_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keyrelays_on_accepter_id ON keyrelays USING btree (accepter_id);


--
-- Name: index_keyrelays_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keyrelays_on_domain_id ON keyrelays USING btree (domain_id);


--
-- Name: index_keyrelays_on_requester_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keyrelays_on_requester_id ON keyrelays USING btree (requester_id);


--
-- Name: index_legal_documents_on_checksum; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_legal_documents_on_checksum ON legal_documents USING btree (checksum);


--
-- Name: index_legal_documents_on_documentable_type_and_documentable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_legal_documents_on_documentable_type_and_documentable_id ON legal_documents USING btree (documentable_type, documentable_id);


--
-- Name: index_log_account_activities_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_account_activities_on_item_type_and_item_id ON log_account_activities USING btree (item_type, item_id);


--
-- Name: index_log_account_activities_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_account_activities_on_whodunnit ON log_account_activities USING btree (whodunnit);


--
-- Name: index_log_accounts_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_accounts_on_item_type_and_item_id ON log_accounts USING btree (item_type, item_id);


--
-- Name: index_log_accounts_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_accounts_on_whodunnit ON log_accounts USING btree (whodunnit);


--
-- Name: index_log_addresses_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_addresses_on_item_type_and_item_id ON log_addresses USING btree (item_type, item_id);


--
-- Name: index_log_addresses_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_addresses_on_whodunnit ON log_addresses USING btree (whodunnit);


--
-- Name: index_log_api_users_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_api_users_on_item_type_and_item_id ON log_api_users USING btree (item_type, item_id);


--
-- Name: index_log_api_users_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_api_users_on_whodunnit ON log_api_users USING btree (whodunnit);


--
-- Name: index_log_bank_statements_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bank_statements_on_item_type_and_item_id ON log_bank_statements USING btree (item_type, item_id);


--
-- Name: index_log_bank_statements_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bank_statements_on_whodunnit ON log_bank_statements USING btree (whodunnit);


--
-- Name: index_log_bank_transactions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bank_transactions_on_item_type_and_item_id ON log_bank_transactions USING btree (item_type, item_id);


--
-- Name: index_log_bank_transactions_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bank_transactions_on_whodunnit ON log_bank_transactions USING btree (whodunnit);


--
-- Name: index_log_blocked_domains_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_blocked_domains_on_item_type_and_item_id ON log_blocked_domains USING btree (item_type, item_id);


--
-- Name: index_log_blocked_domains_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_blocked_domains_on_whodunnit ON log_blocked_domains USING btree (whodunnit);


--
-- Name: index_log_certificates_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_certificates_on_item_type_and_item_id ON log_certificates USING btree (item_type, item_id);


--
-- Name: index_log_certificates_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_certificates_on_whodunnit ON log_certificates USING btree (whodunnit);


--
-- Name: index_log_contact_statuses_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_contact_statuses_on_item_type_and_item_id ON log_contact_statuses USING btree (item_type, item_id);


--
-- Name: index_log_contact_statuses_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_contact_statuses_on_whodunnit ON log_contact_statuses USING btree (whodunnit);


--
-- Name: index_log_contacts_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_contacts_on_item_type_and_item_id ON log_contacts USING btree (item_type, item_id);


--
-- Name: index_log_contacts_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_contacts_on_whodunnit ON log_contacts USING btree (whodunnit);


--
-- Name: index_log_countries_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_countries_on_item_type_and_item_id ON log_countries USING btree (item_type, item_id);


--
-- Name: index_log_countries_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_countries_on_whodunnit ON log_countries USING btree (whodunnit);


--
-- Name: index_log_dnskeys_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_dnskeys_on_item_type_and_item_id ON log_dnskeys USING btree (item_type, item_id);


--
-- Name: index_log_dnskeys_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_dnskeys_on_whodunnit ON log_dnskeys USING btree (whodunnit);


--
-- Name: index_log_domain_contacts_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_domain_contacts_on_item_type_and_item_id ON log_domain_contacts USING btree (item_type, item_id);


--
-- Name: index_log_domain_contacts_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_domain_contacts_on_whodunnit ON log_domain_contacts USING btree (whodunnit);


--
-- Name: index_log_domain_statuses_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_domain_statuses_on_item_type_and_item_id ON log_domain_statuses USING btree (item_type, item_id);


--
-- Name: index_log_domain_statuses_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_domain_statuses_on_whodunnit ON log_domain_statuses USING btree (whodunnit);


--
-- Name: index_log_domain_transfers_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_domain_transfers_on_item_type_and_item_id ON log_domain_transfers USING btree (item_type, item_id);


--
-- Name: index_log_domain_transfers_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_domain_transfers_on_whodunnit ON log_domain_transfers USING btree (whodunnit);


--
-- Name: index_log_domains_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_domains_on_item_type_and_item_id ON log_domains USING btree (item_type, item_id);


--
-- Name: index_log_domains_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_domains_on_whodunnit ON log_domains USING btree (whodunnit);


--
-- Name: index_log_invoice_items_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_invoice_items_on_item_type_and_item_id ON log_invoice_items USING btree (item_type, item_id);


--
-- Name: index_log_invoice_items_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_invoice_items_on_whodunnit ON log_invoice_items USING btree (whodunnit);


--
-- Name: index_log_invoices_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_invoices_on_item_type_and_item_id ON log_invoices USING btree (item_type, item_id);


--
-- Name: index_log_invoices_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_invoices_on_whodunnit ON log_invoices USING btree (whodunnit);


--
-- Name: index_log_keyrelays_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_keyrelays_on_item_type_and_item_id ON log_keyrelays USING btree (item_type, item_id);


--
-- Name: index_log_keyrelays_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_keyrelays_on_whodunnit ON log_keyrelays USING btree (whodunnit);


--
-- Name: index_log_messages_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_messages_on_item_type_and_item_id ON log_messages USING btree (item_type, item_id);


--
-- Name: index_log_messages_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_messages_on_whodunnit ON log_messages USING btree (whodunnit);


--
-- Name: index_log_nameservers_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_nameservers_on_item_type_and_item_id ON log_nameservers USING btree (item_type, item_id);


--
-- Name: index_log_nameservers_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_nameservers_on_whodunnit ON log_nameservers USING btree (whodunnit);


--
-- Name: index_log_registrars_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_registrars_on_item_type_and_item_id ON log_registrars USING btree (item_type, item_id);


--
-- Name: index_log_registrars_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_registrars_on_whodunnit ON log_registrars USING btree (whodunnit);


--
-- Name: index_log_reserved_domains_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_reserved_domains_on_item_type_and_item_id ON log_reserved_domains USING btree (item_type, item_id);


--
-- Name: index_log_reserved_domains_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_reserved_domains_on_whodunnit ON log_reserved_domains USING btree (whodunnit);


--
-- Name: index_log_settings_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_settings_on_item_type_and_item_id ON log_settings USING btree (item_type, item_id);


--
-- Name: index_log_settings_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_settings_on_whodunnit ON log_settings USING btree (whodunnit);


--
-- Name: index_log_users_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_users_on_item_type_and_item_id ON log_users USING btree (item_type, item_id);


--
-- Name: index_log_users_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_users_on_whodunnit ON log_users USING btree (whodunnit);


--
-- Name: index_messages_on_registrar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_registrar_id ON messages USING btree (registrar_id);


--
-- Name: index_nameservers_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nameservers_on_domain_id ON nameservers USING btree (domain_id);


--
-- Name: index_people_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_people_on_email ON people USING btree (email);


--
-- Name: index_people_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_people_on_reset_password_token ON people USING btree (reset_password_token);


--
-- Name: index_registrant_verifications_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_registrant_verifications_on_created_at ON registrant_verifications USING btree (created_at);


--
-- Name: index_registrant_verifications_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_registrant_verifications_on_domain_id ON registrant_verifications USING btree (domain_id);


--
-- Name: index_registrars_on_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_registrars_on_code ON registrars USING btree (code);


--
-- Name: index_registrars_on_legacy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_registrars_on_legacy_id ON registrars USING btree (legacy_id);


--
-- Name: index_settings_on_thing_type_and_thing_id_and_var; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_settings_on_thing_type_and_thing_id_and_var ON settings USING btree (thing_type, thing_id, var);


--
-- Name: index_users_on_identity_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_identity_code ON users USING btree (identity_code);


--
-- Name: index_users_on_registrar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_registrar_id ON users USING btree (registrar_id);


--
-- Name: index_whois_records_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_whois_records_on_domain_id ON whois_records USING btree (domain_id);


--
-- Name: index_whois_records_on_registrar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_whois_records_on_registrar_id ON whois_records USING btree (registrar_id);


--
-- Name: log_contacts_object_legacy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX log_contacts_object_legacy_id ON log_contacts USING btree ((((object ->> 'legacy_id'::text))::integer));


--
-- Name: log_dnskeys_object_legacy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX log_dnskeys_object_legacy_id ON log_contacts USING btree ((((object ->> 'legacy_domain_id'::text))::integer));


--
-- Name: log_domains_object_legacy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX log_domains_object_legacy_id ON log_contacts USING btree ((((object ->> 'legacy_id'::text))::integer));


--
-- Name: log_nameservers_object_legacy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX log_nameservers_object_legacy_id ON log_contacts USING btree ((((object ->> 'legacy_domain_id'::text))::integer));


--
-- Name: unique_data_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_data_migrations ON data_migrations USING btree (version);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140616073945');

INSERT INTO schema_migrations (version) VALUES ('20140620130107');

INSERT INTO schema_migrations (version) VALUES ('20140627082711');

INSERT INTO schema_migrations (version) VALUES ('20140701130945');

INSERT INTO schema_migrations (version) VALUES ('20140702144833');

INSERT INTO schema_migrations (version) VALUES ('20140702145448');

INSERT INTO schema_migrations (version) VALUES ('20140724084927');

INSERT INTO schema_migrations (version) VALUES ('20140730082358');

INSERT INTO schema_migrations (version) VALUES ('20140730082532');

INSERT INTO schema_migrations (version) VALUES ('20140730104916');

INSERT INTO schema_migrations (version) VALUES ('20140730141443');

INSERT INTO schema_migrations (version) VALUES ('20140731073300');

INSERT INTO schema_migrations (version) VALUES ('20140731081816');

INSERT INTO schema_migrations (version) VALUES ('20140801140249');

INSERT INTO schema_migrations (version) VALUES ('20140804095654');

INSERT INTO schema_migrations (version) VALUES ('20140808132327');

INSERT INTO schema_migrations (version) VALUES ('20140813102245');

INSERT INTO schema_migrations (version) VALUES ('20140813135408');

INSERT INTO schema_migrations (version) VALUES ('20140815082619');

INSERT INTO schema_migrations (version) VALUES ('20140815110028');

INSERT INTO schema_migrations (version) VALUES ('20140815114000');

INSERT INTO schema_migrations (version) VALUES ('20140819095802');

INSERT INTO schema_migrations (version) VALUES ('20140819103517');

INSERT INTO schema_migrations (version) VALUES ('20140822122938');

INSERT INTO schema_migrations (version) VALUES ('20140826082057');

INSERT INTO schema_migrations (version) VALUES ('20140826103454');

INSERT INTO schema_migrations (version) VALUES ('20140827140759');

INSERT INTO schema_migrations (version) VALUES ('20140828072329');

INSERT INTO schema_migrations (version) VALUES ('20140828074404');

INSERT INTO schema_migrations (version) VALUES ('20140828080320');

INSERT INTO schema_migrations (version) VALUES ('20140828133057');

INSERT INTO schema_migrations (version) VALUES ('20140902121843');

INSERT INTO schema_migrations (version) VALUES ('20140911101310');

INSERT INTO schema_migrations (version) VALUES ('20140911101604');

INSERT INTO schema_migrations (version) VALUES ('20140925073340');

INSERT INTO schema_migrations (version) VALUES ('20140925073734');

INSERT INTO schema_migrations (version) VALUES ('20140925073831');

INSERT INTO schema_migrations (version) VALUES ('20140925084916');

INSERT INTO schema_migrations (version) VALUES ('20140925085340');

INSERT INTO schema_migrations (version) VALUES ('20140925101927');

INSERT INTO schema_migrations (version) VALUES ('20140926081324');

INSERT INTO schema_migrations (version) VALUES ('20140926082627');

INSERT INTO schema_migrations (version) VALUES ('20140926121409');

INSERT INTO schema_migrations (version) VALUES ('20140929095329');

INSERT INTO schema_migrations (version) VALUES ('20140930093039');

INSERT INTO schema_migrations (version) VALUES ('20141001085322');

INSERT INTO schema_migrations (version) VALUES ('20141006124904');

INSERT INTO schema_migrations (version) VALUES ('20141006130306');

INSERT INTO schema_migrations (version) VALUES ('20141008134959');

INSERT INTO schema_migrations (version) VALUES ('20141009100818');

INSERT INTO schema_migrations (version) VALUES ('20141009101337');

INSERT INTO schema_migrations (version) VALUES ('20141010085152');

INSERT INTO schema_migrations (version) VALUES ('20141010130412');

INSERT INTO schema_migrations (version) VALUES ('20141014073435');

INSERT INTO schema_migrations (version) VALUES ('20141015135255');

INSERT INTO schema_migrations (version) VALUES ('20141015135742');

INSERT INTO schema_migrations (version) VALUES ('20141105150721');

INSERT INTO schema_migrations (version) VALUES ('20141111105931');

INSERT INTO schema_migrations (version) VALUES ('20141114130737');

INSERT INTO schema_migrations (version) VALUES ('20141120110330');

INSERT INTO schema_migrations (version) VALUES ('20141120140837');

INSERT INTO schema_migrations (version) VALUES ('20141121093125');

INSERT INTO schema_migrations (version) VALUES ('20141124105221');

INSERT INTO schema_migrations (version) VALUES ('20141125111414');

INSERT INTO schema_migrations (version) VALUES ('20141126140434');

INSERT INTO schema_migrations (version) VALUES ('20141127091027');

INSERT INTO schema_migrations (version) VALUES ('20141202114457');

INSERT INTO schema_migrations (version) VALUES ('20141203090115');

INSERT INTO schema_migrations (version) VALUES ('20141210085432');

INSERT INTO schema_migrations (version) VALUES ('20141211095604');

INSERT INTO schema_migrations (version) VALUES ('20141215085117');

INSERT INTO schema_migrations (version) VALUES ('20141216075056');

INSERT INTO schema_migrations (version) VALUES ('20141216133831');

INSERT INTO schema_migrations (version) VALUES ('20141218154829');

INSERT INTO schema_migrations (version) VALUES ('20141229115619');

INSERT INTO schema_migrations (version) VALUES ('20150105134026');

INSERT INTO schema_migrations (version) VALUES ('20150109081914');

INSERT INTO schema_migrations (version) VALUES ('20150110000000');

INSERT INTO schema_migrations (version) VALUES ('20150110113257');

INSERT INTO schema_migrations (version) VALUES ('20150122091556');

INSERT INTO schema_migrations (version) VALUES ('20150122091557');

INSERT INTO schema_migrations (version) VALUES ('20150128134352');

INSERT INTO schema_migrations (version) VALUES ('20150129093938');

INSERT INTO schema_migrations (version) VALUES ('20150129144652');

INSERT INTO schema_migrations (version) VALUES ('20150130085458');

INSERT INTO schema_migrations (version) VALUES ('20150130155904');

INSERT INTO schema_migrations (version) VALUES ('20150130180452');

INSERT INTO schema_migrations (version) VALUES ('20150130191056');

INSERT INTO schema_migrations (version) VALUES ('20150200000000');

INSERT INTO schema_migrations (version) VALUES ('20150202084444');

INSERT INTO schema_migrations (version) VALUES ('20150202140346');

INSERT INTO schema_migrations (version) VALUES ('20150203135303');

INSERT INTO schema_migrations (version) VALUES ('20150212125339');

INSERT INTO schema_migrations (version) VALUES ('20150213104014');

INSERT INTO schema_migrations (version) VALUES ('20150217133755');

INSERT INTO schema_migrations (version) VALUES ('20150217133937');

INSERT INTO schema_migrations (version) VALUES ('20150223104842');

INSERT INTO schema_migrations (version) VALUES ('20150226121252');

INSERT INTO schema_migrations (version) VALUES ('20150226144723');

INSERT INTO schema_migrations (version) VALUES ('20150227092508');

INSERT INTO schema_migrations (version) VALUES ('20150227113121');

INSERT INTO schema_migrations (version) VALUES ('20150302161712');

INSERT INTO schema_migrations (version) VALUES ('20150303130729');

INSERT INTO schema_migrations (version) VALUES ('20150303151224');

INSERT INTO schema_migrations (version) VALUES ('20150305092921');

INSERT INTO schema_migrations (version) VALUES ('20150318084300');

INSERT INTO schema_migrations (version) VALUES ('20150318085110');

INSERT INTO schema_migrations (version) VALUES ('20150318114921');

INSERT INTO schema_migrations (version) VALUES ('20150319125655');

INSERT INTO schema_migrations (version) VALUES ('20150320132023');

INSERT INTO schema_migrations (version) VALUES ('20150330083700');

INSERT INTO schema_migrations (version) VALUES ('20150402114712');

INSERT INTO schema_migrations (version) VALUES ('20150407145943');

INSERT INTO schema_migrations (version) VALUES ('20150408081917');

INSERT INTO schema_migrations (version) VALUES ('20150410124724');

INSERT INTO schema_migrations (version) VALUES ('20150410132037');

INSERT INTO schema_migrations (version) VALUES ('20150413080832');

INSERT INTO schema_migrations (version) VALUES ('20150413102310');

INSERT INTO schema_migrations (version) VALUES ('20150413115829');

INSERT INTO schema_migrations (version) VALUES ('20150413140933');

INSERT INTO schema_migrations (version) VALUES ('20150414092249');

INSERT INTO schema_migrations (version) VALUES ('20150414124630');

INSERT INTO schema_migrations (version) VALUES ('20150414151357');

INSERT INTO schema_migrations (version) VALUES ('20150415075408');

INSERT INTO schema_migrations (version) VALUES ('20150416080828');

INSERT INTO schema_migrations (version) VALUES ('20150416091357');

INSERT INTO schema_migrations (version) VALUES ('20150416092026');

INSERT INTO schema_migrations (version) VALUES ('20150416094704');

INSERT INTO schema_migrations (version) VALUES ('20150417082723');

INSERT INTO schema_migrations (version) VALUES ('20150421134820');

INSERT INTO schema_migrations (version) VALUES ('20150422092514');

INSERT INTO schema_migrations (version) VALUES ('20150422132631');

INSERT INTO schema_migrations (version) VALUES ('20150422134243');

INSERT INTO schema_migrations (version) VALUES ('20150423083308');

INSERT INTO schema_migrations (version) VALUES ('20150427073517');

INSERT INTO schema_migrations (version) VALUES ('20150428075052');

INSERT INTO schema_migrations (version) VALUES ('20150429135339');

INSERT INTO schema_migrations (version) VALUES ('20150430121807');

INSERT INTO schema_migrations (version) VALUES ('20150504104922');

INSERT INTO schema_migrations (version) VALUES ('20150504110926');

INSERT INTO schema_migrations (version) VALUES ('20150505111437');

INSERT INTO schema_migrations (version) VALUES ('20150511120755');

INSERT INTO schema_migrations (version) VALUES ('20150512160938');

INSERT INTO schema_migrations (version) VALUES ('20150513080013');

INSERT INTO schema_migrations (version) VALUES ('20150514132606');

INSERT INTO schema_migrations (version) VALUES ('20150515103222');

INSERT INTO schema_migrations (version) VALUES ('20150518084324');

INSERT INTO schema_migrations (version) VALUES ('20150519094929');

INSERT INTO schema_migrations (version) VALUES ('20150519095416');

INSERT INTO schema_migrations (version) VALUES ('20150519102521');

INSERT INTO schema_migrations (version) VALUES ('20150519115050');

INSERT INTO schema_migrations (version) VALUES ('20150519140853');

INSERT INTO schema_migrations (version) VALUES ('20150519144118');

INSERT INTO schema_migrations (version) VALUES ('20150520163237');

INSERT INTO schema_migrations (version) VALUES ('20150520164507');

INSERT INTO schema_migrations (version) VALUES ('20150521120145');

INSERT INTO schema_migrations (version) VALUES ('20150522164020');

INSERT INTO schema_migrations (version) VALUES ('20150525075550');

INSERT INTO schema_migrations (version) VALUES ('20150601083516');

INSERT INTO schema_migrations (version) VALUES ('20150601083800');

INSERT INTO schema_migrations (version) VALUES ('20150603141549');

INSERT INTO schema_migrations (version) VALUES ('20150603211318');

INSERT INTO schema_migrations (version) VALUES ('20150603212659');

INSERT INTO schema_migrations (version) VALUES ('20150609093515');

INSERT INTO schema_migrations (version) VALUES ('20150609103333');

INSERT INTO schema_migrations (version) VALUES ('20150610111019');

INSERT INTO schema_migrations (version) VALUES ('20150610112238');

INSERT INTO schema_migrations (version) VALUES ('20150610144547');

INSERT INTO schema_migrations (version) VALUES ('20150611124920');

INSERT INTO schema_migrations (version) VALUES ('20150612123111');

INSERT INTO schema_migrations (version) VALUES ('20150612125720');

INSERT INTO schema_migrations (version) VALUES ('20150701074344');

INSERT INTO schema_migrations (version) VALUES ('20150703084206');

INSERT INTO schema_migrations (version) VALUES ('20150703084632');

INSERT INTO schema_migrations (version) VALUES ('20150706091724');

INSERT INTO schema_migrations (version) VALUES ('20150707103241');

INSERT INTO schema_migrations (version) VALUES ('20150707103801');

INSERT INTO schema_migrations (version) VALUES ('20150707104937');

INSERT INTO schema_migrations (version) VALUES ('20150707154543');

INSERT INTO schema_migrations (version) VALUES ('20150709092549');

INSERT INTO schema_migrations (version) VALUES ('20150713113436');

INSERT INTO schema_migrations (version) VALUES ('20150722071128');

INSERT INTO schema_migrations (version) VALUES ('20150803080914');

INSERT INTO schema_migrations (version) VALUES ('20150810114746');

INSERT INTO schema_migrations (version) VALUES ('20150810114747');

INSERT INTO schema_migrations (version) VALUES ('20150825125118');

INSERT INTO schema_migrations (version) VALUES ('20150827151906');

INSERT INTO schema_migrations (version) VALUES ('20150903105659');

INSERT INTO schema_migrations (version) VALUES ('20150910113839');

INSERT INTO schema_migrations (version) VALUES ('20150915094707');

INSERT INTO schema_migrations (version) VALUES ('20150921110152');

INSERT INTO schema_migrations (version) VALUES ('20150921111842');

INSERT INTO schema_migrations (version) VALUES ('20151028183132');

INSERT INTO schema_migrations (version) VALUES ('20151029152638');

INSERT INTO schema_migrations (version) VALUES ('20151112160452');

INSERT INTO schema_migrations (version) VALUES ('20151117081204');

INSERT INTO schema_migrations (version) VALUES ('20151120090455');

INSERT INTO schema_migrations (version) VALUES ('20151124200353');

INSERT INTO schema_migrations (version) VALUES ('20151125155601');

INSERT INTO schema_migrations (version) VALUES ('20151127091716');

INSERT INTO schema_migrations (version) VALUES ('20151130175654');

INSERT INTO schema_migrations (version) VALUES ('20151202123506');

INSERT INTO schema_migrations (version) VALUES ('20151209122816');

INSERT INTO schema_migrations (version) VALUES ('20160106101725');

INSERT INTO schema_migrations (version) VALUES ('20160108135436');

INSERT INTO schema_migrations (version) VALUES ('20160113143447');

INSERT INTO schema_migrations (version) VALUES ('20160118092453');

INSERT INTO schema_migrations (version) VALUES ('20160118092454');

INSERT INTO schema_migrations (version) VALUES ('20160218102355');

INSERT INTO schema_migrations (version) VALUES ('20160225113801');

INSERT INTO schema_migrations (version) VALUES ('20160225113812');

INSERT INTO schema_migrations (version) VALUES ('20160226132045');

INSERT INTO schema_migrations (version) VALUES ('20160226132056');

INSERT INTO schema_migrations (version) VALUES ('20160304125933');

INSERT INTO schema_migrations (version) VALUES ('20160311085956');

INSERT INTO schema_migrations (version) VALUES ('20160311085957');

INSERT INTO schema_migrations (version) VALUES ('20160405131315');

INSERT INTO schema_migrations (version) VALUES ('20160411140719');

INSERT INTO schema_migrations (version) VALUES ('20160414110443');

INSERT INTO schema_migrations (version) VALUES ('20160421074023');

INSERT INTO schema_migrations (version) VALUES ('20160429114732');

INSERT INTO schema_migrations (version) VALUES ('20160527110738');

INSERT INTO schema_migrations (version) VALUES ('20160629114503');

INSERT INTO schema_migrations (version) VALUES ('20161004101419');

INSERT INTO schema_migrations (version) VALUES ('20161227193500');

INSERT INTO schema_migrations (version) VALUES ('20170221115548');

INSERT INTO schema_migrations (version) VALUES ('20170419120048');

INSERT INTO schema_migrations (version) VALUES ('20170420125200');

INSERT INTO schema_migrations (version) VALUES ('20170422130054');

INSERT INTO schema_migrations (version) VALUES ('20170422142116');

INSERT INTO schema_migrations (version) VALUES ('20170422162824');

