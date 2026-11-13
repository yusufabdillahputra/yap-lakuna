# Tables & open bills

*F&B* and *Mixed* businesses use the **Tables** screen to record orders per table (dine in) or take away, then pay when the guests are done.

![The floor plan and the open bill for Table M2.](tables)

## Before you start

- Create areas and tables in **Master data › Tables & areas**. Use **Add several** to create T1–T12 at once.
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
- When you **Close & pay** with *Credit / receivable*, the bill's customer is selected automatically. Credit for a different customer is refused; change the bill's customer first.
- The customer cannot be changed once the bill is split or has a part payment. Two bills with different customers cannot be merged.

## Closing a bill

1. When the guests ask for the bill, tap **Request bill** (the table changes colour).
2. Tap **Close & pay**. The Pay screen opens with a total that includes service and PB1.
3. Finish as with [cash payment](pay-cash) or [static QRIS](pay-qris). For guests paying separately, use [Split bill](split-bill).

## Moving and voiding

- **Move table** moves the whole bill to an empty table.
- **Void bill** closes the bill without payment; a reason is required and it needs the *Void receipts* permission (or a manager PIN).

> [!note] Items already sent to the kitchen cannot be changed or removed.
