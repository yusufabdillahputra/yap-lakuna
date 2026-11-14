# Manual discounts

The cashier can give a discount on the whole order or per item, as a percentage or an amount.

![The Order discount dialog with a 10% discount.](discount)

## Order discount

1. On the Cashier screen, tap the discount button (percent icon) next to **Pay**.
2. Choose **Percent (%)** or **Amount (Rp)**, then enter the discount value.
3. Tap **Apply**. The discount appears as *Order discount* in the order summary.

## Item discount

Long-press an order line, then enter the line discount the same way.

## Discounts on table and take-away bills

On the **Tables** screen, the bill panel has a **Discount** button for an order discount on the whole bill. For a single menu item (for example, a dish that came out late), tap the percent button on that item's row and enter the **Item discount** the same way.

- Line discounts work for items that are *New*, *In kitchen*, or *Served*. The discount shows under the item name, and the price on the right is already net.
- A percentage discount follows the item when its quantity changes; an amount discount stays the same but never exceeds the line total.
- Adding the same menu item again creates a new line without a discount.
- Service, PB1, and the order discount are calculated from the total after line discounts.
- When splitting a bill per item, discounted lines can be shared between guests. A percentage discount applies to every portion; an amount discount is split in proportion to the quantity (e.g. Rp 1,000 over 3 portions becomes Rp 333 + Rp 334 + Rp 333), so the bill total does not change. Portions moved back are merged again.
- Once a split bill has a part payment, discounts can no longer be changed.

## Manager approval

Manual discounts need the *Manual discounts* permission. If the cashier lacks it and **Manual discount needs manager PIN** is on, a *Manager approval* window appears after **Apply**: a permitted staff member chooses their name and enters their PIN. The approver's name is recorded on the receipt.

> [!warning] A discount cannot use up the whole order total. To remove a discount, open it again and tap **Remove discount**.

Discounts are printed on the receipt and listed under *Discount* in the [profit & loss report](reports).
