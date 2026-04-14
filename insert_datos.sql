-- =============================================================
-- DATOS DE EJEMPLO — Historia Clínica Distribuida con Citus
-- Esquema Normalizado (1FN, 2FN, 3FN)
-- Orden: catálogos (reference tables) → tablas distribuidas
-- =============================================================


-- =============================================================
-- SECCIÓN 1: CATÁLOGOS (reference tables)
-- =============================================================

-- cat_pais
INSERT INTO cat_pais (nombre_pais) VALUES
    ('China'),            -- 1
    ('Malasia'),          -- 2
    ('Nicaragua'),        -- 3
    ('Santa Lucía'),      -- 4
    ('Dominicana'),       -- 5
    ('Trinidad y Tabago'),-- 6
    ('Lituania'),         -- 7
    ('Haití'),            -- 8
    ('México'),           -- 9
    ('República Dominicana'), -- 10
    ('Kenya'),            -- 11
    ('Venezuela'),        -- 12
    ('Samoa'),            -- 13
    ('Saint Kitts y Nevis'),  -- 14
    ('Tuvalu'),           -- 15
    ('República Centroafricana'), -- 16
    ('Jordania'),         -- 17
    ('Zimbabwe'),         -- 18
    ('Ucrania'),          -- 19
    ('España');           -- 20 (para los municipios)

-- cat_municipio (todos en España — id_pais = 20)
INSERT INTO cat_municipio (nombre_municipio, id_pais) VALUES
    ('Huelva',      20),  -- 1
    ('Alicante',    20),  -- 2
    ('Guadalajara', 20),  -- 3
    ('Almería',     20),  -- 4
    ('León',        20),  -- 5
    ('Cádiz',       20),  -- 6
    ('Salamanca',   20),  -- 7
    ('Córdoba',     20),  -- 8
    ('Lugo',        20),  -- 9
    ('Tarragona',   20);  -- 10

-- cat_etnia
INSERT INTO cat_etnia (nombre_etnia) VALUES
    ('Indígena'),        -- 1
    ('Mestizo'),         -- 2
    ('Afrodescendiente');-- 3

-- cat_comunidad_etnica (id_etnia: 1=Indígena, 2=Mestizo, 3=Afrodescendiente)
INSERT INTO cat_comunidad_etnica (nombre_comunidad, id_etnia) VALUES
    ('Corrupti',   1),  -- 1  (Indígena)
    ('At',         2),  -- 2  (Mestizo)
    ('Expedita',   1),  -- 3  (Indígena)
    ('Qui',        3),  -- 4  (Afrodescendiente)
    ('Voluptatum', 3),  -- 5  (Afrodescendiente)
    ('Nam',        2),  -- 6  (Mestizo)
    ('Ipsum',      2),  -- 7  (Mestizo)
    ('Odio',       1),  -- 8  (Indígena)
    ('Ipsam',      2),  -- 9  (Mestizo)
    ('Quidem',     1);  -- 10 (Indígena)

-- cat_sexo
INSERT INTO cat_sexo (descripcion) VALUES
    ('Masculino'),  -- 1
    ('Femenino'),   -- 2
    ('Otro');       -- 3

-- cat_genero
INSERT INTO cat_genero (descripcion) VALUES
    ('Masculino'),   -- 1
    ('Femenino'),    -- 2
    ('No binario');  -- 3

-- cat_zona_residencia
INSERT INTO cat_zona_residencia (descripcion) VALUES
    ('Urbana'),  -- 1
    ('Rural');   -- 2

-- cat_discapacidad
INSERT INTO cat_discapacidad (descripcion) VALUES
    ('Severa'),          -- 1
    ('Moderada'),        -- 2
    ('Leve'),            -- 3
    ('Sin discapacidad');-- 4

-- cat_modalidad_entrega
INSERT INTO cat_modalidad_entrega (descripcion) VALUES
    ('Intramural'),   -- 1
    ('Extramural'),   -- 2
    ('Telemedicina'); -- 3

