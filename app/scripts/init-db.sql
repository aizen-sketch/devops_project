-- Create databases for both microservices
SELECT 'CREATE DATABASE taskapp_user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'taskapp_user')\gexec

SELECT 'CREATE DATABASE taskapp_task'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'taskapp_task')\gexec
