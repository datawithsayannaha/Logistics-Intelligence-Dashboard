IF OBJECT_ID('fact_delivery', 'V') IS NOT NULL
	DROP VIEW fact_delivery;
GO

CREATE VIEW fact_delivery AS

-- Base Order

WITH orders_base AS(
	SELECT
		o.order_id,
		o.customer_id,
		CAST(o.order_purchase_timestamp AS DATE) AS purchase_date,
        CAST(o.order_delivered_customer_date AS DATE) AS delivered_date,
        CAST(o.order_estimated_delivery_date AS DATE) AS estimated_date,
        o.order_status
    FROM orders_dataset o
),
-- Order Item (Product + Seller)
orders_items_base AS(
	SELECT
		oi.order_id,
		oi.product_id,
		oi.seller_id,
        oi.price,
		oi.freight_value
	FROM order_items_dataset oi
),
-- join Orders+Items
orders_items_join AS(
	SELECT
		ob.*,
		oi.product_id,
		oi.seller_id,
		oi.price,
		oi.freight_value
	FROM orders_base ob
	LEFT JOIN orders_items_base oi
		ON ob.order_id = oi.order_id
),
-- Add Customer Location
customer_join AS (
    SELECT
        oij.*,
        c.customer_city,
        c.customer_state
    FROM orders_items_join oij
    LEFT JOIN customers_dataset c
        ON oij.customer_id = c.customer_id
),
-- Add Seller
seller_join AS(
	SELECT
		cj.*,
		s.seller_city,
		s.seller_state
	FROM customer_join cj
	LEFT JOIN sellers_dataset s
        ON cj.seller_id = s.seller_id
),
-- Add Product Information
product_join AS (
    SELECT
        sj.*,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm
    FROM seller_join sj
    LEFT JOIN products_dataset p
        ON sj.product_id = p.product_id
),
-- Delivery 
delivery_calc AS (
    SELECT
        *,
        DATEDIFF(DAY, purchase_date, delivered_date) AS delivery_days,
        DATEDIFF(DAY, purchase_date, estimated_date) AS estimated_days,

        DATEDIFF(DAY, estimated_date, delivered_date) AS delay_days,

        CASE 
            WHEN DATEDIFF(DAY, estimated_date, delivered_date) > 0 THEN 1
            ELSE 0
        END AS delayed_flag
    FROM product_join
)

-- Final Output
SELECT * FROM delivery_calc;
GO

-- SELECT * FROM fact_delivery
