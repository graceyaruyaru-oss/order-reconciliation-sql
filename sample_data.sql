-- Made-up data with a few problems planted on purpose (see README).

INSERT INTO customers VALUES
 ('C01','Northern Outdoor Retail'), ('C02','Prairie Supply Co.'), ('C03','Coastal Sports Chain');

INSERT INTO products VALUES
 ('SKU-100','Hard case, large'), ('SKU-200','Soft case, medium'),
 ('SKU-300','Cleaning kit'),     ('SKU-400','Storage cabinet'), ('SKU-500','Wall mount');

INSERT INTO price_list VALUES
 ('C01','SKU-100',120.00), ('C01','SKU-200',45.00), ('C01','SKU-300',18.00),
 ('C02','SKU-100',125.00), ('C02','SKU-400',640.00),
 ('C03','SKU-200',44.00),  ('C03','SKU-300',17.50), ('C03','SKU-500',32.00);

INSERT INTO orders VALUES
 ('SO-1001','C01','PO-88412','2026-03-02'),
 ('SO-1002','C02','PO-55107','2026-03-04'),
 ('SO-1003','C03','PO-90233','2026-03-05'),
 ('SO-1004','C01','PO-88460','2026-03-09'),
 ('SO-1005','C03','PO-90301','2026-03-11');

INSERT INTO order_lines VALUES
 ('SO-1001','SKU-100',200,120.00), ('SO-1001','SKU-200',150,45.00),
 ('SO-1002','SKU-100', 40,125.00), ('SO-1002','SKU-400', 10,640.00),
 ('SO-1003','SKU-200', 80,44.00),  ('SO-1003','SKU-300',120,17.50),
 ('SO-1004','SKU-300', 60,18.00),
 ('SO-1005','SKU-500', 90,32.00);

-- SO-1001 ships in four parts and is still short on SKU-100
INSERT INTO shipments VALUES
 ('SH-01','SO-1001','2026-03-06'), ('SH-02','SO-1001','2026-03-13'),
 ('SH-03','SO-1001','2026-03-20'), ('SH-04','SO-1001','2026-03-27'),
 ('SH-05','SO-1002','2026-03-07'),
 ('SH-06','SO-1003','2026-03-09'), ('SH-07','SO-1003','2026-03-16'),
 ('SH-08','SO-1004','2026-03-12'),
 ('SH-09','SO-1005','2026-03-14');

INSERT INTO shipment_lines VALUES
 ('SH-01','SKU-100',60), ('SH-01','SKU-200',150),
 ('SH-02','SKU-100',50),
 ('SH-03','SKU-100',40),
 ('SH-04','SKU-100',20),
 ('SH-05','SKU-100',40), ('SH-05','SKU-400',10),
 ('SH-06','SKU-200',80), ('SH-06','SKU-300',70),
 ('SH-07','SKU-300',50),
 ('SH-08','SKU-300',60),
 ('SH-09','SKU-500',90);

-- Invoices: SO-1001 shipment 4 never invoiced; SO-1003 billed one unit too many;
-- SO-1004 billed at the wrong price; SO-1005 not invoiced at all
INSERT INTO invoices VALUES
 ('INV-5001','SO-1001','2026-03-21'),
 ('INV-5002','SO-1002','2026-03-08'),
 ('INV-5003','SO-1003','2026-03-17'),
 ('INV-5004','SO-1004','2026-03-13');

INSERT INTO invoice_lines VALUES
 ('INV-5001','SKU-100',150,120.00), ('INV-5001','SKU-200',150,45.00),
 ('INV-5002','SKU-100', 40,125.00), ('INV-5002','SKU-400', 10,640.00),
 ('INV-5003','SKU-200', 81,44.00),  ('INV-5003','SKU-300',120,17.50),
 ('INV-5004','SKU-300', 60,19.50);

-- The two inventory systems disagree on two SKUs
INSERT INTO inventory_system_a VALUES
 ('SKU-100',35), ('SKU-200',210), ('SKU-300',400), ('SKU-400',12), ('SKU-500',75);
INSERT INTO inventory_system_b VALUES
 ('SKU-100',55), ('SKU-200',210), ('SKU-300',388), ('SKU-400',12), ('SKU-500',75);
