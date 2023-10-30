USE sql_store;
SELECT
    order_id,
    IFNULL(shipper_id, 'Not resigned') AS shipper,
    COALESCE(shipper_id, comments, 'Not resigned') AS shipper2
FROM orders;