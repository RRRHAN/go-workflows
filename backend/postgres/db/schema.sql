--
-- PostgreSQL database dump
--

\restrict 06PUqkTL2m8Xz2uUVrVzF5DQ8GwEh6MCzWN7NvAszvHtXvbmmEgefbbJBDOjU3l

-- Dumped from database version 16.4 (Debian 16.4-1.pgdg120+1)
-- Dumped by pg_dump version 16.10 (Homebrew)

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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    activity_id character varying(64) NOT NULL,
    instance_id character varying(128) NOT NULL,
    execution_id character varying(128) NOT NULL,
    event_type integer NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    schedule_event_id bigint NOT NULL,
    visible_at timestamp without time zone,
    locked_until timestamp without time zone,
    worker character varying(64),
    queue character varying(128) DEFAULT ''::character varying
);


--
-- Name: attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attributes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id character varying(128) NOT NULL,
    instance_id character varying(128) NOT NULL,
    execution_id character varying(128) NOT NULL,
    data jsonb NOT NULL
);


--
-- Name: history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id character varying(64) NOT NULL,
    sequence_id bigint NOT NULL,
    instance_id character varying(128) NOT NULL,
    execution_id character varying(128) NOT NULL,
    event_type integer NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    schedule_event_id bigint NOT NULL,
    visible_at timestamp without time zone
);


--
-- Name: instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    instance_id character varying(128) NOT NULL,
    execution_id character varying(128) NOT NULL,
    parent_instance_id character varying(128),
    parent_execution_id character varying(128),
    parent_schedule_event_id bigint,
    metadata jsonb,
    state integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    completed_at timestamp without time zone,
    locked_until timestamp without time zone,
    sticky_until timestamp without time zone,
    worker character varying(64),
    queue character varying(128) DEFAULT ''::character varying
);


--
-- Name: pending_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pending_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id character varying(128) NOT NULL,
    sequence_id bigint NOT NULL,
    instance_id character varying(128) NOT NULL,
    execution_id character varying(128) NOT NULL,
    event_type integer NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    schedule_event_id bigint NOT NULL,
    visible_at timestamp without time zone
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    dirty boolean NOT NULL
);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: attributes attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_pkey PRIMARY KEY (id);


--
-- Name: history history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.history
    ADD CONSTRAINT history_pkey PRIMARY KEY (id);


--
-- Name: activities idx_activities_instance_id_execution_id_activity_id_worker; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT idx_activities_instance_id_execution_id_activity_id_worker UNIQUE (instance_id, execution_id, activity_id, worker);


--
-- Name: attributes idx_attributes_instance_id_execution_id_event_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT idx_attributes_instance_id_execution_id_event_id UNIQUE (instance_id, execution_id, event_id);


--
-- Name: instances idx_instances_instance_id_execution_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instances
    ADD CONSTRAINT idx_instances_instance_id_execution_id UNIQUE (instance_id, execution_id);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: pending_events pending_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_events
    ADD CONSTRAINT pending_events_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: idx_activities_locked_until_queue; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activities_locked_until_queue ON public.activities USING btree (locked_until, queue);


--
-- Name: idx_attributes_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_attributes_event_id ON public.attributes USING btree (event_id);


--
-- Name: idx_history_instance_id_execution_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_history_instance_id_execution_id ON public.history USING btree (instance_id, execution_id);


--
-- Name: idx_history_instance_id_execution_id_sequence_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_history_instance_id_execution_id_sequence_id ON public.history USING btree (instance_id, execution_id, sequence_id);


--
-- Name: idx_instances_locked_until_completed_at_queue; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instances_locked_until_completed_at_queue ON public.instances USING btree (completed_at, locked_until, sticky_until, worker, queue);


--
-- Name: idx_instances_parent_instance_id_parent_execution_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instances_parent_instance_id_parent_execution_id ON public.instances USING btree (parent_instance_id, parent_execution_id);


--
-- Name: idx_pending_events_inid_exid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pending_events_inid_exid ON public.pending_events USING btree (instance_id, execution_id);


--
-- Name: idx_pending_events_inid_exid_visible_at_schedule_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pending_events_inid_exid_visible_at_schedule_event_id ON public.pending_events USING btree (instance_id, execution_id, visible_at, schedule_event_id);


--
-- PostgreSQL database dump complete
--

\unrestrict 06PUqkTL2m8Xz2uUVrVzF5DQ8GwEh6MCzWN7NvAszvHtXvbmmEgefbbJBDOjU3l