-- cat_entorno_atencion
INSERT INTO cat_entorno_atencion (descripcion) VALUES
    ('Hospitalario'),  -- 1
    ('Ambulatorio'),   -- 2
    ('Domiciliario'),  -- 3
    ('Urgencias');     -- 4

-- cat_via_ingreso
INSERT INTO cat_via_ingreso (descripcion) VALUES
    ('Urgencias'),    -- 1
    ('Remisión'),     -- 2
    ('Programada'),   -- 3
    ('Espontánea');   -- 4

-- cat_triage
INSERT INTO cat_triage (clasificacion) VALUES
    ('I'),    -- 1
    ('II'),   -- 2
    ('III'),  -- 3
    ('IV'),   -- 4
    ('V');    -- 5

-- cat_tipo_diagnostico
INSERT INTO cat_tipo_diagnostico (descripcion) VALUES
    ('Confirmado'),   -- 1
    ('Presuntivo'),   -- 2
    ('En estudio');   -- 3

-- cat_condicion_salida
INSERT INTO cat_condicion_salida (descripcion) VALUES
    ('Vivo'),       -- 1
    ('Fallecido'),  -- 2
    ('Traslado'),   -- 3
    ('Fuga'),       -- 4
    ('Abandonó');   -- 5

-- cat_via_administracion
INSERT INTO cat_via_administracion (descripcion) VALUES
    ('Oral'),         -- 1
    ('Intravenosa'),  -- 2
    ('Intramuscular'),-- 3
    ('Subcutánea'),   -- 4
    ('Tópica'),       -- 5
    ('Inhalatoria');  -- 6

-- cat_finalidad_tecnologia
INSERT INTO cat_finalidad_tecnologia (descripcion) VALUES
    ('Tratamiento'),    -- 1
    ('Diagnóstico'),    -- 2
    ('Rehabilitación'), -- 3
    ('Prevención'),     -- 4
    ('Paliativo');      -- 5

-- cat_tipo_incapacidad
INSERT INTO cat_tipo_incapacidad (descripcion) VALUES
    ('Laboral'),           -- 1
    ('Maternidad'),        -- 2
    ('Paternidad'),        -- 3
    ('Enfermedad general');-- 4


-- =============================================================
-- SECCIÓN 2: PROFESIONAL DE SALUD (reference table)
-- =============================================================
INSERT INTO profesional_salud (id_personal_salud, nombre, especialidad) VALUES
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Dra. Ana María Torres',   'Medicina Interna'),
    ('b2c3d4e5-f6a7-8901-bcde-f12345678901', 'Dr. Carlos Mendoza Ruiz', 'Urgencias'),
    ('c3d4e5f6-a7b8-9012-cdef-123456789012', 'Dra. Laura Pinto Sosa',   'Pediatría');


-- =============================================================
-- SECCIÓN 3: USUARIOS (distribuidos por documento_id)
-- Campos de catálogo: se usan IDs en vez de strings libres
-- Campo `edad` eliminado — se calcula con la vista v_usuario
-- =============================================================

-- Mapeo de catálogos usado:
--   id_sexo:    1=Masculino, 2=Femenino, 3=Otro
--   id_genero:  1=Masculino, 2=Femenino, 3=No binario
--   id_zona:    1=Urbana,    2=Rural
--   id_discap:  1=Severa,    2=Moderada

INSERT INTO usuario (documento_id, nombre_completo, fecha_nacimiento, voluntad_anticipada, ocupacion,
    id_pais_nacionalidad, id_sexo, id_genero, id_discapacidad,
    id_pais_residencia, id_municipio, id_zona, id_etnia, id_comunidad)
VALUES (9307000778, 'Ariadna Valderrama-Ibarra', '1989-10-30', FALSE, 'Engineer, maintenance (IT)',
    1,  3, 1, 1,   10, 1, 1,  1, 1);

