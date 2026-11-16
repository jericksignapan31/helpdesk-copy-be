--
-- PostgreSQL database dump
--


-- Dumped from database version 17.12
-- Dumped by pg_dump version 17.12

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;



--
-- Name: chatbot_interaction_response_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.chatbot_interaction_response_type_enum AS ENUM (
    'FAQ',
    'TICKET_CREATION',
    'TROUBLESHOOTING',
    'ESCALATION',
    'GENERAL',
    'TICKET_STATUS'
);


--
-- Name: conversation_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.conversation_type_enum AS ENUM (
    'DIRECT',
    'TICKET',
    'GROUP'
);


--
-- Name: part_requisitions_requested_by_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.part_requisitions_requested_by_type_enum AS ENUM (
    'it',
    'warehouse'
);


--
-- Name: part_requisitions_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.part_requisitions_status_enum AS ENUM (
    'pending',
    'pending_admin_review',
    'approved',
    'rejected',
    'declined_by_admin',
    'returned_by_warehouse'
);


--
-- Name: warehouse_part_requests_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.warehouse_part_requests_status_enum AS ENUM (
    'pending',
    'approved',
    'rejected'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: asset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset (
    asset_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    asset_tag character varying NOT NULL,
    brand_id uuid,
    branch_id uuid,
    category character varying NOT NULL,
    model character varying,
    serial_number character varying,
    status character varying DEFAULT 'available'::character varying NOT NULL,
    condition character varying(20) DEFAULT 'good'::character varying,
    assigned_to uuid,
    notes text,
    specifications text,
    ip_address character varying(45),
    mac_address character varying(17),
    hostname character varying(255),
    anydesk_id character varying(50),
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: asset_assignment_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset_assignment_history (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    asset_id uuid NOT NULL,
    previous_employee_id uuid,
    new_employee_id uuid,
    assigned_by uuid NOT NULL,
    notes text,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: asset_movement_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset_movement_history (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    asset_id uuid NOT NULL,
    from_branch_id uuid,
    to_branch_id uuid NOT NULL,
    moved_by uuid NOT NULL,
    reason text,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: asset_status_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset_status_history (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    asset_id uuid NOT NULL,
    previous_status character varying,
    new_status character varying NOT NULL,
    changed_by uuid NOT NULL,
    reason text,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: branch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branch (
    branch_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    branch_name character varying NOT NULL,
    location character varying,
    contact_number character varying,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: brand; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.brand (
    brand_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    brand_name character varying NOT NULL,
    description character varying,
    brand_image_url character varying,
    status boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: chatbot_interaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chatbot_interaction (
    interaction_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    conversation_id uuid NOT NULL,
    user_message text NOT NULL,
    chatbot_response text NOT NULL,
    response_type public.chatbot_interaction_response_type_enum DEFAULT 'GENERAL'::public.chatbot_interaction_response_type_enum NOT NULL,
    detected_intent character varying,
    intent_confidence numeric(3,2),
    knowledge_id uuid,
    ticket_id uuid,
    satisfaction_score integer,
    is_helpful boolean,
    user_feedback text,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: chatbot_knowledge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chatbot_knowledge (
    knowledge_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    category character varying NOT NULL,
    question text NOT NULL,
    answer text NOT NULL,
    keywords text,
    relevant_ticket_ids text,
    confidence_score numeric(3,2) DEFAULT 0.5 NOT NULL,
    usage_count integer DEFAULT 0 NOT NULL,
    helpful_count integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: conversation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversation (
    conversation_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type public.conversation_type_enum DEFAULT 'DIRECT'::public.conversation_type_enum NOT NULL,
    ticket_id character varying,
    name character varying NOT NULL,
    participant_ids text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: department; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.department (
    department_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    department_name character varying NOT NULL,
    description character varying,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: employee; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employee (
    employee_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    branch_id uuid,
    department_id uuid,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    middle_name character varying,
    email character varying NOT NULL,
    role character varying DEFAULT 'employee'::character varying NOT NULL,
    "position" character varying,
    contact_number character varying,
    employment_status boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: file_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_attachments (
    attachment_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    message_id uuid NOT NULL,
    filename character varying(255) NOT NULL,
    file_type character varying(100) NOT NULL,
    file_size bigint NOT NULL,
    file_url character varying(500) NOT NULL,
    preview_url character varying(500),
    uploaded_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.message (
    message_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    conversation_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    content text NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: part_requisitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.part_requisitions (
    requisition_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    rf_number character varying NOT NULL,
    requested_by uuid NOT NULL,
    department_id uuid,
    requested_by_type public.part_requisitions_requested_by_type_enum DEFAULT 'warehouse'::public.part_requisitions_requested_by_type_enum NOT NULL,
    deadline timestamp without time zone,
    status public.part_requisitions_status_enum DEFAULT 'pending'::public.part_requisitions_status_enum NOT NULL,
    acknowledged_by uuid,
    acknowledged_at timestamp without time zone,
    acknowledged_notes character varying,
    approved_by uuid,
    approved_at timestamp without time zone,
    rejection_reason character varying,
    decline_reason character varying,
    declined_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: repair_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repair_log (
    repair_log_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    asset_id uuid NOT NULL,
    reported_by uuid,
    repaired_by uuid,
    repair_date timestamp without time zone NOT NULL,
    issue_description text NOT NULL,
    action_taken text,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    cost numeric(10,2),
    notes text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: requisition_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.requisition_comments (
    comment_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    return_id uuid NOT NULL,
    commented_by uuid NOT NULL,
    role character varying NOT NULL,
    message text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: requisition_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.requisition_items (
    item_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    requisition_id uuid NOT NULL,
    item_name character varying NOT NULL,
    quantity integer NOT NULL,
    unit character varying NOT NULL,
    supplier character varying,
    unit_cost numeric(10,2),
    total_cost numeric(10,2),
    purpose_remarks character varying
);


--
-- Name: requisition_returns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.requisition_returns (
    return_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    requisition_id uuid NOT NULL,
    returned_by uuid NOT NULL,
    warehouse_notes text NOT NULL,
    return_cycle integer DEFAULT 1 NOT NULL,
    resubmitted_by uuid,
    resubmitted_at timestamp without time zone,
    it_response_notes text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: ticket; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket (
    ticket_id character varying(20) NOT NULL,
    employee_id uuid NOT NULL,
    department_id uuid,
    asset_id uuid,
    assigned_to uuid,
    image_url text,
    category character varying NOT NULL,
    priority character varying NOT NULL,
    status character varying DEFAULT 'pending_approval'::character varying NOT NULL,
    approval_status character varying DEFAULT 'pending'::character varying NOT NULL,
    require_approval boolean DEFAULT true NOT NULL,
    approved_by uuid,
    approved_at timestamp without time zone,
    rejection_reason text,
    subject character varying NOT NULL,
    description text NOT NULL,
    started_at timestamp without time zone,
    resolved_at timestamp without time zone,
    closed_at timestamp without time zone,
    unit_status character varying,
    observation text,
    action_taken text,
    recommendation text,
    resolution_notes text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: ticket_parts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_parts (
    part_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    ticket_id character varying(20) NOT NULL,
    part_name character varying NOT NULL,
    quantity integer NOT NULL,
    unit_cost numeric(10,2) NOT NULL,
    total_cost numeric(10,2) NOT NULL,
    supplier character varying NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    requested_date timestamp without time zone,
    received_date timestamp without time zone,
    notes text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: ticket_sequence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_sequence (
    date character varying(10) NOT NULL,
    sequence integer DEFAULT 0 NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: ticket_solution; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_solution (
    solution_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    ticket_id character varying NOT NULL,
    issue_type character varying,
    category character varying,
    solution_summary text NOT NULL,
    resolution_steps text,
    resolution_notes text,
    resolution_time_minutes integer,
    tags text,
    prevent_tips text,
    is_active boolean DEFAULT true NOT NULL,
    usage_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: user_account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_account (
    user_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    employee_id uuid NOT NULL,
    email character varying NOT NULL,
    password character varying NOT NULL,
    password_changed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: warehouse_part_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.warehouse_part_requests (
    request_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    requested_by uuid NOT NULL,
    approved_by uuid,
    part_name character varying NOT NULL,
    quantity integer NOT NULL,
    unit_cost numeric(10,2) NOT NULL,
    total_cost numeric(10,2) NOT NULL,
    supplier character varying NOT NULL,
    notes character varying NOT NULL,
    status public.warehouse_part_requests_status_enum DEFAULT 'pending'::public.warehouse_part_requests_status_enum NOT NULL,
    rejection_reason character varying,
    requested_at timestamp without time zone DEFAULT now() NOT NULL,
    approved_at timestamp without time zone,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: warehouse_part_requests PK_02d4003f0fcef2e56b748b774f7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouse_part_requests
    ADD CONSTRAINT "PK_02d4003f0fcef2e56b748b774f7" PRIMARY KEY (request_id);


--
-- Name: message PK_06a563cdbd963a9f7cbcb25c447; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT "PK_06a563cdbd963a9f7cbcb25c447" PRIMARY KEY (message_id);


--
-- Name: requisition_items PK_1308206f15577f0e5d02d91e89a; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requisition_items
    ADD CONSTRAINT "PK_1308206f15577f0e5d02d91e89a" PRIMARY KEY (item_id);


--
-- Name: ticket_sequence PK_1c8ea05047b963bd07977502756; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_sequence
    ADD CONSTRAINT "PK_1c8ea05047b963bd07977502756" PRIMARY KEY (date);


--
-- Name: chatbot_interaction PK_1d8be4ebf75e7e10cf2ff878c67; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chatbot_interaction
    ADD CONSTRAINT "PK_1d8be4ebf75e7e10cf2ff878c67" PRIMARY KEY (interaction_id);


--
-- Name: user_account PK_1e7af5387f4169347ddef6e8180; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT "PK_1e7af5387f4169347ddef6e8180" PRIMARY KEY (user_id);


--
-- Name: department PK_28a598987c3302c0b4dfc71f868; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT "PK_28a598987c3302c0b4dfc71f868" PRIMARY KEY (department_id);


--
-- Name: asset PK_2a48e81afa7729ed31c2c7b18ed; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT "PK_2a48e81afa7729ed31c2c7b18ed" PRIMARY KEY (asset_id);


--
-- Name: chatbot_knowledge PK_2ddc0f6d0f48d27f2e2b0b2d4b6; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chatbot_knowledge
    ADD CONSTRAINT "PK_2ddc0f6d0f48d27f2e2b0b2d4b6" PRIMARY KEY (knowledge_id);


--
-- Name: branch PK_30ca7f4dce440475a49dba3d48c; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT "PK_30ca7f4dce440475a49dba3d48c" PRIMARY KEY (branch_id);


--
-- Name: ticket_solution PK_35f08a55f025cac219f8a0e676e; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_solution
    ADD CONSTRAINT "PK_35f08a55f025cac219f8a0e676e" PRIMARY KEY (solution_id);


--
-- Name: requisition_returns PK_46044ad0840ea02c1eee9b85ff7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requisition_returns
    ADD CONSTRAINT "PK_46044ad0840ea02c1eee9b85ff7" PRIMARY KEY (return_id);


--
-- Name: part_requisitions PK_491f2b35a802dd681e3d936fb79; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_requisitions
    ADD CONSTRAINT "PK_491f2b35a802dd681e3d936fb79" PRIMARY KEY (requisition_id);


--
-- Name: asset_movement_history PK_5c81749a8126386405288c8bf99; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_movement_history
    ADD CONSTRAINT "PK_5c81749a8126386405288c8bf99" PRIMARY KEY (id);


--
-- Name: asset_assignment_history PK_61a9fb2a69956a3ae84cde55e56; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_assignment_history
    ADD CONSTRAINT "PK_61a9fb2a69956a3ae84cde55e56" PRIMARY KEY (id);


--
-- Name: conversation PK_66e2b75e2704e382f3a4f2a5466; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation
    ADD CONSTRAINT "PK_66e2b75e2704e382f3a4f2a5466" PRIMARY KEY (conversation_id);


--
-- Name: file_attachments PK_7921f2f0b25f80a1ab72559c8cc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_attachments
    ADD CONSTRAINT "PK_7921f2f0b25f80a1ab72559c8cc" PRIMARY KEY (attachment_id);


--
-- Name: requisition_comments PK_96957dbc1601fa2530a4427e446; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requisition_comments
    ADD CONSTRAINT "PK_96957dbc1601fa2530a4427e446" PRIMARY KEY (comment_id);


--
-- Name: ticket_parts PK_9f28b8fb309fc20801e42c761c1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_parts
    ADD CONSTRAINT "PK_9f28b8fb309fc20801e42c761c1" PRIMARY KEY (part_id);


--
-- Name: brand PK_a6201ff889d4681c6e521d26231; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brand
    ADD CONSTRAINT "PK_a6201ff889d4681c6e521d26231" PRIMARY KEY (brand_id);


--
-- Name: ticket PK_a7b0a31430509c3d3e22832e341; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT "PK_a7b0a31430509c3d3e22832e341" PRIMARY KEY (ticket_id);


--
-- Name: asset_status_history PK_d4d95c3361fed64aa55747bcadb; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_status_history
    ADD CONSTRAINT "PK_d4d95c3361fed64aa55747bcadb" PRIMARY KEY (id);


--
-- Name: repair_log PK_e4a62fee0cc8a2ec6f3391f2ba8; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_log
    ADD CONSTRAINT "PK_e4a62fee0cc8a2ec6f3391f2ba8" PRIMARY KEY (repair_log_id);


--
-- Name: employee PK_f9d306b968b54923539b3936b03; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT "PK_f9d306b968b54923539b3936b03" PRIMARY KEY (employee_id);


--
-- Name: user_account REL_784fd63373771d11ae88ac399e; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT "REL_784fd63373771d11ae88ac399e" UNIQUE (employee_id);


--
-- Name: part_requisitions UQ_0b2819835b8cdce86e536da538c; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_requisitions
    ADD CONSTRAINT "UQ_0b2819835b8cdce86e536da538c" UNIQUE (rf_number);


--
-- Name: user_account UQ_56a0e4bcec2b5411beafa47ffa5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT "UQ_56a0e4bcec2b5411beafa47ffa5" UNIQUE (email);


--
-- Name: employee UQ_817d1d427138772d47eca048855; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT "UQ_817d1d427138772d47eca048855" UNIQUE (email);


--
-- Name: asset UQ_e2845451aeb8c99ec01eb96f152; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT "UQ_e2845451aeb8c99ec01eb96f152" UNIQUE (asset_tag);


--
-- Name: idx_asset_assignment_history_asset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asset_assignment_history_asset_id ON public.asset_assignment_history USING btree (asset_id);


--
-- Name: idx_asset_assignment_history_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asset_assignment_history_created_at ON public.asset_assignment_history USING btree (created_at);


--
-- Name: idx_asset_movement_history_asset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asset_movement_history_asset_id ON public.asset_movement_history USING btree (asset_id);


--
-- Name: idx_asset_movement_history_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asset_movement_history_created_at ON public.asset_movement_history USING btree (created_at);


--
-- Name: idx_asset_status_history_asset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asset_status_history_asset_id ON public.asset_status_history USING btree (asset_id);


--
-- Name: idx_asset_status_history_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asset_status_history_created_at ON public.asset_status_history USING btree (created_at);


--
-- Name: ticket FK_036b5f20f93359a0dfe0058facd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT "FK_036b5f20f93359a0dfe0058facd" FOREIGN KEY (assigned_to) REFERENCES public.employee(employee_id);


--
-- Name: asset_movement_history FK_09d8dd11f8496628aa05c2ccf7d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_movement_history
    ADD CONSTRAINT "FK_09d8dd11f8496628aa05c2ccf7d" FOREIGN KEY (asset_id) REFERENCES public.asset(asset_id);


--
-- Name: part_requisitions FK_0cc6bfdf454e7cb255381de1e5a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_requisitions
    ADD CONSTRAINT "FK_0cc6bfdf454e7cb255381de1e5a" FOREIGN KEY (approved_by) REFERENCES public.employee(employee_id);


--
-- Name: asset_assignment_history FK_0e8c02a5000ab45a55669abba00; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_assignment_history
    ADD CONSTRAINT "FK_0e8c02a5000ab45a55669abba00" FOREIGN KEY (asset_id) REFERENCES public.asset(asset_id);


--
-- Name: repair_log FK_0eb0a87036e59c7f163466a2d0a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_log
    ADD CONSTRAINT "FK_0eb0a87036e59c7f163466a2d0a" FOREIGN KEY (asset_id) REFERENCES public.asset(asset_id);


--
-- Name: ticket FK_121ce93fa7c5778a91d37b9bb47; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT "FK_121ce93fa7c5778a91d37b9bb47" FOREIGN KEY (department_id) REFERENCES public.department(department_id);


--
-- Name: ticket FK_129dbc9512c2886f382196c1fd5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT "FK_129dbc9512c2886f382196c1fd5" FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);


--
-- Name: requisition_returns FK_1b4f2658f834e3679e64c9563a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requisition_returns
    ADD CONSTRAINT "FK_1b4f2658f834e3679e64c9563a1" FOREIGN KEY (requisition_id) REFERENCES public.part_requisitions(requisition_id);


--
-- Name: warehouse_part_requests FK_2867d4ff47c7fecab88874ab684; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouse_part_requests
    ADD CONSTRAINT "FK_2867d4ff47c7fecab88874ab684" FOREIGN KEY (approved_by) REFERENCES public.employee(employee_id);


--
-- Name: requisition_items FK_2afa61cf14fa20efa7dc12883dd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requisition_items
    ADD CONSTRAINT "FK_2afa61cf14fa20efa7dc12883dd" FOREIGN KEY (requisition_id) REFERENCES public.part_requisitions(requisition_id) ON DELETE CASCADE;


--
-- Name: requisition_comments FK_34bd0ace43c6b6088a8ff14942d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requisition_comments
    ADD CONSTRAINT "FK_34bd0ace43c6b6088a8ff14942d" FOREIGN KEY (return_id) REFERENCES public.requisition_returns(return_id);


--
-- Name: employee FK_380241ef3c0ea0a87b9411f37ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT "FK_380241ef3c0ea0a87b9411f37ff" FOREIGN KEY (branch_id) REFERENCES public.branch(branch_id);


--
-- Name: asset_movement_history FK_3ec87967757c6e1356d0dcfcb8a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_movement_history
    ADD CONSTRAINT "FK_3ec87967757c6e1356d0dcfcb8a" FOREIGN KEY (moved_by) REFERENCES public.user_account(user_id);


--
-- Name: part_requisitions FK_466fda79f609ab0fa50f216dbd7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_requisitions
    ADD CONSTRAINT "FK_466fda79f609ab0fa50f216dbd7" FOREIGN KEY (department_id) REFERENCES public.department(department_id);


--
-- Name: ticket_parts FK_56bb1d67213d45889c2b2535b83; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_parts
    ADD CONSTRAINT "FK_56bb1d67213d45889c2b2535b83" FOREIGN KEY (ticket_id) REFERENCES public.ticket(ticket_id) ON DELETE CASCADE;


--
-- Name: asset_status_history FK_5b5eaf8239efb2ad06ad2af00c6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_status_history
    ADD CONSTRAINT "FK_5b5eaf8239efb2ad06ad2af00c6" FOREIGN KEY (changed_by) REFERENCES public.user_account(user_id);


--
-- Name: asset_assignment_history FK_5d0656397f02b0aad10d6d7811b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_assignment_history
    ADD CONSTRAINT "FK_5d0656397f02b0aad10d6d7811b" FOREIGN KEY (previous_employee_id) REFERENCES public.employee(employee_id);


--
-- Name: ticket FK_6efc8e7b0774203d2be369fde01; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT "FK_6efc8e7b0774203d2be369fde01" FOREIGN KEY (approved_by) REFERENCES public.employee(employee_id);


--
-- Name: user_account FK_784fd63373771d11ae88ac399ea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT "FK_784fd63373771d11ae88ac399ea" FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);


--
-- Name: part_requisitions FK_7ac7114dcad0b10beacdcfdc839; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_requisitions
    ADD CONSTRAINT "FK_7ac7114dcad0b10beacdcfdc839" FOREIGN KEY (acknowledged_by) REFERENCES public.employee(employee_id);


--
-- Name: message FK_7fe3e887d78498d9c9813375ce2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT "FK_7fe3e887d78498d9c9813375ce2" FOREIGN KEY (conversation_id) REFERENCES public.conversation(conversation_id) ON DELETE CASCADE;


--
-- Name: asset_movement_history FK_84537d266136ac33fac499bd0e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_movement_history
    ADD CONSTRAINT "FK_84537d266136ac33fac499bd0e7" FOREIGN KEY (from_branch_id) REFERENCES public.branch(branch_id);


--
-- Name: file_attachments FK_94a46f928ed51f2cc31d4dc3fcf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_attachments
    ADD CONSTRAINT "FK_94a46f928ed51f2cc31d4dc3fcf" FOREIGN KEY (message_id) REFERENCES public.message(message_id) ON DELETE CASCADE;


--
-- Name: ticket FK_96d3c13a68dd57ede8e1400d3a9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT "FK_96d3c13a68dd57ede8e1400d3a9" FOREIGN KEY (asset_id) REFERENCES public.asset(asset_id);


--
-- Name: asset_assignment_history FK_a7becea97dce9957af55f075a11; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_assignment_history
    ADD CONSTRAINT "FK_a7becea97dce9957af55f075a11" FOREIGN KEY (new_employee_id) REFERENCES public.employee(employee_id);


--
-- Name: asset FK_bb8c67015d7a14286d0c4045e69; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT "FK_bb8c67015d7a14286d0c4045e69" FOREIGN KEY (branch_id) REFERENCES public.branch(branch_id);


--
-- Name: message FK_c0ab99d9dfc61172871277b52f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT "FK_c0ab99d9dfc61172871277b52f6" FOREIGN KEY (sender_id) REFERENCES public.user_account(user_id) ON DELETE SET NULL;


--
-- Name: asset_status_history FK_cc05a184626e741ae37b5924b03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_status_history
    ADD CONSTRAINT "FK_cc05a184626e741ae37b5924b03" FOREIGN KEY (asset_id) REFERENCES public.asset(asset_id);


--
-- Name: repair_log FK_d1b662f1a52f6b322089af363dd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_log
    ADD CONSTRAINT "FK_d1b662f1a52f6b322089af363dd" FOREIGN KEY (repaired_by) REFERENCES public.employee(employee_id);


--
-- Name: employee FK_d62835db8c0aec1d18a5a927549; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT "FK_d62835db8c0aec1d18a5a927549" FOREIGN KEY (department_id) REFERENCES public.department(department_id);


--
-- Name: part_requisitions FK_da27edbe439cb1130d094b9e254; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_requisitions
    ADD CONSTRAINT "FK_da27edbe439cb1130d094b9e254" FOREIGN KEY (requested_by) REFERENCES public.employee(employee_id);


--
-- Name: asset_assignment_history FK_e28c88ec6a48489f4aef24b6d5f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_assignment_history
    ADD CONSTRAINT "FK_e28c88ec6a48489f4aef24b6d5f" FOREIGN KEY (assigned_by) REFERENCES public.user_account(user_id);


--
-- Name: repair_log FK_e367a05411b54dacbe473697917; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_log
    ADD CONSTRAINT "FK_e367a05411b54dacbe473697917" FOREIGN KEY (reported_by) REFERENCES public.employee(employee_id);


--
-- Name: asset FK_e38434d5f91feb8d955fb63504a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT "FK_e38434d5f91feb8d955fb63504a" FOREIGN KEY (assigned_to) REFERENCES public.employee(employee_id);


--
-- Name: asset FK_ea359b979895d3d89c419cd9457; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT "FK_ea359b979895d3d89c419cd9457" FOREIGN KEY (brand_id) REFERENCES public.brand(brand_id);


--
-- Name: asset_movement_history FK_f356fa64a0d8a453a37cf492142; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_movement_history
    ADD CONSTRAINT "FK_f356fa64a0d8a453a37cf492142" FOREIGN KEY (to_branch_id) REFERENCES public.branch(branch_id);


--
-- Name: warehouse_part_requests FK_f788e43f9ce6f486170b1794ad8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouse_part_requests
    ADD CONSTRAINT "FK_f788e43f9ce6f486170b1794ad8" FOREIGN KEY (requested_by) REFERENCES public.employee(employee_id);


--
-- Name: chatbot_interaction FK_fa67174b5d3c575207a384dd79e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chatbot_interaction
    ADD CONSTRAINT "FK_fa67174b5d3c575207a384dd79e" FOREIGN KEY (user_id) REFERENCES public.user_account(user_id) ON DELETE SET NULL;


--
-- Name: chatbot_interaction FK_fb0baec21d8a9e2ca1c30625643; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chatbot_interaction
    ADD CONSTRAINT "FK_fb0baec21d8a9e2ca1c30625643" FOREIGN KEY (conversation_id) REFERENCES public.conversation(conversation_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--
