SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: address; Type: TABLE; Schema: public; Owner: postgres
--
CREATE SCHEMA staging
CREATE TABLE staging.address (
    address_id integer NOT NULL,
    street_number character varying(10),
    street_name character varying(200),
    city character varying(100),
    country_id integer,
	created_at timestamp default now()
);


ALTER TABLE staging.address OWNER TO postgres;

--
-- Name: address_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.address_status (
    status_id integer NOT NULL,
    address_status character varying(30),
	created_at timestamp default now()
);


ALTER TABLE staging.address_status OWNER TO postgres;

--
-- Name: author; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.author (
    author_id integer NOT NULL,
    author_name character varying(400),
	created_at timestamp default now()
);


ALTER TABLE staging.author OWNER TO postgres;

--
-- Name: book; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.book (
    book_id integer NOT NULL,
    title character varying(400),
    isbn13 character varying(13),
    language_id integer,
    num_pages integer,
    publication_date date,
    publisher_id integer,
	created_at timestamp default now()
);


ALTER TABLE staging.book OWNER TO postgres;

--
-- Name: book_author; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.book_author (
    book_id integer NOT NULL,
    author_id integer NOT NULL,
	created_at timestamp default now()
);


ALTER TABLE staging.book_author OWNER TO postgres;

--
-- Name: book_language; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.book_language (
    language_id integer NOT NULL,
    language_code character varying(8),
    language_name character varying(50),
	created_at timestamp default now()
);


ALTER TABLE staging.book_language OWNER TO postgres;

--
-- Name: country; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.country (
    country_id integer NOT NULL,
    country_name character varying(200),
	created_at timestamp default now()
);


ALTER TABLE staging.country OWNER TO postgres;

--
-- Name: cust_order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.cust_order (
    order_id integer NOT NULL,
    order_date timestamp without time zone,
    customer_id integer,
    shipping_method_id integer,
    dest_address_id integer,
	created_at timestamp default now()
);


ALTER TABLE staging.cust_order OWNER TO postgres;

--
-- Name: cust_order_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE staging.cust_order_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE staging.cust_order_order_id_seq OWNER TO postgres;

--
-- Name: cust_order_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE staging.cust_order_order_id_seq OWNED BY staging.cust_order.order_id;


--
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.customer (
    customer_id integer NOT NULL,
    first_name character varying(200),
    last_name character varying(200),
    email character varying(350),
	created_at timestamp default now()
);


ALTER TABLE staging.customer OWNER TO postgres;

--
-- Name: customer_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.customer_address (
    customer_id integer NOT NULL,
    address_id integer NOT NULL,
    status_id integer,
	created_at timestamp default now()
);


ALTER TABLE staging.customer_address OWNER TO postgres;

--
-- Name: order_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.order_history (
    history_id integer NOT NULL,
    order_id integer,
    status_id integer,
    status_date timestamp without time zone,
	created_at timestamp default now()
);


ALTER TABLE staging.order_history OWNER TO postgres;

--
-- Name: order_history_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE staging.order_history_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE staging.order_history_history_id_seq OWNER TO postgres;

--
-- Name: order_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE staging.order_history_history_id_seq OWNED BY staging.order_history.history_id;


--
-- Name: order_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.order_line (
    line_id integer NOT NULL,
    order_id integer,
    book_id integer,
    price numeric(5,2),
	created_at timestamp default now()
);


ALTER TABLE staging.order_line OWNER TO postgres;

--
-- Name: order_line_line_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE staging.order_line_line_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE staging.order_line_line_id_seq OWNER TO postgres;

--
-- Name: order_line_line_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE staging.order_line_line_id_seq OWNED BY staging.order_line.line_id;


--
-- Name: order_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.order_status (
    status_id integer NOT NULL,
    status_value character varying(20),
	created_at timestamp default now()
);


ALTER TABLE staging.order_status OWNER TO postgres;

--
-- Name: publisher; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.publisher (
    publisher_id integer NOT NULL,
    publisher_name character varying(400),
	created_at timestamp default now()
);


ALTER TABLE staging.publisher OWNER TO postgres;

--
-- Name: shipping_method; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE staging.shipping_method (
    method_id integer NOT NULL,
    method_name character varying(100),
    cost numeric(6,2),
	created_at timestamp default now()
);


ALTER TABLE staging.shipping_method OWNER TO postgres;

--
-- Name: cust_order order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY staging.cust_order ALTER COLUMN order_id SET DEFAULT nextval('staging.cust_order_order_id_seq'::regclass);


--
-- Name: order_history history_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY staging.order_history ALTER COLUMN history_id SET DEFAULT nextval('staging.order_history_history_id_seq'::regclass);


--
-- Name: order_line line_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY staging.order_line ALTER COLUMN line_id SET DEFAULT nextval('staging.order_line_line_id_seq'::regclass);


--
-- Data for Name: address; Type: TABLE DATA; Schema: public; Owner: postgres
--