INSERT INTO usuario (documento_id, nombre_completo, fecha_nacimiento, voluntad_anticipada, ocupacion,
    id_pais_nacionalidad, id_sexo, id_genero, id_discapacidad,
    id_pais_residencia, id_municipio, id_zona, id_etnia, id_comunidad)
VALUES (7100168051, 'Jaider Enrique Reyes Herazo', '1987-03-07', FALSE, 'Hydrologist',
    2,  2, 1, 2,   11, 2, 2,  2, 2);

INSERT INTO usuario (documento_id, nombre_completo, fecha_nacimiento, voluntad_anticipada, ocupacion,
    id_pais_nacionalidad, id_sexo, id_genero, id_discapacidad,
    id_pais_residencia, id_municipio, id_zona, id_etnia, id_comunidad)
VALUES (8851083276, 'Sebastián Zamorano Terrón', '1988-04-14', TRUE, 'Clinical scientist, histocompatibility and immunogenetics',
    9,  3, 2, 2,   12, 3, 1,  1, 3);

INSERT INTO usuario (documento_id, nombre_completo, fecha_nacimiento, voluntad_anticipada, ocupacion,
    id_pais_nacionalidad, id_sexo, id_genero, id_discapacidad,
    id_pais_residencia, id_municipio, id_zona, id_etnia, id_comunidad)
VALUES (3524351848, 'Jose Manuel Reguera-Pallarès', '1996-06-29', FALSE, 'Patent attorney',
    2,  1, 3, 1,   13, 4, 2,  3, 4);

INSERT INTO usuario (documento_id, nombre_completo, fecha_nacimiento, voluntad_anticipada, ocupacion,
    id_pais_nacionalidad, id_sexo, id_genero, id_discapacidad,
    id_pais_residencia, id_municipio, id_zona, id_etnia, id_comunidad)
VALUES (1807949924, 'Jessica Candelaria Canales Gárate', '1972-05-18', FALSE, 'Production assistant, radio',
    3,  1, 3, 1,   14, 5, 2,  3, 5);

INSERT INTO usuario (documento_id, nombre_completo, fecha_nacimiento, voluntad_anticipada, ocupacion,
    id_pais_nacionalidad, id_sexo, id_genero, id_discapacidad,
    id_pais_residencia, id_municipio, id_zona, id_etnia, id_comunidad)
VALUES (5444459189, 'Chuy Granados', '1991-04-19', TRUE, 'Clinical molecular geneticist',
    4,  3, 3, 1,   15, 6, 2,  2, 6);

INSERT INTO usuario (documento_id, nombre_completo, fecha_nacimiento, voluntad_anticipada, ocupacion,
    id_pais_nacionalidad, id_sexo, id_genero, id_discapacidad,
    id_pais_residencia, id_municipio, id_zona, id_etnia, id_comunidad)
VALUES (4200621587, 'Ariadna Valderrama Montenegro', '1971-11-17', TRUE, 'Insurance claims handler',
    5,  1, 3, 2,   16, 7, 2,  2, 7);

INSERT INTO usuario (documento_id, nombre_completo, fecha_nacimiento, voluntad_anticipada, ocupacion,
    id_pais_nacionalidad, id_sexo, id_genero, id_discapacidad,
    id_pais_residencia, id_municipio, id_zona, id_etnia, id_comunidad)
VALUES (3011288776, 'Abilio Ferrera Chacón', '1979-01-14', TRUE, 'Speech and language therapist',
    6,  3, 1, 1,   17, 8, 1,  1, 8);

INSERT INTO usuario (documento_id, nombre_completo, fecha_nacimiento, voluntad_anticipada, ocupacion,
    id_pais_nacionalidad, id_sexo, id_genero, id_discapacidad,
    id_pais_residencia, id_municipio, id_zona, id_etnia, id_comunidad)
VALUES (7712565174, 'Jovita Villalobos Cordero', '1996-03-13', FALSE, 'Chief Financial Officer',
    7,  2, 3, 2,   18, 9, 1,  2, 9);

