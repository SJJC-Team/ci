#!/usr/bin/env bash

# 用法: ./postgres.sh 17 "user1 db1 pass1 6001 db2 db3 db4" "user2 db2 pass2 6002" ...
if [ "$#" -eq 0 ]; then
    echo "用法: $0 <PostgreSQL Version> \"user db pass port\" ..."
    exit 1
fi

set -e

echo create user pg_tester

useradd -m -s /bin/bash pg_tester
usermod -aG sudo pg_tester

echo installing postgresql@${1}

apt-get update
apt-get install curl ca-certificates -y
install -d /usr/share/postgresql-common/pgdg
curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
. /etc/os-release
sh -c "echo 'deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main' > /etc/apt/sources.list.d/pgdg.list"

apt-get update
apt-get install postgresql-${1} postgresql-client-${1} -y

export PATH="/usr/lib/postgresql/$1/bin:$PATH"

chmod 777 "/var/run/postgresql"

echo postgresql success installed

psql --version
initdb --version
pg_ctl --version

shift 1

for cfg in "$@"; do
    read POSTGRES_USER POSTGRES_DB POSTGRES_PASSWORD PORT DBS <<< "$cfg"
    
    # 检查必要参数是否为空
    if [[ -z "$POSTGRES_USER" || -z "$POSTGRES_DB" || -z "$POSTGRES_PASSWORD" || -z "$PORT" ]]; then
        echo "❌ 缺少必要参数，跳过: $cfg"
        continue
    fi
    
    data_dir="pg_${PORT}"
    conf_file="$data_dir/postgresql.conf"
    
    function on_fail {
        echo "⚠️ PostgreSQL 启动失败，日志如下："

        su - pg_tester -c "bash -c '
        if [[ -f \"$data_dir/logfile\" ]]; then
          cat \"$data_dir/logfile\"
        else
          echo \"日志文件不存在: $data_dir/logfile\"
        fi
        '"
    }
    
    su - pg_tester -c "env PATH=\"$PATH\" initdb -D $data_dir -U $POSTGRES_USER"
    su - pg_tester -c "env PATH=\"$PATH\" bash -c 'echo \"listen_addresses = '\''localhost'\''\" >> \"$conf_file\"'"
    su - pg_tester -c "env PATH=\"$PATH\" bash -c 'echo \"port = $PORT\" >> \"$conf_file\"'"
    trap on_fail ERR
    su - pg_tester -c "env PATH=\"$PATH\" pg_ctl start -D $data_dir -l $data_dir/logfile"
    
    psql -v ON_ERROR_STOP=1 -d template1 -U $POSTGRES_USER -p $PORT -c "DROP DATABASE postgres;"
    psql -v ON_ERROR_STOP=1 -d template1 -U $POSTGRES_USER -p $PORT -c "CREATE DATABASE $POSTGRES_DB;"
    
    dbs=($DBS)
    sql=""

    for db in "${dbs[@]}"; do
        sql+="CREATE DATABASE $db;\n"
    done

    psql -v ON_ERROR_STOP=1 -d template1 -U $POSTGRES_USER -h localhost -p $PORT <<-EOSQL
        $(echo -e "$sql")
EOSQL

done
