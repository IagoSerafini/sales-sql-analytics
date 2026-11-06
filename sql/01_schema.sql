DROP DATABASE IF EXISTS sales_analytics;
CREATE DATABASE sales_analytics CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sales_analytics;

CREATE TABLE customers (
  customer_id INT PRIMARY KEY AUTO_INCREMENT,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL UNIQUE,
  city VARCHAR(80) NOT NULL,
  state CHAR(2) NOT NULL,
  created_at DATE NOT NULL
);

CREATE TABLE categories (
  category_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE products (
  product_id INT PRIMARY KEY AUTO_INCREMENT,
  category_id INT NOT NULL,
  name VARCHAR(120) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
  stock_qty INT NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
  active BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT NOT NULL,
  order_date DATETIME NOT NULL,
  status ENUM('PAID','SHIPPED','DELIVERED','CANCELLED') NOT NULL,
  channel ENUM('WEB','APP','MARKETPLACE') NOT NULL,
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  INDEX idx_orders_customer_date (customer_id, order_date),
  INDEX idx_orders_status_date (status, order_date)
);

CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
  discount_pct DECIMAL(5,2) NOT NULL DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 100),
  CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id),
  INDEX idx_items_order (order_id),
  INDEX idx_items_product (product_id)
);

CREATE TABLE payments (
  payment_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT NOT NULL UNIQUE,
  payment_method ENUM('PIX','CREDIT_CARD','DEBIT_CARD','BOLETO') NOT NULL,
  installments INT NOT NULL DEFAULT 1 CHECK (installments >= 1),
  paid_at DATETIME NULL,
  CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);
