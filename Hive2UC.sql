-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Migrating managed tables in HIVE to UC
-- MAGIC 
-- MAGIC These steps assumes you have an external location and credentials configured to the target buckets for your environment

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Create a managed table in Hive - Preparing the environment
-- MAGIC These steps are running on workspace 1

-- COMMAND ----------

CREATE DATABASE hive_metastore.hive2uc_db;

-- COMMAND ----------

CREATE TABLE IF NOT EXISTS hive_metastore.hive2uc_db.customers(
                          id BIGINT,
                          name STRING);
                          
DESCRIBE TABLE EXTENDED hive_metastore.hive2uc_db.customers;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Adding Some data

-- COMMAND ----------

INSERT INTO hive_metastore.hive2uc_db.customers VALUES (1, 'CUST 1');
INSERT INTO hive_metastore.hive2uc_db.customers VALUES (2, 'CUST 2');
INSERT INTO hive_metastore.hive2uc_db.customers VALUES (3, 'CUST 3');
INSERT INTO hive_metastore.hive2uc_db.customers VALUES (4, 'CUST 4');
INSERT INTO hive_metastore.hive2uc_db.customers VALUES (5, 'CUST 5');

-- COMMAND ----------

SELECT * FROM hive_metastore.hive2uc_db.customers;

-- COMMAND ----------

-- MAGIC %md 
-- MAGIC 
-- MAGIC ## Exposing the table under root bucket

-- COMMAND ----------

CREATE  DATABASE  hive_metastore.hive2uc_db_clone;

-- COMMAND ----------

CREATE OR REPLACE TABLE hive_metastore.hive2uc_db_clone.customers CLONE  hive_metastore.hive2uc_db.customers LOCATION "s3://databricks-ext-bkt/hive2uc_db_clone/customers";

-- COMMAND ----------

-- MAGIC %md 
-- MAGIC 
-- MAGIC ## Importing the tables to UC
-- MAGIC 
-- MAGIC Preparing the UC catalog and database

-- COMMAND ----------

CREATE CATALOG IF NOT EXISTS hive2uc_catalog;
CREATE DATABASE hive2uc_catalog.hive2uc_db;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Creates a table in UC from an external S3 Bucket
-- MAGIC These steps are running from workspace 2

-- COMMAND ----------

CREATE TABLE hive2uc_catalog.hive2uc_db.customers LOCATION 's3://databricks-ext-bkt/hive2uc_db_clone/customers';

-- COMMAND ----------

-- MAGIC %md 
-- MAGIC ### Query to check the table

-- COMMAND ----------

SELECT * FROM hive2uc_catalog.hive2uc_db.customers;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ##Clean the environment

-- COMMAND ----------

DROP CATALOG hive2uc_catalog CASCADE;

-- COMMAND ----------

DROP SCHEMA hive_metastore.hive2uc_db CASCADE;


-- COMMAND ----------

DROP SCHEMA hive_metastore.hive2uc_db_clone CASCADE;
