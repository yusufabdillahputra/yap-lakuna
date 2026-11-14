# Adjustments & minimum stock

Stock in Lakuna is a ledger: every change is recorded as a movement (opening stock, purchase, sale, return, adjustment). The balance is never edited directly.

![A stock adjustment with a reason per line.](stock)

## Viewing stock

Open **Stock**. The **Product list** tab shows stock per location, the minimum, and the value (COGS). The **Stock card** tab shows the movement history of one product.

## Printing a stock list for counting

Tap **Print stock** at the top of the Stock screen. Lakuna creates an A4 PDF with every item at the selected location: SKU/barcode, stock, minimum, value, and an empty **Counted** column to fill in by hand at the shelf. The search box does not filter the printout, so the list is always complete.

- On a computer, the PDF is saved in the Lakuna documents folder and its location is shown on screen. Open it and print from your PDF viewer.
- On a phone or tablet, the share sheet opens: choose a printer, save, or send.

After counting, enter the physical numbers on the **Adjustment** tab.

## Stock adjustment (stock take)

1. Open the **Adjustment** tab.
2. Choose a **General reason**: *Routine check*, *Damaged*, *Lost*, *Expired*, or *Other*.
3. In **Scan / add product**, scan a barcode or type the name of each counted product.
4. Enter the **Physical** stock. The difference from the system stock is calculated automatically. Add a line reason if it differs.
5. Tap **Save adjustment**.

Adjustments need the *Stock adjustments* permission. Lines with an empty physical count are not saved.

## Minimum stock

Enter **Min stock** per variant in the product form. The **Minimum stock** tab and Home list products below their minimum, so you know when to [buy more](purchases).

Tap **Create purchase** under that list to open a *New purchase* already filled with every item below its minimum, received into the location you are viewing. The suggested quantity is **2 × minimum stock − current stock**, rounded up (e.g. stock 2, minimum 20 → buy 38). Prices use the latest cost price. Choose a supplier, adjust quantities and prices, then save a draft or receive the goods as usual. The button only appears for staff with the *Manage purchases* permission.

## Stock locations

Use the **Stock locations** tab to add a display shelf, warehouse, or separate rack in this branch.

> [!note] Adjustment differences appear on the *Stock adjustments* line of the [profit & loss report](reports).
