USE sales_analytics;

DELIMITER $$
CREATE PROCEDURE sp_customer_summary(IN p_customer_id INT)
BEGIN
  SELECT
    c.customer_id,
    c.full_name,
    COUNT(DISTINCT CASE WHEN o.status <> 'CANCELLED' THEN o.order_id END) AS valid_orders,
    ROUND(COALESCE(SUM(CASE WHEN o.status <> 'CANCELLED' THEN oi.quantity * oi.unit_price * (1 - oi.discount_pct/100) END),0),2) AS total_spent,
    MAX(o.order_date) AS last_order_at
  FROM customers c
  LEFT JOIN orders o ON o.customer_id = c.customer_id
  LEFT JOIN order_items oi ON oi.order_id = o.order_id
  WHERE c.customer_id = p_customer_id
  GROUP BY c.customer_id, c.full_name;
END$$
DELIMITER ;