INSERT INTO usuario (documento_id, nombre_completo, fecha_nacimiento, voluntad_anticipada, ocupacion,
    id_pais_nacionalidad, id_sexo, id_genero, id_discapacidad,
    id_pais_residencia, id_municipio, id_zona, id_etnia, id_comunidad)
VALUES (2739427151, 'Tadeo Falcó Gascón', '1994-08-27', FALSE, 'Location manager',
    8,  1, 1, 1,   19, 10, 1,  1, 10);


-- =============================================================
-- SECCIÓN 4: ATENCIONES (distribuidas por documento_id)
-- id_modalidad: 1=Intramural, 2=Extramural, 3=Telemedicina
-- id_entorno:   1=Hospitalario, 2=Ambulatorio, 3=Domiciliario, 4=Urgencias
-- id_via:       1=Urgencias, 2=Remisión, 3=Programada, 4=Espontánea
-- id_triage:    1=I ... 5=V
-- =============================================================

INSERT INTO atencion (documento_id, entidad_salud, fecha_ingreso, causa_atencion, fecha_triage,
    id_modalidad, id_entorno, id_via_ingreso, id_triage)
VALUES (9307000778, 'Clínica Salud Total S.A.', '2024-03-15 08:30:00', 'Dolor torácico agudo', '2024-03-15 08:35:00', 1, 4, 1, 2);

INSERT INTO atencion (documento_id, entidad_salud, fecha_ingreso, causa_atencion, fecha_triage,
    id_modalidad, id_entorno, id_via_ingreso, id_triage)
VALUES (7100168051, 'Hospital Universitario del Norte', '2024-04-02 14:00:00', 'Control prenatal', '2024-04-02 14:10:00', 1, 2, 3, 5);

INSERT INTO atencion (documento_id, entidad_salud, fecha_ingreso, causa_atencion, fecha_triage,
    id_modalidad, id_entorno, id_via_ingreso, id_triage)
VALUES (8851083276, 'Centro Médico del Sur', '2024-05-20 09:00:00', 'Fractura expuesta de tibia', '2024-05-20 09:05:00', 1, 1, 1, 1);

INSERT INTO atencion (documento_id, entidad_salud, fecha_ingreso, causa_atencion, fecha_triage,
    id_modalidad, id_entorno, id_via_ingreso, id_triage)
VALUES (3524351848, 'IPS Comunitaria', '2024-06-10 16:45:00', 'Hipertensión no controlada', '2024-06-10 16:50:00', 2, 2, 4, 3);

INSERT INTO atencion (documento_id, entidad_salud, fecha_ingreso, causa_atencion, fecha_triage,
    id_modalidad, id_entorno, id_via_ingreso, id_triage)
VALUES (1807949924, 'Hospital General Regional', '2024-07-01 11:20:00', 'Cuadro febril prolongado', '2024-07-01 11:25:00', 1, 1, 2, 3);


-- =============================================================
-- SECCIÓN 5: DIAGNÓSTICOS (distribuidos por documento_id)
-- id_tipo: 1=Confirmado, 2=Presuntivo, 3=En estudio
-- =============================================================

INSERT INTO diagnostico (documento_id, atencion_id, id_tipo_ingreso, diagnostico_ingreso, id_tipo_egreso, diagnostico_egreso)
VALUES (9307000778, 1, 2, 'I20.9 - Angina de pecho no especificada', 1, 'I21.0 - Infarto agudo de miocardio');

INSERT INTO diagnostico (documento_id, atencion_id, id_tipo_ingreso, diagnostico_ingreso, id_tipo_egreso, diagnostico_egreso)
VALUES (7100168051, 2, 1, 'Z34.1 - Supervisión de embarazo normal', 1, 'Z34.1 - Embarazo sin complicaciones');

