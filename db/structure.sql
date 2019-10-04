--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
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


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: fill_ident_country(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fill_ident_country() RETURNS boolean
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

CREATE FUNCTION public.generate_zonefile(i_origin character varying) RETURNS text
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

CREATE TABLE public.account_activities (
    id integer NOT NULL,
    account_id integer NOT NULL,
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
    price_id integer
);


--
-- Name: account_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_activities_id_seq OWNED BY public.account_activities.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.accounts (
    id integer NOT NULL,
    registrar_id integer NOT NULL,
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

CREATE SEQUENCE public.accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: actions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.actions (
    id integer NOT NULL,
    user_id integer,
    operation character varying NOT NULL,
    created_at timestamp without time zone,
    contact_id integer
);


--
-- Name: actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.actions_id_seq OWNED BY public.actions.id;


--
-- Name: auctions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.auctions (
    id integer NOT NULL,
    domain character varying NOT NULL,
    status character varying NOT NULL,
    uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    registration_code character varying
);


--
-- Name: auctions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auctions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auctions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auctions_id_seq OWNED BY public.auctions.id;


--
-- Name: bank_statements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.bank_statements (
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

CREATE SEQUENCE public.bank_statements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_statements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bank_statements_id_seq OWNED BY public.bank_statements.id;


--
-- Name: bank_transactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.bank_transactions (
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
    updator_str character varying
);


--
-- Name: bank_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bank_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bank_transactions_id_seq OWNED BY public.bank_transactions.id;


--
-- Name: blocked_domains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.blocked_domains (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying,
    name character varying NOT NULL
);


--
-- Name: blocked_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blocked_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blocked_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blocked_domains_id_seq OWNED BY public.blocked_domains.id;


--
-- Name: certificates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.certificates (
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

CREATE SEQUENCE public.certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.certificates_id_seq OWNED BY public.certificates.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.contacts (
    id integer NOT NULL,
    code character varying NOT NULL,
    phone character varying,
    email character varying NOT NULL,
    fax character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ident character varying,
    ident_type character varying,
    auth_info character varying NOT NULL,
    name character varying,
    org_name character varying,
    registrar_id integer NOT NULL,
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
    status_notes public.hstore,
    legacy_history_id integer,
    original_id integer,
    ident_updated_at timestamp without time zone,
    upid integer,
    up_date timestamp without time zone,
    uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    disclosed_attributes character varying[] DEFAULT '{}'::character varying[] NOT NULL
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: directos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.directos (
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

CREATE SEQUENCE public.directos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: directos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.directos_id_seq OWNED BY public.directos.id;


--
-- Name: dnskeys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.dnskeys (
    id integer NOT NULL,
    domain_id integer,
    flags integer,
    protocol integer,
    alg integer,
    public_key text,
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

CREATE SEQUENCE public.dnskeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dnskeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dnskeys_id_seq OWNED BY public.dnskeys.id;


--
-- Name: domain_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.domain_contacts (
    id integer NOT NULL,
    contact_id integer,
    domain_id integer,
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

CREATE SEQUENCE public.domain_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: domain_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.domain_contacts_id_seq OWNED BY public.domain_contacts.id;


--
-- Name: domain_transfers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.domain_transfers (
    id integer NOT NULL,
    domain_id integer NOT NULL,
    status character varying,
    transfer_requested_at timestamp without time zone,
    transferred_at timestamp without time zone,
    old_registrar_id integer NOT NULL,
    new_registrar_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    wait_until timestamp without time zone
);


--
-- Name: domain_transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.domain_transfers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: domain_transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.domain_transfers_id_seq OWNED BY public.domain_transfers.id;


--
-- Name: domains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.domains (
    id integer NOT NULL,
    name character varying NOT NULL,
    registrar_id integer NOT NULL,
    registered_at timestamp without time zone,
    valid_to timestamp without time zone NOT NULL,
    registrant_id integer NOT NULL,
    transfer_code character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name_dirty character varying NOT NULL,
    name_puny character varying NOT NULL,
    period integer,
    period_unit character varying(1),
    creator_str character varying,
    updator_str character varying,
    legacy_id integer,
    legacy_registrar_id integer,
    legacy_registrant_id integer,
    outzone_at timestamp without time zone,
    delete_date date,
    registrant_verification_asked_at timestamp without time zone,
    registrant_verification_token character varying,
    pending_json jsonb,
    force_delete_date date,
    statuses character varying[],
    status_notes public.hstore,
    statuses_before_force_delete character varying[] DEFAULT '{}'::character varying[],
    upid integer,
    up_date timestamp without time zone,
    uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    locked_by_registrant_at timestamp without time zone
);


--
-- Name: domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.domains_id_seq OWNED BY public.domains.id;


--
-- Name: epp_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.epp_sessions (
    id integer NOT NULL,
    session_id character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id integer NOT NULL
);


--
-- Name: epp_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.epp_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: epp_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.epp_sessions_id_seq OWNED BY public.epp_sessions.id;


--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.invoice_items (
    id integer NOT NULL,
    invoice_id integer NOT NULL,
    description character varying NOT NULL,
    unit character varying NOT NULL,
    quantity integer NOT NULL,
    price numeric(10,2) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying
);


--
-- Name: invoice_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoice_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoice_items_id_seq OWNED BY public.invoice_items.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.invoices (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    due_date date NOT NULL,
    currency character varying NOT NULL,
    description character varying,
    reference_no character varying NOT NULL,
    vat_rate numeric(4,3) NOT NULL,
    seller_name character varying NOT NULL,
    seller_reg_no character varying NOT NULL,
    seller_iban character varying NOT NULL,
    seller_bank character varying NOT NULL,
    seller_swift character varying NOT NULL,
    seller_vat_no character varying,
    seller_country_code character varying NOT NULL,
    seller_state character varying,
    seller_street character varying NOT NULL,
    seller_city character varying NOT NULL,
    seller_zip character varying,
    seller_phone character varying,
    seller_url character varying,
    seller_email character varying NOT NULL,
    seller_contact_name character varying NOT NULL,
    buyer_id integer NOT NULL,
    buyer_name character varying NOT NULL,
    buyer_reg_no character varying NOT NULL,
    buyer_country_code character varying NOT NULL,
    buyer_state character varying,
    buyer_street character varying NOT NULL,
    buyer_city character varying NOT NULL,
    buyer_zip character varying,
    buyer_phone character varying,
    buyer_url character varying,
    buyer_email character varying NOT NULL,
    creator_str character varying,
    updator_str character varying,
    number integer NOT NULL,
    cancelled_at timestamp without time zone,
    total numeric(10,2) NOT NULL,
    in_directo boolean DEFAULT false,
    buyer_vat_no character varying,
    issue_date date NOT NULL
);


--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: keyrelays; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.keyrelays (
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

CREATE SEQUENCE public.keyrelays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: keyrelays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.keyrelays_id_seq OWNED BY public.keyrelays.id;


--
-- Name: legal_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.legal_documents (
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

CREATE SEQUENCE public.legal_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: legal_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.legal_documents_id_seq OWNED BY public.legal_documents.id;


--
-- Name: log_account_activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_account_activities (
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

CREATE SEQUENCE public.log_account_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_account_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_account_activities_id_seq OWNED BY public.log_account_activities.id;


--
-- Name: log_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_accounts (
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

CREATE SEQUENCE public.log_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_accounts_id_seq OWNED BY public.log_accounts.id;


--
-- Name: log_actions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_actions (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object jsonb,
    object_changes jsonb,
    created_at timestamp without time zone,
    session character varying,
    children jsonb,
    uuid character varying
);


--
-- Name: log_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.log_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_actions_id_seq OWNED BY public.log_actions.id;


--
-- Name: log_bank_statements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_bank_statements (
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

CREATE SEQUENCE public.log_bank_statements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_bank_statements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_bank_statements_id_seq OWNED BY public.log_bank_statements.id;


--
-- Name: log_bank_transactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_bank_transactions (
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

CREATE SEQUENCE public.log_bank_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_bank_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_bank_transactions_id_seq OWNED BY public.log_bank_transactions.id;


--
-- Name: log_blocked_domains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_blocked_domains (
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

CREATE SEQUENCE public.log_blocked_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_blocked_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_blocked_domains_id_seq OWNED BY public.log_blocked_domains.id;


--
-- Name: log_certificates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_certificates (
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

CREATE SEQUENCE public.log_certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_certificates_id_seq OWNED BY public.log_certificates.id;


--
-- Name: log_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_contacts (
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

CREATE SEQUENCE public.log_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_contacts_id_seq OWNED BY public.log_contacts.id;


--
-- Name: log_dnskeys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_dnskeys (
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

CREATE SEQUENCE public.log_dnskeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_dnskeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_dnskeys_id_seq OWNED BY public.log_dnskeys.id;


--
-- Name: log_domain_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_domain_contacts (
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

CREATE SEQUENCE public.log_domain_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_domain_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_domain_contacts_id_seq OWNED BY public.log_domain_contacts.id;


--
-- Name: log_domains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_domains (
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
-- Name: log_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.log_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_domains_id_seq OWNED BY public.log_domains.id;


--
-- Name: log_invoice_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_invoice_items (
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

CREATE SEQUENCE public.log_invoice_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_invoice_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_invoice_items_id_seq OWNED BY public.log_invoice_items.id;


--
-- Name: log_invoices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_invoices (
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

CREATE SEQUENCE public.log_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_invoices_id_seq OWNED BY public.log_invoices.id;


--
-- Name: log_keyrelays; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_keyrelays (
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

CREATE SEQUENCE public.log_keyrelays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_keyrelays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_keyrelays_id_seq OWNED BY public.log_keyrelays.id;


--
-- Name: log_nameservers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_nameservers (
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

CREATE SEQUENCE public.log_nameservers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_nameservers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_nameservers_id_seq OWNED BY public.log_nameservers.id;


--
-- Name: log_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_notifications (
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
-- Name: log_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.log_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_notifications_id_seq OWNED BY public.log_notifications.id;


--
-- Name: log_registrars; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_registrars (
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

CREATE SEQUENCE public.log_registrars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_registrars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_registrars_id_seq OWNED BY public.log_registrars.id;


--
-- Name: log_reserved_domains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_reserved_domains (
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

CREATE SEQUENCE public.log_reserved_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_reserved_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_reserved_domains_id_seq OWNED BY public.log_reserved_domains.id;


--
-- Name: log_settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_settings (
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

CREATE SEQUENCE public.log_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_settings_id_seq OWNED BY public.log_settings.id;


--
-- Name: log_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_users (
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

CREATE SEQUENCE public.log_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_users_id_seq OWNED BY public.log_users.id;


--
-- Name: log_white_ips; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.log_white_ips (
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

CREATE SEQUENCE public.log_white_ips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_white_ips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_white_ips_id_seq OWNED BY public.log_white_ips.id;


--
-- Name: nameservers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.nameservers (
    id integer NOT NULL,
    hostname character varying NOT NULL,
    ipv4 character varying[] DEFAULT '{}'::character varying[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ipv6 character varying[] DEFAULT '{}'::character varying[],
    domain_id integer NOT NULL,
    creator_str character varying,
    updator_str character varying,
    legacy_domain_id integer,
    hostname_puny character varying
);


--
-- Name: nameservers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nameservers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nameservers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nameservers_id_seq OWNED BY public.nameservers.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    registrar_id integer NOT NULL,
    text character varying NOT NULL,
    attached_obj_type character varying,
    attached_obj_id integer,
    read boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying,
    action_id integer
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: prices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.prices (
    id integer NOT NULL,
    price_cents integer NOT NULL,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    creator_str character varying,
    updator_str character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    duration interval,
    operation_category character varying,
    zone_id integer NOT NULL
);


--
-- Name: prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.prices_id_seq OWNED BY public.prices.id;


--
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.que_jobs (
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

COMMENT ON TABLE public.que_jobs IS '3';


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.que_jobs_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.que_jobs_job_id_seq OWNED BY public.que_jobs.job_id;


--
-- Name: registrant_verifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.registrant_verifications (
    id integer NOT NULL,
    domain_name character varying NOT NULL,
    verification_token character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    action character varying NOT NULL,
    domain_id integer NOT NULL,
    action_type character varying NOT NULL
);


--
-- Name: registrant_verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registrant_verifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registrant_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.registrant_verifications_id_seq OWNED BY public.registrant_verifications.id;


--
-- Name: registrars; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.registrars (
    id integer NOT NULL,
    name character varying NOT NULL,
    reg_no character varying NOT NULL,
    vat_no character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying,
    phone character varying,
    email character varying NOT NULL,
    billing_email character varying,
    address_country_code character varying NOT NULL,
    address_state character varying,
    address_city character varying NOT NULL,
    address_street character varying NOT NULL,
    address_zip character varying,
    code character varying NOT NULL,
    website character varying,
    accounting_customer_code character varying NOT NULL,
    legacy_id integer,
    reference_no character varying NOT NULL,
    test_registrar boolean DEFAULT false,
    language character varying NOT NULL,
    vat_rate numeric(4,3),
    iban character varying,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: registrars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registrars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registrars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.registrars_id_seq OWNED BY public.registrars.id;


--
-- Name: reserved_domains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.reserved_domains (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_str character varying,
    updator_str character varying,
    legacy_id integer,
    name character varying NOT NULL,
    password character varying NOT NULL
);


--
-- Name: reserved_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reserved_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reserved_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reserved_domains_id_seq OWNED BY public.reserved_domains.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.settings (
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

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying,
    plain_text_password character varying,
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

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.versions (
    id integer NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp without time zone,
    object_changes jsonb
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: white_ips; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.white_ips (
    id integer NOT NULL,
    registrar_id integer NOT NULL,
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

CREATE SEQUENCE public.white_ips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: white_ips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.white_ips_id_seq OWNED BY public.white_ips.id;


--
-- Name: whois_records; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.whois_records (
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

CREATE SEQUENCE public.whois_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: whois_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.whois_records_id_seq OWNED BY public.whois_records.id;


--
-- Name: zones; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE public.zones (
    id integer NOT NULL,
    origin character varying NOT NULL,
    ttl integer NOT NULL,
    refresh integer NOT NULL,
    retry integer NOT NULL,
    expire integer NOT NULL,
    minimum_ttl integer NOT NULL,
    email character varying NOT NULL,
    master_nameserver character varying NOT NULL,
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

CREATE SEQUENCE public.zones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.zones_id_seq OWNED BY public.zones.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_activities ALTER COLUMN id SET DEFAULT nextval('public.account_activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actions ALTER COLUMN id SET DEFAULT nextval('public.actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auctions ALTER COLUMN id SET DEFAULT nextval('public.auctions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_statements ALTER COLUMN id SET DEFAULT nextval('public.bank_statements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_transactions ALTER COLUMN id SET DEFAULT nextval('public.bank_transactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocked_domains ALTER COLUMN id SET DEFAULT nextval('public.blocked_domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates ALTER COLUMN id SET DEFAULT nextval('public.certificates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directos ALTER COLUMN id SET DEFAULT nextval('public.directos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dnskeys ALTER COLUMN id SET DEFAULT nextval('public.dnskeys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domain_contacts ALTER COLUMN id SET DEFAULT nextval('public.domain_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domain_transfers ALTER COLUMN id SET DEFAULT nextval('public.domain_transfers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domains ALTER COLUMN id SET DEFAULT nextval('public.domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.epp_sessions ALTER COLUMN id SET DEFAULT nextval('public.epp_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_items ALTER COLUMN id SET DEFAULT nextval('public.invoice_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keyrelays ALTER COLUMN id SET DEFAULT nextval('public.keyrelays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_documents ALTER COLUMN id SET DEFAULT nextval('public.legal_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_account_activities ALTER COLUMN id SET DEFAULT nextval('public.log_account_activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_accounts ALTER COLUMN id SET DEFAULT nextval('public.log_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_actions ALTER COLUMN id SET DEFAULT nextval('public.log_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_bank_statements ALTER COLUMN id SET DEFAULT nextval('public.log_bank_statements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_bank_transactions ALTER COLUMN id SET DEFAULT nextval('public.log_bank_transactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_blocked_domains ALTER COLUMN id SET DEFAULT nextval('public.log_blocked_domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_certificates ALTER COLUMN id SET DEFAULT nextval('public.log_certificates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_contacts ALTER COLUMN id SET DEFAULT nextval('public.log_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_dnskeys ALTER COLUMN id SET DEFAULT nextval('public.log_dnskeys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_domain_contacts ALTER COLUMN id SET DEFAULT nextval('public.log_domain_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_domains ALTER COLUMN id SET DEFAULT nextval('public.log_domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_invoice_items ALTER COLUMN id SET DEFAULT nextval('public.log_invoice_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_invoices ALTER COLUMN id SET DEFAULT nextval('public.log_invoices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_keyrelays ALTER COLUMN id SET DEFAULT nextval('public.log_keyrelays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_nameservers ALTER COLUMN id SET DEFAULT nextval('public.log_nameservers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_notifications ALTER COLUMN id SET DEFAULT nextval('public.log_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_registrars ALTER COLUMN id SET DEFAULT nextval('public.log_registrars_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_reserved_domains ALTER COLUMN id SET DEFAULT nextval('public.log_reserved_domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_settings ALTER COLUMN id SET DEFAULT nextval('public.log_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_users ALTER COLUMN id SET DEFAULT nextval('public.log_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_white_ips ALTER COLUMN id SET DEFAULT nextval('public.log_white_ips_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nameservers ALTER COLUMN id SET DEFAULT nextval('public.nameservers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prices ALTER COLUMN id SET DEFAULT nextval('public.prices_id_seq'::regclass);


--
-- Name: job_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_jobs ALTER COLUMN job_id SET DEFAULT nextval('public.que_jobs_job_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrant_verifications ALTER COLUMN id SET DEFAULT nextval('public.registrant_verifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrars ALTER COLUMN id SET DEFAULT nextval('public.registrars_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reserved_domains ALTER COLUMN id SET DEFAULT nextval('public.reserved_domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.white_ips ALTER COLUMN id SET DEFAULT nextval('public.white_ips_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.whois_records ALTER COLUMN id SET DEFAULT nextval('public.whois_records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zones ALTER COLUMN id SET DEFAULT nextval('public.zones_id_seq'::regclass);


--
-- Name: account_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.account_activities
    ADD CONSTRAINT account_activities_pkey PRIMARY KEY (id);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (id);


--
-- Name: auctions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.auctions
    ADD CONSTRAINT auctions_pkey PRIMARY KEY (id);


--
-- Name: bank_statements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.bank_statements
    ADD CONSTRAINT bank_statements_pkey PRIMARY KEY (id);


--
-- Name: bank_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.bank_transactions
    ADD CONSTRAINT bank_transactions_pkey PRIMARY KEY (id);


--
-- Name: blocked_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.blocked_domains
    ADD CONSTRAINT blocked_domains_pkey PRIMARY KEY (id);


--
-- Name: certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);


--
-- Name: contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: directos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.directos
    ADD CONSTRAINT directos_pkey PRIMARY KEY (id);


--
-- Name: dnskeys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.dnskeys
    ADD CONSTRAINT dnskeys_pkey PRIMARY KEY (id);


--
-- Name: domain_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.domain_contacts
    ADD CONSTRAINT domain_contacts_pkey PRIMARY KEY (id);


--
-- Name: domain_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.domain_transfers
    ADD CONSTRAINT domain_transfers_pkey PRIMARY KEY (id);


--
-- Name: domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_pkey PRIMARY KEY (id);


--
-- Name: epp_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.epp_sessions
    ADD CONSTRAINT epp_sessions_pkey PRIMARY KEY (id);


--
-- Name: invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: keyrelays_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.keyrelays
    ADD CONSTRAINT keyrelays_pkey PRIMARY KEY (id);


--
-- Name: legal_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.legal_documents
    ADD CONSTRAINT legal_documents_pkey PRIMARY KEY (id);


--
-- Name: log_account_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_account_activities
    ADD CONSTRAINT log_account_activities_pkey PRIMARY KEY (id);


--
-- Name: log_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_accounts
    ADD CONSTRAINT log_accounts_pkey PRIMARY KEY (id);


--
-- Name: log_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_actions
    ADD CONSTRAINT log_actions_pkey PRIMARY KEY (id);


--
-- Name: log_bank_statements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_bank_statements
    ADD CONSTRAINT log_bank_statements_pkey PRIMARY KEY (id);


--
-- Name: log_bank_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_bank_transactions
    ADD CONSTRAINT log_bank_transactions_pkey PRIMARY KEY (id);


--
-- Name: log_blocked_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_blocked_domains
    ADD CONSTRAINT log_blocked_domains_pkey PRIMARY KEY (id);


--
-- Name: log_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_certificates
    ADD CONSTRAINT log_certificates_pkey PRIMARY KEY (id);


--
-- Name: log_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_contacts
    ADD CONSTRAINT log_contacts_pkey PRIMARY KEY (id);


--
-- Name: log_dnskeys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_dnskeys
    ADD CONSTRAINT log_dnskeys_pkey PRIMARY KEY (id);


--
-- Name: log_domain_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_domain_contacts
    ADD CONSTRAINT log_domain_contacts_pkey PRIMARY KEY (id);


--
-- Name: log_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_domains
    ADD CONSTRAINT log_domains_pkey PRIMARY KEY (id);


--
-- Name: log_invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_invoice_items
    ADD CONSTRAINT log_invoice_items_pkey PRIMARY KEY (id);


--
-- Name: log_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_invoices
    ADD CONSTRAINT log_invoices_pkey PRIMARY KEY (id);


--
-- Name: log_keyrelays_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_keyrelays
    ADD CONSTRAINT log_keyrelays_pkey PRIMARY KEY (id);


--
-- Name: log_nameservers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_nameservers
    ADD CONSTRAINT log_nameservers_pkey PRIMARY KEY (id);


--
-- Name: log_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_notifications
    ADD CONSTRAINT log_notifications_pkey PRIMARY KEY (id);


--
-- Name: log_registrars_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_registrars
    ADD CONSTRAINT log_registrars_pkey PRIMARY KEY (id);


--
-- Name: log_reserved_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_reserved_domains
    ADD CONSTRAINT log_reserved_domains_pkey PRIMARY KEY (id);


--
-- Name: log_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_settings
    ADD CONSTRAINT log_settings_pkey PRIMARY KEY (id);


--
-- Name: log_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_users
    ADD CONSTRAINT log_users_pkey PRIMARY KEY (id);


--
-- Name: log_white_ips_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.log_white_ips
    ADD CONSTRAINT log_white_ips_pkey PRIMARY KEY (id);


--
-- Name: nameservers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.nameservers
    ADD CONSTRAINT nameservers_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.prices
    ADD CONSTRAINT prices_pkey PRIMARY KEY (id);


--
-- Name: que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (queue, priority, run_at, job_id);


--
-- Name: registrant_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.registrant_verifications
    ADD CONSTRAINT registrant_verifications_pkey PRIMARY KEY (id);


--
-- Name: registrars_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.registrars
    ADD CONSTRAINT registrars_pkey PRIMARY KEY (id);


--
-- Name: reserved_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.reserved_domains
    ADD CONSTRAINT reserved_domains_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: uniq_blocked_domains_name; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.blocked_domains
    ADD CONSTRAINT uniq_blocked_domains_name UNIQUE (name);


--
-- Name: uniq_contact_uuid; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT uniq_contact_uuid UNIQUE (uuid);


--
-- Name: uniq_domain_uuid; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT uniq_domain_uuid UNIQUE (uuid);


--
-- Name: uniq_reserved_domains_name; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.reserved_domains
    ADD CONSTRAINT uniq_reserved_domains_name UNIQUE (name);


--
-- Name: uniq_uuid; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.auctions
    ADD CONSTRAINT uniq_uuid UNIQUE (uuid);


--
-- Name: unique_code; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.registrars
    ADD CONSTRAINT unique_code UNIQUE (code);


--
-- Name: unique_contact_code; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT unique_contact_code UNIQUE (code);


--
-- Name: unique_name; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.registrars
    ADD CONSTRAINT unique_name UNIQUE (name);


--
-- Name: unique_number; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT unique_number UNIQUE (number);


--
-- Name: unique_reference_no; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.registrars
    ADD CONSTRAINT unique_reference_no UNIQUE (reference_no);


--
-- Name: unique_registration_code; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.auctions
    ADD CONSTRAINT unique_registration_code UNIQUE (registration_code);


--
-- Name: unique_session_id; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.epp_sessions
    ADD CONSTRAINT unique_session_id UNIQUE (session_id);


--
-- Name: unique_zone_origin; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT unique_zone_origin UNIQUE (origin);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: white_ips_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.white_ips
    ADD CONSTRAINT white_ips_pkey PRIMARY KEY (id);


--
-- Name: whois_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.whois_records
    ADD CONSTRAINT whois_records_pkey PRIMARY KEY (id);


--
-- Name: zones_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_pkey PRIMARY KEY (id);


--
-- Name: index_account_activities_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_activities_on_account_id ON public.account_activities USING btree (account_id);


--
-- Name: index_account_activities_on_bank_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_activities_on_bank_transaction_id ON public.account_activities USING btree (bank_transaction_id);


--
-- Name: index_account_activities_on_invoice_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_activities_on_invoice_id ON public.account_activities USING btree (invoice_id);


--
-- Name: index_accounts_on_registrar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_registrar_id ON public.accounts USING btree (registrar_id);


--
-- Name: index_certificates_on_api_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_certificates_on_api_user_id ON public.certificates USING btree (api_user_id);


--
-- Name: index_contacts_on_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_code ON public.contacts USING btree (code);


--
-- Name: index_contacts_on_registrar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_registrar_id ON public.contacts USING btree (registrar_id);


--
-- Name: index_contacts_on_registrar_id_and_ident_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contacts_on_registrar_id_and_ident_type ON public.contacts USING btree (registrar_id, ident_type);


--
-- Name: index_directos_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_directos_on_item_type_and_item_id ON public.directos USING btree (item_type, item_id);


--
-- Name: index_dnskeys_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dnskeys_on_domain_id ON public.dnskeys USING btree (domain_id);


--
-- Name: index_dnskeys_on_legacy_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dnskeys_on_legacy_domain_id ON public.dnskeys USING btree (legacy_domain_id);


--
-- Name: index_domain_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domain_contacts_on_contact_id ON public.domain_contacts USING btree (contact_id);


--
-- Name: index_domain_contacts_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domain_contacts_on_domain_id ON public.domain_contacts USING btree (domain_id);


--
-- Name: index_domain_transfers_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domain_transfers_on_domain_id ON public.domain_transfers USING btree (domain_id);


--
-- Name: index_domains_on_delete_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_delete_date ON public.domains USING btree (delete_date);


--
-- Name: index_domains_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_domains_on_name ON public.domains USING btree (name);


--
-- Name: index_domains_on_outzone_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_outzone_at ON public.domains USING btree (outzone_at);


--
-- Name: index_domains_on_registrant_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_registrant_id ON public.domains USING btree (registrant_id);


--
-- Name: index_domains_on_registrant_verification_asked_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_registrant_verification_asked_at ON public.domains USING btree (registrant_verification_asked_at);


--
-- Name: index_domains_on_registrant_verification_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_registrant_verification_token ON public.domains USING btree (registrant_verification_token);


--
-- Name: index_domains_on_registrar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_registrar_id ON public.domains USING btree (registrar_id);


--
-- Name: index_domains_on_statuses; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_domains_on_statuses ON public.domains USING gin (statuses);


--
-- Name: index_epp_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_epp_sessions_on_updated_at ON public.epp_sessions USING btree (updated_at);


--
-- Name: index_invoice_items_on_invoice_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invoice_items_on_invoice_id ON public.invoice_items USING btree (invoice_id);


--
-- Name: index_invoices_on_buyer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invoices_on_buyer_id ON public.invoices USING btree (buyer_id);


--
-- Name: index_keyrelays_on_accepter_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keyrelays_on_accepter_id ON public.keyrelays USING btree (accepter_id);


--
-- Name: index_keyrelays_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keyrelays_on_domain_id ON public.keyrelays USING btree (domain_id);


--
-- Name: index_keyrelays_on_requester_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keyrelays_on_requester_id ON public.keyrelays USING btree (requester_id);


--
-- Name: index_legal_documents_on_checksum; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_legal_documents_on_checksum ON public.legal_documents USING btree (checksum);


--
-- Name: index_legal_documents_on_documentable_type_and_documentable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_legal_documents_on_documentable_type_and_documentable_id ON public.legal_documents USING btree (documentable_type, documentable_id);


--
-- Name: index_log_account_activities_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_account_activities_on_item_type_and_item_id ON public.log_account_activities USING btree (item_type, item_id);


--
-- Name: index_log_account_activities_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_account_activities_on_whodunnit ON public.log_account_activities USING btree (whodunnit);


--
-- Name: index_log_accounts_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_accounts_on_item_type_and_item_id ON public.log_accounts USING btree (item_type, item_id);


--
-- Name: index_log_accounts_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_accounts_on_whodunnit ON public.log_accounts USING btree (whodunnit);


--
-- Name: index_log_bank_statements_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bank_statements_on_item_type_and_item_id ON public.log_bank_statements USING btree (item_type, item_id);


--
-- Name: index_log_bank_statements_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bank_statements_on_whodunnit ON public.log_bank_statements USING btree (whodunnit);


--
-- Name: index_log_bank_transactions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bank_transactions_on_item_type_and_item_id ON public.log_bank_transactions USING btree (item_type, item_id);


--
-- Name: index_log_bank_transactions_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bank_transactions_on_whodunnit ON public.log_bank_transactions USING btree (whodunnit);


--
-- Name: index_log_blocked_domains_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_blocked_domains_on_item_type_and_item_id ON public.log_blocked_domains USING btree (item_type, item_id);


--
-- Name: index_log_blocked_domains_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_blocked_domains_on_whodunnit ON public.log_blocked_domains USING btree (whodunnit);


--
-- Name: index_log_certificates_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_certificates_on_item_type_and_item_id ON public.log_certificates USING btree (item_type, item_id);


--
-- Name: index_log_certificates_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_certificates_on_whodunnit ON public.log_certificates USING btree (whodunnit);


--
-- Name: index_log_contacts_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_contacts_on_item_type_and_item_id ON public.log_contacts USING btree (item_type, item_id);


--
-- Name: index_log_contacts_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_contacts_on_whodunnit ON public.log_contacts USING btree (whodunnit);


--
-- Name: index_log_dnskeys_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_dnskeys_on_item_type_and_item_id ON public.log_dnskeys USING btree (item_type, item_id);


--
-- Name: index_log_dnskeys_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_dnskeys_on_whodunnit ON public.log_dnskeys USING btree (whodunnit);


--
-- Name: index_log_domain_contacts_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_domain_contacts_on_item_type_and_item_id ON public.log_domain_contacts USING btree (item_type, item_id);


--
-- Name: index_log_domain_contacts_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_domain_contacts_on_whodunnit ON public.log_domain_contacts USING btree (whodunnit);


--
-- Name: index_log_domains_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_domains_on_item_type_and_item_id ON public.log_domains USING btree (item_type, item_id);


--
-- Name: index_log_domains_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_domains_on_whodunnit ON public.log_domains USING btree (whodunnit);


--
-- Name: index_log_invoice_items_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_invoice_items_on_item_type_and_item_id ON public.log_invoice_items USING btree (item_type, item_id);


--
-- Name: index_log_invoice_items_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_invoice_items_on_whodunnit ON public.log_invoice_items USING btree (whodunnit);


--
-- Name: index_log_invoices_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_invoices_on_item_type_and_item_id ON public.log_invoices USING btree (item_type, item_id);


--
-- Name: index_log_invoices_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_invoices_on_whodunnit ON public.log_invoices USING btree (whodunnit);


--
-- Name: index_log_keyrelays_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_keyrelays_on_item_type_and_item_id ON public.log_keyrelays USING btree (item_type, item_id);


--
-- Name: index_log_keyrelays_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_keyrelays_on_whodunnit ON public.log_keyrelays USING btree (whodunnit);


--
-- Name: index_log_nameservers_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_nameservers_on_item_type_and_item_id ON public.log_nameservers USING btree (item_type, item_id);


--
-- Name: index_log_nameservers_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_nameservers_on_whodunnit ON public.log_nameservers USING btree (whodunnit);


--
-- Name: index_log_notifications_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_notifications_on_item_type_and_item_id ON public.log_notifications USING btree (item_type, item_id);


--
-- Name: index_log_notifications_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_notifications_on_whodunnit ON public.log_notifications USING btree (whodunnit);


--
-- Name: index_log_registrars_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_registrars_on_item_type_and_item_id ON public.log_registrars USING btree (item_type, item_id);


--
-- Name: index_log_registrars_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_registrars_on_whodunnit ON public.log_registrars USING btree (whodunnit);


--
-- Name: index_log_reserved_domains_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_reserved_domains_on_item_type_and_item_id ON public.log_reserved_domains USING btree (item_type, item_id);


--
-- Name: index_log_reserved_domains_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_reserved_domains_on_whodunnit ON public.log_reserved_domains USING btree (whodunnit);


--
-- Name: index_log_settings_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_settings_on_item_type_and_item_id ON public.log_settings USING btree (item_type, item_id);


--
-- Name: index_log_settings_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_settings_on_whodunnit ON public.log_settings USING btree (whodunnit);


--
-- Name: index_log_users_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_users_on_item_type_and_item_id ON public.log_users USING btree (item_type, item_id);


--
-- Name: index_log_users_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_users_on_whodunnit ON public.log_users USING btree (whodunnit);


--
-- Name: index_nameservers_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nameservers_on_domain_id ON public.nameservers USING btree (domain_id);


--
-- Name: index_notifications_on_registrar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_registrar_id ON public.notifications USING btree (registrar_id);


--
-- Name: index_prices_on_zone_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_prices_on_zone_id ON public.prices USING btree (zone_id);


--
-- Name: index_registrant_verifications_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_registrant_verifications_on_created_at ON public.registrant_verifications USING btree (created_at);


--
-- Name: index_registrant_verifications_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_registrant_verifications_on_domain_id ON public.registrant_verifications USING btree (domain_id);


--
-- Name: index_settings_on_thing_type_and_thing_id_and_var; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_settings_on_thing_type_and_thing_id_and_var ON public.settings USING btree (thing_type, thing_id, var);


--
-- Name: index_users_on_identity_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_identity_code ON public.users USING btree (identity_code);


--
-- Name: index_users_on_registrar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_registrar_id ON public.users USING btree (registrar_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: index_whois_records_on_domain_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_whois_records_on_domain_id ON public.whois_records USING btree (domain_id);


--
-- Name: index_whois_records_on_registrar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_whois_records_on_registrar_id ON public.whois_records USING btree (registrar_id);


--
-- Name: log_contacts_object_legacy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX log_contacts_object_legacy_id ON public.log_contacts USING btree ((((object ->> 'legacy_id'::text))::integer));


--
-- Name: log_dnskeys_object_legacy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX log_dnskeys_object_legacy_id ON public.log_contacts USING btree ((((object ->> 'legacy_domain_id'::text))::integer));


--
-- Name: log_domains_object_legacy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX log_domains_object_legacy_id ON public.log_contacts USING btree ((((object ->> 'legacy_id'::text))::integer));


--
-- Name: log_nameservers_object_legacy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX log_nameservers_object_legacy_id ON public.log_contacts USING btree ((((object ->> 'legacy_domain_id'::text))::integer));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: contacts_registrar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_registrar_id_fk FOREIGN KEY (registrar_id) REFERENCES public.registrars(id);


--
-- Name: domain_contacts_contact_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domain_contacts
    ADD CONSTRAINT domain_contacts_contact_id_fk FOREIGN KEY (contact_id) REFERENCES public.contacts(id);


--
-- Name: domain_contacts_domain_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domain_contacts
    ADD CONSTRAINT domain_contacts_domain_id_fk FOREIGN KEY (domain_id) REFERENCES public.domains(id);


--
-- Name: domains_registrant_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_registrant_id_fk FOREIGN KEY (registrant_id) REFERENCES public.contacts(id);


--
-- Name: domains_registrar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_registrar_id_fk FOREIGN KEY (registrar_id) REFERENCES public.registrars(id);


--
-- Name: fk_rails_242b91538b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT fk_rails_242b91538b FOREIGN KEY (buyer_id) REFERENCES public.registrars(id);


--
-- Name: fk_rails_36cff3de9c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.white_ips
    ADD CONSTRAINT fk_rails_36cff3de9c FOREIGN KEY (registrar_id) REFERENCES public.registrars(id);


--
-- Name: fk_rails_59c422f73d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domain_transfers
    ADD CONSTRAINT fk_rails_59c422f73d FOREIGN KEY (old_registrar_id) REFERENCES public.registrars(id);


--
-- Name: fk_rails_78c376257f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prices
    ADD CONSTRAINT fk_rails_78c376257f FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: fk_rails_833ed7f3c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domain_transfers
    ADD CONSTRAINT fk_rails_833ed7f3c0 FOREIGN KEY (new_registrar_id) REFERENCES public.registrars(id);


--
-- Name: fk_rails_86cd2b09f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_activities
    ADD CONSTRAINT fk_rails_86cd2b09f5 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: fk_rails_87b8e40c63; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domain_transfers
    ADD CONSTRAINT fk_rails_87b8e40c63 FOREIGN KEY (domain_id) REFERENCES public.domains(id);


--
-- Name: fk_rails_8c6b5c12eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT fk_rails_8c6b5c12eb FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_8f9734b530; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_rails_8f9734b530 FOREIGN KEY (action_id) REFERENCES public.actions(id);


--
-- Name: fk_rails_a5ae3c203d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT fk_rails_a5ae3c203d FOREIGN KEY (contact_id) REFERENCES public.contacts(id);


--
-- Name: fk_rails_adff2dc8e3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.epp_sessions
    ADD CONSTRAINT fk_rails_adff2dc8e3 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: fk_rails_b80dbb973d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_activities
    ADD CONSTRAINT fk_rails_b80dbb973d FOREIGN KEY (bank_transaction_id) REFERENCES public.bank_transactions(id);


--
-- Name: fk_rails_c9f635c0b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT fk_rails_c9f635c0b3 FOREIGN KEY (registrar_id) REFERENCES public.registrars(id);


--
-- Name: fk_rails_ce38d749f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_activities
    ADD CONSTRAINT fk_rails_ce38d749f6 FOREIGN KEY (invoice_id) REFERENCES public.invoices(id);


--
-- Name: fk_rails_d2cc3c2fa9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_activities
    ADD CONSTRAINT fk_rails_d2cc3c2fa9 FOREIGN KEY (price_id) REFERENCES public.prices(id);


--
-- Name: fk_rails_f41617a0e9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrant_verifications
    ADD CONSTRAINT fk_rails_f41617a0e9 FOREIGN KEY (domain_id) REFERENCES public.domains(id);


--
-- Name: invoice_items_invoice_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_invoice_id_fk FOREIGN KEY (invoice_id) REFERENCES public.invoices(id);


--
-- Name: messages_registrar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT messages_registrar_id_fk FOREIGN KEY (registrar_id) REFERENCES public.registrars(id);


--
-- Name: nameservers_domain_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nameservers
    ADD CONSTRAINT nameservers_domain_id_fk FOREIGN KEY (domain_id) REFERENCES public.domains(id);


--
-- Name: user_registrar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_registrar_id_fk FOREIGN KEY (registrar_id) REFERENCES public.registrars(id);


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

INSERT INTO schema_migrations (version) VALUES ('20170423151046');

INSERT INTO schema_migrations (version) VALUES ('20170423210622');

INSERT INTO schema_migrations (version) VALUES ('20170423214500');

INSERT INTO schema_migrations (version) VALUES ('20170423222302');

INSERT INTO schema_migrations (version) VALUES ('20170423225333');

INSERT INTO schema_migrations (version) VALUES ('20170424115801');

INSERT INTO schema_migrations (version) VALUES ('20170506144743');

INSERT INTO schema_migrations (version) VALUES ('20170506155009');

INSERT INTO schema_migrations (version) VALUES ('20170506162952');

INSERT INTO schema_migrations (version) VALUES ('20170506205356');

INSERT INTO schema_migrations (version) VALUES ('20170506205946');

INSERT INTO schema_migrations (version) VALUES ('20170506212014');

INSERT INTO schema_migrations (version) VALUES ('20170509215614');

INSERT INTO schema_migrations (version) VALUES ('20170604182521');

INSERT INTO schema_migrations (version) VALUES ('20170606133501');

INSERT INTO schema_migrations (version) VALUES ('20170606150352');

INSERT INTO schema_migrations (version) VALUES ('20170606202859');

INSERT INTO schema_migrations (version) VALUES ('20171009080822');

INSERT INTO schema_migrations (version) VALUES ('20171009082321');

INSERT INTO schema_migrations (version) VALUES ('20171025113808');

INSERT INTO schema_migrations (version) VALUES ('20171025153841');

INSERT INTO schema_migrations (version) VALUES ('20171121233843');

INSERT INTO schema_migrations (version) VALUES ('20171123035941');

INSERT INTO schema_migrations (version) VALUES ('20180112080312');

INSERT INTO schema_migrations (version) VALUES ('20180112084221');

INSERT INTO schema_migrations (version) VALUES ('20180112084442');

INSERT INTO schema_migrations (version) VALUES ('20180120172042');

INSERT INTO schema_migrations (version) VALUES ('20180120172649');

INSERT INTO schema_migrations (version) VALUES ('20180120172657');

INSERT INTO schema_migrations (version) VALUES ('20180120182712');

INSERT INTO schema_migrations (version) VALUES ('20180120183441');

INSERT INTO schema_migrations (version) VALUES ('20180121165304');

INSERT INTO schema_migrations (version) VALUES ('20180122105335');

INSERT INTO schema_migrations (version) VALUES ('20180123154407');

INSERT INTO schema_migrations (version) VALUES ('20180123165604');

INSERT INTO schema_migrations (version) VALUES ('20180123170112');

INSERT INTO schema_migrations (version) VALUES ('20180125092422');

INSERT INTO schema_migrations (version) VALUES ('20180126104536');

INSERT INTO schema_migrations (version) VALUES ('20180126104903');

INSERT INTO schema_migrations (version) VALUES ('20180129143538');

INSERT INTO schema_migrations (version) VALUES ('20180129232054');

INSERT INTO schema_migrations (version) VALUES ('20180129233223');

INSERT INTO schema_migrations (version) VALUES ('20180206213435');

INSERT INTO schema_migrations (version) VALUES ('20180206234620');

INSERT INTO schema_migrations (version) VALUES ('20180207071528');

INSERT INTO schema_migrations (version) VALUES ('20180207072139');

INSERT INTO schema_migrations (version) VALUES ('20180211011450');

INSERT INTO schema_migrations (version) VALUES ('20180211011948');

INSERT INTO schema_migrations (version) VALUES ('20180212123810');

INSERT INTO schema_migrations (version) VALUES ('20180212152810');

INSERT INTO schema_migrations (version) VALUES ('20180212154731');

INSERT INTO schema_migrations (version) VALUES ('20180213183818');

INSERT INTO schema_migrations (version) VALUES ('20180214200224');

INSERT INTO schema_migrations (version) VALUES ('20180214213743');

INSERT INTO schema_migrations (version) VALUES ('20180218004148');

INSERT INTO schema_migrations (version) VALUES ('20180228055259');

INSERT INTO schema_migrations (version) VALUES ('20180228064342');

INSERT INTO schema_migrations (version) VALUES ('20180228070102');

INSERT INTO schema_migrations (version) VALUES ('20180228070431');

INSERT INTO schema_migrations (version) VALUES ('20180228074442');

INSERT INTO schema_migrations (version) VALUES ('20180306180401');

INSERT INTO schema_migrations (version) VALUES ('20180306181538');

INSERT INTO schema_migrations (version) VALUES ('20180306181554');

INSERT INTO schema_migrations (version) VALUES ('20180306181911');

INSERT INTO schema_migrations (version) VALUES ('20180306182456');

INSERT INTO schema_migrations (version) VALUES ('20180306182758');

INSERT INTO schema_migrations (version) VALUES ('20180306182941');

INSERT INTO schema_migrations (version) VALUES ('20180306183540');

INSERT INTO schema_migrations (version) VALUES ('20180306183549');

INSERT INTO schema_migrations (version) VALUES ('20180308123240');

INSERT INTO schema_migrations (version) VALUES ('20180309053424');

INSERT INTO schema_migrations (version) VALUES ('20180309053921');

INSERT INTO schema_migrations (version) VALUES ('20180309054510');

INSERT INTO schema_migrations (version) VALUES ('20180310142630');

INSERT INTO schema_migrations (version) VALUES ('20180313090437');

INSERT INTO schema_migrations (version) VALUES ('20180313124751');

INSERT INTO schema_migrations (version) VALUES ('20180314122722');

INSERT INTO schema_migrations (version) VALUES ('20180327151906');

INSERT INTO schema_migrations (version) VALUES ('20180331200125');

INSERT INTO schema_migrations (version) VALUES ('20180422154642');

INSERT INTO schema_migrations (version) VALUES ('20180612042234');

INSERT INTO schema_migrations (version) VALUES ('20180612042625');

INSERT INTO schema_migrations (version) VALUES ('20180612042953');

INSERT INTO schema_migrations (version) VALUES ('20180613030330');

INSERT INTO schema_migrations (version) VALUES ('20180613045614');

INSERT INTO schema_migrations (version) VALUES ('20180713154915');

INSERT INTO schema_migrations (version) VALUES ('20180808064402');

INSERT INTO schema_migrations (version) VALUES ('20180816123540');

INSERT INTO schema_migrations (version) VALUES ('20180823161237');

INSERT INTO schema_migrations (version) VALUES ('20180823163548');

INSERT INTO schema_migrations (version) VALUES ('20180823174331');

INSERT INTO schema_migrations (version) VALUES ('20180823212823');

INSERT INTO schema_migrations (version) VALUES ('20180824092855');

INSERT INTO schema_migrations (version) VALUES ('20180824102834');

INSERT INTO schema_migrations (version) VALUES ('20180824215326');

INSERT INTO schema_migrations (version) VALUES ('20180825193437');

INSERT INTO schema_migrations (version) VALUES ('20180825232819');

INSERT INTO schema_migrations (version) VALUES ('20180826162821');

INSERT INTO schema_migrations (version) VALUES ('20181001090536');

INSERT INTO schema_migrations (version) VALUES ('20181002090319');

INSERT INTO schema_migrations (version) VALUES ('20181017092829');

INSERT INTO schema_migrations (version) VALUES ('20181017153658');

INSERT INTO schema_migrations (version) VALUES ('20181017153812');

INSERT INTO schema_migrations (version) VALUES ('20181017153935');

INSERT INTO schema_migrations (version) VALUES ('20181017154038');

INSERT INTO schema_migrations (version) VALUES ('20181017154143');

INSERT INTO schema_migrations (version) VALUES ('20181017205123');

INSERT INTO schema_migrations (version) VALUES ('20181022100114');

INSERT INTO schema_migrations (version) VALUES ('20181108154921');

INSERT INTO schema_migrations (version) VALUES ('20181129150515');

INSERT INTO schema_migrations (version) VALUES ('20181212105100');

INSERT INTO schema_migrations (version) VALUES ('20181212145456');

INSERT INTO schema_migrations (version) VALUES ('20181212145914');

INSERT INTO schema_migrations (version) VALUES ('20181213113115');

INSERT INTO schema_migrations (version) VALUES ('20181217144701');

INSERT INTO schema_migrations (version) VALUES ('20181217144845');

INSERT INTO schema_migrations (version) VALUES ('20181220094738');

INSERT INTO schema_migrations (version) VALUES ('20181220095053');

INSERT INTO schema_migrations (version) VALUES ('20181223153407');

INSERT INTO schema_migrations (version) VALUES ('20181226211337');

INSERT INTO schema_migrations (version) VALUES ('20181227155537');

INSERT INTO schema_migrations (version) VALUES ('20181227172042');

INSERT INTO schema_migrations (version) VALUES ('20181230231015');

INSERT INTO schema_migrations (version) VALUES ('20190102114702');

INSERT INTO schema_migrations (version) VALUES ('20190102115333');

INSERT INTO schema_migrations (version) VALUES ('20190102144032');

INSERT INTO schema_migrations (version) VALUES ('20190209150026');

INSERT INTO schema_migrations (version) VALUES ('20190302091059');

INSERT INTO schema_migrations (version) VALUES ('20190302111152');

INSERT INTO schema_migrations (version) VALUES ('20190311111718');

INSERT INTO schema_migrations (version) VALUES ('20190312211614');

INSERT INTO schema_migrations (version) VALUES ('20190315172802');

INSERT INTO schema_migrations (version) VALUES ('20190319133036');

INSERT INTO schema_migrations (version) VALUES ('20190322152123');

INSERT INTO schema_migrations (version) VALUES ('20190322152529');

INSERT INTO schema_migrations (version) VALUES ('20190328151516');

INSERT INTO schema_migrations (version) VALUES ('20190328151838');

INSERT INTO schema_migrations (version) VALUES ('20190415120246');

INSERT INTO schema_migrations (version) VALUES ('20190426174225');

INSERT INTO schema_migrations (version) VALUES ('20190506100655');

INSERT INTO schema_migrations (version) VALUES ('20190510090240');

INSERT INTO schema_migrations (version) VALUES ('20190510102549');

INSERT INTO schema_migrations (version) VALUES ('20190515113153');

INSERT INTO schema_migrations (version) VALUES ('20190516161439');

INSERT INTO schema_migrations (version) VALUES ('20190520093231');

INSERT INTO schema_migrations (version) VALUES ('20190617120112');

INSERT INTO schema_migrations (version) VALUES ('20190617121716');

INSERT INTO schema_migrations (version) VALUES ('20190617121949');

INSERT INTO schema_migrations (version) VALUES ('20190617122505');

INSERT INTO schema_migrations (version) VALUES ('20190620084334');

INSERT INTO schema_migrations (version) VALUES ('20190811184334');

INSERT INTO schema_migrations (version) VALUES ('20190811195814');

INSERT INTO schema_migrations (version) VALUES ('20190811202042');

INSERT INTO schema_migrations (version) VALUES ('20190811202347');

INSERT INTO schema_migrations (version) VALUES ('20190811202711');

INSERT INTO schema_migrations (version) VALUES ('20190811205406');

INSERT INTO schema_migrations (version) VALUES ('20191004095229');

INSERT INTO schema_migrations (version) VALUES ('20191004103144');

INSERT INTO schema_migrations (version) VALUES ('20191004105643');

INSERT INTO schema_migrations (version) VALUES ('20191004105732');

INSERT INTO schema_migrations (version) VALUES ('20191004110234');

INSERT INTO schema_migrations (version) VALUES ('20191004154844');

INSERT INTO schema_migrations (version) VALUES ('20191005162437');

INSERT INTO schema_migrations (version) VALUES ('20191007123000');

INSERT INTO schema_migrations (version) VALUES ('20191008024334');

