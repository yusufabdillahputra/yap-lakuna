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

> [!note] The adjustment draft only lives while the Stock screen is open. Once the draft has products (or a note), switching menus or pressing back shows **Discard changes?**: choose **Cancel** to keep counting, or **Discard** to leave. Changing the **location** at the top of the screen also asks first, because the draft is cleared when the location changes. Switching tabs (*Product list*, *Stock card*, and so on) or opening a purchase form from *Minimum stock* keeps the draft.

## Minimum stock

Enter **Min stock** per variant in the product form. The **Minimum stock** tab and Home list products below their minimum, so you know when to [buy more](purchases).

Tap **Create purchase** under that list to open a *New purchase* already filled with every item below its minimum, received into the location you are viewing. The suggested quantity is **2 × minimum stock − current stock**, rounded up (e.g. stock 2, minimum 20 → buy 38). Each line's price comes from the purchase price on that item's last purchase (per base unit, e.g. IDR 185,000 per box of 6 becomes IDR 30,833); items never bought before use the cost price. The note above the form says how many items took their price from the last purchase. The **supplier** is filled with the supplier of the last purchase for most of those items (the note above the form names it and how many items); change it if needed, adjust quantities and prices, then save a draft or receive the goods as usual. The button only appears for staff with the *Manage purchases* permission.

The suggested quantity is in the base unit. If the supplier sells by the box, change the line's **Unit** to the box and the quantity is converted, rounded up to whole boxes (e.g. a suggestion of 38 bottles → 7 boxes of 6); switching back to bottles restores 38. Once you type a quantity yourself or add the item again by scanning, the quantity is no longer converted when the unit changes.

A draft does not add stock, so items already in a draft still show below minimum. If a **purchase draft** for the same location already has some of those items, **Create purchase** first shows *A purchase draft already exists* with the draft number and how many of the items it already has. Choose **Open draft** to continue that draft: items below minimum that are not in any draft yet are added with the suggested quantity and last purchase price, while the draft's existing lines stay as they are (the note above the form says how many were added; tap **Save draft** to keep them), **Create new draft** if you really need a separate purchase, or **Cancel**. When several drafts match, the one with the most matching items opens; the others are in the *Purchases* menu.

So you don't have to guess, items in the *Below minimum stock* list that are already in a purchase draft for this location show a blue **Already in draft** note with the draft number. Items without that note have not been ordered yet. The note only appears for staff with the *Manage purchases* permission.

## Stock locations

Use the **Stock locations** tab to add a display shelf, warehouse, or separate rack in this branch.

> [!note] Adjustment differences appear on the *Stock adjustments* line of the [profit & loss report](reports).
