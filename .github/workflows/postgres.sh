#!/usr/bin/env bash

# 用法: ./testing.sh "user1 db1 pass1 6001 db2 db3 db4" "user2 db2 pass2 6002" ...
if [ "$#" -eq 0 ]; then
    echo "用法: $0 \"user db pass port\" ..."
    exit 1
fi

set -e

for cfg in "$@"; do
    read POSTGRES_USER POSTGRES_DB POSTGRES_PASSWORD PORT DBS <<< "$cfg"

    container_name="pg_${PORT}"

    docker run -d \
        --name "$container_name" \
        -e POSTGRES_USER="$POSTGRES_USER" \
        -e POSTGRES_DB="$POSTGRES_DB" \
        -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
        -e PGDATA=./pgdata_$PORT \
        -p "$PORT":5432 \
        postgres

    # 👇 等待 Postgres 容器启动完成（最多等待 30 秒）
    for i in {1..30}; do
        if docker exec "$container_name" pg_isready -U "$POSTGRES_USER" > /dev/null 2>&1; then
            echo "Postgres [$container_name] is ready."
            break
        else
            echo "Waiting for Postgres [$container_name] to be ready..."
            sleep 1
        fi
    done

    dbs=($DBS)
    sql=""

    for db in "${dbs[@]}"; do
        sql+="CREATE DATABASE $db;\n"
        sql+="GRANT ALL PRIVILEGES ON DATABASE $db TO $POSTGRES_USER;\n"
    done

    PGPASSWORD=$POSTGRES_PASSWORD psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -h "localhost" -p $PORT <<-EOSQL
        $(echo -e "$sql")
EOSQL

done
