# Tables & open bills

*F&B* and *Mixed* businesses use the **Tables** screen to record orders per table (dine in) or take away, then pay when the guests are done.

![The floor plan and the open bill for Table M2.](tables)

## Before you start

- Create areas and tables in **Master data › Tables & areas**. Use **Add several** to create T1–T12 at once. If you have changed an area, table, or range dialog and press **Cancel**, Esc, tap outside the dialog, or use the phone's back button, Lakuna asks **Discard changes?** first. Choose **Cancel** to return to the dialog, **Discard** to close without saving, or **Save** to save it straight away. If a name is already used (for example a T1–T12 range when T7 exists), the dialog stays open and the message appears right under the **Name** field (for a range: in place of the name preview). The cursor moves straight to the wrong field (Name, Seats, or From/To for a range), so you can retype it and save again.
- Set the service charge and PB1 restaurant tax in **Settings › Tax & service**. Service applies to dine in only.

## Opening a bill

1. Open **Tables**. Table colours show the status: *Empty*, *Occupied · open bill*, or *Bill requested*.
2. Tap an empty table, enter the number of **Guests**, then **Open bill**. For take away, tap **New take away** and add a customer name if needed.
3. Tap **+ Menu**, search for items, and tap to add them. Items with [modifiers](modifiers) open a choice sheet first.
4. Tap **Send to kitchen**. The kitchen ticket lists only the new items and can be printed with **Print ticket**. If a *Kitchen printer* is set in **Settings › Receipt & printer**, the ticket prints there right away; if it fails, tap **Reprint**. Items with *Send to kitchen ticket* turned off are left off the ticket and marked *Served* right away (see [Menu modifiers](modifiers)).
5. Use **Mark served** when the food is delivered.

## Customer on the bill

- Tap **Choose customer** under the bill title, search by name or phone, then tap the customer. If the customer belongs to a group with [wholesale prices](first-product), every item on the bill switches to the group price right away, including items already sent to the kitchen.
- **Change** picks another customer; the **×** button removes the customer and restores normal prices.
- If the customer's group is changed under **Customers** while the bill is still open, the bill panel shows *Customer group changed. Bill prices still use the old group.* Tap **Refresh prices** to recalculate every item with the new group and the current menu prices. Until you refresh, newly added items already use the new group.
- When you **Close & pay** with *Credit / receivable*, the bill's customer is selected automatically. Credit for a different customer is refused; change the bill's customer first.
- The customer cannot be changed once the bill is split or has a part payment. Two bills with different customers cannot be merged.

## Merging tables

A group sitting at two tables can pay on one bill. On the bill panel, tap **Merge tables**, then pick the other table whose bill should move into this one. Both tables must allow merging (set it on the floor plan or in **Master data › Tables & areas**). Every item moves to this bill and the source table becomes free.

The merge leaves a trail. Once the bill is paid, its receipt detail in [History](return-void) reads *Merged from table M3 (OB-…) · 03/11/26 09.10 · Rina*: the source table and bill number, the time, and the staff member who merged it. Bills that had already taken in another table are listed too.

## Closing a bill

1. When the guests ask for the bill, tap **Request bill** (the table changes colour).
2. Tap **Close & pay**. The Pay screen opens with a total that includes service and PB1.
3. Finish as with [cash payment](pay-cash) or [static QRIS](pay-qris). For guests paying separately, use [Split bill](split-bill).

## Printing the bill

Guests can check the bill before paying.

1. In the bill panel, tap **Print bill**. A preview appears with the order, Subtotal, discount, service, PB1, rounding, and TOTAL, under the banner *BILL - NOT PAID*.
2. Tap **Print bill** in the dialog to print on the receipt printer, or **Share PDF** to send it via WhatsApp.
3. If some guests have already paid through split bill, the bill shows *Paid so far* and *Balance due*. The store's transfer account is printed too when it is set in [Store settings](store-settings).

> [!note] Printing the bill does not close it, does not change the *Request bill* status, and does not create a new receipt number. Guests can still order more; print the bill again afterwards.

## Moving and voiding

- **Move table** moves the whole bill to an empty table.
- **Void bill** closes the bill without payment; a reason is required and it needs the *Void receipts* permission (or a manager PIN).

> [!note] Items already sent to the kitchen cannot be changed or removed.
