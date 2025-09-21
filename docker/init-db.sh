#!/bin/bash
set -e

# Espera a que PostgreSQL esté listo
until PGPASSWORD=$POSTGRES_PASSWORD psql -h "localhost" -U "$POSTGRES_USER" -d "postgres" -c '\q'; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done

echo "PostgreSQL is up - executing command"

# Crea la base de datos si no existe
psql -U "$POSTGRES_USER" -d "postgres" -c "CREATE DATABASE $POSTGRES_DB;"

# Restaura el dump
pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v /docker-entrypoint-initdb.d/latest.dump
