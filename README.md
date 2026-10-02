# Order Reconciliation with SQL

At a wholesale distributor I spent a lot of time answering the same questions by hand, across five systems that were supposed to agree: the customer EDI feed, two inventory systems, the accounting ledger and the online store.

- What do we still owe this customer after a split shipment?
- Did we ship something we never billed?
- Did we bill the price we agreed to?
- Which stock count is right?

This repository turns those questions into SQL. **The data is made up**, but the structure and the problems planted in it are the kind I dealt with every week.

## The data

```
customers ─┬─ price_list (contract price per customer and SKU)
           └─ orders ─┬─ order_lines
                      ├─ shipments ─ shipment_lines   (one order, several shipments)
                      └─ invoices  ─ invoice_lines
inventory_system_a / inventory_system_b               (two counts that should match)
```

## What the queries find

**Q1. Open quantity after partial shipments.** Order SO-1001 shipped in four parts and is still 30 units short.

| order_id | sku | ordered | shipped | open | shipments |
|---|---|---|---|---|---|
| SO-1001 | SKU-100 | 200 | 170 | 30 | 4 |

**Q2. Shipped vs. invoiced.** One shipment was never billed, one order was billed one unit too many, and one order was never invoiced at all.

| order_id | sku | shipped | invoiced | difference | issue |
|---|---|---|---|---|---|
| SO-1001 | SKU-100 | 170 | 150 | 20 | Shipped, not billed |
| SO-1003 | SKU-200 | 80 | 81 | -1 | Billed, not shipped |
| SO-1005 | SKU-500 | 90 | 0 | 90 | Shipped, not billed |

**Q3. Invoice price vs. contract price.** One line was billed above the agreed price.

| invoice | order | customer | sku | invoiced | contract | overbilled |
|---|---|---|---|---|---|---|
| INV-5004 | SO-1004 | C01 | SKU-300 | 19.50 | 18.00 | 90.00 |

**Q4. The two inventory systems disagree.**

| sku | description | system A | system B | gap |
|---|---|---|---|---|
| SKU-100 | Hard case, large | 35 | 55 | 20 |
| SKU-300 | Cleaning kit | 400 | 388 | -12 |

**Q5. A one-line summary** for a weekly check-in, so the team sees how many problems are open without reading every row.

| check | issues |
|---|---|
| Order lines still open | 1 |
| Shipped but not invoiced | 2 |
| Invoice price off contract | 1 |
| Inventory systems disagree | 2 |

## Run it yourself

With [DB Browser for SQLite](https://sqlitebrowser.org/) or the `sqlite3` command line:

```bash
sqlite3 demo.db < schema.sql
sqlite3 demo.db < sample_data.sql
sqlite3 -header -column demo.db < queries.sql
```

## Files

| File | What it is |
|---|---|
| [`schema.sql`](schema.sql) | Table definitions |
| [`sample_data.sql`](sample_data.sql) | Made-up data with the problems planted on purpose |
| [`queries.sql`](queries.sql) | The five reconciliation queries, each with the business question it answers |

## Why it matters

Finding the mismatch is only half the job. Each query points to the handoff where records stopped agreeing, so the process can be fixed and the same order doesn't need rebuilding next month.
