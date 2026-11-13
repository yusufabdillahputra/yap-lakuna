# Suppliers & payables

The **Suppliers** menu keeps supplier details and the payable for each purchase, and records payments.

## Adding a supplier

1. Open **Suppliers**, then tap **Supplier**.
2. Enter the supplier name, contact, phone, goods category, and **Standard term (days)**. The term fills in the default due date in [Purchases](purchases).
3. Tap **Save**.

Many suppliers at once? Tap **Import Excel** and choose an .xlsx or .csv file with the columns **Name** (required), Contact, Phone, Category, Term days, Address, Note. Headers can be in Indonesian or English.

- The preview shows how many rows are ready and which rows are skipped, with the reason (empty name, invalid phone, term outside 0–365 days, text too long, name repeated in the file).
- A name that is already registered (ignoring upper/lower case) **updates** that supplier: only filled cells replace data, empty cells keep the old data.
- New suppliers without a term get the standard 14 days. The term can be written `30` or `30 days`.
- All rows are saved together. You can import the same file again to update the data without creating duplicate suppliers.

## Paying a payable

1. Choose the supplier. The total payable and unpaid purchases appear, with overdue ones marked.
2. Enter the **Amount paid**, or tap **Pay in full**.
3. Choose where it is **Paid from**: store cash, cash drawer (needs an open cash session and today's date), or bank account.
4. Enter the **Transfer reference** and attach a proof photo if you have one.
5. Automatic allocation pays the nearest due date first. Tap **Allocate manually** to fill in each purchase yourself.
6. Tap **Save payment**.

You can also start a payment from the purchase detail with the **Pay payable** button.

## Voiding a supplier payment

1. In the supplier's payment history, tap the **Void payment** icon on that payment's row.
2. Enter the **Reason**, then tap **Yes, void**.
3. Each purchase's amount owed returns to what it was before the payment. The payment stays in the list struck through with a *Void* label and the reason.

A payment made from the cash drawer is put back into the drawer in the open cash session. After voiding, record the correct payment again.

> [!note] Due and overdue payables also appear on the *Receivables & payables* tab in [Reports](reports).
