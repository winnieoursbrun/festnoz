SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: immutable_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.immutable_unaccent(input_text text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$SELECT public.unaccent(input_text);$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: artists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artists (
    id bigint NOT NULL,
    country character varying,
    created_at timestamp(6) without time zone NOT NULL,
    description text,
    genre character varying,
    image_url character varying,
    name character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    website character varying,
    audiodb_id character varying,
    biography text,
    fanart_url character varying,
    banner_url character varying,
    logo_url character varying,
    thumbnail_url character varying,
    music_style character varying,
    formed_year integer,
    disbanded_year integer,
    facebook_url character varying,
    twitter_handle character varying,
    audiodb_enriched_at timestamp(6) without time zone,
    audiodb_status character varying,
    spotify_id character varying,
    spotify_url character varying,
    popularity integer,
    ticketmaster_id character varying,
    ticketmaster_url character varying,
    ticketmaster_name character varying
);


--
-- Name: artists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artists_id_seq OWNED BY public.artists.id;


--
-- Name: concerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.concerts (
    id bigint NOT NULL,
    artist_id bigint NOT NULL,
    city character varying NOT NULL,
    country character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    description text,
    ends_at timestamp(6) without time zone,
    latitude numeric(10,6) NOT NULL,
    longitude numeric(10,6) NOT NULL,
    price numeric(10,2),
    price_currency character varying DEFAULT 'EUR'::character varying,
    starts_at timestamp(6) without time zone NOT NULL,
    ticket_url character varying,
    title character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    venue_address character varying,
    venue_name character varying NOT NULL
);


--
-- Name: concerts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.concerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: concerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.concerts_id_seq OWNED BY public.concerts.id;


--
-- Name: jwt_denylist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jwt_denylist (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    exp timestamp(6) without time zone NOT NULL,
    jti character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: jwt_denylist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jwt_denylist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jwt_denylist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jwt_denylist_id_seq OWNED BY public.jwt_denylist.id;


--
-- Name: push_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.push_subscriptions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    endpoint text NOT NULL,
    p256dh_key character varying NOT NULL,
    auth_key character varying NOT NULL,
    expiration_time timestamp(6) without time zone,
    user_agent character varying,
    last_seen_at timestamp(6) without time zone,
    revoked_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: push_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.push_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: push_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.push_subscriptions_id_seq OWNED BY public.push_subscriptions.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: suggested_artists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suggested_artists (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    artist_id bigint NOT NULL,
    spotify_artist_id character varying,
    rank integer,
    synced_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: suggested_artists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.suggested_artists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: suggested_artists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.suggested_artists_id_seq OWNED BY public.suggested_artists.id;


--
-- Name: ticketmaster_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticketmaster_events (
    id bigint NOT NULL,
    concert_id bigint NOT NULL,
    artist_id bigint NOT NULL,
    ticketmaster_event_id character varying NOT NULL,
    name character varying,
    event_url character varying,
    locale character varying,
    status_code character varying,
    price_min numeric(10,2),
    price_max numeric(10,2),
    price_currency character varying,
    price_type character varying,
    starts_at timestamp(6) without time zone,
    sales_start_at timestamp(6) without time zone,
    sales_end_at timestamp(6) without time zone,
    last_synced_at timestamp(6) without time zone NOT NULL,
    info text,
    please_note text,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticketmaster_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticketmaster_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticketmaster_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticketmaster_events_id_seq OWNED BY public.ticketmaster_events.id;


--
-- Name: user_artists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_artists (
    id bigint NOT NULL,
    artist_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: user_artists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_artists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_artists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_artists_id_seq OWNED BY public.user_artists.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    admin boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    current_sign_in_at timestamp(6) without time zone,
    current_sign_in_ip character varying,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    last_sign_in_at timestamp(6) without time zone,
    last_sign_in_ip character varying,
    remember_created_at timestamp(6) without time zone,
    reset_password_sent_at timestamp(6) without time zone,
    reset_password_token character varying,
    sign_in_count integer DEFAULT 0 NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    username character varying NOT NULL,
    provider character varying,
    uid character varying,
    spotify_access_token text,
    spotify_refresh_token text,
    spotify_token_expires_at timestamp(6) without time zone,
    jti character varying NOT NULL,
    account_deletion_token_digest character varying,
    account_deletion_requested_at timestamp(6) without time zone
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
-- Name: artists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists ALTER COLUMN id SET DEFAULT nextval('public.artists_id_seq'::regclass);


--
-- Name: concerts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concerts ALTER COLUMN id SET DEFAULT nextval('public.concerts_id_seq'::regclass);


--
-- Name: jwt_denylist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jwt_denylist ALTER COLUMN id SET DEFAULT nextval('public.jwt_denylist_id_seq'::regclass);


--
-- Name: push_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.push_subscriptions_id_seq'::regclass);


--
-- Name: suggested_artists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggested_artists ALTER COLUMN id SET DEFAULT nextval('public.suggested_artists_id_seq'::regclass);


--
-- Name: ticketmaster_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketmaster_events ALTER COLUMN id SET DEFAULT nextval('public.ticketmaster_events_id_seq'::regclass);


--
-- Name: user_artists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_artists ALTER COLUMN id SET DEFAULT nextval('public.user_artists_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: artists artists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (id);


--
-- Name: concerts concerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concerts
    ADD CONSTRAINT concerts_pkey PRIMARY KEY (id);


--
-- Name: jwt_denylist jwt_denylist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jwt_denylist
    ADD CONSTRAINT jwt_denylist_pkey PRIMARY KEY (id);


--
-- Name: push_subscriptions push_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT push_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: suggested_artists suggested_artists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggested_artists
    ADD CONSTRAINT suggested_artists_pkey PRIMARY KEY (id);


--
-- Name: ticketmaster_events ticketmaster_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketmaster_events
    ADD CONSTRAINT ticketmaster_events_pkey PRIMARY KEY (id);


--
-- Name: user_artists user_artists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_artists
    ADD CONSTRAINT user_artists_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_artists_on_audiodb_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_audiodb_id ON public.artists USING btree (audiodb_id);


--
-- Name: index_artists_on_audiodb_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_audiodb_status ON public.artists USING btree (audiodb_status);


--
-- Name: index_artists_on_genre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_genre ON public.artists USING btree (genre);


--
-- Name: index_artists_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_name ON public.artists USING btree (name);


--
-- Name: index_artists_on_name_unaccent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_name_unaccent ON public.artists USING btree (public.immutable_unaccent((name)::text));


--
-- Name: index_artists_on_spotify_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_artists_on_spotify_id ON public.artists USING btree (spotify_id);


--
-- Name: index_artists_on_ticketmaster_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_artists_on_ticketmaster_id ON public.artists USING btree (ticketmaster_id);


--
-- Name: index_artists_on_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_tsvector ON public.artists USING gin (to_tsvector('simple'::regconfig, lower(public.immutable_unaccent((name)::text))));


--
-- Name: index_concerts_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concerts_on_artist_id ON public.concerts USING btree (artist_id);


--
-- Name: index_concerts_on_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concerts_on_city ON public.concerts USING btree (city);


--
-- Name: index_concerts_on_city_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concerts_on_city_tsvector ON public.concerts USING gin (to_tsvector('simple'::regconfig, lower(public.immutable_unaccent((city)::text))));


--
-- Name: index_concerts_on_city_unaccent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concerts_on_city_unaccent ON public.concerts USING btree (public.immutable_unaccent((city)::text));


--
-- Name: index_concerts_on_latitude_and_longitude; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concerts_on_latitude_and_longitude ON public.concerts USING btree (latitude, longitude);


--
-- Name: index_concerts_on_starts_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concerts_on_starts_at ON public.concerts USING btree (starts_at);


--
-- Name: index_concerts_on_title_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concerts_on_title_tsvector ON public.concerts USING gin (to_tsvector('simple'::regconfig, lower(public.immutable_unaccent((title)::text))));


--
-- Name: index_concerts_on_title_unaccent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concerts_on_title_unaccent ON public.concerts USING btree (public.immutable_unaccent((title)::text));


--
-- Name: index_concerts_on_venue_name_unaccent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concerts_on_venue_name_unaccent ON public.concerts USING btree (public.immutable_unaccent((venue_name)::text));


--
-- Name: index_concerts_on_venue_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_concerts_on_venue_tsvector ON public.concerts USING gin (to_tsvector('simple'::regconfig, lower(public.immutable_unaccent((venue_name)::text))));


--
-- Name: index_jwt_denylist_on_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jwt_denylist_on_jti ON public.jwt_denylist USING btree (jti);


--
-- Name: index_push_subscriptions_on_endpoint; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_push_subscriptions_on_endpoint ON public.push_subscriptions USING btree (endpoint);


--
-- Name: index_push_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_push_subscriptions_on_user_id ON public.push_subscriptions USING btree (user_id);


--
-- Name: index_push_subscriptions_on_user_id_and_revoked_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_push_subscriptions_on_user_id_and_revoked_at ON public.push_subscriptions USING btree (user_id, revoked_at);


--
-- Name: index_suggested_artists_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_suggested_artists_on_artist_id ON public.suggested_artists USING btree (artist_id);


--
-- Name: index_suggested_artists_on_synced_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_suggested_artists_on_synced_at ON public.suggested_artists USING btree (synced_at);


--
-- Name: index_suggested_artists_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_suggested_artists_on_user_id ON public.suggested_artists USING btree (user_id);


--
-- Name: index_suggested_artists_on_user_id_and_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_suggested_artists_on_user_id_and_artist_id ON public.suggested_artists USING btree (user_id, artist_id);


--
-- Name: index_ticketmaster_events_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketmaster_events_on_artist_id ON public.ticketmaster_events USING btree (artist_id);


--
-- Name: index_ticketmaster_events_on_artist_id_and_starts_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketmaster_events_on_artist_id_and_starts_at ON public.ticketmaster_events USING btree (artist_id, starts_at);


--
-- Name: index_ticketmaster_events_on_concert_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketmaster_events_on_concert_id ON public.ticketmaster_events USING btree (concert_id);


--
-- Name: index_ticketmaster_events_on_starts_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticketmaster_events_on_starts_at ON public.ticketmaster_events USING btree (starts_at);


--
-- Name: index_ticketmaster_events_on_ticketmaster_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ticketmaster_events_on_ticketmaster_event_id ON public.ticketmaster_events USING btree (ticketmaster_event_id);


--
-- Name: index_user_artists_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_artists_on_artist_id ON public.user_artists USING btree (artist_id);


--
-- Name: index_user_artists_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_artists_on_user_id ON public.user_artists USING btree (user_id);


--
-- Name: index_user_artists_on_user_id_and_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_artists_on_user_id_and_artist_id ON public.user_artists USING btree (user_id, artist_id);


--
-- Name: index_users_on_account_deletion_token_digest; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_account_deletion_token_digest ON public.users USING btree (account_deletion_token_digest);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_jti ON public.users USING btree (jti);


--
-- Name: index_users_on_provider_and_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_provider_and_uid ON public.users USING btree (provider, uid);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: user_artists fk_rails_1636685173; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_artists
    ADD CONSTRAINT fk_rails_1636685173 FOREIGN KEY (artist_id) REFERENCES public.artists(id);


--
-- Name: ticketmaster_events fk_rails_1653a15677; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketmaster_events
    ADD CONSTRAINT fk_rails_1653a15677 FOREIGN KEY (artist_id) REFERENCES public.artists(id);


--
-- Name: user_artists fk_rails_21d079302c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_artists
    ADD CONSTRAINT fk_rails_21d079302c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: push_subscriptions fk_rails_43d43720fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT fk_rails_43d43720fc FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: suggested_artists fk_rails_4990526a34; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggested_artists
    ADD CONSTRAINT fk_rails_4990526a34 FOREIGN KEY (artist_id) REFERENCES public.artists(id);


--
-- Name: ticketmaster_events fk_rails_a9a8933e2d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticketmaster_events
    ADD CONSTRAINT fk_rails_a9a8933e2d FOREIGN KEY (concert_id) REFERENCES public.concerts(id);


--
-- Name: concerts fk_rails_d40a0fb5cb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concerts
    ADD CONSTRAINT fk_rails_d40a0fb5cb FOREIGN KEY (artist_id) REFERENCES public.artists(id);


--
-- Name: suggested_artists fk_rails_f1dbf5563f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggested_artists
    ADD CONSTRAINT fk_rails_f1dbf5563f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260328134906'),
('20260319200000'),
('20260318195500'),
('20260318194500'),
('20260306120000'),
('20260302110000'),
('20260108214025'),
('20260107235432'),
('20260107232257'),
('20260107230911'),
('20260107230248'),
('20260105185656'),
('20260102202532'),
('20251230120005'),
('20251230120004'),
('20251230120003'),
('20251230120002'),
('20251230120001');

