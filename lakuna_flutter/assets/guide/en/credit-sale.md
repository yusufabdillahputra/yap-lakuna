# Credit sales (receivables)

Regular customers can take goods now and pay later. The unpaid balance becomes the customer's receivable.

## Before you start

The customer must be registered with a **Credit limit** above 0 in [Customers](customers-credit). The payment term follows the customer group (no group: 14 days).

## Steps

1. On the Pay screen, choose **Credit / receivable**.
2. **Choose customer**. The running balance and remaining limit appear.
3. Enter **Pay now (down payment)** if the customer pays part in cash. Zero is allowed.
4. Check the **Due** date (today + standard term) and change it if needed.
5. Tap **Save as receivable**.

> [!warning] If the running balance plus the new receivable exceeds the limit, the receipt cannot be saved. Lower the amount or raise the down payment.

The receipt prints the *On credit* and *Due* lines. If a *Transfer account* is set in [Store settings](store-settings), it also prints *Transfer to:* followed by the account so the customer knows where to pay the rest.

In F&B, credit is also available from **Close & pay** on a table or takeaway bill, and for the last part of a [split bill](split-bill). For a split bill, the limit is checked against that part's amount minus the down payment, while the other guests' parts stay recorded as payments on the same receipt.

The receipt is marked *Unpaid* in History and added to the customer's receivables. Later payments are recorded in [Customers & receivables](customers-credit).
