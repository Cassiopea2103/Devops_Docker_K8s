-- Create the database if it doesn't already exist
DO
$$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'company') THEN
      PERFORM dblink_exec('dbname=postgres', 'CREATE DATABASE company');
   END IF;
END
$$;

-- Connect to the company database
\c company;

-- Create the users table if it doesn't already exist
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    age INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

