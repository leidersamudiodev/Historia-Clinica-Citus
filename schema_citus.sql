-- =============================================================
-- HISTORIA CLÍNICA DISTRIBUIDA CON POSTGRESQL + CITUS
-- Esquema Normalizado — 1FN, 2FN, 3FN
-- Autor: Leider Samudio && Jose Sierra
-- =============================================================
-- REGLAS CITUS aplicadas:
--   1. Las reference tables pueden referenciar a otras reference tables (OK)
--   2. Las distributed tables NO pueden tener FK a reference tables en el
--      CREATE TABLE — se agregan DESPUÉS con ALTER TABLE ADD FOREIGN KEY
--   3. Las FK entre distributed tables co-locadas se agregan DESPUÉS de
--      distribuir ambas tablas
--   4. La clave de distribución (documento_id) debe ser parte de la PK
--      en tablas distribuidas con clave compuesta
-- =============================================================

CREATE EXTENSION IF NOT EXISTS citus;

-- =============================================================
-- SECCIÓN 1: TABLAS DE CATÁLOGO (reference tables)
-- Replicadas en todos los nodos — sin documento_id
-- Inter-FK entre reference tables: permitidas
-- =============================================================

-- Países (doble rol: nacionalidad y residencia)
CREATE TABLE cat_pais (
    id_pais     SERIAL PRIMARY KEY,
    nombre_pais VARCHAR(100) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_pais');

-- Municipios — FK a cat_pais (ambas reference: OK)
CREATE TABLE cat_municipio (
    id_municipio     SERIAL PRIMARY KEY,
    nombre_municipio VARCHAR(100) NOT NULL,
    id_pais          INT NOT NULL REFERENCES cat_pais(id_pais)
);
SELECT create_reference_table('cat_municipio');

-- Etnias
CREATE TABLE cat_etnia (
    id_etnia     SERIAL PRIMARY KEY,
    nombre_etnia VARCHAR(100) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_etnia');

-- Comunidades étnicas — FK a cat_etnia (ambas reference: OK)
CREATE TABLE cat_comunidad_etnica (
    id_comunidad     SERIAL PRIMARY KEY,
    nombre_comunidad VARCHAR(100) NOT NULL,
    id_etnia         INT NOT NULL REFERENCES cat_etnia(id_etnia)
);
SELECT create_reference_table('cat_comunidad_etnica');

-- Sexo biológico
CREATE TABLE cat_sexo (
    id_sexo     SERIAL PRIMARY KEY,
    descripcion VARCHAR(20) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_sexo');

-- Género
CREATE TABLE cat_genero (
    id_genero   SERIAL PRIMARY KEY,
    descripcion VARCHAR(30) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_genero');

-- Zona de residencia
CREATE TABLE cat_zona_residencia (
    id_zona     SERIAL PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_zona_residencia');

-- Categoría de discapacidad
CREATE TABLE cat_discapacidad (
    id_discapacidad SERIAL PRIMARY KEY,
    descripcion     VARCHAR(50) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_discapacidad');

-- Modalidad de entrega del servicio
CREATE TABLE cat_modalidad_entrega (
    id_modalidad SERIAL PRIMARY KEY,
    descripcion  VARCHAR(100) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_modalidad_entrega');

-- Entorno de atención
CREATE TABLE cat_entorno_atencion (
    id_entorno  SERIAL PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_entorno_atencion');

-- Vía de ingreso
CREATE TABLE cat_via_ingreso (
    id_via      SERIAL PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_via_ingreso');

-- Clasificación de triage
CREATE TABLE cat_triage (
    id_triage     SERIAL PRIMARY KEY,
    clasificacion VARCHAR(10) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_triage');

-- Tipo de diagnóstico
CREATE TABLE cat_tipo_diagnostico (
    id_tipo     SERIAL PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_tipo_diagnostico');

-- Condición de salida
CREATE TABLE cat_condicion_salida (
    id_condicion SERIAL PRIMARY KEY,
    descripcion  VARCHAR(100) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_condicion_salida');

-- Vía de administración de medicamentos
CREATE TABLE cat_via_administracion (
    id_via_admin SERIAL PRIMARY KEY,
    descripcion  VARCHAR(100) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_via_administracion');

-- Finalidad de la tecnología en salud
CREATE TABLE cat_finalidad_tecnologia (
    id_finalidad SERIAL PRIMARY KEY,
    descripcion  VARCHAR(255) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_finalidad_tecnologia');

-- Tipo de incapacidad
CREATE TABLE cat_tipo_incapacidad (
    id_tipo_incapacidad SERIAL PRIMARY KEY,
    descripcion         VARCHAR(100) NOT NULL UNIQUE
);
SELECT create_reference_table('cat_tipo_incapacidad');

-- =============================================================
-- SECCIÓN 2: PROFESIONAL DE SALUD (reference table)
-- =============================================================
CREATE TABLE profesional_salud (
    id_personal_salud UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre            VARCHAR(255) NOT NULL,
    especialidad      VARCHAR(100)
);
SELECT create_reference_table('profesional_salud');


-- =============================================================
-- SECCIÓN 3A: TABLAS DISTRIBUIDAS — SOLO ESTRUCTURA
-- SIN FK entre distribuidas ni a reference tables todavía
-- (Las FK se agregan DESPUÉS de distribuir — regla Citus)
-- =============================================================

-- usuario: distribuida por documento_id
-- NORMALIZACIÓN: quita `edad` (3FN), reemplaza strings por FK ids (3FN)
CREATE TABLE usuario (
    documento_id         BIGINT PRIMARY KEY,
    nombre_completo      VARCHAR(255) NOT NULL,
    fecha_nacimiento     DATE         NOT NULL,
    voluntad_anticipada  BOOLEAN      DEFAULT FALSE,
    ocupacion            VARCHAR(150),
    id_pais_nacionalidad INT,
    id_sexo              INT,
    id_genero            INT,
    id_discapacidad      INT,
    id_pais_residencia   INT,
    id_municipio         INT,
    id_zona              INT,
    id_etnia             INT,
    id_comunidad         INT
);
SELECT create_distributed_table('usuario', 'documento_id');

-- atencion: PK compuesta obligatoria en Citus (shard key en PK)
-- NORMALIZACIÓN: modalidad, entorno, via_ingreso, triage → FK ids (3FN)
CREATE TABLE atencion (
    atencion_id    BIGSERIAL,
    documento_id   BIGINT NOT NULL,
    entidad_salud  VARCHAR(255),
    fecha_ingreso  TIMESTAMP,
    causa_atencion TEXT,
    fecha_triage   TIMESTAMP,
    id_modalidad   INT,
    id_entorno     INT,
    id_via_ingreso INT,
    id_triage      INT,
    PRIMARY KEY (atencion_id, documento_id)
);
SELECT create_distributed_table('atencion', 'documento_id');

-- tecnologia_salud: PK compuesta
-- NORMALIZACIÓN: via_administracion, finalidad_tecnologia → FK ids (3FN)
CREATE TABLE tecnologia_salud (
    tecnologia_id           UUID DEFAULT gen_random_uuid(),
    documento_id            BIGINT NOT NULL,
    atencion_id             BIGINT,
    descripcion_medicamento VARCHAR(255),
    dosis                   VARCHAR(50),
    frecuencia              VARCHAR(50),
    dias_tratamiento        INT,
    unidades_aplicadas      INT,
    id_via_admin            INT,
    id_finalidad            INT,
    id_personal_salud       UUID,
    PRIMARY KEY (tecnologia_id, documento_id)
);
SELECT create_distributed_table('tecnologia_salud', 'documento_id');

-- diagnostico: PK compuesta
-- NORMALIZACIÓN 1FN: eliminados diagnostico_rel1/2/3 → tabla diagnostico_relacionado
-- NORMALIZACIÓN 3FN: tipo_diagnostico → FK ids
CREATE TABLE diagnostico (
    diagnostico_id      BIGSERIAL,
    documento_id        BIGINT NOT NULL,
    atencion_id         BIGINT,
    id_tipo_ingreso     INT,
    diagnostico_ingreso VARCHAR(255),
    id_tipo_egreso      INT,
    diagnostico_egreso  VARCHAR(255),
    PRIMARY KEY (diagnostico_id, documento_id)
);
SELECT create_distributed_table('diagnostico', 'documento_id');

-- diagnostico_relacionado: NUEVA tabla (1FN)
-- Reemplaza diagnostico_rel1, diagnostico_rel2, diagnostico_rel3
CREATE TABLE diagnostico_relacionado (
    rel_id         BIGSERIAL,
    documento_id   BIGINT NOT NULL,
    diagnostico_id BIGINT NOT NULL,
    codigo_cie10   VARCHAR(20),
    descripcion    VARCHAR(255),
    PRIMARY KEY (rel_id, documento_id)
);
SELECT create_distributed_table('diagnostico_relacionado', 'documento_id');

-- egreso: PK compuesta
-- NORMALIZACIÓN 1FN: eliminados alergias, antecedente_familiar, riesgos_ocupacionales TEXT
-- NORMALIZACIÓN 3FN: condicion_salida, tipo_incapacidad → FK ids
CREATE TABLE egreso (
    egreso_id            BIGSERIAL,
    documento_id         BIGINT NOT NULL,
    atencion_id          BIGINT,
    fecha_salida         TIMESTAMP,
    diagnostico_muerte   VARCHAR(255),
    codigo_prestador     VARCHAR(20),
    dias_incapacidad     INT,
    dias_lic_maternidad  INT,
    responsable_egreso   VARCHAR(255),
    id_condicion_salida  INT,
    id_tipo_incapacidad  INT,
    PRIMARY KEY (egreso_id, documento_id)
);
SELECT create_distributed_table('egreso', 'documento_id');

-- alergia: NUEVA — grupos de repetición en egreso.alergias (1FN)
CREATE TABLE alergia (
    alergia_id   BIGSERIAL,
    documento_id BIGINT NOT NULL,
    descripcion  TEXT   NOT NULL,
    PRIMARY KEY (alergia_id, documento_id)
);
SELECT create_distributed_table('alergia', 'documento_id');

-- antecedente_familiar_paciente: NUEVA — egreso.antecedente_familiar (1FN)
CREATE TABLE antecedente_familiar_paciente (
    antecedente_id BIGSERIAL,
    documento_id   BIGINT NOT NULL,
    descripcion    TEXT   NOT NULL,
    PRIMARY KEY (antecedente_id, documento_id)
);
SELECT create_distributed_table('antecedente_familiar_paciente', 'documento_id');

-- riesgo_ocupacional: NUEVA — egreso.riesgos_ocupacionales (1FN)
CREATE TABLE riesgo_ocupacional (
    riesgo_id    BIGSERIAL,
    documento_id BIGINT NOT NULL,
    descripcion  TEXT   NOT NULL,
    PRIMARY KEY (riesgo_id, documento_id)
);
SELECT create_distributed_table('riesgo_ocupacional', 'documento_id');


-- =============================================================
-- SECCIÓN 3B: FOREIGN KEYS — Después de distribuir todas las tablas
-- Citus permite FK de distributed → reference table post-distribución
-- Citus permite FK entre co-located distributed tables post-distribución
-- =============================================================

-- FK de usuario → catálogos (reference tables) — una por ALTER TABLE (Citus)
ALTER TABLE usuario ADD CONSTRAINT fk_usuario_pais_nac  FOREIGN KEY (id_pais_nacionalidad) REFERENCES cat_pais(id_pais);
ALTER TABLE usuario ADD CONSTRAINT fk_usuario_sexo      FOREIGN KEY (id_sexo)              REFERENCES cat_sexo(id_sexo);
ALTER TABLE usuario ADD CONSTRAINT fk_usuario_genero    FOREIGN KEY (id_genero)            REFERENCES cat_genero(id_genero);
ALTER TABLE usuario ADD CONSTRAINT fk_usuario_discap    FOREIGN KEY (id_discapacidad)      REFERENCES cat_discapacidad(id_discapacidad);
ALTER TABLE usuario ADD CONSTRAINT fk_usuario_pais_res  FOREIGN KEY (id_pais_residencia)   REFERENCES cat_pais(id_pais);
ALTER TABLE usuario ADD CONSTRAINT fk_usuario_municipio FOREIGN KEY (id_municipio)         REFERENCES cat_municipio(id_municipio);
ALTER TABLE usuario ADD CONSTRAINT fk_usuario_zona      FOREIGN KEY (id_zona)              REFERENCES cat_zona_residencia(id_zona);
ALTER TABLE usuario ADD CONSTRAINT fk_usuario_etnia     FOREIGN KEY (id_etnia)             REFERENCES cat_etnia(id_etnia);
ALTER TABLE usuario ADD CONSTRAINT fk_usuario_comunidad FOREIGN KEY (id_comunidad)         REFERENCES cat_comunidad_etnica(id_comunidad);

-- FK de atencion → usuario (co-located) y → catálogos
ALTER TABLE atencion ADD CONSTRAINT fk_atencion_usuario   FOREIGN KEY (documento_id)   REFERENCES usuario(documento_id);
ALTER TABLE atencion ADD CONSTRAINT fk_atencion_modalidad FOREIGN KEY (id_modalidad)   REFERENCES cat_modalidad_entrega(id_modalidad);
ALTER TABLE atencion ADD CONSTRAINT fk_atencion_entorno   FOREIGN KEY (id_entorno)     REFERENCES cat_entorno_atencion(id_entorno);
ALTER TABLE atencion ADD CONSTRAINT fk_atencion_via       FOREIGN KEY (id_via_ingreso) REFERENCES cat_via_ingreso(id_via);
ALTER TABLE atencion ADD CONSTRAINT fk_atencion_triage    FOREIGN KEY (id_triage)      REFERENCES cat_triage(id_triage);

-- FK de tecnologia_salud → usuario, atencion (co-located) y catálogos
ALTER TABLE tecnologia_salud ADD CONSTRAINT fk_tecno_usuario     FOREIGN KEY (documento_id)             REFERENCES usuario(documento_id);
ALTER TABLE tecnologia_salud ADD CONSTRAINT fk_tecno_atencion    FOREIGN KEY (atencion_id, documento_id) REFERENCES atencion(atencion_id, documento_id);
ALTER TABLE tecnologia_salud ADD CONSTRAINT fk_tecno_via_admin   FOREIGN KEY (id_via_admin)             REFERENCES cat_via_administracion(id_via_admin);
ALTER TABLE tecnologia_salud ADD CONSTRAINT fk_tecno_finalidad   FOREIGN KEY (id_finalidad)             REFERENCES cat_finalidad_tecnologia(id_finalidad);
ALTER TABLE tecnologia_salud ADD CONSTRAINT fk_tecno_profesional FOREIGN KEY (id_personal_salud)        REFERENCES profesional_salud(id_personal_salud);

-- FK de diagnostico → usuario, atencion (co-located) y catálogos
ALTER TABLE diagnostico ADD CONSTRAINT fk_diag_usuario      FOREIGN KEY (documento_id)              REFERENCES usuario(documento_id);
ALTER TABLE diagnostico ADD CONSTRAINT fk_diag_atencion     FOREIGN KEY (atencion_id, documento_id)  REFERENCES atencion(atencion_id, documento_id);
ALTER TABLE diagnostico ADD CONSTRAINT fk_diag_tipo_ingreso FOREIGN KEY (id_tipo_ingreso)           REFERENCES cat_tipo_diagnostico(id_tipo);
ALTER TABLE diagnostico ADD CONSTRAINT fk_diag_tipo_egreso  FOREIGN KEY (id_tipo_egreso)            REFERENCES cat_tipo_diagnostico(id_tipo);

-- FK de diagnostico_relacionado → usuario, diagnostico (co-located)
ALTER TABLE diagnostico_relacionado ADD CONSTRAINT fk_diagrel_usuario     FOREIGN KEY (documento_id)                 REFERENCES usuario(documento_id);
ALTER TABLE diagnostico_relacionado ADD CONSTRAINT fk_diagrel_diagnostico FOREIGN KEY (diagnostico_id, documento_id)  REFERENCES diagnostico(diagnostico_id, documento_id);

-- FK de egreso → usuario, atencion (co-located) y catálogos
ALTER TABLE egreso ADD CONSTRAINT fk_egreso_usuario     FOREIGN KEY (documento_id)              REFERENCES usuario(documento_id);
ALTER TABLE egreso ADD CONSTRAINT fk_egreso_atencion    FOREIGN KEY (atencion_id, documento_id)  REFERENCES atencion(atencion_id, documento_id);
ALTER TABLE egreso ADD CONSTRAINT fk_egreso_condicion   FOREIGN KEY (id_condicion_salida)       REFERENCES cat_condicion_salida(id_condicion);
ALTER TABLE egreso ADD CONSTRAINT fk_egreso_incapacidad FOREIGN KEY (id_tipo_incapacidad)       REFERENCES cat_tipo_incapacidad(id_tipo_incapacidad);

-- FK de tablas de antecedentes/alergias → usuario (co-located)
ALTER TABLE alergia                    ADD CONSTRAINT fk_alergia_usuario FOREIGN KEY (documento_id) REFERENCES usuario(documento_id);
ALTER TABLE antecedente_familiar_paciente ADD CONSTRAINT fk_antec_usuario  FOREIGN KEY (documento_id) REFERENCES usuario(documento_id);
ALTER TABLE riesgo_ocupacional         ADD CONSTRAINT fk_riesgo_usuario  FOREIGN KEY (documento_id) REFERENCES usuario(documento_id);


-- =============================================================
-- SECCIÓN 4: VISTA NORMALIZADA
-- Calcula `edad` dinámicamente (evita dato derivado — 3FN)
-- Une todas las referencias para presentación completa
-- =============================================================
CREATE VIEW v_usuario AS
SELECT
    u.documento_id,
    u.nombre_completo,
    u.fecha_nacimiento,
    EXTRACT(YEAR FROM AGE(u.fecha_nacimiento))::INT AS edad,
    u.voluntad_anticipada,
    u.ocupacion,
    cp.nombre_pais   AS pais_nacionalidad,
    s.descripcion    AS sexo,
    g.descripcion    AS genero,
    d.descripcion    AS categoria_discapacidad,
    cr.nombre_pais   AS pais_residencia,
    m.nombre_municipio,
    z.descripcion    AS zona_residencia,
    e.nombre_etnia   AS etnia,
    c.nombre_comunidad AS comunidad_etnica
FROM usuario u
LEFT JOIN cat_pais                cp ON u.id_pais_nacionalidad = cp.id_pais
LEFT JOIN cat_sexo                 s ON u.id_sexo              = s.id_sexo
LEFT JOIN cat_genero               g ON u.id_genero            = g.id_genero
LEFT JOIN cat_discapacidad         d ON u.id_discapacidad      = d.id_discapacidad
LEFT JOIN cat_pais                cr ON u.id_pais_residencia   = cr.id_pais
LEFT JOIN cat_municipio            m ON u.id_municipio         = m.id_municipio
LEFT JOIN cat_zona_residencia      z ON u.id_zona              = z.id_zona
LEFT JOIN cat_etnia                e ON u.id_etnia             = e.id_etnia
LEFT JOIN cat_comunidad_etnica     c ON u.id_comunidad         = c.id_comunidad;
