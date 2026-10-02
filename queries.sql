-- Order reconciliation queries (SQLite)
-- Each query answers one question I used to answer by hand across several systems.

-- Q1. Open quantity on every order line, after all partial shipments
--     "What do we still owe this customer?"
SELECT ol.order_id, ol.sku, ol.qty_ordered,
       COALESCE(SUM(sl.qty_shipped), 0)                  AS qty_shipped,
       ol.qty_ordered - COALESCE(SUM(sl.qty_shipped), 0) AS qty_open,
       COUNT(DISTINCT s.shipment_id)                     AS shipments
FROM order_lines ol
LEFT JOIN shipments s       ON s.order_id = ol.order_id
LEFT JOIN shipment_lines sl ON sl.shipment_id = s.shipment_id AND sl.sku = ol.sku
GROUP BY ol.order_id, ol.sku
HAVING qty_open <> 0
ORDER BY qty_open DESC;

-- Q2. Shipped vs. invoiced, line by line
--     "Did we ship something we never billed, or bill something we never shipped?"
WITH shipped AS (
  SELECT s.order_id, sl.sku, SUM(sl.qty_shipped) AS qty_shipped
  FROM shipments s JOIN shipment_lines sl ON sl.shipment_id = s.shipment_id
  GROUP BY s.order_id, sl.sku
), invoiced AS (
  SELECT i.order_id, il.sku, SUM(il.qty_invoiced) AS qty_invoiced
  FROM invoices i JOIN invoice_lines il ON il.invoice_id = i.invoice_id
  GROUP BY i.order_id, il.sku
)
SELECT sh.order_id, sh.sku, sh.qty_shipped,
       COALESCE(iv.qty_invoiced, 0)                  AS qty_invoiced,
       sh.qty_shipped - COALESCE(iv.qty_invoiced, 0) AS difference,
       CASE WHEN COALESCE(iv.qty_invoiced, 0) < sh.qty_shipped
            THEN 'Shipped, not billed' ELSE 'Billed, not shipped' END AS issue
FROM shipped sh
LEFT JOIN invoiced iv ON iv.order_id = sh.order_id AND iv.sku = sh.sku
WHERE sh.qty_shipped <> COALESCE(iv.qty_invoiced, 0)
ORDER BY sh.order_id;

-- Q3. Invoice price vs. the customer's contract price
--     "Did we bill the price we agreed to?"
SELECT i.invoice_id, i.order_id, o.customer_id, il.sku,
       il.unit_price  AS invoiced_price,
       p.contract_price,
       ROUND((il.unit_price - p.contract_price) * il.qty_invoiced, 2) AS overbilled_amount
FROM invoice_lines il
JOIN invoices i   ON i.invoice_id = il.invoice_id
JOIN orders o     ON o.order_id = i.order_id
JOIN price_list p ON p.customer_id = o.customer_id AND p.sku = il.sku
WHERE il.unit_price <> p.contract_price;

-- Q4. The two inventory systems disagree
--     "Which stock count can we trust?"
SELECT a.sku, pr.description,
       a.on_hand AS system_a, b.on_hand AS system_b,
       b.on_hand - a.on_hand AS gap
FROM inventory_system_a a
JOIN inventory_system_b b ON b.sku = a.sku
JOIN products pr          ON pr.sku = a.sku
WHERE a.on_hand <> b.on_hand;

-- Q5. One-line exception summary for a weekly check-in
SELECT 'Order lines still open'       AS check_name, COUNT(*) AS issues FROM (
  SELECT ol.order_id, ol.sku
  FROM order_lines ol
  LEFT JOIN shipments s       ON s.order_id = ol.order_id
  LEFT JOIN shipment_lines sl ON sl.shipment_id = s.shipment_id AND sl.sku = ol.sku
  GROUP BY ol.order_id, ol.sku
  HAVING ol.qty_ordered <> COALESCE(SUM(sl.qty_shipped), 0))
UNION ALL
SELECT 'Shipped but not invoiced', COUNT(*) FROM (
  SELECT s.order_id, sl.sku
  FROM shipments s JOIN shipment_lines sl ON sl.shipment_id = s.shipment_id
  GROUP BY s.order_id, sl.sku
  HAVING SUM(sl.qty_shipped) > COALESCE((
    SELECT SUM(il.qty_invoiced) FROM invoices i
    JOIN invoice_lines il ON il.invoice_id = i.invoice_id
    WHERE i.order_id = s.order_id AND il.sku = sl.sku), 0))
UNION ALL
SELECT 'Invoice price off contract', COUNT(*)
FROM invoice_lines il
JOIN invoices i   ON i.invoice_id = il.invoice_id
JOIN orders o     ON o.order_id = i.order_id
JOIN price_list p ON p.customer_id = o.customer_id AND p.sku = il.sku
WHERE il.unit_price <> p.contract_price
UNION ALL
SELECT 'Inventory systems disagree', COUNT(*)
FROM inventory_system_a a JOIN inventory_system_b b ON b.sku = a.sku
WHERE a.on_hand <> b.on_hand;
