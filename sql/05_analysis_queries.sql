USE sales_analytics;

-- 1) Receita total e ticket médio
SELECT
  ROUND(SUM(order_total),2) AS revenue,
  ROUND(AVG(order_total),2) AS average_ticket,
  COUNT(*) AS valid_orders
FROM vw_order_summary
WHERE status <> 'CANCELLED';

-- 2) Receita mensal
SELECT DATE_FORMAT(order_date,'%Y-%m') AS month,
       ROUND(SUM(order_total),2) AS revenue
FROM vw_order_summary
WHERE status <> 'CANCELLED'
GROUP BY month
ORDER BY month;

-- 3) Top 5 produtos por receita
SELECT p.name,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)),2) AS revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status <> 'CANCELLED'
GROUP BY p.product_id, p.name
ORDER BY revenue DESC
LIMIT 5;

-- 4) Receita por categoria
SELECT c.name AS category,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)),2) AS revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE o.status <> 'CANCELLED'
GROUP BY c.category_id, c.name
ORDER BY revenue DESC;

-- 5) Clientes recorrentes
SELECT customer_id, full_name, valid_orders, lifetime_value
FROM vw_customer_ltv
WHERE valid_orders >= 3
ORDER BY lifetime_value DESC;

-- 6) Taxa de cancelamento
SELECT ROUND(100 * SUM(status='CANCELLED') / COUNT(*),2) AS cancellation_rate_pct
FROM orders;

-- 7) Vendas por canal
SELECT channel, COUNT(*) AS orders, ROUND(SUM(order_total),2) AS revenue
FROM vw_order_summary
WHERE status <> 'CANCELLED'
GROUP BY channel
ORDER BY revenue DESC;

-- 8) Métodos de pagamento
SELECT payment_method, COUNT(*) AS payments
FROM payments
GROUP BY payment_method
ORDER BY payments DESC;

-- 9) Produtos com estoque baixo
SELECT product_id, name, stock_qty
FROM products
WHERE stock_qty < 40
ORDER BY stock_qty;

-- 10) Ranking de clientes
SELECT customer_id, full_name, lifetime_value,
       DENSE_RANK() OVER (ORDER BY lifetime_value DESC) AS customer_rank
FROM vw_customer_ltv
ORDER BY customer_rank
LIMIT 15;

-- 11) Comparação mensal com mês anterior (window function)
WITH monthly AS (
  SELECT DATE_FORMAT(order_date,'%Y-%m') AS month,
         SUM(order_total) AS revenue
  FROM vw_order_summary
  WHERE status <> 'CANCELLED'
  GROUP BY month
)
SELECT month,
       ROUND(revenue,2) AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY month),2) AS previous_month,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month)) /
             NULLIF(LAG(revenue) OVER (ORDER BY month),0),2) AS growth_pct
FROM monthly;

-- 12) Resumo de um cliente via stored procedure
CALL sp_customer_summary(1);
