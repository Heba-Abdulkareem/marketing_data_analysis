CREATE DATABASE IF NOT EXISTS olist_marketing_analytics;

USE olist_marketing_analytics;


-- Basic overview

SELECT
    COUNT(*) AS total_leads,
    COUNT(DISTINCT mql_id) AS unique_leads,
    COUNT(DISTINCT landing_page_id) AS landing_pages,
    COUNT(DISTINCT origin) AS origins,
    MIN(first_contact_date) AS first_contact,
    MAX(first_contact_date) AS last_contact
FROM olist_marketing_qualified_leads_dataset;


-- Leads by origin

SELECT
    CASE
        WHEN origin IS NULL OR TRIM(origin) = '' THEN 'Missing Origin'
        ELSE origin
    END AS origin,
    COUNT(*) AS leads,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_total
FROM olist_marketing_qualified_leads_dataset
GROUP BY
    CASE
        WHEN origin IS NULL OR TRIM(origin) = '' THEN 'Missing Origin'
        ELSE origin
    END
ORDER BY leads DESC;


-- Top landing pages

SELECT
    landing_page_id,
    COUNT(*) AS leads,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_total
FROM olist_marketing_qualified_leads_dataset
GROUP BY landing_page_id
ORDER BY leads DESC
LIMIT 10;


-- Origin and landing page combinations

SELECT
    CASE
        WHEN origin IS NULL OR TRIM(origin) = '' THEN 'Missing Origin'
        ELSE origin
    END AS origin,
    landing_page_id,
    COUNT(*) AS leads,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_total
FROM olist_marketing_qualified_leads_dataset
GROUP BY
    CASE
        WHEN origin IS NULL OR TRIM(origin) = '' THEN 'Missing Origin'
        ELSE origin
    END,
    landing_page_id
ORDER BY leads DESC
LIMIT 15;


-- Monthly leads

WITH monthly_leads AS (
    SELECT
        DATE_FORMAT(first_contact_date, '%Y-%m') AS month,
        COUNT(*) AS leads
    FROM olist_marketing_qualified_leads_dataset
    GROUP BY DATE_FORMAT(first_contact_date, '%Y-%m')
)

SELECT
    month,
    leads,
    ROUND(
        100.0 * leads / SUM(leads) OVER (),
        2
    ) AS percentage_of_total
FROM monthly_leads
ORDER BY month;


-- Monthly growth

WITH monthly_leads AS (
    SELECT
        DATE_FORMAT(first_contact_date, '%Y-%m') AS month,
        COUNT(*) AS leads
    FROM olist_marketing_qualified_leads_dataset
    GROUP BY DATE_FORMAT(first_contact_date, '%Y-%m')
),

monthly_growth AS (
    SELECT
        month,
        leads,
        LAG(leads) OVER (ORDER BY month) AS previous_month
    FROM monthly_leads
)

SELECT
    month,
    leads,
    previous_month,
    CASE
        WHEN previous_month IS NULL OR previous_month = 0 THEN NULL
        ELSE ROUND(
            100.0 * (leads - previous_month) / previous_month,
            2
        )
    END AS growth_rate
FROM monthly_growth
ORDER BY month;


-- Origin performance by month

WITH monthly_origin AS (
    SELECT
        DATE_FORMAT(first_contact_date, '%Y-%m') AS month,
        CASE
            WHEN origin IS NULL OR TRIM(origin) = '' THEN 'Missing Origin'
            ELSE origin
        END AS origin,
        COUNT(*) AS leads
    FROM olist_marketing_qualified_leads_dataset
    GROUP BY
        DATE_FORMAT(first_contact_date, '%Y-%m'),
        CASE
            WHEN origin IS NULL OR TRIM(origin) = '' THEN 'Missing Origin'
            ELSE origin
        END
)

SELECT
    month,
    origin,
    leads,
    ROUND(
        100.0 * leads /
        SUM(leads) OVER (PARTITION BY month),
        2
    ) AS monthly_share,
    RANK() OVER (
        PARTITION BY month
        ORDER BY leads DESC
    ) AS origin_rank
FROM monthly_origin
ORDER BY month, origin_rank;


-- Best origin and landing page for each month

WITH monthly_combinations AS (
    SELECT
        DATE_FORMAT(first_contact_date, '%Y-%m') AS month,
        CASE
            WHEN origin IS NULL OR TRIM(origin) = '' THEN 'Missing Origin'
            ELSE origin
        END AS origin,
        landing_page_id,
        COUNT(*) AS leads
    FROM olist_marketing_qualified_leads_dataset
    GROUP BY
        DATE_FORMAT(first_contact_date, '%Y-%m'),
        CASE
            WHEN origin IS NULL OR TRIM(origin) = '' THEN 'Missing Origin'
            ELSE origin
        END,
        landing_page_id
),

ranked_combinations AS (
    SELECT
        month,
        origin,
        landing_page_id,
        leads,
        ROW_NUMBER() OVER (
            PARTITION BY month
            ORDER BY leads DESC
        ) AS rank_in_month
    FROM monthly_combinations
)

SELECT
    month,
    origin,
    landing_page_id,
    leads
FROM ranked_combinations
WHERE rank_in_month <= 3
ORDER BY month, rank_in_month;


-- Leads by day of week

SELECT
    DAYNAME(first_contact_date) AS day_name,
    COUNT(*) AS leads,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_total,
    RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS lead_rank
FROM olist_marketing_qualified_leads_dataset
GROUP BY
    DAYNAME(first_contact_date),
    DAYOFWEEK(first_contact_date)
ORDER BY DAYOFWEEK(first_contact_date);


-- Data quality check

SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN mql_id IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_mql_id,

    SUM(
        CASE
            WHEN first_contact_date IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_dates,

    SUM(
        CASE
            WHEN landing_page_id IS NULL
                 OR TRIM(landing_page_id) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_landing_pages,

    SUM(
        CASE
            WHEN origin IS NULL
                 OR TRIM(origin) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_origins,

    COUNT(mql_id) - COUNT(DISTINCT mql_id) AS duplicate_mql_ids

FROM olist_marketing_qualified_leads_dataset;


-- Top origins and their contribution

WITH origin_leads AS (
    SELECT
        CASE
            WHEN origin IS NULL OR TRIM(origin) = '' THEN 'Missing Origin'
            ELSE origin
        END AS origin,
        COUNT(*) AS leads
    FROM olist_marketing_qualified_leads_dataset
    GROUP BY
        CASE
            WHEN origin IS NULL OR TRIM(origin) = '' THEN 'Missing Origin'
            ELSE origin
        END
),

ranked_origins AS (
    SELECT
        origin,
        leads,
        RANK() OVER (ORDER BY leads DESC) AS origin_rank
    FROM origin_leads
)

SELECT
    origin_rank,
    origin,
    leads,
    ROUND(
        100.0 * leads / SUM(leads) OVER (),
        2
    ) AS percentage_of_total,
    ROUND(
        100.0 * SUM(leads) OVER (
            ORDER BY leads DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(leads) OVER (),
        2
    ) AS cumulative_percentage
FROM ranked_origins
ORDER BY origin_rank;