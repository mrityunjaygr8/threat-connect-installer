#!/usr/bin/env bash

firewall-cmd --permanent --zone=public --add-service=ssh


yum update -y
yum install -y wget

# setup opensearch
# will be listening on localhost:9200
# will be single host cluster
pushd /opt
wget https://artifacts.opensearch.org/releases/bundle/opensearch/1.2.3/opensearch-1.2.3-linux-x64.tar.gz
tar -zxf opensearch-1.2.3-linux-x64.tar.gz
groupadd -g 1001 opensearch && useradd opensearch -u 1001 -g 1001
chown -R opensearch:opensearch opensearch-1.2.3
sudo -u opensearch mv opensearch-1.2.3/config/opensearch.yml{,.bak}
popd
sudo -u opensearch cp ./opensearch.yml opensearch-1.2.3/config
pushd /opt
mkdir opensearch-1.2.3/logs
chown -R opensearch:opensearch opensearch-1.2.3
sudo -u opensearch opensearch-1.2.3/bin/opensearch-plugin install --batch ingest-attachment
popd
cp ./opensearch.sh /etc/init.d/opensearch 
chmod 755 /etc/init.d/opensearch
service opensearch start

# setup postgres
yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum -y install postgresql11-server postgresql11
PGSETUP_INITDB_OPTIONS="--lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8" /usr/pgsql-11/bin/postgresql-11-setup initdb
systemctl enable --now postgresql-11
firewall-cmd --permanent --zone=public --add-service=postgresql
firewall-cmd --reload
sudo -iu postgres psql < ./threatconnect.sql
# sudo -iu postgres psql -U $TC_PSQL_USER -d $TC_PSQL_NAME < /opt/threatconnect/app/scripts/postgres/ThreatConnect-__version__.sql
cp ./pg_hba.conf /var/lib/pgsql/11/data
chown -R postgres:postgres /var/lib/pgsql/11/data 
systemctl restart postgresql-11

