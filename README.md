
# Historia Clínica Distribuida con PostgreSQL + Citus

Este laboratorio implementa una base de datos distribuida real usando PostgreSQL con la extensión **Citus**,
permitiendo fragmentar automáticamente los datos y distribuir las consultas de forma transparente.

---

## Arquitectura

- 1 Coordinator (puerto 5432)
- 2 Workers
- Todas las tablas distribuidas por `documento_id`, excepto `profesional_salud`, que es replicada.

---

## Requisitos

- Docker
- Docker Compose
- psql (cliente PostgreSQL)

---

## Instrucciones

1. Clona este repositorio y entra en el directorio:

```bash
git clone https://github.com/TU_USUARIO/historia-clinica-distribuida-citus.git
cd historia-clinica-distribuida-citus
```

2. Levanta los servicios:

```bash
docker-compose -f docker-compose-citus.yml up -d
```

3. Accede al coordinador y ejecuta el script de esquema:

```bash
docker exec -it citus_coordinator psql -U admin -d historia_clinica -c "CREATE EXTENSION IF NOT EXISTS citus;"
docker exec -i citus_coordinator psql -U admin -d historia_clinica < /mnt/schema_citus.sql
```

4. Inserta datos de ejemplo:

```bash
docker exec -i citus_coordinator psql -U admin -d historia_clinica < /mnt/insert_datos.sql
```

---

##  Validación

Puedes hacer consultas distribuidas directamente desde el coordinador:

```sql
SELECT * FROM usuario WHERE documento_id > 0;
```

---

##  Archivos

```
.
├── docker-compose-citus.yml
├── schema_citus.sql
├── insert_datos.sql
├── README_CITUS.md
```

---

## Autor

Leider Samudio - Jose Sierra
