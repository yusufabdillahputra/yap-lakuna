# Recording purchases

A purchase records goods coming in from a supplier: stock goes up, the average cost (COGS) is updated, and any unpaid amount becomes a payable.

![A new purchase paid in part; the rest becomes a payable.](purchase)

## Steps

1. Open **Purchases**, then **New purchase**.
2. Choose the **Supplier**, or **+ New supplier** to type a new name. Fill in the **Supplier invoice no.**, **Date**, and **Receive into** location.
3. Tap **+ Scan / search product**, then enter the unit, quantity, and cost price for each line. Items in their base unit are filled with the price from their last purchase (per base unit). Once a **Supplier** is chosen, the price comes from the last purchase **from that supplier**; items never bought from that supplier use the last purchase price from any supplier. Lines in a conversion unit such as a carton use the carton price from the last purchase **in cartons**, not the bottle price times the pack size. Items never bought in that unit use the cost price. Changing the supplier updates the prices of lines you have not changed; a price you have already typed is never overwritten. On lines filled from *Minimum stock*, changing the unit also converts the suggested quantity (e.g. 38 bottles → 7 boxes of 6) as long as you have not changed the quantity.
4. Enter the **Invoice discount** and **Shipping** if any. Shipping is added to the cost of the goods.
5. Enter **Pay now** and its source (**Store cash**, **Cash drawer**, or **Bank account**), or tap **Pay in full**. The rest becomes a payable with a **Balance due on** date.
6. If you have it, tap **Attach invoice photo** (or **Take invoice photo** on a phone) under *Invoice photo*. The photo is saved with the purchase.
7. Tap **Receive goods & save**. Use **Save draft** if the goods have not arrived yet. If a field is wrong or saving fails, the form scrolls straight to the top-most error message (for example a supplier that has not been chosen).

If you leave a form with unsaved changes (with **Back**, the phone's back button, the side menu, or by picking another draft in the list), Lakuna first asks **Discard changes?**. Choose **Cancel** to return to the form, **Discard** to leave without saving, or **Save draft** to save what you entered as a draft and go straight on (the goods are not received yet and stock does not change). If something is wrong, for example a quantity of 0, you stay on the form with the message. A draft opened from *Minimum stock* with added items also asks until you tap **Save draft**.

## After saving

The purchase detail shows the new average cost and a *Suggested price* that keeps your margin. Tick the products whose price you want to change, then **Apply sell price**.

Tap **Print / share PDF** in the *Actions* card to create a purchase PDF (goods, payment summary, returns, and due date). On a computer the PDF is saved in the Lakuna documents folder; on a phone the share sheet opens so you can send it by WhatsApp or email.

Tap a product name under *Goods received* to open that product's **stock card** at the purchase's receiving location (requires access to the Stock menu).

The *Invoice photo* card shows the supplier's invoice. Tap **View invoice photo** to open it full screen (you can zoom), **Replace photo** to change it, or **Remove photo**. Changing the photo doesn't change stock, cost, or payables. Photos can be PNG, JPG, or WebP up to 20 MB; large photos are resized automatically to 2,000 px on the longest side, so the invoice stays readable while the file stays small.

## Purchase returns

In the purchase detail, tap **Purchase return**, enter the return quantities, then **Process return**. A return lowers stock and the payable; if the purchase is already paid, choose where the refund goes.

> [!note] Paying from the cash drawer needs an open cash session on this device. A received purchase cannot be deleted, only returned.