INSERT INTO diagnostico (documento_id, atencion_id, id_tipo_ingreso, diagnostico_ingreso, id_tipo_egreso, diagnostico_egreso)
VALUES (8851083276, 3, 1, 'S82.2 - Fractura de diáfisis de tibia', 1, 'S82.2 - Fractura de tibia intervenida');

INSERT INTO diagnostico (documento_id, atencion_id, id_tipo_ingreso, diagnostico_ingreso, id_tipo_egreso, diagnostico_egreso)
VALUES (3524351848, 4, 1, 'I10 - Hipertensión esencial', 1, 'I10 - Hipertensión controlada con medicación');

INSERT INTO diagnostico (documento_id, atencion_id, id_tipo_ingreso, diagnostico_ingreso, id_tipo_egreso, diagnostico_egreso)
VALUES (1807949924, 5, 2, 'R50.9 - Fiebre no especificada', 1, 'A91 - Fiebre del dengue');


-- =============================================================
-- SECCIÓN 6: DIAGNÓSTICOS RELACIONADOS (nueva tabla — 1FN)
-- Reemplaza diagnostico_rel1, diagnostico_rel2, diagnostico_rel3
-- =============================================================

INSERT INTO diagnostico_relacionado (documento_id, diagnostico_id, codigo_cie10, descripcion)
VALUES (9307000778, 1, 'E11.9', 'Diabetes mellitus tipo 2 sin complicaciones');

INSERT INTO diagnostico_relacionado (documento_id, diagnostico_id, codigo_cie10, descripcion)
VALUES (9307000778, 1, 'I25.1', 'Enfermedad aterosclerótica del corazón');

INSERT INTO diagnostico_relacionado (documento_id, diagnostico_id, codigo_cie10, descripcion)
VALUES (8851083276, 3, 'M81.0', 'Osteoporosis relacionada con la edad');

INSERT INTO diagnostico_relacionado (documento_id, diagnostico_id, codigo_cie10, descripcion)
VALUES (3524351848, 4, 'E78.5', 'Hiperlipidemia no especificada');

INSERT INTO diagnostico_relacionado (documento_id, diagnostico_id, codigo_cie10, descripcion)
VALUES (1807949924, 5, 'D50.9', 'Anemia ferropénica no especificada');


-- =============================================================
-- SECCIÓN 7: TECNOLOGÍAS EN SALUD (distribuidas por documento_id)
-- id_via_admin: 1=Oral, 2=IV, 3=IM, 4=SC, 5=Tópica, 6=Inhalatoria
-- id_finalidad: 1=Tratamiento, 2=Diagnóstico, 3=Rehabilitación, ...
-- =============================================================

INSERT INTO tecnologia_salud (documento_id, atencion_id, descripcion_medicamento, dosis, frecuencia,
    dias_tratamiento, unidades_aplicadas, id_via_admin, id_finalidad, id_personal_salud)
