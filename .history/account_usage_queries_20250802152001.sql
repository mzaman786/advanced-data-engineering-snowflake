-- session setup (safe to run multiple times)
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
-- You can keep DB/SCHEMA unset when querying SNOWFLAKE.ACCOUNT_USAGE
-- or set a working database if your script creates objects:
-- USE DATABASE MY_DB;
-- USE SCHEMA PUBLIC;

-- recent queries by user (last 24h)
SELECT user_name, query_text, start_time, total_elapsed_time/1000 AS secs
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD('hour', -24, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 100;

-- warehouse consumption (last 7 days)
SELECT warehouse_name, start_time::date AS day,
       SUM(credits_used) AS credits
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE start_time >= DATEADD(day,-7,CURRENT_TIMESTAMP())
GROUP BY 1,2
ORDER BY 2 DESC, 1;

-- storage by database
SELECT database_name, active_bytes/POWER(1024,3) AS active_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY
WHERE usage_date = (SELECT MAX(usage_date) FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY)
ORDER BY active_gb DESC;
