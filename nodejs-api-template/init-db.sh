#!/bin/sh
# init-db.sh

# Start MySQL server
docker-entrypoint.sh mysqld &

# Wait for MySQL to be ready
echo "Waiting for MySQL to start..."
sleep 30

# Import the SQL dump
echo "Importing SQL dump..."
mysql -h127.0.0.1 -uroot -pmy-secret-pw nodejs_api < /docker-entrypoint-initdb.d/nodejs_api_dump.sql

# Keep the container running
wait