VALUES (9307000778, 1, 'Aspirina 100mg', '100mg', 'Cada 24 horas', 30, 30,
    1, 1, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');

INSERT INTO tecnologia_salud (documento_id, atencion_id, descripcion_medicamento, dosis, frecuencia,
    dias_tratamiento, unidades_aplicadas, id_via_admin, id_finalidad, id_personal_salud)
VALUES (9307000778, 1, 'Atorvastatina 40mg', '40mg', 'Cada 24 horas', 90, 90,
    1, 1, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');

INSERT INTO tecnologia_salud (documento_id, atencion_id, descripcion_medicamento, dosis, frecuencia,
    dias_tratamiento, unidades_aplicadas, id_via_admin, id_finalidad, id_personal_salud)
VALUES (8851083276, 3, 'Metamizol 1g', '1g', 'Cada 8 horas', 5, 15,
    2, 1, 'b2c3d4e5-f6a7-8901-bcde-f12345678901');

INSERT INTO tecnologia_salud (documento_id, atencion_id, descripcion_medicamento, dosis, frecuencia,
    dias_tratamiento, unidades_aplicadas, id_via_admin, id_finalidad, id_personal_salud)
VALUES (3524351848, 4, 'Losartán 50mg', '50mg', 'Cada 24 horas', 60, 60,
    1, 1, 'b2c3d4e5-f6a7-8901-bcde-f12345678901');

INSERT INTO tecnologia_salud (documento_id, atencion_id, descripcion_medicamento, dosis, frecuencia,
    dias_tratamiento, unidades_aplicadas, id_via_admin, id_finalidad, id_personal_salud)
VALUES (1807949924, 5, 'Suero oral', '250ml', 'Cada 4 horas', 3, 18,
    1, 1, 'c3d4e5f6-a7b8-9012-cdef-123456789012');


-- =============================================================
-- SECCIÓN 8: EGRESOS (distribuidos por documento_id)
-- id_condicion: 1=Vivo, 2=Fallecido, 3=Traslado, 4=Fuga, 5=Abandonó
-- id_tipo_inc:  1=Laboral, 2=Maternidad, 3=Paternidad, 4=Enf. general
-- =============================================================

INSERT INTO egreso (documento_id, atencion_id, fecha_salida, codigo_prestador,
    dias_incapacidad, dias_lic_maternidad, responsable_egreso,
    id_condicion_salida, id_tipo_incapacidad)
VALUES (9307000778, 1, '2024-03-20 10:00:00', 'IPS-001', 15, 0,
    'Dr. Carlos Mendoza Ruiz', 1, 4);

INSERT INTO egreso (documento_id, atencion_id, fecha_salida, codigo_prestador,
    dias_incapacidad, dias_lic_maternidad, responsable_egreso,
    id_condicion_salida, id_tipo_incapacidad)
VALUES (7100168051, 2, '2024-04-02 16:00:00', 'IPS-002', 0, 0,
    'Dra. Laura Pinto Sosa', 1, NULL);

INSERT INTO egreso (documento_id, atencion_id, fecha_salida, codigo_prestador,
    dias_incapacidad, dias_lic_maternidad, responsable_egreso,
    id_condicion_salida, id_tipo_incapacidad)
VALUES (8851083276, 3, '2024-06-01 08:00:00', 'IPS-003', 45, 0,
    'Dr. Carlos Mendoza Ruiz', 1, 1);

INSERT INTO egreso (documento_id, atencion_id, fecha_salida, codigo_prestador,
    dias_incapacidad, dias_lic_maternidad, responsable_egreso,
    id_condicion_salida, id_tipo_incapacidad)
VALUES (1807949924, 5, '2024-07-05 12:00:00', 'IPS-005', 7, 0,
    'Dra. Ana María Torres', 1, 4);


-- =============================================================
-- SECCIÓN 9: ALERGIAS, ANTECEDENTES, RIESGOS (nuevas tablas — 1FN)
-- Antes eran campos TEXT multivaluados en egreso
-- =============================================================

-- Alergias
INSERT INTO alergia (documento_id, descripcion) VALUES
    (9307000778, 'Penicilina'),
    (9307000778, 'AINE - Ibuprofeno'),
    (8851083276, 'Látex'),
    (1807949924, 'Sulfamidas');

-- Antecedentes familiares
INSERT INTO antecedente_familiar_paciente (documento_id, descripcion) VALUES
    (9307000778, 'Padre con cardiopatía isquémica'),
    (9307000778, 'Madre con diabetes mellitus tipo 2'),
    (3524351848, 'Abuelo paterno con hipertensión arterial'),
    (1807949924, 'Hermano con anemia falciforme');

-- Riesgos ocupacionales
INSERT INTO riesgo_ocupacional (documento_id, descripcion) VALUES
    (9307000778, 'Exposición a ruido industrial'),
    (8851083276, 'Trabajo en alturas'),
    (7100168051, 'Exposición a sustancias químicas'),
    (1807949924, 'Sedentarismo prolongado');
