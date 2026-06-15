CREATE DATABASE
marketplace_fraud;

SELECT *
FROM marketplace_fraud.vendors
WHERE city = 'Lagos' AND risk_category = 'critical';

-- how many vendors belongs to each risk categories --
SELECT risk_category,
	COUNT(vendor_id) AS Total_vendors_by_risk_categories
FROM marketplace_fraud.vendors
GROUP BY risk_category;

-- Any bank accounts used by more than one restaurant --
SELECT bank_account,
	COUNT(vendor_id) AS restuarants_using_the_same_bank_account
FROM marketplace_fraud.vendors
GROUP BY bank_account
HAVING bank_account > 1;

-- how much total money # has been refunded, broken down by risk category--
SELECT v.risk_category,
	SUM(order_amount) AS total_amount_refunded_by_risk_category
FROM marketplace_fraud.vendors AS v
		INNER JOIN marketplace_fraud.orders AS o
        ON v.vendor_id = o.vendor_id
WHERE o.refund_requested = 'True'
GROUP BY v.risk_category;

-- which vendors haven't processed an order yet--
SELECT v.vendor_id,
		v.restaurant_name,
        v.risk_category,
        o.order_id
FROM marketplace_fraud.vendors AS v
	LEFT JOIN marketplace_fraud.orders AS o
    ON v.vendor_id = o.vendor_id
WHERE o.order_id IS NULL;

-- what is the average customer rating for each risk category--
SELECT v.risk_category,
	ROUND(AVG(o.customer_rating), 1)
FROM marketplace_fraud.vendors AS v
	INNER JOIN marketplace_fraud.orders AS o
    ON v.vendor_id = o.vendor_id
WHERE o.delivery_status = 'Delivered'
GROUP BY v.risk_category;

-- For each risk category, what is the percentage of orders that results in a refund--
SELECT v.risk_category,
	COUNT(o.order_id) AS Total_orders,
    SUM(CASE WHEN o.refund_requested = 'True'
	THEN 1 ELSE 0 END) AS Refunded_orders,
    ROUND((SUM(CASE WHEN o.refund_requested = 'True'
	THEN 1 ELSE 0 END) / count(o.order_id)) * 100, 2) AS refund_percentage
FROM marketplace_fraud.vendors AS v
	INNER JOIN marketplace_fraud.orders AS o
    ON v.vendor_id = o.vendor_id
GROUP BY v.risk_category;

-- when did the highest number of critical and high risk vendors sign up, month and year--
SELECT YEAR(signup_date) AS Signup_year,
	DATE_FORMAT(signup_date, '%b') AS Signup_month,
    COUNT(vendor_id) AS Total_risky_vendors
FROM marketplace_fraud.vendors
WHERE risk_category IN ('Critical', 'High')
	AND YEAR(signup_date) IS NOT NULL
GROUP BY Signup_year,
		Signup_month
ORDER BY Total_risky_vendors DESC;

-- what is the average order value for each risk category--
SELECT v.risk_category,
	ROUND(AVG(o.order_amount),2) AS avg_order_value_for_each_risk_category
FROM marketplace_fraud.vendors AS v
	INNER JOIN marketplace_fraud.orders AS o
    ON v.vendor_id = o.vendor_id
GROUP BY v.risk_category;

-- restaurants with the highest total refund requested amounts--
SELECT v.restaurant_name,
	SUM(o.order_amount) AS Total_request_amount
FROM marketplace_fraud.vendors AS v
	INNER JOIN marketplace_fraud.orders AS o
    ON v.vendor_id = o.vendor_id
WHERE refund_requested = 'True'
GROUP BY v.restaurant_name
ORDER BY Total_request_amount DESC
LIMIT 10;

SELECT *
FROM marketplace_fraud.images;

-- are there restaurants with orders on the same date as there sign up date--
SELECT v.vendor_id AS Vendor_id,
	v.restaurant_name AS restaurant_name,
    v.risk_category AS Risk_category,
    o.delivery_status AS Delivery_status,
    o.customer_rating AS Customer_rating,
    o.refund_requested AS Refund_request_status
FROM marketplace_fraud.vendors AS v
	INNER JOIN marketplace_fraud.orders AS o
    ON v.vendor_id = o.vendor_id
WHERE v.signup_date = str_to_date(o.order_time, '%M/%D/%Y');

SELECT v.vendor_id,
	v.signup_date,
    o.order_time,
    STR_TO_DATE(o.order_time, '%m/%d/%Y') AS Translated_order_time
FROM marketplace_fraud.vendors AS v
	INNER JOIN marketplace_fraud.orders AS o
    ON v.vendor_id = o.vendor_id
LIMIT 20;

-- are multiple vendors using the same image--
SELECT image_id,
	COUNT(DISTINCT vendor_id) AS Number_of_vendor_using_this_image
FROM marketplace_fraud.images
GROUP BY image_id
HAVING COUNT(DISTINCT vendor_id) > 1
ORDER BY Number_of_vendor_using_this_image DESC;

-- does vendors risk categories correspond to there image source--
SELECT v.risk_category AS Risk_category,
	i.image_source AS Source_of_image,
    COUNT(DISTINCT v.vendor_id) AS Number_of_vendor_using_this_image
FROM marketplace_fraud.vendors AS v
	INNER JOIN marketplace_fraud.images AS i
    ON v.vendor_id = i.vendor_id
GROUP BY Risk_category,
	Source_of_image
ORDER BY Number_of_vendor_using_this_image DESC;
