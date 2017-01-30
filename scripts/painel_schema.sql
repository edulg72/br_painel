--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: ur_materialized_refresh_row(integer); Type: FUNCTION; Schema: public; Owner: adminzdfyiwy
--

CREATE FUNCTION ur_materialized_refresh_row(id integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  delete from ur_materialized um where um.id = id;
  insert into ur_materialized
    select *, false from vw_ur_tmp vu where vu.id = id;
end
$$;


ALTER FUNCTION public.ur_materialized_refresh_row(id integer) OWNER TO adminzdfyiwy;

--
-- Name: vw_mp_refresh_table(); Type: FUNCTION; Schema: public; Owner: adminzdfyiwy
--

CREATE FUNCTION vw_mp_refresh_table() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  delete from vw_mp;
  insert into vw_mp
    select id,resolvida_por,resolvida_em,peso,ST_X(posicao) as longitude,ST_Y(posicao) as latitude,resolucao,municipioid from mp;
end
$$;


ALTER FUNCTION public.vw_mp_refresh_table() OWNER TO adminzdfyiwy;

--
-- Name: vw_pu_refresh_table(); Type: FUNCTION; Schema: public; Owner: adminzdfyiwy
--

CREATE FUNCTION vw_pu_refresh_table() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  delete from vw_pu;
  insert into vw_pu
    SELECT l.id, p.autor, p.data_criacao, st_x(p.posicao) AS longitude, st_y(p.posicao) AS latitude, p.staff, COALESCE(l.nome, '[Sem nome]') AS nome_local, p.municipioid FROM local l, pu p WHERE l.id = p.localid;
end
$$;


ALTER FUNCTION public.vw_pu_refresh_table() OWNER TO adminzdfyiwy;

--
-- Name: vw_segments_refresh_table(); Type: FUNCTION; Schema: public; Owner: adminzdfyiwy
--

CREATE FUNCTION vw_segments_refresh_table() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  delete from vw_segments;
  insert into vw_segments
 SELECT s.id,
    s.roadtype,
    s.level,
    s.separator,
    s.lockrank,
    s.validated,
    s.createdby,
    s.createdon,
    s.updatedby,
    s.updatedon,
    s.fwddirection,
    s.revdirection,
    s.fromnodeid,
    s.tonodeid,
    s.primarystreetid,
    s.fwdmaxspeed,
    s.revmaxspeed,
    s.junctionid,
    s.has_hns,
    s.hasclosures,
    s.length,
    s.fwdrestrictions,
    s.revrestrictions,
    s.crossroadid,
    st_x(st_startpoint(s.geometry)) AS longitude,
    st_y(st_startpoint(s.geometry)) AS latitude,
    s.fwdtoll,
    s.revtoll,
    s.fwdturnslocked,
    s.revturnslocked,
    s.rank,
    s.allownodirection,
    s.permissions,
    s.flags,s.municipioid
   FROM segment s;
end;
$$;


ALTER FUNCTION public.vw_segments_refresh_table() OWNER TO adminzdfyiwy;

--
-- Name: vw_ur_refresh_table(); Type: FUNCTION; Schema: public; Owner: adminzdfyiwy
--

CREATE FUNCTION vw_ur_refresh_table() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  delete from vw_ur;
  insert into vw_ur
    select id,comentarios,ultimo_comentario,data_ultimo_comentario,autor_comentario,resolvida_por,resolvida_em,data_abertura,ST_X(posicao) as longitude,ST_Y(posicao) as latitude,resolucao,municipioid from ur;
end
$$;


ALTER FUNCTION public.vw_ur_refresh_table() OWNER TO adminzdfyiwy;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: atualizacao; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE atualizacao (
    objeto character varying(20) NOT NULL,
    data timestamp with time zone
);


ALTER TABLE public.atualizacao OWNER TO waze;

--
-- Name: cidades; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE cidades (
    id integer NOT NULL,
    nome character varying(100),
    estadoid integer,
    paisid integer,
    semnome boolean
);


ALTER TABLE public.cidades OWNER TO waze;

--
-- Name: estados; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE estados (
    id integer NOT NULL,
    nm_estado character varying(100),
    nm_regiao character varying(20),
    cd_geocuf character varying(2),
    geom geometry(MultiPolygon,4674),
    sigla character varying(2),
    paisid integer
);


ALTER TABLE public.estados OWNER TO waze;

--
-- Name: local; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE local (
    id character varying(50) NOT NULL,
    nome character varying(100),
    ruaid integer,
    criado_em timestamp without time zone,
    alterado_em timestamp without time zone,
    alterado_por integer,
    posicao geometry(Point,4674),
    lock integer,
    aprovado boolean,
    residencial boolean,
    categoria character varying(40),
    staff boolean,
    criado_por integer
);


ALTER TABLE public.local OWNER TO waze;

--
-- Name: microrregioes; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE microrregioes (
    gid integer NOT NULL,
    nm_micro character varying(100),
    cd_geocmi character varying(5),
    geom geometry(MultiPolygon,4674),
    regiaoid character varying(4)
);


ALTER TABLE public.microrregioes OWNER TO waze;

--
-- Name: microrregioes_gid_seq; Type: SEQUENCE; Schema: public; Owner: waze
--

CREATE SEQUENCE microrregioes_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.microrregioes_gid_seq OWNER TO waze;

--
-- Name: microrregioes_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: waze
--

ALTER SEQUENCE microrregioes_gid_seq OWNED BY microrregioes.gid;


--
-- Name: mp; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE mp (
    id integer NOT NULL,
    resolvida_por integer,
    resolvida_em timestamp without time zone,
    peso integer,
    posicao geometry(Point,4674),
    resolucao integer,
    municipioid character varying(7)
);


ALTER TABLE public.mp OWNER TO waze;

--
-- Name: municipios; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE municipios (
    gid integer NOT NULL,
    nm_municip character varying(60),
    cd_geocmu character varying(7),
    geom geometry(MultiPolygon,4674),
    microrregiaoid character varying(5)
);


ALTER TABLE public.municipios OWNER TO waze;

--
-- Name: municipios_gid_seq; Type: SEQUENCE; Schema: public; Owner: waze
--

CREATE SEQUENCE municipios_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.municipios_gid_seq OWNER TO waze;

--
-- Name: municipios_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: waze
--

ALTER SEQUENCE municipios_gid_seq OWNED BY municipios.gid;


--
-- Name: pu; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE pu (
    id character varying(60) NOT NULL,
    autor integer,
    posicao geometry(Point,4674),
    staff boolean,
    nome_local character varying(80),
    municipioid character varying(7),
    localid character varying(50),
    data_criacao timestamp with time zone
);


ALTER TABLE public.pu OWNER TO waze;

--
-- Name: regioes; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE regioes (
    gid integer NOT NULL,
    nm_meso character varying(100),
    cd_geocme character varying(4),
    geom geometry(MultiPolygon,4674),
    estadoid character varying(2)
);


ALTER TABLE public.regioes OWNER TO waze;

--
-- Name: regioes_gid_seq; Type: SEQUENCE; Schema: public; Owner: waze
--

CREATE SEQUENCE regioes_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.regioes_gid_seq OWNER TO waze;

--
-- Name: regioes_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: waze
--

ALTER SEQUENCE regioes_gid_seq OWNED BY regioes.gid;


--
-- Name: ruas; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE ruas (
    id integer NOT NULL,
    nome character varying(100),
    cidadeid integer,
    semnome boolean
);


ALTER TABLE public.ruas OWNER TO waze;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: adminzdfyiwy; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO adminzdfyiwy;

--
-- Name: segment; Type: TABLE; Schema: public; Owner: adminzdfyiwy; Tablespace: 
--

CREATE TABLE segment (
    id integer NOT NULL,
    roadtype integer,
    level integer,
    separator boolean,
    lockrank integer,
    validated boolean,
    createdby integer,
    createdon timestamp with time zone,
    updatedby integer,
    updatedon timestamp with time zone,
    fwddirection boolean,
    revdirection boolean,
    fromnodeid integer,
    tonodeid integer,
    primarystreetid integer,
    fwdmaxspeed integer,
    revmaxspeed integer,
    junctionid integer,
    has_hns boolean,
    hasclosures boolean,
    length integer,
    fwdrestrictions boolean,
    revrestrictions boolean,
    crossroadid integer,
    geometry geometry(LineString,4674),
    fwdtoll boolean,
    revtoll boolean,
    fwdturnslocked boolean,
    revturnslocked boolean,
    rank integer,
    allownodirection boolean,
    permissions integer,
    flags integer,
    municipioid integer
);


ALTER TABLE public.segment OWNER TO adminzdfyiwy;

--
-- Name: segmentos; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE segmentos (
    id integer NOT NULL,
    tipo integer,
    lock integer,
    elevacao integer,
    criado_por integer,
    criado_em timestamp without time zone,
    alterado_por integer,
    alterado_em timestamp without time zone,
    interdicoes boolean,
    tamanho integer,
    ruaid integer
);


ALTER TABLE public.segmentos OWNER TO waze;

--
-- Name: ur; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE ur (
    id integer,
    comentarios integer,
    ultimo_comentario text,
    autor_comentario integer,
    resolvida_por integer,
    posicao geometry(Point,4674),
    resolucao integer,
    municipioid character varying(7),
    data_ultimo_comentario timestamp with time zone,
    resolvida_em timestamp with time zone,
    data_abertura timestamp with time zone
);


ALTER TABLE public.ur OWNER TO waze;

--
-- Name: usuario; Type: TABLE; Schema: public; Owner: waze; Tablespace: 
--

CREATE TABLE usuario (
    id integer NOT NULL,
    username character varying(50),
    rank integer
);


ALTER TABLE public.usuario OWNER TO waze;

--
-- Name: vw_mp; Type: TABLE; Schema: public; Owner: adminzdfyiwy; Tablespace: 
--

CREATE TABLE vw_mp (
    id integer,
    resolvida_por integer,
    resolvida_em timestamp without time zone,
    peso integer,
    longitude double precision,
    latitude double precision,
    resolucao integer,
    municipioid character varying(7)
);


ALTER TABLE public.vw_mp OWNER TO adminzdfyiwy;

--
-- Name: vw_pu; Type: TABLE; Schema: public; Owner: adminzdfyiwy; Tablespace: 
--

CREATE TABLE vw_pu (
    id character varying(50),
    autor integer,
    data_criacao timestamp with time zone,
    longitude double precision,
    latitude double precision,
    staff boolean,
    nome_local character varying,
    municipioid character varying(7)
);


ALTER TABLE public.vw_pu OWNER TO adminzdfyiwy;

--
-- Name: vw_segments; Type: TABLE; Schema: public; Owner: adminzdfyiwy; Tablespace: 
--

CREATE TABLE vw_segments (
    id integer,
    roadtype integer,
    level integer,
    separator boolean,
    lockrank integer,
    validated boolean,
    createdby integer,
    createdon timestamp with time zone,
    updatedby integer,
    updatedon timestamp with time zone,
    fwddirection boolean,
    revdirection boolean,
    fromnodeid integer,
    tonodeid integer,
    primarystreetid integer,
    fwdmaxspeed integer,
    revmaxspeed integer,
    junctionid integer,
    has_hns boolean,
    hasclosures boolean,
    length integer,
    fwdrestrictions boolean,
    revrestrictions boolean,
    crossroadid integer,
    longitude double precision,
    latitude double precision,
    fwdtoll boolean,
    revtoll boolean,
    fwdturnslocked boolean,
    revturnslocked boolean,
    rank integer,
    allownodirection boolean,
    permissions integer,
    flags integer,
    municipioid integer
);


ALTER TABLE public.vw_segments OWNER TO adminzdfyiwy;

--
-- Name: vw_ur; Type: TABLE; Schema: public; Owner: adminzdfyiwy; Tablespace: 
--

CREATE TABLE vw_ur (
    id integer,
    comentarios integer,
    ultimo_comentario text,
    data_ultimo_comentario timestamp with time zone,
    autor_comentario integer,
    resolvida_por integer,
    resolvida_em timestamp with time zone,
    data_abertura timestamp with time zone,
    longitude double precision,
    latitude double precision,
    resolucao integer,
    municipioid character varying(7)
);


ALTER TABLE public.vw_ur OWNER TO adminzdfyiwy;

--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: waze
--

ALTER TABLE ONLY microrregioes ALTER COLUMN gid SET DEFAULT nextval('microrregioes_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: waze
--

ALTER TABLE ONLY municipios ALTER COLUMN gid SET DEFAULT nextval('municipios_gid_seq'::regclass);


--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: waze
--

ALTER TABLE ONLY regioes ALTER COLUMN gid SET DEFAULT nextval('regioes_gid_seq'::regclass);


--
-- Name: cidades_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY cidades
    ADD CONSTRAINT cidades_pkey PRIMARY KEY (id);


--
-- Name: local_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY local
    ADD CONSTRAINT local_pkey PRIMARY KEY (id);


--
-- Name: microrregioes_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY microrregioes
    ADD CONSTRAINT microrregioes_pkey PRIMARY KEY (gid);


--
-- Name: mp_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY mp
    ADD CONSTRAINT mp_pkey PRIMARY KEY (id);


--
-- Name: municipios_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY municipios
    ADD CONSTRAINT municipios_pkey PRIMARY KEY (gid);


--
-- Name: pk_atualizacao; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY atualizacao
    ADD CONSTRAINT pk_atualizacao PRIMARY KEY (objeto);


--
-- Name: pu_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY pu
    ADD CONSTRAINT pu_pkey PRIMARY KEY (id);


--
-- Name: regioes_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY regioes
    ADD CONSTRAINT regioes_pkey PRIMARY KEY (gid);


--
-- Name: ruas_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY ruas
    ADD CONSTRAINT ruas_pkey PRIMARY KEY (id);


--
-- Name: segment_pkey; Type: CONSTRAINT; Schema: public; Owner: adminzdfyiwy; Tablespace: 
--

ALTER TABLE ONLY segment
    ADD CONSTRAINT segment_pkey PRIMARY KEY (id);


--
-- Name: segmentos_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY segmentos
    ADD CONSTRAINT segmentos_pkey PRIMARY KEY (id);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: waze; Tablespace: 
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- Name: ix_geometry; Type: INDEX; Schema: public; Owner: waze; Tablespace: 
--

CREATE INDEX ix_geometry ON municipios USING gist (geom);


--
-- Name: ix_mr_geom; Type: INDEX; Schema: public; Owner: waze; Tablespace: 
--

CREATE INDEX ix_mr_geom ON microrregioes USING gist (geom);


--
-- Name: ix_ur_comentarios; Type: INDEX; Schema: public; Owner: waze; Tablespace: 
--

CREATE INDEX ix_ur_comentarios ON ur USING btree (comentarios);


--
-- Name: ix_ur_municipio; Type: INDEX; Schema: public; Owner: waze; Tablespace: 
--

CREATE INDEX ix_ur_municipio ON ur USING btree (municipioid);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: adminzdfyiwy; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

