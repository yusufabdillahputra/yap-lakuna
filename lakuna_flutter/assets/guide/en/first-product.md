# Adding your first product

Products must exist before they can be sold at the cashier. One product can have several variants (e.g. sizes), conversion units (e.g. a box of 12), and wholesale prices.

![The Edit product form with tabs for variants, units, wholesale and modifiers.](product)

> [!note] During store setup, step 4 can already create one first product (name, price, unit, barcode, opening stock) or open the Excel import right away.

## Steps

1. Open **Products**, then tap **New product**.
2. Under *Basic info*, enter the **Product name**, choose a **Category**, and the **Type**: *Goods* (stock tracked), *Service* (no stock), or *F&B menu*.
3. Enter the **Base unit**, for example pcs, bottle, or kg. Stock is always kept in this unit.
4. On the **Variants** tab, enter the cost price, sell price, minimum stock, and opening stock. Add rows with **Add variant** if needed. SKU and barcode are optional for scanning.
5. Tap **Save**.

## Units & wholesale prices

- **Units & conversion** tab: add a unit such as *box* holding 12 pcs. Selling 1 box takes 12 pcs out of stock. An empty price means base price × contents.
- **Wholesale prices** tab: set a unit price from a given quantity. The cashier applies it automatically.

## Many products at once

In **Products**, tap **Import Excel**. Tap **Download template** for an Excel file with the headers (Name, Category, Type, Unit, SKU, Barcode, Cost price, Sell price, Opening stock, Minimum stock) and two sample rows. Replace the sample rows with your products (leftover sample rows are skipped automatically), then tap **Choose file**. The preview shows the rows that are ready and the rows that are skipped, with the reason.

> [!note] Categories and units can also be managed in **Master data**. The category order there becomes the tab order at the cashier.

Once the product is saved, continue with [Sales & wholesale prices](sale).
