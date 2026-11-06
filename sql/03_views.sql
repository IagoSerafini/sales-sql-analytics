USE sales_analytics;

CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
  o.order_id,
  o.order_date,
  o.status,
  o.channel,
  c.customer_id,
  c.full_name,
  c.city,
  c.state,
  ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS order_total
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.order_date, o.status, o.channel, c.customer_id, c.full_name, c.city, c.state;

CREATE OR REPLACE VIEW vw_customer_ltv AS
SELECT
  c.customer_id,
  c.full_name,
  c.city,
  c.state,
  COUNT(DISTINCT CASE WHEN o.status <> 'CANCELLED' THEN o.order_id END) AS valid_orders,
  COALESCE(ROUND(SUM(CASE WHEN o.status <> 'CANCELLED' THEN oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100) ELSE 0 END),2),0) AS lifetime_value
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.full_name, c.city, c.state;
