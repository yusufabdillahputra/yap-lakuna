# Customers & receivables

The **Customers** menu keeps customer details, credit limits, and receivables per receipt, and records receivable payments with a printed receipt.

## Adding a customer

1. Open **Customers**, then tap **Customer**.
2. Enter the name, phone number, group, **Credit limit** (0 means no credit purchases), address, and note.
3. Tap **Save**.

To find a customer, type a name or phone number in the search field. The phone number can be in any format, for example `0812-3456`, `+62 812 3456`, or a part from the middle (at least 3 digits). The same rule applies when choosing a customer in Cashier, table bills, and *Credit*.

Many customers at once? Tap **Import Excel** and choose an .xlsx or .csv file with the columns Name, Phone, Address, Group, Limit, Note. No file yet? Tap **Download template** in the same dialog, fill in the rows under the headers, then import. The template is in English while the app language is English (in Indonesian otherwise), and the two sample rows ("Sample …") are skipped automatically.

## Customer groups

Manage groups in **Master data › Customer groups**. A group's standard term fills in the due date automatically for [credit sales](credit-sale). Customers without a group use a 14-day term.

## Receiving a receivable payment

1. Choose the customer, then under *Receive payment* enter the **Amount received** or tap **Pay in full**.
2. Choose the **Method**. Cash goes into the drawer when a cash session is open, otherwise it is recorded as store cash.
3. Automatic allocation pays the oldest receipt first. Tap **Allocate manually** to fill in each receipt yourself.
4. Tap **Save & print receipt**. The payment receipt comes as A5/PDF or a thermal slip. If a balance remains and a *Transfer account* is set, the receipt includes *Pay the balance to* (A5) or *Transfer to:* (thermal) with the store account.

## Voiding a receivable payment

Recorded the wrong amount, method, or customer? Void the payment, then record it again.

1. In the customer's payment history, tap the **Void payment** icon on that payment's row.
2. Enter the **Reason**, then tap **Yes, void**.
3. Each receipt's outstanding balance returns to what it was before the payment. The payment stays in the list struck through with a *Void* label and the reason, and its receipt is stamped VOID.

Cash that went into the drawer is taken out again in the open cash session, so open a session first. A payment recorded at another branch can only be voided there.

> [!note] Payment receipts can be reprinted from the customer's payment history, marked COPY. A customer who still owes money cannot be deleted.
