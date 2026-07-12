CREATE TABLE customers (
  id BIGINT NOT NULL AUTO_INCREMENT,
  email VARCHAR(255) NOT NULL,
  name VARCHAR(100),
  PRIMARY KEY (id),
  UNIQUE KEY uq_customers_email (email)
);

CREATE TABLE orders (
  id BIGINT NOT NULL AUTO_INCREMENT,
  status VARCHAR(20) NOT NULL,
  total_amount BIGINT,
  customer_id BIGINT NOT NULL,
  PRIMARY KEY (id),
  KEY idx_orders_status (status),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);
