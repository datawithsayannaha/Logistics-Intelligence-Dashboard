CREATE VIEW dim_customer AS
SELECT DISTINCT
    customer_id,
    customer_city,
    customer_state
FROM customers_dataset;

-- SELECT * FROM dim_customer

CREATE VIEW dim_warehouse AS
SELECT DISTINCT
    seller_id,
    seller_city,
    seller_state
FROM sellers_dataset;

-- SELECT * FROM dim_warehouse

CREATE VIEW dim_product AS
SELECT
    product_id,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM products_dataset;

-- SELECT * FROM dim_product

CREATE VIEW dim_date AS
SELECT DISTINCT
    purchase_date AS date,
    YEAR(purchase_date) AS year,
    MONTH(purchase_date) AS month
FROM fact_delivery;

-- SELECT * FROM dim_date
