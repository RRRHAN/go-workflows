#!/bin/bash

# === Configuration ===
DB_NAME="go_workflows"
DB_USER="postgres"
DB_PASS=""  
DB_HOST="localhost"
DB_PORT="5432"
SCHEMA_NAME="public"
OUTPUT_FILE="schema.sql"

MIGRATION_DIR="./migrations"

echo "Running migrations from $MIGRATION_DIR..."
migrate -path "$MIGRATION_DIR" -database "postgres://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" up

if [ $? -ne 0 ]; then
  echo "Migration failed!"
  exit 1
fi
echo "Migration completed."

echo "Dumping schema '$SCHEMA_NAME'..."
pg_dump \
  --username="$DB_USER" \
  --host="$DB_HOST" \
  --port="$DB_PORT" \
  --schema="$SCHEMA_NAME" \
  --no-owner \
  --no-privileges \
  --schema-only \
  "$DB_NAME" > "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
  echo "Schema dumped successfully to $OUTPUT_FILE"
else
  echo "Error dumping schema"
  exit 1
fi
