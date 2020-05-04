--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
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
            AND (ns.hostname LIKE '%.' || d.name) OR (ns.hostname LIKE d.name)
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
            AND (ns.hostname LIKE '%.' || d.name) OR (ns.hostname LIKE d.name)
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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


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
    name character varying NOT NULL,
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
    locked_by_registrant_at timestamp without time zone,
    force_delete_start timestamp without time zone,
    force_delete_data public.hstore
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
    updator_str character varying,
    CONSTRAINT invoice_items_quantity_is_positive CHECK ((quantity > 0))
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
    issue_date date NOT NULL,
    e_invoice_sent_at timestamp without time zone,
    CONSTRAINT invoices_due_date_is_not_before_issue_date CHECK ((due_date >= issue_date))
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
-- Name: log_payment_orders; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.log_payment_orders (
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
-- Name: log_payment_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.log_payment_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_payment_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_payment_orders_id_seq OWNED BY public.log_payment_orders.id;


--
-- Name: log_registrant_verifications; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.log_registrant_verifications (
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
-- Name: log_registrant_verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.log_registrant_verifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_registrant_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_registrant_verifications_id_seq OWNED BY public.log_registrant_verifications.id;


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
-- Name: payment_orders; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.payment_orders (
    id integer NOT NULL,
    type character varying NOT NULL,
    status character varying DEFAULT 'issued'::character varying NOT NULL,
    invoice_id integer,
    response jsonb,
    notes character varying,
    creator_str character varying,
    updator_str character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: payment_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_orders_id_seq OWNED BY public.payment_orders.id;


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
    verification_token character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    action character varying NOT NULL,
    domain_id integer NOT NULL,
    action_type character varying NOT NULL,
    creator_id integer,
    updater_id integer
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

ALTER TABLE ONLY public.log_nameservers ALTER COLUMN id SET DEFAULT nextval('public.log_nameservers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_notifications ALTER COLUMN id SET DEFAULT nextval('public.log_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_payment_orders ALTER COLUMN id SET DEFAULT nextval('public.log_payment_orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_registrant_verifications ALTER COLUMN id SET DEFAULT nextval('public.log_registrant_verifications_id_seq'::regclass);


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

ALTER TABLE ONLY public.payment_orders ALTER COLUMN id SET DEFAULT nextval('public.payment_orders_id_seq'::regclass);


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
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


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
-- Name: log_payment_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.log_payment_orders
    ADD CONSTRAINT log_payment_orders_pkey PRIMARY KEY (id);


--
-- Name: log_registrant_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.log_registrant_verifications
    ADD CONSTRAINT log_registrant_verifications_pkey PRIMARY KEY (id);


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
-- Name: payment_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.payment_orders
    ADD CONSTRAINT payment_orders_pkey PRIMARY KEY (id);


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
-- Name: index_log_registrant_verifications_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_log_registrant_verifications_on_item_type_and_item_id ON public.log_registrant_verifications USING btree (item_type, item_id);


--
-- Name: index_log_registrant_verifications_on_whodunnit; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_log_registrant_verifications_on_whodunnit ON public.log_registrant_verifications USING btree (whodunnit);


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
-- Name: index_payment_orders_on_invoice_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_payment_orders_on_invoice_id ON public.payment_orders USING btree (invoice_id);


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
-- Name: fk_rails_f9dc5857c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_orders
    ADD CONSTRAINT fk_rails_f9dc5857c3 FOREIGN KEY (invoice_id) REFERENCES public.invoices(id);


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

INSERT INTO "schema_migrations" (version) VALUES
('20140616073945'),
('20140620130107'),
('20140627082711'),
('20140701130945'),
('20140702144833'),
('20140702145448'),
('20140724084927'),
('20140730082358'),
('20140730082532'),
('20140730104916'),
('20140730141443'),
('20140731073300'),
('20140731081816'),
('20140801140249'),
('20140804095654'),
('20140808132327'),
('20140813102245'),
('20140813135408'),
('20140815082619'),
('20140815110028'),
('20140815114000'),
('20140819095802'),
('20140819103517'),
('20140822122938'),
('20140826082057'),
('20140826103454'),
('20140827140759'),
('20140828072329'),
('20140828074404'),
('20140828080320'),
('20140828133057'),
('20140902121843'),
('20140911101310'),
('20140911101604'),
('20140925073340'),
('20140925073734'),
('20140925073831'),
('20140925084916'),
('20140925085340'),
('20140925101927'),
('20140926081324'),
('20140926082627'),
('20140926121409'),
('20140929095329'),
('20140930093039'),
('20141001085322'),
('20141006124904'),
('20141006130306'),
('20141008134959'),
('20141009100818'),
('20141009101337'),
('20141010085152'),
('20141010130412'),
('20141014073435'),
('20141015135255'),
('20141015135742'),
('20141105150721'),
('20141111105931'),
('20141114130737'),
('20141120110330'),
('20141120140837'),
('20141121093125'),
('20141124105221'),
('20141125111414'),
('20141126140434'),
('20141127091027'),
('20141202114457'),
('20141203090115'),
('20141210085432'),
('20141211095604'),
('20141215085117'),
('20141216075056'),
('20141216133831'),
('20141218154829'),
('20141229115619'),
('20150105134026'),
('20150109081914'),
('20150110000000'),
('20150110113257'),
('20150122091556'),
('20150122091557'),
('20150128134352'),
('20150129093938'),
('20150129144652'),
('20150130085458'),
('20150130155904'),
('20150130180452'),
('20150130191056'),
('20150200000000'),
('20150202084444'),
('20150202140346'),
('20150203135303'),
('20150212125339'),
('20150213104014'),
('20150217133755'),
('20150217133937'),
('20150223104842'),
('20150226121252'),
('20150226144723'),
('20150227092508'),
('20150227113121'),
('20150302161712'),
('20150303130729'),
('20150303151224'),
('20150305092921'),
('20150318084300'),
('20150318085110'),
('20150318114921'),
('20150319125655'),
('20150320132023'),
('20150330083700'),
('20150402114712'),
('20150407145943'),
('20150408081917'),
('20150410124724'),
('20150410132037'),
('20150413080832'),
('20150413102310'),
('20150413115829'),
('20150413140933'),
('20150414092249'),
('20150414124630'),
('20150414151357'),
('20150415075408'),
('20150416080828'),
('20150416091357'),
('20150416092026'),
('20150416094704'),
('20150417082723'),
('20150421134820'),
('20150422092514'),
('20150422132631'),
('20150422134243'),
('20150423083308'),
('20150427073517'),
('20150428075052'),
('20150429135339'),
('20150430121807'),
('20150504104922'),
('20150504110926'),
('20150505111437'),
('20150511120755'),
('20150512160938'),
('20150513080013'),
('20150514132606'),
('20150515103222'),
('20150518084324'),
('20150519094929'),
('20150519095416'),
('20150519102521'),
('20150519115050'),
('20150519140853'),
('20150519144118'),
('20150520163237'),
('20150520164507'),
('20150521120145'),
('20150522164020'),
('20150525075550'),
('20150601083516'),
('20150601083800'),
('20150603141549'),
('20150603211318'),
('20150603212659'),
('20150609093515'),
('20150609103333'),
('20150610111019'),
('20150610112238'),
('20150610144547'),
('20150611124920'),
('20150612123111'),
('20150612125720'),
('20150701074344'),
('20150703084206'),
('20150703084632'),
('20150706091724'),
('20150707103241'),
('20150707103801'),
('20150707104937'),
('20150707154543'),
('20150709092549'),
('20150713113436'),
('20150722071128'),
('20150803080914'),
('20150810114746'),
('20150810114747'),
('20150825125118'),
('20150827151906'),
('20150903105659'),
('20150910113839'),
('20150915094707'),
('20150921110152'),
('20150921111842'),
('20151028183132'),
('20151029152638'),
('20151112160452'),
('20151117081204'),
('20151120090455'),
('20151124200353'),
('20151125155601'),
('20151127091716'),
('20151130175654'),
('20151202123506'),
('20151209122816'),
('20160106101725'),
('20160108135436'),
('20160113143447'),
('20160118092453'),
('20160118092454'),
('20160218102355'),
('20160225113801'),
('20160225113812'),
('20160226132045'),
('20160226132056'),
('20160304125933'),
('20160311085956'),
('20160311085957'),
('20160405131315'),
('20160411140719'),
('20160414110443'),
('20160421074023'),
('20160429114732'),
('20160527110738'),
('20160629114503'),
('20161004101419'),
('20161227193500'),
('20170221115548'),
('20170419120048'),
('20170420125200'),
('20170422130054'),
('20170422142116'),
('20170422162824'),
('20170423151046'),
('20170423210622'),
('20170423214500'),
('20170423222302'),
('20170423225333'),
('20170424115801'),
('20170506144743'),
('20170506155009'),
('20170506162952'),
('20170506205356'),
('20170506205946'),
('20170506212014'),
('20170509215614'),
('20170604182521'),
('20170606133501'),
('20170606150352'),
('20170606202859'),
('20171009080822'),
('20171009082321'),
('20171025113808'),
('20171025153841'),
('20171121233843'),
('20171123035941'),
('20180112080312'),
('20180112084221'),
('20180112084442'),
('20180120172042'),
('20180120172649'),
('20180120172657'),
('20180120182712'),
('20180120183441'),
('20180121165304'),
('20180122105335'),
('20180123154407'),
('20180123165604'),
('20180123170112'),
('20180125092422'),
('20180126104536'),
('20180126104903'),
('20180129143538'),
('20180129232054'),
('20180129233223'),
('20180206213435'),
('20180206234620'),
('20180207071528'),
('20180207072139'),
('20180211011450'),
('20180211011948'),
('20180212123810'),
('20180212152810'),
('20180212154731'),
('20180213183818'),
('20180214200224'),
('20180214213743'),
('20180218004148'),
('20180228055259'),
('20180228064342'),
('20180228070102'),
('20180228070431'),
('20180228074442'),
('20180306180401'),
('20180306181538'),
('20180306181554'),
('20180306181911'),
('20180306182456'),
('20180306182758'),
('20180306182941'),
('20180306183540'),
('20180306183549'),
('20180308123240'),
('20180309053424'),
('20180309053921'),
('20180309054510'),
('20180310142630'),
('20180313090437'),
('20180313124751'),
('20180314122722'),
('20180327151906'),
('20180331200125'),
('20180422154642'),
('20180612042234'),
('20180612042625'),
('20180612042953'),
('20180613030330'),
('20180613045614'),
('20180713154915'),
('20180801114403'),
('20180808064402'),
('20180816123540'),
('20180823161237'),
('20180823163548'),
('20180823174331'),
('20180823212823'),
('20180824092855'),
('20180824102834'),
('20180824215326'),
('20180825193437'),
('20180825232819'),
('20180826162821'),
('20181001090536'),
('20181002090319'),
('20181017092829'),
('20181017153658'),
('20181017153812'),
('20181017153935'),
('20181017154038'),
('20181017154143'),
('20181017205123'),
('20181022100114'),
('20181108154921'),
('20181129150515'),
('20181212105100'),
('20181212145456'),
('20181212145914'),
('20181213113115'),
('20181217144701'),
('20181217144845'),
('20181220094738'),
('20181220095053'),
('20181223153407'),
('20181226211337'),
('20181227155537'),
('20181227172042'),
('20181230231015'),
('20190102114702'),
('20190102115333'),
('20190102144032'),
('20190209150026'),
('20190302091059'),
('20190302111152'),
('20190311111718'),
('20190312211614'),
('20190315172802'),
('20190319133036'),
('20190322152123'),
('20190322152529'),
('20190328151516'),
('20190328151838'),
('20190415120246'),
('20190426174225'),
('20190506100655'),
('20190510090240'),
('20190510102549'),
('20190515113153'),
('20190516161439'),
('20190520093231'),
('20190617120112'),
('20190617121716'),
('20190617121949'),
('20190617122505'),
('20190620084334'),
('20190811184334'),
('20190811195814'),
('20190811202042'),
('20190811202347'),
('20190811202711'),
('20190811205406'),
('20190917114907'),
('20191004095229'),
('20191004103144'),
('20191004105643'),
('20191004105732'),
('20191004110234'),
('20191004154844'),
('20191005162437'),
('20191007123000'),
('20191008024334'),
('20191024153351'),
('20191024160038'),
('20191203083643'),
('20191206183853'),
('20191212133136'),
('20191227110904'),
('20200113091254'),
('20200115102202'),
('20200130092113'),
('20200203143458'),
('20200204103125'),
('20200311114649');

