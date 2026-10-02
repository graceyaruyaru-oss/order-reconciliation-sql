-- Order reconciliation sample database (SQLite)
-- All data is made up. Structure mirrors a wholesale distributor's order flow.

CREATE TABLE customers   (customer_id TEXT PRIMARY KEY, name TEXT);
CREATE TABLE products    (sku TEXT PRIMARY KEY, description TEXT);
CREATE TABLE price_list  (customer_id TEXT, sku TEXT, contract_price REAL,
                          PRIMARY KEY (customer_id, sku));

CREATE TABLE orders      (order_id TEXT PRIMARY KEY, customer_id TEXT, po_number TEXT, order_date TEXT);
CREATE TABLE order_lines (order_id TEXT, sku TEXT, qty_ordered INTEGER, unit_price REAL,
                          PRIMARY KEY (order_id, sku));

CREATE TABLE shipments      (shipment_id TEXT PRIMARY KEY, order_id TEXT, ship_date TEXT);
CREATE TABLE shipment_lines (shipment_id TEXT, sku TEXT, qty_shipped INTEGER,
                             PRIMARY KEY (shipment_id, sku));

CREATE TABLE invoices      (invoice_id TEXT PRIMARY KEY, order_id TEXT, invoice_date TEXT);
CREATE TABLE invoice_lines (invoice_id TEXT, sku TEXT, qty_invoiced INTEGER, unit_price REAL,
                            PRIMARY KEY (invoice_id, sku));

-- Two inventory systems that are supposed to agree, but were never synchronized
CREATE TABLE inventory_system_a (sku TEXT PRIMARY KEY, on_hand INTEGER);
CREATE TABLE inventory_system_b (sku TEXT PRIMARY KEY, on_hand INTEGER);
